// ************************************************************************
// ***************************** CEF4Delphi *******************************
// ************************************************************************
//
// CEF4Delphi is based on DCEF3 which uses CEF3 to embed a chromium-based


unit uSimpleFMXBrowser;

{$I cef.inc}

interface

uses
  {$IFDEF MSWINDOWS}
  Winapi.Messages, Winapi.Windows,
  {$ENDIF}
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.StdCtrls,
  FMX.Edit, FMX.Controls.Presentation, uCEFFMXWindowParent, uCEFFMXChromium,
  uCEFInterfaces, uCEFConstants, uCEFTypes, FMX.Menus, System.Actions,
  FMX.ActnList;

const
  MINIBROWSER_CONTEXTMENU_SHOWDEVTOOLS    = MENU_ID_USER_FIRST + 1;

type
  TSimpleFMXBrowserFrm = class(TForm)
    AddressPnl: TPanel;
    AddressEdt: TEdit;
    GoBtn: TButton;
    brs: TFMXChromium;
    Timer1: TTimer;
    PopupMenu1: TPopupMenu;
    mainactions: TActionList;
    actscriptlogin: TAction;
    MenuItem1: TMenuItem;
    procedure GoBtnClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormCreate(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure brsClose(Sender: TObject;
      const browser: ICefBrowser; var aAction : TCefCloseBrowserAction);
    procedure brsBeforeClose(Sender: TObject;
      const browser: ICefBrowser);
    procedure brsBeforePopup(Sender: TObject;
      const browser: ICefBrowser; const frame: ICefFrame; const targetUrl,
      targetFrameName: ustring;
      targetDisposition: TCefWindowOpenDisposition; userGesture: Boolean;
      const popupFeatures: TCefPopupFeatures;
      var windowInfo: TCefWindowInfo; var client: ICefClient;
      var settings: TCefBrowserSettings;
      var extra_info: ICefDictionaryValue;
      var noJavascriptAccess, Result: Boolean);
    procedure FormResize(Sender: TObject);
    procedure brsAfterCreated(Sender: TObject;
      const browser: ICefBrowser);
    procedure brsBeforeContextMenu(Sender: TObject;
      const browser: ICefBrowser; const frame: ICefFrame;
      const params: ICefContextMenuParams; const model: ICefMenuModel);
    procedure brsContextMenuCommand(Sender: TObject;
      const browser: ICefBrowser; const frame: ICefFrame;
      const params: ICefContextMenuParams; commandId: Integer;
      eventFlags: Cardinal; out Result: Boolean);
    procedure actscriptloginExecute(Sender: TObject);

  protected

    FCanClose : boolean;
    FClosing  : boolean;

    FMXWindowParent : TFMXWindowParent;

    procedure LoadURL;
    procedure ResizeChild;
    procedure CreateFMXWindowParent;
    function  PostCustomMessage(aMessage : cardinal; wParam : cardinal = 0; lParam : integer = 0) : boolean;

  public
    procedure DoBrowserCreated;
    procedure DoDestroyParent;
    procedure NotifyMoveOrResizeStarted;
  end;

var
  SimpleFMXBrowserFrm: TSimpleFMXBrowserFrm;

implementation

{$R *.fmx}



uses
  FMX.Platform, FMX.Platform.Win,
  uCEFMiscFunctions, uCEFApplication, uFMXApplicationService;

procedure TSimpleFMXBrowserFrm.actscriptloginExecute(Sender: TObject);
var

  oscript: string;
  vsenha: string;
  vuser: string;
begin
   vuser := 'wilsonluz2019';
   vsenha := 'w2061614' ;

    oscript := 'var osenha = document.getElementsByName(''password'')[0];' +
    #13#10 + 'var nativeInputValueSetter = Object.getOwnPropertyDescriptor(window.HTMLInputElement.prototype, "value").set; '
    + #13#10 + 'nativeInputValueSetter.call(osenha,' +QuotedStr( vsenha) + ');' + #13#10 +
    'var evsenha = new Event(''input'', { bubbles: true});' + #13#10 +
    'osenha.dispatchEvent(evsenha);' + #13#10 +
    'var ouser = document.getElementsByName(''username'')[0];' + #13#10 +
    'var nativeInputValueSetter = Object.getOwnPropertyDescriptor(window.HTMLInputElement.prototype, "value").set; '
    + #13#10 + 'nativeInputValueSetter.call(ouser,' +QuotedStr( vuser) + ');' + #13#10 +
    'var evuser = new Event(''input'', { bubbles: true});' + #13#10 +
    'ouser.dispatchEvent(evuser);' + #13#10 +
    'var aTags = document.getElementsByTagName("button");  ' + #13#10 +
    'var searchText = "Log In";                         ' + #13#10 +
    'for (var i = 0; i < aTags.length; i++) {           ' + #13#10 +
    '  if (aTags[i].textContent == searchText) {        ' + #13#10 +
    '   var blogin = aTags[i];                          ' + #13#10 +
    '    break;                                         ' + #13#10 +
    '  }                                                ' + #13#10 +
    ' };                                                ' + #13#10 +
    ' blogin.click();                                   ';
   brs.ExecuteJavaScript(oscript,brs.Browser.FocusedFrame.Url  );
end;

procedure TSimpleFMXBrowserFrm.brsAfterCreated(Sender: TObject;
  const browser: ICefBrowser);
begin

  PostCustomMessage(CEF_AFTERCREATED);
end;

procedure TSimpleFMXBrowserFrm.brsBeforeClose(Sender: TObject; const browser: ICefBrowser);
begin
  FCanClose := True;
  PostCustomMessage(WM_CLOSE);
end;

procedure TSimpleFMXBrowserFrm.brsBeforeContextMenu(
  Sender: TObject; const browser: ICefBrowser; const frame: ICefFrame;
  const params: ICefContextMenuParams; const model: ICefMenuModel);
begin
  model.AddItem(MINIBROWSER_CONTEXTMENU_SHOWDEVTOOLS, 'Mostrar Dev Tools');
end;

procedure TSimpleFMXBrowserFrm.brsBeforePopup(      Sender             : TObject;
                                                       const browser            : ICefBrowser;
                                                       const frame              : ICefFrame;
                                                       const targetUrl          : ustring;
                                                       const targetFrameName    : ustring;
                                                             targetDisposition  : TCefWindowOpenDisposition;
                                                             userGesture        : Boolean;
                                                       const popupFeatures      : TCefPopupFeatures;
                                                       var   windowInfo         : TCefWindowInfo;
                                                       var   client             : ICefClient;
                                                       var   settings           : TCefBrowserSettings;
                                                       var   extra_info         : ICefDictionaryValue;
                                                       var   noJavascriptAccess : boolean;
                                                       var   Result             : boolean);
begin

  Result := (targetDisposition in [WOD_NEW_FOREGROUND_TAB, WOD_NEW_BACKGROUND_TAB, WOD_NEW_POPUP, WOD_NEW_WINDOW]);
end;

procedure TSimpleFMXBrowserFrm.brsClose(Sender: TObject; const browser: ICefBrowser; var aAction : TCefCloseBrowserAction);
begin
  PostCustomMessage(CEF_DESTROY);
  aAction := cbaDelay;
end;

procedure TSimpleFMXBrowserFrm.brsContextMenuCommand(
  Sender: TObject; const browser: ICefBrowser; const frame: ICefFrame;
  const params: ICefContextMenuParams; commandId: Integer;
  eventFlags: Cardinal; out Result: Boolean);
var
  TempPoint : TPoint;
begin
  if (commandId = MINIBROWSER_CONTEXTMENU_SHOWDEVTOOLS) then
    begin
      TempPoint.x := params.XCoord;
      TempPoint.y := params.YCoord;

      brs.ShowDevTools(TempPoint);
    end;
end;

function TSimpleFMXBrowserFrm.PostCustomMessage(aMessage, wParam : cardinal; lParam : integer) : boolean;
{$IFDEF MSWINDOWS}
var
  TempHWND : HWND;
{$ENDIF}
begin
  {$IFDEF MSWINDOWS}
  TempHWND := FmxHandleToHWND(Handle);
  Result   := (TempHWND <> 0) and WinApi.Windows.PostMessage(TempHWND, aMessage, wParam, lParam);
  {$ELSE}
  Result   := False;
  {$ENDIF}
end;

procedure TSimpleFMXBrowserFrm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose := FCanClose;

  if not(FClosing) then
    begin
      FClosing := True;
      Visible  := False;
      brs.CloseBrowser(True);
    end;
end;

procedure TSimpleFMXBrowserFrm.FormCreate(Sender: TObject);
begin

  TFMXApplicationService.AddPlatformService;

  FCanClose       := False;
  FClosing        := False;
  FMXWindowParent := nil;
end;

procedure TSimpleFMXBrowserFrm.FormResize(Sender: TObject);
begin

  ResizeChild;
end;

procedure TSimpleFMXBrowserFrm.ResizeChild;
begin
  if (FMXWindowParent <> nil) then
    FMXWindowParent.SetBounds(0, round(AddressPnl.Height), ClientWidth - 1, ClientHeight -  1);
end;

procedure TSimpleFMXBrowserFrm.CreateFMXWindowParent;
begin
  if (FMXWindowParent = nil) then
    begin
      FMXWindowParent := TFMXWindowParent.CreateNew(nil);
      FMXWindowParent.Reparent(Handle);
      ResizeChild;
      FMXWindowParent.Show;
    end;
end;

procedure TSimpleFMXBrowserFrm.FormShow(Sender: TObject);
var
  TempHandle : HWND;
  TempRect   : System.Types.TRect;
  TempClientRect : TRectF;
begin

  CreateFMXWindowParent;


  if not(brs.Initialized) then
    begin
      TempHandle      := FmxHandleToHWND(FMXWindowParent.Handle);
      TempClientRect  := FMXWindowParent.ClientRect;
      TempRect.Left   := round(TempClientRect.Left);
      TempRect.Top    := round(TempClientRect.Top);
      TempRect.Right  := round(TempClientRect.Right);
      TempRect.Bottom := round(TempClientRect.Bottom);

      brs.DefaultUrl := AddressEdt.Text;
      if not(brs.CreateBrowser(TempHandle, TempRect)) then Timer1.Enabled := True;
    end;
end;

procedure TSimpleFMXBrowserFrm.GoBtnClick(Sender: TObject);
begin
  LoadURL;
end;

procedure TSimpleFMXBrowserFrm.NotifyMoveOrResizeStarted;
begin
  if (brs <> nil) then brs.NotifyMoveOrResizeStarted;
end;

procedure TSimpleFMXBrowserFrm.Timer1Timer(Sender: TObject);
var
  TempHandle : HWND;
  TempRect   : System.Types.TRect;
  TempClientRect : TRectF;
begin
  Timer1.Enabled  := False;
  TempHandle      := FmxHandleToHWND(FMXWindowParent.Handle);
  TempClientRect  := FMXWindowParent.ClientRect;
  TempRect.Left   := round(TempClientRect.Left);
  TempRect.Top    := round(TempClientRect.Top);
  TempRect.Right  := round(TempClientRect.Right);
  TempRect.Bottom := round(TempClientRect.Bottom);

  if not(brs.CreateBrowser(TempHandle, TempRect)) and not(brs.Initialized) then
    Timer1.Enabled := True;
end;

procedure TSimpleFMXBrowserFrm.DoBrowserCreated;
begin

  Caption            := 'Pelicam browser';
  AddressPnl.Enabled := True;
end;

procedure TSimpleFMXBrowserFrm.DoDestroyParent;
begin
  if (FMXWindowParent <> nil) then FreeAndNil(FMXWindowParent);
end;

procedure TSimpleFMXBrowserFrm.LoadURL;
begin
  brs.LoadURL(AddressEdt.Text);

  brs.ExecuteJavaScript(
  'jQuery(function($) {             '+#13#10+
  '  alert("pagina pronta" );'    +#13#10+
  '});' ,brs.Browser.FocusedFrame.Url);

end;

end.

unit main;

interface

uses
  System.SysUtils,
  System.Types,
  System.UITypes,
  System.Classes,
  System.Variants,
  FMX.Types,
  FMX.Controls,
  FMX.Forms,
  FMX.Graphics,
  FMX.Dialogs,
  FMX.StdCtrls,
  System.JSON,
  pel.android.navegador,
  FMX.DialogService,
  FMX.Controls.Presentation,
  FMX.Edit,
  FMX.WebBrowser,
  FMX.Calendar,
  FMX.TabControl,
  FMX.ScrollBox,
  System.IOUtils,
  FMX.Memo,
  FMX.Objects,
  SG.ScriptGate,
  // -----------------ANDROID

  Androidapi.JNI.Webkit,
  Androidapi.JNI.App,
  Androidapi.JNI.Embarcadero,
  Androidapi.JNI.GraphicsContentViewText,
  Androidapi.JNI.JavaTypes,
  Androidapi.JNIBridge,
  Androidapi.JNI.Os,
  Androidapi.JNI.Net,
  Androidapi.Helpers,
  Androidapi.JNI.Widget,
  pel.datamodule,

  FMX.Helpers.android,

  FMX.Surfaces,
  FMX.ZOrder.android,

  FMX.Platform,

  FMX.Platform.android,
  System.ImageList,
  FMX.ImgList,
  FMX.ListView.Types,
  FMX.ListView.Appearances,
  FMX.ListView.Adapters.Base,
  Data.Bind.Components,
  Data.Bind.DBScope,
  FMX.ListView, System.Rtti,
  System.Bindings.Outputs,
  FMX.Bind.Editors,
  Data.Bind.EngExt,
  FMX.DialogService.Async,
  FMX.Bind.DBEngExt, FMX.Layouts

    ;

type
  Tfmain = class(TForm)
    tabmaster: TTabControl;
    TabItem1: TTabItem;
    brs: TWebBrowser;
    tabconfig1: TTabItem;
    toolbarmain: TToolBar;
    pnloperacao: TCalloutPanel;
    tablog: TTabItem;
    pnllogs: TCalloutPanel;
    memolog: TMemo;
    lblog: TLabel;
    ImageList1: TImageList;
    btnavigate: TSpeedButton;
    btstop: TSpeedButton;
    AniIndicator1: TAniIndicator;
    StyleBook1: TStyleBook;
    Image1: TImage;
    Panel1: TPanel;
    scbconfig: TScrollBox;
    pnhastags: TPanel;
    ToolBar1: TToolBar;
    btaddtag: TButton;
    btremovertag: TButton;
    Label1: TLabel;
    lsthastags: TListView;
    pdadosgerais: TPanel;
    ToolBar2: TToolBar;
    btrefresgdados: TButton;
    btsalvardadosgerais: TButton;
    Label2: TLabel;
    Label3: TLabel;
    edtuserconta: TEdit;
    Label4: TLabel;
    edtsenhaconta: TEdit;
    Label5: TLabel;
    edtsenhainsta: TEdit;
    edtcontainsta: TEdit;
    Label6: TLabel;
    edtemail: TEdit;
    Label7: TLabel;
    pncomentarios: TPanel;
    ToolBar3: TToolBar;
    btaddcoments: TButton;
    btdeletecoment: TButton;
    Label8: TLabel;
    lstcomentarios: TListView;
    ToolBar4: TToolBar;
    BindSourceDB1: TBindSourceDB;
    BindingsList1: TBindingsList;
    LinkFillControlToField1: TLinkFillControlToField;
    BindSourceDB2: TBindSourceDB;
    LinkFillControlToField2: TLinkFillControlToField;
    BindSourceDB3: TBindSourceDB;
    LinkControlToField1: TLinkControlToField;
    LinkControlToField2: TLinkControlToField;
    LinkControlToField3: TLinkControlToField;
    LinkControlToField4: TLinkControlToField;
    LinkControlToField5: TLinkControlToField;
    procedure btnavigateClick(Sender: TObject);
    procedure btstopClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Image1Click(Sender: TObject);
    procedure lsthastagsItemClick(const Sender: TObject;
      const AItem: TListViewItem);

    procedure btaddtagClick(Sender: TObject);
    procedure btremovertagClick(Sender: TObject);
    procedure lsthastagsClick(Sender: TObject);
    procedure btaddcomentsClick(Sender: TObject);

  private
    { Private declarations }
    Fnavegador: TinstaNavegador;

    procedure OnInputQuery_Close(const AResult: TModalResult;
      const AValues: array of string);

    procedure Logop(value: string);
    procedure LogOut;
    function getcooki(value: string): string;

  public
    { Public declarations }
  end;

var
  fmain: Tfmain;

implementation

uses
  pell.view.modalcoments;
{$R *.fmx}
{$R *.NmXhdpiPh.fmx ANDROID}
{$R *.iPhone4in.fmx IOS}

procedure Tfmain.btremovertagClick(Sender: TObject);

var
  TaskName: String;
begin
  TaskName := TListViewItem(lsthastags.Selected).Text;

  try
    dm_local.deleteHashTag(TaskName);
    btremovertag.Visible := lsthastags.Selected <> nil;

  except
    on e: Exception do
    begin
      ShowMessage(e.Message);
    end;
  end;
end;

{ ------------------------------------------------------------------------------ }
procedure Tfmain.btstopClick(Sender: TObject);
begin
  Fnavegador.stopall;
  AniIndicator1.Enabled := false;
end;

procedure Tfmain.btaddcomentsClick(Sender: TObject);
begin
  try
    fModalComments := TfModalComments.Create(Nil);
    if fModalComments.ShowModal = mrOk then
    begin
      if fModalComments.memocoments.Text <> '' then
      begin

        dm_local.insertComents(fModalComments.memocoments.Text);
        dm_local.qry_coments.Close;
        dm_local.qry_coments.Open;
      end;
    end;
  finally

    FreeAndNil(fModalComments);
  end;
end;

procedure Tfmain.btaddtagClick(Sender: TObject);

var
  TaskName: string;
begin
  TDialogServiceAsync.InputQuery('Indique a hash tag', ['Hash tag'], [''],
    Self.OnInputQuery_Close);

end;

procedure Tfmain.btnavigateClick(Sender: TObject);
var
  i: Integer;

begin;
  Fnavegador.HashsTags.Clear;
  for i := 0 to lsthastags.ItemCount - 1 do
  begin
    Fnavegador.HashsTags.add(TListViewItem(i).Text);
  end;
  Fnavegador.Comentarios.add('Linda foto');
  Fnavegador.Comentarios.add('Legal,que vc tenha um lindo dia');
  Fnavegador.Comentarios.add('show...');
  Fnavegador.Comentarios.add('caminhando chegaremos');
  Fnavegador.Comentarios.add
    ('nada esta perdido ... ate que tudo esteja perdido...');
  AniIndicator1.Enabled := true;
  Fnavegador.startSpan();

end;

procedure Tfmain.FormCreate(Sender: TObject);

begin
  try
    Fnavegador := TinstaNavegador.Create(brs, memolog);
    if not Assigned(dm_local) then
      dm_local := Tdm_local.Create(Application);
    dm_local.qry_hashtags.Open();
    Fnavegador.User := 'wilsonluz2019';
    Fnavegador.Password := 'w2061614';
  except
    on e: Exception do
      ShowMessage(e.Message);

  end;
end;

procedure Tfmain.lsthastagsClick(Sender: TObject);
begin
  btremovertag.Visible :=lsthastags.Selected <> nil;
end;

procedure Tfmain.lsthastagsItemClick(const Sender: TObject;
  const AItem: TListViewItem);
begin
  btremovertag.Visible := lsthastags.Selected <> nil;
end;

procedure Tfmain.Logop(value: string);
begin
  memolog.Lines.add(value);
end;

function Tfmain.getcooki(value: string): string;
var
  CookieSyncManager: JCookieSyncManager;
  CookieManager: JCookieManager;
  s: string;
begin

  CookieSyncManager := TJCookieSyncManager.JavaClass.createInstance
    (TAndroidHelper.Context);

  CookieManager := TJCookieManager.JavaClass.getInstance;

  result := JStringToString(CookieManager.getCookie(StringToJString(value)));
  s := result;

end;

procedure Tfmain.Image1Click(Sender: TObject);
begin

end;

{ ------------------------------------------------------------------------------ }

procedure Tfmain.LogOut;
var
  CookieSyncManager: JCookieSyncManager;
  CookieManager: JCookieManager;
begin
  CookieSyncManager := TJCookieSyncManager.JavaClass.createInstance
    (TAndroidHelper.Context);
  CookieManager := TJCookieManager.JavaClass.getInstance;
  CookieManager.removeAllCookie

end;

procedure Tfmain.OnInputQuery_Close(const AResult: TModalResult;
  const AValues: array of string);
var
  TaskName: String;
begin
  TaskName := string.Empty;
  if AResult <> mrOk then
    Exit;
  TaskName := AValues[0];
  try
    if (TaskName.Trim <> '') then
    begin
      dm_local.insertHashTag(TaskName);
      btremovertag.Visible := lsthastags.Selected <> nil;
      dm_local.qry_hashtags.Close;
      dm_local.qry_hashtags.Open();
    end;
  except
    on e: Exception do
    begin
      ShowMessage(e.Message);
    end;
  end;

end;

end.

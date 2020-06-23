unit nagram.view.main;

interface

uses
  System.SysUtils,
  FMX.Types,
  System.Types,
  FMX.ListView.Types,
  nagram.view.releasenotes,
  nagram.android.util,

  FMX.ListView.Appearances,
  FMX.ListView.Adapters.Base,
  Data.Bind.EngExt,
  FMX.Bind.DBEngExt,
  System.Rtti,
  System.Bindings.Outputs,
  FMX.Bind.Editors,
  System.ImageList,
  FMX.ImgList,
  Data.Bind.Components,
  Data.Bind.DBScope,
  FMX.Controls,
  FMX.ScrollBox,
  FMX.Memo,
  FMX.StdCtrls,
  FMX.ListView,
  FMX.Edit,
  FMX.Layouts,
  FMX.Objects,
  FMX.TabControl,
  System.Classes,
  FMX.Controls.Presentation,
  System.UITypes,
  System.JSON,
  nagram.service.navegador,
  FMX.DialogService,
  FMX.WebBrowser,
  FMX.Calendar,
  System.IOUtils,
  nagram.control.person,
  nagram.service.deviceinfo,

  SG.ScriptGate,

{$IF DEFINED(ANDROID)}
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
  FMX.Helpers.android,
  FMX.ZOrder.android,
  nagram.service.geolocation,
  FMX.Platform.android,

  FMX.FontGlyphs.android,
{$ENDIF}
{$IF DEFINED(MSWINDOWS)}
{$ENDIF}
  nagram.datamodule,
  FMX.Surfaces,
  FMX.Platform,
  FMX.DialogService.Async,
  nagram.control.localoption,
  nagram.dao.action,
  FMX.Forms,
  FMX.Effects,
  FMX.Dialogs,

  FMX.Ani,
  FMX.ListBox,
  System.Actions,
  FMX.ActnList, FMX.MultiView, FMX.Menus, System.Sensors,
  System.Sensors.Components, FMX.Graphics

    ;

type
  Tfmain = class(TForm)
    toolbarmain: TToolBar;
    AniIndicator1: TAniIndicator;
    Image1: TImage;
    ImageList1: TImageList;
    TmLabel: TTimer;
    actmain: TActionList;
    ChangeTabAction1: TChangeTabAction;
    ChangeTabAction2: TChangeTabAction;
    ChangeTabAction3: TChangeTabAction;
    ChangeTabAction4: TChangeTabAction;
    ChangeTabAction5: TChangeTabAction;
    ImageList2: TImageList;
    tm_iniciar: TTimer;
    lblcords: TLabel;
    tm_cords: TTimer;
    tabmaster: TTabControl;
    taboperacao: TTabItem;
    pnloperacao: TToolBar;
    Rectangle5: TRectangle;
    btnavigate: TSpeedButton;
    lblinteracao: TLabel;
    btstop: TSpeedButton;
    tabconfig: TTabItem;
    tabcontrolconfig: TTabControl;
    tabconfigmain: TTabItem;
    toomainconfig: TToolBar;
    SettingsMain: TLabel;
    lstdadosgerais: TListBox;
    AccountInfo: TListBoxGroupHeader;
    linomeconta: TListBoxItem;
    SyncSettings: TListBoxGroupHeader;
    lienviarcomentario: TListBoxItem;
    swcomentario: TSwitch;
    Label7: TLabel;
    SyncWifi: TListBoxItem;
    swcurtirpostagem: TSwitch;
    Label8: TLabel;
    lidiasseguir: TListBoxItem;
    edtdaysunfolow: TEdit;
    Label10: TLabel;
    lidelaynavegacao: TListBoxItem;
    edtdelaynavigation: TEdit;
    Label11: TLabel;
    lidelayoperacao: TListBoxItem;
    edtdelayexecution: TEdit;
    Label12: TLabel;
    lideephashtag: TListBoxItem;
    edtpesquisashashtag: TEdit;
    Label13: TLabel;
    ligcadastros: TListBoxGroupHeader;
    ListBoxItem2: TListBoxItem;
    Label14: TLabel;
    licomentarios: TListBoxItem;
    Label16: TLabel;
    tabrashtags: TTabItem;
    toolhashtags: TToolBar;
    lbltophastags: TLabel;
    bthashtagback: TSpeedButton;
    btremovertag: TSpeedButton;
    btaddtag: TSpeedButton;
    lsthastags: TListView;
    tabcomentarios: TTabItem;
    tabcontrolcomentarios: TTabControl;
    tabsubcomentariosview: TTabItem;
    toolcomentarios: TToolBar;
    Label1: TLabel;
    btcomentgoback: TSpeedButton;
    btdeletecoment: TSpeedButton;
    btaddcoments: TSpeedButton;
    lstcomentarios: TListView;
    tabsubcomentariosedit: TTabItem;
    tooltopsubcomentariosedit: TToolBar;
    btbackeditcomentario: TSpeedButton;
    lbtopcoments: TLabel;
    btsalvarcomentario: TSpeedButton;
    memoeditcoments: TMemo;
    tablog: TTabItem;
    pnllogs: TToolBar;
    memolog: TMemo;
    tabatividades: TTabItem;
    tooativaidades: TToolBar;
    lblactions: TLabel;
    btrefreshactions: TSpeedButton;
    lstactions: TListView;
    tabusuarios: TTabItem;
    ToolBar4: TToolBar;
    lblusercount: TLabel;
    btupdateusers: TSpeedButton;
    lstuers: TListView;
    Popup1: TPopup;
    btrefreshtags: TSpeedButton;
    btatualizarcomentarios: TSpeedButton;
    btoptions: TSpeedButton;
    pnexec: TRectangle;
    ColorAnimation1: TColorAnimation;
    ccopanel: TColorAnimation;
    FloatAnimation1: TFloatAnimation;
    Label2: TLabel;
    Lang1: TLang;
    mainthema: TStyleBook;
    layoutmaster: TLayout;
    recBody: TRectangle;
    rectarquee: TRectangle;
    lbinfouser: TLabel;
    bt_updatecomment: TSpeedButton;
    flapnexec: TFloatAnimation;
    ColorAnimation2: TColorAnimation;
    flatoooperacao: TFloatAnimation;
    ListBoxItem4: TListBoxItem;
    Label3: TLabel;
    edtmaxinthour: TEdit;
    lblversion: TLabel;
    lbexec: TLabel;
    MultiView1: TMultiView;
    OverflowMenu: TListBox;
    ListBoxItem3: TListBoxItem;
    Image2: TImage;
    lilogout: TListBoxItem;
    liespace: TListBoxItem;
    ListBoxItem1: TListBoxItem;
    sweoverflowmenu: TShadowEffect;
    efcoverflowmenu: TFloatAnimation;
    Label4: TLabel;
    aninbrowser: TAniIndicator;
    procedure btnavigateClick(Sender: TObject);
    procedure btstopClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure lsthastagsItemClick(const Sender: TObject;
      const AItem: TListViewItem);

    procedure btaddtagClick(Sender: TObject);
    procedure btremovertagClick(Sender: TObject);
    procedure lsthastagsClick(Sender: TObject);
    procedure btaddcomentsClick(Sender: TObject);
    procedure btsalvardadosgeraisClick(Sender: TObject);
    procedure btdeletecomentClick(Sender: TObject);
    procedure lsthastagsDeletingItem(Sender: TObject; AIndex: Integer;
      var ACanDelete: Boolean);
    procedure lstactionsItemClick(const Sender: TObject;
      const AItem: TListViewItem);
    procedure btasalvaroptionsClick(Sender: TObject);
    procedure btremoveractionsClick(Sender: TObject);
    procedure btaba1Click(Sender: TObject);
    procedure lstuersItemClick(const Sender: TObject;
      const AItem: TListViewItem);
    procedure btupdateusersClick(Sender: TObject);
    procedure btremoveruserClick(Sender: TObject);
    procedure lstuersDeleteItem(Sender: TObject; AIndex: Integer);
    procedure TmLabelTimer(Sender: TObject);
    procedure lstcomentariosClick(Sender: TObject);
    procedure ListBoxItem2Click(Sender: TObject);
    procedure licomentariosClick(Sender: TObject);
    procedure swcomentarioClick(Sender: TObject);
    procedure swcurtirpostagemClick(Sender: TObject);

    procedure edtusercontaEnter(Sender: TObject);
    procedure btbackeditcomentarioClick(Sender: TObject);
    procedure lstcomentariosItemClick(const Sender: TObject;
      const AItem: TListViewItem);
    procedure btsalvarcomentarioClick(Sender: TObject);
    procedure tm_iniciarTimer(Sender: TObject);
    procedure setBrowserControl();
    procedure linomecontaClick(Sender: TObject);
    procedure tm_cordsTimer(Sender: TObject);
    procedure ListBoxItemLatitudeClick(Sender: TObject);
    procedure btrefreshtagsClick(Sender: TObject);
    procedure btatualizarcomentariosClick(Sender: TObject);
    procedure btrefreshactionsClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var action: TCloseAction);
    procedure lilogoutClick(Sender: TObject);
    procedure liupdateallClick(Sender: TObject);
    procedure liupdatedataClick(Sender: TObject);
    procedure lstcomentariosItemClickEx(const Sender: TObject;
      ItemIndex: Integer; const LocalClickPos: TPointF;
      const ItemObject: TListItemDrawable);
    procedure btoptionsMouseEnter(Sender: TObject);
    procedure ListBoxItem1Click(Sender: TObject);
    procedure bt_updatecommentClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure tabconfigClick(Sender: TObject);
    procedure liespaceClick(Sender: TObject);
    procedure MultiView1StartShowing(Sender: TObject);
    procedure MultiView1StartHiding(Sender: TObject);
    procedure lblversionClick(Sender: TObject);

  private
    { Private declarations }

    FcommentId: Integer;
    FHashTagId: Integer;
{$IF DEFINED(MSWINDOWS_)}
    brs: TFMXChromium;
{$ELSE}
    brs: TWebBrowser;
{$ENDIF}
    Fnavegador: TinstaNavegador;
    procedure afterUpdateLocation(Sender: TObject);
    procedure OnInputQuery_Close(const AResult: TModalResult;
      const AValues: array of string);

    procedure Logop(value: string);
    procedure LogOut;
    procedure prepareview;
    function getcooki(value: string): string;
    procedure OnGeocodeReverseEvent(const Address: TCivicAddress);
  public
    { Public declarations }
    property CommentId: Integer read FcommentId write FcommentId;
  end;

var
  fmain: Tfmain;
  fbol: Boolean;

implementation

uses
  nagram.resource.master,
  nagram.view.sendfeedback,
  nagram.dao.comment,
  nagram.control.main,
  nagram.model.comment,
  nagram.model.action,
  nagram.control.action,
  nagram.model.user,
  nagram.view.action,
  nagram.control.user,
  nagram.view.user,
  nagram.view.person,
  nagram.view.login;
{$R *.fmx}

procedure Tfmain.OnGeocodeReverseEvent(const Address: TCivicAddress);
begin
  GlobalPerson.TmpAdress := 'Estado:' + Address.AdminArea + #13#10 + 'Pais:' +
    Address.CountryCode + #13#10 + 'Pais:' + Address.CountryName + #13#10 +
    'Numero:' + Address.FeatureName + #13#10 + Address.Locality + #13#10 +
    'Cep:' + Address.PostalCode + #13#10 + 'Estado:' + Address.SubAdminArea +
    #13#10 + 'Bairro' + Address.SubLocality + #13#10 + 'Numero ' +
    Address.SubThoroughfare + #13#10 + 'Complemento' + Address.Thoroughfare;
end;

{ ---------------------------------------------------------------------------- }
procedure Tfmain.btrefreshactionsClick(Sender: TObject);
begin
  FmainController.sincronizeactions;
  FmainController.setViewAction(Sender);
end;

{ ---------------------------------------------------------------------------- }
procedure Tfmain.btrefreshtagsClick(Sender: TObject);
begin
  FmainController.sincronizehashtags;
  FmainController.setViewHashTag(Sender);
end;

{ --------------------------------------------------------------------------- }
procedure Tfmain.btremoveractionsClick(Sender: TObject);
begin
  { TDialogService.PreferredMode := TDialogService.TPreferredMode.Platform;
    TDialogService.MessageDialog('Confirma a exclusao de todos os registros ?',
    TMsgDlgType.mtConfirmation, FMX.Dialogs.mbYesNo, TMsgDlgBtn.mbNo, 0,
    procedure(const AResult: TModalResult)
    begin
    case AResult of
    mrYes:
    // dm_local.deleteAllActions;

    end;
    end); }

end;

{ --------------------------------------------------------------------------- }
procedure Tfmain.btremovertagClick(Sender: TObject);
var
  TaskName: String;
begin
  if assigned(TListViewItem(lsthastags.Selected)) then
  begin

    TaskName := TListViewItem(lsthastags.Selected).Text;
    try
      btremovertag.Visible := false;
      FmainController.deleteHashTag(TListViewItem(lsthastags.Selected).Tag);
      btremovertag.Visible := lsthastags.Selected <> nil;
      FmainController.setViewHashTag(Sender);
      ShowMessage('Hash tag excluida');
    except
      on e: exception do
      begin
        tutil.gravalog('[TVIEWMAIN 382]' + e.Message);
        ShowMessage('Erro ao exclur hashtag ');

      end;
    end;
  end;
end;

{ --------------------------------------------------------------------------- }
procedure Tfmain.btremoveruserClick(Sender: TObject);
begin

end;

{ ------------------------------------------------------------------------------ }
procedure Tfmain.btsalvarcomentarioClick(Sender: TObject);
begin
  if True then

    FmainController.saveComent();
  btbackeditcomentarioClick(Sender);
  FmainController.setViewComment(nil);

end;

procedure Tfmain.btsalvardadosgeraisClick(Sender: TObject);
begin
end;

{ ------------------------------------------------------------------------------ }
procedure Tfmain.btstopClick(Sender: TObject);
begin
  Fnavegador.stopall;
  brs.Visible := false;
  AniIndicator1.Enabled := false;
  AniIndicator1.Visible := false;
  btnavigate.Enabled := True;
  btstop.Enabled := false;
  lblinteracao.Text := 'Processo interompido.';
  TmLabel.Enabled := false;
  btnavigate.ImageIndex := 12;
  btstop.ImageIndex := 6;
  lblinteracao.Visible := True;
  aninbrowser.Visible := false;
  aninbrowser.Enabled := false;
end;
{ ------------------------------------------------------------------------------ }

procedure Tfmain.edtusercontaEnter(Sender: TObject);
var
  s: string;
begin
  try
    s := TEdit(Sender).Parent.ClassName;
    s := '';
  except

  end;
  if assigned(TEdit(Sender).Parent) and
    (TEdit(Sender).Parent.ClassName = 'TListBoxItem') then
    TListBoxItem(TEdit(Sender).Parent).TextSettings.Font.Size := 5;
end;

{ ------------------------------------------------------------------------------ }
procedure Tfmain.afterUpdateLocation(Sender: TObject);
begin
  lblcords.Text := 'atualizado...'

end;

procedure Tfmain.btaba1Click(Sender: TObject);
begin
  tabmaster.ActiveTab := taboperacao;
end;

procedure Tfmain.btaddcomentsClick(Sender: TObject);
begin
  ChangeTabAction5.ExecuteTarget(Sender);
  memoeditcoments.Lines.clear;
  FcommentId := 0;
  lbtopcoments.Text := 'Inserindo comentario';
  btsalvarcomentario.Visible := True;
  memoeditcoments.ReadOnly := false;

end;

{ ------------------------------------------------------------------------------ }
procedure Tfmain.btaddtagClick(Sender: TObject);

begin
  TDialogServiceAsync.InputQuery('Indique a hash tag', [''], [''],
    Self.OnInputQuery_Close);

end;

{ ------------------------------------------------------------------------------ }
procedure Tfmain.btasalvaroptionsClick(Sender: TObject);
begin
  FmainController.persistLocalOptions();
  FmainController.setViewLocalOptions();
  ShowMessage('Dados atualizados');
end;

procedure Tfmain.btatualizarcomentariosClick(Sender: TObject);
begin
  btdeletecomentClick(Sender);

end;

{ ------------------------------------------------------------------------------ }
procedure Tfmain.btdeletecomentClick(Sender: TObject);
var
  Fid: Integer;
begin
  if assigned(TListViewItem(lstcomentarios.Selected)) then
  begin

    Fid := TListViewItem(lstcomentarios.Selected).Tag;
    try
      FmainController.deleteComment(Fid);
      FmainController.setViewComment(Sender);
      btdeletecoment.Visible := false;
      ShowMessage('Comentario excluido.');
      FcommentId := -1;
    except
      on e: exception do
        tutil.gravalog('[TVIEWMAIN 504]' + e.Message);

    end;
  end
  else
    ShowMessage('Nehum comentario selecionado.');
end;

{ ------------------------------------------------------------------------------ }
procedure Tfmain.btnavigateClick(Sender: TObject);
var
  i: Integer;
  olocaloption: TLocalOptionController;
begin
  try
    AniIndicator1.Visible := True;
    AniIndicator1.Enabled := True;
    aninbrowser.Visible := True;
    aninbrowser.Enabled := True;
    aninbrowser.BringToFront;
    LogOut;
    i := TActionDao.getCountLikeHour;
    Fnavegador.HashsTags.clear;
    if lsthastags.ItemCount = 0 then
    begin
      tabmaster.ActiveTab := tabconfig;
      tabcontrolconfig.ActiveTab := tabrashtags;
      raise exception.Create
        ('Nehuma hashtag  foi definida,adicione uma ou mais hashtags ');

    end;
    if lstcomentarios.ItemCount = 0 then
    begin
      tabmaster.ActiveTab := tabconfig;
      tabcontrolconfig.ActiveTab := tabcomentarios;
      raise exception.Create
        ('Nehum comentario foi definido,adicione um ou mais comentario');
    end;
    if GlobalPerson.person.person_insta_user = '' then
    begin
      if not assigned(FviewPerson) then
        FviewPerson := TFviewPerson.Create(Nil);
      FviewPerson.tpOperacao := 0;
      FviewPerson.Show;
      try
        FviewPerson.edtcontainsta.SetFocus;
      except
      end;
      raise exception.Create(' O usuário instagram não foi definido ');
    end;
    if GlobalPerson.person.person_insta_password = '' then
    begin
      if not assigned(FviewPerson) then
        FviewPerson := TFviewPerson.Create(Nil);
      FviewPerson.tpOperacao := 0;
      FviewPerson.Show;
      try
        FviewPerson.edtsenhainsta.SetFocus;
      except
      end;
      raise exception.Create('A senha para a conta instagram não informada ');
    end;

    olocaloption := TLocalOptionController.Create;
    if olocaloption.localoption.Maxinthour < 1 then
    begin
      tabmaster.ActiveTab := tabconfig;
      tabcontrolconfig.ActiveTab := tabconfigmain;
      try
        edtmaxinthour.SetFocus;
      except
      end;
      raise exception.Create('Maximo de interações menor que 1');
    end;

    if i >= olocaloption.localoption.Maxinthour then
    begin
      tabmaster.ActiveTab := tabconfig;
      tabcontrolconfig.ActiveTab := tabconfigmain;
      try
        edtmaxinthour.SetFocus;
      except
      end;
      raise exception.Create('Maximo de interações na ultima hora atingido');
    end;

    for i := 0 to lsthastags.ItemCount - 1 do
    begin
      Fnavegador.HashsTags.add(TListViewItem(lsthastags.Items[i]).Text);
    end;
    for i := 0 to lstcomentarios.ItemCount - 1 do
    begin
      Fnavegador.Comentarios.add(TListViewItem(lstcomentarios.Items[i]).Text);
    end;
    AniIndicator1.Enabled := True;
    brs.Visible := True;
    brs.Enabled:=false;
    Fnavegador.user := GlobalPerson.person.person_insta_user;
    FmainController.sincronizeusers;
    Fnavegador.Password := GlobalPerson.person.person_insta_password;
    Fnavegador.startSpan();
    btstop.Enabled := True;
    btnavigate.Enabled := false;
    btnavigate.ImageIndex := 7;
    btstop.ImageIndex := 13;
    lblinteracao.Text := 'não toque no navegador.';
    TmLabel.Enabled := True;
  except
    on e: exception do
    begin
      ShowMessage('Lamento não pude iniciar  ' + e.Message);
      AniIndicator1.Enabled := false;
      AniIndicator1.Visible := false;
      btstop.Enabled := false;
      btnavigate.Enabled := True;
      aninbrowser.Visible := false;
      aninbrowser.Enabled := false;
      brs.Visible := false;
      lblinteracao.Text := 'Inativo';
    end;
  end;
end;

procedure Tfmain.btoptionsMouseEnter(Sender: TObject);
begin

end;

{ ------------------------------------------------------------------------------ }
procedure Tfmain.FormClose(Sender: TObject; var action: TCloseAction);
begin
  fmain := nil;
end;

procedure Tfmain.FormCreate(Sender: TObject);
begin
  try
    tm_iniciar.Enabled := True;
    FmainController.FormView := Self;

    tabmaster.ActiveTab := taboperacao;
    tabcontrolcomentarios.ActiveTab := tabsubcomentariosview;
    btremovertag.Visible := false;
    btdeletecoment.Visible := false;
    MultiView1.Mode := TMultiViewMode(3);
    setBrowserControl();
    aninbrowser.Visible := false;
    aninbrowser.Enabled := false;
    aninbrowser.BringToFront;
    AniIndicator1.Visible := false;
    AniIndicator1.Enabled := false;
    pnexec.Visible := false;

  except
    on e: exception do
    begin
      tutil.gravalog('[TVIEWMAIN 548]' + e.Message);
    end;
  end;
end;

procedure Tfmain.lstactionsItemClick(const Sender: TObject;
  const AItem: TListViewItem);
begin
  if AItem.Tag > 0 then
  begin

    fviewAction := TfviewAction.Create(nil);
    fviewAction.id := AItem.Tag;
    fviewAction.Show;
  end;
end;

{ ------------------------------------------------------------------------------ }
procedure Tfmain.lstcomentariosClick(Sender: TObject);
begin
  btdeletecoment.Visible := lstcomentarios.Selected <> nil;
end;

procedure Tfmain.lstcomentariosItemClick(const Sender: TObject;
  const AItem: TListViewItem);
begin
  if assigned(AItem) then
  begin
    FcommentId := AItem.Tag;
  end;
end;

procedure Tfmain.lstcomentariosItemClickEx(const Sender: TObject;
  ItemIndex: Integer; const LocalClickPos: TPointF;
  const ItemObject: TListItemDrawable);
begin
  if (LocalClickPos.X > 250) and (LocalClickPos.X < 350) and
    (LocalClickPos.Y > 0) and (LocalClickPos.Y < 100) then
  begin
    ChangeTabAction5.ExecuteTarget(Sender);
    memoeditcoments.Lines.Text := lstcomentarios.Items[ItemIndex].Text;
    lbtopcoments.Text := 'visualizando comentario : ' +
      inttostr(lstcomentarios.Items[ItemIndex].Tag);
    memoeditcoments.ReadOnly := True;
    btsalvarcomentario.Visible := false;
  end;
end;

procedure Tfmain.lsthastagsClick(Sender: TObject);
begin
  btremovertag.Visible := lsthastags.Selected <> nil;
end;

{ ------------------------------------------------------------------------------ }
procedure Tfmain.lsthastagsDeletingItem(Sender: TObject; AIndex: Integer;
  var ACanDelete: Boolean);
begin
  btremovertagClick(Sender);
end;

{ ------------------------------------------------------------------------------ }
procedure Tfmain.lsthastagsItemClick(const Sender: TObject;
  const AItem: TListViewItem);
begin
  btremovertag.Visible := lsthastags.Selected <> nil;
end;

procedure Tfmain.lstuersDeleteItem(Sender: TObject; AIndex: Integer);
begin

  if assigned(lstuers.Items[AIndex]) then
  begin
    FmainController.deleteUser(lstuers.Items[AIndex].Tag);
    FmainController.setViewUser(Sender);
  end;
end;

procedure Tfmain.lstuersItemClick(const Sender: TObject;
  const AItem: TListViewItem);
begin
  if AItem.Tag > 0 then
  begin
    FUserView := TFUserView.Create(nil);
    FUserView.id := AItem.Tag;
    FUserView.Show;
  end;
end;

procedure Tfmain.MultiView1StartHiding(Sender: TObject);
begin
  brs.Visible := True;
end;

procedure Tfmain.MultiView1StartShowing(Sender: TObject);
begin
  brs.Visible := false;
end;

procedure Tfmain.ListBoxItem1Click(Sender: TObject);
begin
  if not assigned(Fmailsend) then
    Fmailsend := TFmailSend.Create(Nil);
  Fmailsend.Show;
end;

procedure Tfmain.ListBoxItem2Click(Sender: TObject);
begin
  ChangeTabAction2.ExecuteTarget(Self);
  FmainController.setViewHashTag(Sender);
end;

procedure Tfmain.liupdatedataClick(Sender: TObject);
begin
  FmainController.sincronizeall;
  FmainController.setAllViews;
end;

procedure Tfmain.ListBoxItemLatitudeClick(Sender: TObject);
begin
  ShowMessage('excluir dados ?')
end;

procedure Tfmain.liupdateallClick(Sender: TObject);
begin
  FmainController.sincronizeall;
end;

procedure Tfmain.Logop(value: string);
begin
  memolog.Lines.add(value);
end;

function Tfmain.getcooki(value: string): string;
begin

end;

procedure Tfmain.lblversionClick(Sender: TObject);
begin
  tablog.Visible:=true;
end;

procedure Tfmain.licomentariosClick(Sender: TObject);
begin
  FmainController.setViewComment(Sender);
  ChangeTabAction3.ExecuteTarget(Self);

end;

procedure Tfmain.liespaceClick(Sender: TObject);
begin
  if not assigned(FreleaseNotes) then
    FreleaseNotes := tFreleaseNotes.Create(Nil);
  FreleaseNotes.Show;
end;

procedure Tfmain.lilogoutClick(Sender: TObject);
begin
  btstopClick((Nil));
  Flogin.Show;
  Self.Close;
end;

procedure Tfmain.linomecontaClick(Sender: TObject);
begin
  if not assigned(FviewPerson) then
    FviewPerson := TFviewPerson.Create(Nil);
  FviewPerson.tpOperacao := 0;
  FviewPerson.Show;
end;

{ ------------------------------------------------------------------------------ }

procedure Tfmain.LogOut;
{$IF DEFINED(iOS) or DEFINED(ANDROID)}
var

  CookieSyncManager: JCookieSyncManager;
  CookieManager: JCookieManager;

{$ENDIF}
begin
{$IF DEFINED(iOS) or DEFINED(ANDROID)}
  CookieSyncManager := TJCookieSyncManager.JavaClass.createInstance
    (TAndroidHelper.Context);
  CookieManager := TJCookieManager.JavaClass.getInstance;
  CookieManager.removeAllCookie
{$ENDIF}
end;

{ ------------------------------------------------------------------------------ }
procedure Tfmain.OnInputQuery_Close(const AResult: TModalResult;
  const AValues: array of string);
var
  TaskName: String;
begin
  TaskName := string.Empty;
  if AResult <> mrOk then
    exit;
  TaskName := AValues[0];
  try
    if (TaskName.Trim <> '') then
    begin
      FmainController.saveHashTag(TaskName);
      btremovertag.Visible := lsthastags.Selected <> nil;
      FmainController.setViewHashTag(Nil);
    end;
  except
    on e: exception do
    begin
      ShowMessage(e.Message);
      tutil.gravalog('[TVIEWMAIN 814]' + e.Message);
    end;
  end;
end;

procedure Tfmain.btbackeditcomentarioClick(Sender: TObject);
begin
  ChangeTabAction4.ExecuteTarget(Sender);
end;

{ --------------------------------------------------------------------------- }
procedure Tfmain.btupdateusersClick(Sender: TObject);
begin
  FmainController.sincronizeusers;
  FmainController.setViewUser(Sender);
end;

procedure Tfmain.bt_updatecommentClick(Sender: TObject);
begin
  FmainController.sincronizecomments;
end;

procedure Tfmain.Button1Click(Sender: TObject);
begin
  pnexec.Visible := True;
  lbexec.Text := 'Comentario salvo';
  flapnexec.Start;
end;

procedure Tfmain.swcomentarioClick(Sender: TObject);
begin
  FmainController.persistLocalOptions()
end;

procedure Tfmain.swcurtirpostagemClick(Sender: TObject);
begin
  FmainController.persistLocalOptions();
end;

procedure Tfmain.tabconfigClick(Sender: TObject);
begin
  tabcontrolconfig.ActiveTab := tabconfigmain;
  tabcontrolcomentarios.ActiveTab := tabsubcomentariosview;
end;

procedure Tfmain.TmLabelTimer(Sender: TObject);
begin
  if lblinteracao.Visible = True then
    lblinteracao.Visible := false
  else
   lblinteracao.Visible := True;
end;

procedure Tfmain.tm_cordsTimer(Sender: TObject);
begin
  try
    lblcords.Text := 'Atualizando status';
    tm_cords.Enabled := false;
    GlobalPerson.person.person_last_latitude := GlobalPerson.atualLatitude;
    GlobalPerson.person.person_last_longitude := GlobalPerson.atualLongitude;
    GlobalPerson.updateLocationInfo(afterUpdateLocation);

  except
    on e: exception do
    begin
      lblcords.Text := e.Message;
    end;
  end;
  tm_cords.Enabled := True;

end;

procedure Tfmain.prepareview;
begin
  lbexec.Text := 'Carregando açoes...';
  FmainController.sincronizeactions;
  lbexec.Text := 'Carregando usuarios...';
  FmainController.sincronizeusers;
  lbexec.Text := 'Carregando comentarios...';
  FmainController.sincronizecomments;
  lbexec.Text := 'Carregando hashtags...';
  FmainController.sincronizehashtags;
  lbexec.Text := 'Preparando tela...';
  FmainController.setAllViews;
  pnexec.Visible := false;
end;

procedure Tfmain.setBrowserControl();
begin
  try

{$IF DEFINED(MSWINDOWS_)}
    brs := TFMXChromium.Create(Self);

{$ELSE}
    brs := TWebBrowser.Create(Self);

{$ENDIF}
    brs.Parent := taboperacao;
    brs.SendToBack;
    brs.Align := TAlignLayout.client;
    brs.CanFocus := false;
    brs.Visible :=false;
    Fnavegador := TinstaNavegador.Create(brs, memolog);
    if not assigned(dm_local) then
      dm_local := Tdm_local.Create(Application);
    // brs.Navigate('https://www.instagram.com/');
  except
    on e: exception do
      tutil.gravalog('[TVIEWMAIN 951]' + e.Message);
  end;
end;

procedure Tfmain.tm_iniciarTimer(Sender: TObject);
var
  amsg: string;
  op: Integer;
begin
  try
    op := 0;
    tm_iniciar.Enabled := false;
    op := 1;
    GlobalPerson.setLocalPerson(nil);
    op := 2;
    GlobalPerson.setDataToserver(amsg, True);
    op := 3;
    AniIndicator1.Enabled := True;
    pnexec.Visible := True;
    op := 4;
    prepareview();
    op := 5;
    GlobalPerson.sincronizar;
    op := 6;
    NgDeviceInfo.updateDeviceInfo();
    op := 7;
    op := 8;
    brs.SendToBack;
    AniIndicator1.BringToFront;
    lbinfouser.Text := 'Bem vindo ' + GlobalPerson.person.person_name;
    op := 9;
    tm_cords.Enabled := True;
    op := 10;

  Except
    on e: exception do
      tutil.gravalog('[VIEWMAIN ] E979 ' + e.Message + ' - ' + inttostr(op));
  end;
end;

end.

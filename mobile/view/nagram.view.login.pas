unit nagram.view.login;

interface

uses
  System.SysUtils,
  json,
  System.NetEncoding,
  rtti,
  System.ZLib,

  System.Types,
  System.UITypes,
  math,
  System.Classes,
  System.Variants,
  FMX.Types,
  FMX.Controls,
  FMX.Forms,
  FMX.Graphics,
  FMX.Dialogs,
  System.ImageList,
  FMX.ImgList,
  FMX.StdCtrls,
  FMX.Edit,
  FMX.ListBox,
  FMX.Layouts,
  System.IOUtils,
  FMX.Objects,
  FMX.Controls.Presentation,
  FMX.DialogService,
  System.Sensors,
  FMX.Effects,
  FMX.Filter.Effects,
  System.Sensors.Components,
  IdBaseComponent,
  IdComponent,
  IdTCPConnection,
  IdTCPClient,
  IdExplicitTLSClientServerBase,
  IdMessageClient,
  IdSMTPBase,
  IdSMTPRelay,
  FMX.Ani,
  {NAGRAM USES}
  nagram.service.deviceinfo,
  nagram.lib.getpermision,
  nagram.datamodule,
  nagram.android.util,
  nagram.service.http,
  nagram.view.person, System.Net.URLClient, System.Net.HttpClient,
  System.Net.HttpClientComponent

    ;

type
  TFlogin = class(TForm)
    ImageList2: TImageList;
    tm_init: TTimer;
    lblerror: TLabel;
    btnewuser: TSpeedButton;
    rectmaster: TRoundRect;
    imglogo: TImage;
    lbinfo: TLabel;
    ShadowEffect1: TShadowEffect;
    ShadowEffect2: TShadowEffect;
    AniIndicator1: TAniIndicator;
    FloatAnimation1: TFloatAnimation;
    RectAnimation1: TRectAnimation;
    GradientAnimation1: TGradientAnimation;
    FormLayout: TLayout;
    edtuserconta: TEdit;
    MailImage: TImage;
    edtsenhaconta: TEdit;
    LockImage: TImage;
    AuthenticateRectBTN: TRectangle;
    thema: TStyleBook;
    bt_login: TSpeedButton;
    Brush1: TBrushObject;
    lblversion: TLabel;
    ShadowEffect3: TShadowEffect;
    procedure bt_loginClick(Sender: TObject);
    procedure tm_initTimer(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure lblnewPersonClick(Sender: TObject);
    procedure btnewuserClick(Sender: TObject);
    procedure otesteClick(Sender: TObject);
    procedure cp1AuthEvent(const Sender: TObject; AnAuthTarget: TAuthTargetType;
      const ARealm, AURL: string; var AUserName, APassword: string;
      var AbortAuth: Boolean; var Persistence: TAuthPersistenceType);
    procedure netreqRequestCompleted(const Sender: TObject;
      const AResponse: IHTTPResponse);

    function decompress(value: TStream): TStream;
    procedure cp1RequestCompleted(const Sender: TObject;
      const AResponse: IHTTPResponse);
  private

    FConsultaLogin: TConsultaLogin;
    procedure dologin();
    function GetInfoAcount: string;
    procedure processLogin(Sender: TObject);

  public
    { Public declarations }
  end;

var
  Flogin: TFlogin;

implementation

uses

  nagram.model.person,
  nagram.lib.infoacount,
  nagram.control.person,
  nagram.dao.user,
  nagram.control.user,
  nagram.model.user,
  nagram.view.main;
{$R *.fmx}

{ ----------------------------------------------------------------------------- }
procedure TFlogin.processLogin(Sender: TObject);

begin
  try
    bt_login.Enabled := true;
    AniIndicator1.Visible := false;
    AniIndicator1.Enabled := false;
    if FConsultaLogin.Logedin then
    begin
      if not Assigned(fmain) then
        Application.CreateForm(Tfmain, fmain);
      fmain.show;
      self.hide;
    end
    else
    begin
      ShowMessage(FConsultaLogin.MensageReturned);
    end;
  except
    on e: exception do
      ShowMessage(e.Message);
  end;
end;

{ ----------------------------------------------------------------------------- }
procedure TFlogin.dologin;
begin
  try
    FConsultaLogin := TConsultaLogin.Create(true);
    FConsultaLogin.LoginUser := edtuserconta.text;
    FConsultaLogin.Senha := edtsenhaconta.text;
    FConsultaLogin.FreeOnTerminate := true;
    FConsultaLogin.OnTerminate := processLogin;
    FConsultaLogin.resume;
  except
    on e: exception do
      ShowMessage(e.Message);
  end;
end;

{ ----------------------------------------------------------------------------- }
Function TFlogin.GetInfoAcount: string;
const
  AccountType = 'com.google';
var
  AccountNames: TArray<String>;
  AccountLoopCounter: Integer;
begin
{$IF DEFINED(ANDROID)}
  try
    if not HasPermission('android.permission.GET_ACCOUNTS') then
    begin
      TDialogService.MessageDialog
        ('O aplicativo não pode funcionar sem acesso a conta de usuario',
        TMsgDlgType.mtError, [TMsgDlgBtn.mbCancel],
        TMsgDlgBtn.mbCancel, 0, nil);
      halt;
    end
    else
    begin
      { AccountNames := GetAccountEmails(AccountType);
        // AccountsListBox.Items.Clear;
        // for AccountLoopCounter := Low(AccountNames) to High(AccountNames) do
        // AccountsListBox.Items.Add(AccountNames[AccountLoopCounter])
        if High(AccountNames) > -1 then
        result := AccountNames[0];
      }
    end;
  except
    on e: exception do
      ShowMessage(e.Message);
  end;
{$ENDIF}
end;

{ ----------------------------------------------------------------------------- }
procedure TFlogin.lblnewPersonClick(Sender: TObject);
begin
  FviewPerson := TFviewPerson.Create(Nil);
  FviewPerson.show;
end;

function TFlogin.decompress(value: TStream): TStream;
begin
  // compress to buff (System.ZLib)
  value.Position := 0;
  result := TstringStream.Create;
  ZDecompressStream(value, result);
end;

procedure TFlogin.netreqRequestCompleted(const Sender: TObject;
  const AResponse: IHTTPResponse);
begin
  AResponse.ContentStream;
end;

{ ----------------------------------------------------------------------------- }
procedure TFlogin.otesteClick(Sender: TObject);
var
  ouser: TUser;
  odao: TUserDao;
  s: string;
  i: Integer;
begin
  odao := TUserDao.Create;
  ouser := TUser.Create;
  s := GlobalPerson.person.person_uuid;
  for i := 0 to 1000 do
  begin

    ouser.insta_user_Id := 0;
    ouser.insta_user_Date := now;

    ouser.insta_user_Last_Visit := now;
    ouser.insta_user_Posts := 10;
    ouser.insta_user_name := 'helena lion users ' + inttostr(i);
    ouser.insta_user_Bio := 'snipe e nipe cord';
    odao.setUser(ouser);

  end;
end;

{ ----------------------------------------------------------------------------- }
procedure TFlogin.FormCreate(Sender: TObject);
begin
  tm_init.Enabled := true;

end;

procedure TFlogin.btnewuserClick(Sender: TObject);
begin
  FviewPerson := TFviewPerson.Create(Nil);
  FviewPerson.lblpersoncad.text := 'Inerindo dados';
  FviewPerson.tpOperacao := 1;
  edtuserconta.text := '';
  edtsenhaconta.text := '';
  FviewPerson.show;

end;

{ ----------------------------------------------------------------------------- }
procedure TFlogin.bt_loginClick(Sender: TObject);
begin
  try
    if (edtuserconta.text = '') or (edtsenhaconta.text = '') then
    begin
      ShowMessage('Login e senha devem ser informados');
    end
    else
    begin

      bt_login.Enabled := false;
      dologin();
      AniIndicator1.Visible := true;
      AniIndicator1.Enabled := true;
    end;
  except
    on e: exception do
      ShowMessage(e.Message);
  end;
end;

{ ----------------------------------------------------------------------------- }
procedure TFlogin.cp1AuthEvent(const Sender: TObject;
  AnAuthTarget: TAuthTargetType; const ARealm, AURL: string;
  var AUserName, APassword: string; var AbortAuth: Boolean;
  var Persistence: TAuthPersistenceType);
begin
  AUserName := 'master';
  APassword := '2061614';
end;

procedure TFlogin.cp1RequestCompleted(const Sender: TObject;
  const AResponse: IHTTPResponse);

var
  Params: TStringList;
  mresponse: TStream;
  s: string;
begin
  mresponse := TStream.Create;

  mresponse := decompress(AResponse.ContentStream);
  s := TstringStream(mresponse).DataString;
  ShowMessage(s);;

end;

{ ----------------------------------------------------------------------------- }
procedure TFlogin.tm_initTimer(Sender: TObject);
var
  operacao: string;
begin
  tm_init.Enabled := false;
  try
    if checarpermisalocation then
    begin
      ShowMessage('O aplicativo só pode funcionar com as permisoes ativadas');
      halt;
    end;
    operacao := 'Carregando dados...';
    Application.CreateForm(Tdm_local, dm_local);
    operacao := 'Dados carregados...';
    operacao := 'buscando dados pessoais...';
    GlobalPerson.getLocalPerson;
    AniIndicator1.Visible := false;

    if GlobalPerson.person.person_login <> '' then
    begin
      edtuserconta.text := GlobalPerson.person.person_login;
      edtsenhaconta.text := GlobalPerson.person.person_password;
    end;
    operacao := 'Sincronizando dados no servidor';
    GlobalPerson.sincronizar();
    operacao := 'finalizando';
{$IF DEFINED(ANDROID)}
    if edtuserconta.text = '' then
    begin
      operacao := 'obtendo email android';
      // edtuserconta.text := GetInfoAcount;
    end;
{$ENDIF}
  except
    on e: exception do
      ShowMessage(e.Message + ' - ' + operacao);
  end;

end;

{ ----------------------------------------------------------------------------- }
end.

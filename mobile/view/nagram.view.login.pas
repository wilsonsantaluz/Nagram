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
    btresendepass: TSpeedButton;
    procedure bt_loginClick(Sender: TObject);
    procedure tm_initTimer(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure lblnewPersonClick(Sender: TObject);
    procedure btnewuserClick(Sender: TObject);
    procedure otesteClick(Sender: TObject);
    procedure netreqRequestCompleted(const Sender: TObject;
      const AResponse: IHTTPResponse);

    function decompress(value: TStream): TStream;
    procedure btresendepassClick(Sender: TObject);
  private
    FfatalMsg: Boolean;
    FConsultaLogin: TConsultaLogin;
    procedure dologin();
    function GetInfoAcount: string;
    procedure processLogin(Sender: TObject);
    procedure onfinalizethd(Sender: TObject);
    procedure onfinalizeinfoconta(Sender: TObject);

  public
    { Public declarations }
  end;

var
  Flogin: TFlogin;

implementation

uses
  nagram.service.geolocation,
  nagram.service.sendmail,
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

procedure TFlogin.btresendepassClick(Sender: TObject);
var

  Fco: TConsultaLogin;
begin
  if edtuserconta.Text = '' then
  begin
    ShowMessage('Informe o usuário');
  end
  else
  begin
    AniIndicator1.Visible:=true;
    btresendepass.Enabled:=true;
    Fco := TConsultaLogin.Create(true);
    Fco.LoginUser := edtuserconta.Text;
    Fco.Senha := edtsenhaconta.Text;
    Fco.OnTerminate := onfinalizeinfoconta;
    Fco.FreeOnTerminate := true;
    Fco.resume;
  end;
end;

{ ----------------------------------------------------------------------------- }
procedure TFlogin.dologin;
begin
  try
    FConsultaLogin := TConsultaLogin.Create(true);
    FConsultaLogin.LoginUser := edtuserconta.Text;
    FConsultaLogin.Senha := edtsenhaconta.Text;
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
procedure TFlogin.onfinalizeinfoconta(Sender: TObject);
var
  Foevio: TngSendMail;
begin
  if GlobalPerson.person.person_mail <> '' then
  begin
    Foevio := TngSendMail.Create(true);
    Foevio.feedback := 'Recuperação de senha ' + GlobalPerson.person.person_name
      + ' senha : ' + GlobalPerson.person.person_password;
    Foevio.destinatario := GlobalPerson.person.person_mail;
    Foevio.FreeOnTerminate := true;
    Foevio.OnTerminate := onfinalizethd;
    Foevio.resume;
  end
  else
    ShowMessage('Não foi encontrado email cadastrado para esta conta');

end;

procedure TFlogin.onfinalizethd(Sender: TObject);
begin
  if TngSendMail(Sender).success then
  begin
    ShowMessage('Envio realizado com sucesso');
    if FfatalMsg then
      halt
  end
  else
  begin
    ShowMessage('Lamento não pude enviar o email ');
  end;
end;

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
  with TlocationInfo.Create(true) do
  begin
    resume;

  end;

end;

procedure TFlogin.btnewuserClick(Sender: TObject);
begin
  FviewPerson := TFviewPerson.Create(Nil);
  FviewPerson.lblpersoncad.Text := 'Inerindo dados';
  FviewPerson.tpOperacao := 1;
  edtuserconta.Text := '';
  edtsenhaconta.Text := '';
  FviewPerson.show;

end;

{ ----------------------------------------------------------------------------- }
procedure TFlogin.bt_loginClick(Sender: TObject);
begin
  try
    if (edtuserconta.Text = '') or (edtsenhaconta.Text = '') then
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

procedure TFlogin.tm_initTimer(Sender: TObject);
var
  operacao: string;
  Foevio: TngSendMail;
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
    operacao := 'buscando dados locais..';
    GlobalPerson.getLocalPerson;
    AniIndicator1.Visible := false;

    if GlobalPerson.person.person_login <> '' then
    begin
      edtuserconta.Text := GlobalPerson.person.person_login;
      edtsenhaconta.Text := GlobalPerson.person.person_password;
    end;
    operacao := 'Sincronizando dados no servidor';
    try
      GlobalPerson.sincronizar();
    except
    end;
    operacao := 'finalizando';
{$IF DEFINED(ANDROID)}
{$ENDIF}
  except
    on e: exception do
    begin

      FfatalMsg := true;
      ShowMessage
        ('Falha iniciar o sistema um email esta sendo enviado ao suporte');
      Foevio := TngSendMail.Create(true);
      Foevio.feedback := 'ERRO CRITICO ' + operacao + '- ' + e.Message;
      Foevio.FreeOnTerminate := true;
      Foevio.OnTerminate := onfinalizethd;
      Foevio.resume;
    end;

  end;

end;

{ ----------------------------------------------------------------------------- }
end.

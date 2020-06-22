unit nagram.view.sendfeedback;

interface

uses
  System.SysUtils,
  System.Types,
  System.IOUtils,
  System.UITypes,
  System.Classes,
  System.Variants,
  IdAttachmentFile,
  IdAttachment,
  FMX.Types,
  FMX.Controls,
  FMX.Forms,
  FMX.Graphics,
  FMX.Dialogs,
  IdIOHandler,
  IdIOHandlerSocket,
  IdIOHandlerStack,
  IdSSL,
  IdSSLOpenSSL,
  IdComponent,
  IdTCPConnection,
  IdTCPClient,
  IdExplicitTLSClientServerBase,
  IdMessageClient,
  IdSMTPBase,
  nagram.service.deviceinfo,
  FMX.ZDeviceInfo,
  nagram.resource.master,
  nagram.control.person,
  IdSMTP,
  IdBaseComponent,
  IdMessage, FMX.Objects,
  FMX.ScrollBox,
  FMX.Memo,
  FMX.Layouts,
  FMX.StdCtrls,
  FMX.Ani,

  FMX.Controls.Presentation, IdPOP3;

type
  TbeforeExecute = TNotifyEvent;

type
  Toenvio = class(TThread)
  private
    Fsuccess: Boolean;
    FfeedBack: string;
    mailreader: TIdPOP3;
    mailsend: TIdSMTP;
    omsg: TIdMessage;
    sslhandle: TIdSSLIOHandlerSocketOpenSSL;
    smtpsslhandle: TIdSSLIOHandlerSocketOpenSSL;
    FbeforeExecute: TbeforeExecute;
    FmsgRetono: string;
    procedure setup;
    procedure execute; override;
  public
    property OnBeforeExecute: TbeforeExecute Read FbeforeExecute
      write FbeforeExecute;
    property success: Boolean read Fsuccess write Fsuccess;
    property feedback: string read FfeedBack write FfeedBack;
    property msgretorno: string read FmsgRetono write FmsgRetono;
  end;

type
  TFmailSend = class(TForm)
    toolbarmain: TToolBar;
    FloatAnimation1: TFloatAnimation;
    btoptions: TSpeedButton;
    Label1: TLabel;
    ltlgeral: TLayout;
    memoinfo: TMemo;
    rectop: TRectangle;
    recbtn: TRectangle;
    bt_enviar: TSpeedButton;
    recmemo: TRectangle;
    lbtop: TLabel;
    AniIndicator1: TAniIndicator;
    procedure btoptionsClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure bt_enviarClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    procedure onfinalizethd(Sender: TObject);
  public
    { Public declarations }
  end;

var
  FmailSend: TFmailSend;

implementation

uses
  nagram.view.main;
{$R *.fmx}

procedure TFmailSend.btoptionsClick(Sender: TObject);
begin
  self.Close;

end;

procedure TFmailSend.bt_enviarClick(Sender: TObject);
Var
  Foevio: Toenvio;

begin
  bt_enviar.Enabled := false;
  AniIndicator1.Enabled := true;
  AniIndicator1.Visible := true;
  Foevio := Toenvio.Create(true);
  Foevio.feedback := memoinfo.Text;
  Foevio.FreeOnTerminate := true;
  Foevio.OnTerminate := onfinalizethd;
  Foevio.Resume;

end;

procedure TFmailSend.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  FmailSend := Nil;
end;

procedure TFmailSend.FormCreate(Sender: TObject);
begin
  AniIndicator1.Visible := false;
end;

procedure TFmailSend.onfinalizethd(Sender: TObject);
begin
  if Toenvio(Sender).success then
  begin
    ShowMessage('Envio realizado com sucesso');
  end
  else
  begin
    ShowMessage('Lamento não pude enviar o email ');
  end;
  bt_enviar.Enabled := true;
  AniIndicator1.Enabled := false;
  AniIndicator1.Visible := false;
end;

{ Toenvio }

procedure Toenvio.execute;
var
  oarquivo: TIdAttachment;
  ofile: string;
  i: integer;
  lstMails: Tstrings;
  oinfo: TZDeviceInfo;
begin

  setup;
  try
    try
      if not mailreader.Connected then
        mailreader.Connect;
      for i := 0 to 3 do
      begin
        ofile := System.IOUtils.TPath.Combine
          (System.IOUtils.TPath.GetDocumentsPath,
          'nagramerror_' + FormatDateTime('ddmmyy', date - i) + '.log');
        if FileExists(ofile) then
        begin
          oarquivo := TIdAttachmentFile.Create(omsg.MessageParts, ofile);
        end;
      end;
      oinfo := TZDeviceInfo.Create;
      omsg.Body.AddPair('device_id', oinfo.DeviceID);
      omsg.Body.AddPair('device_uuid', GlobalPerson.person.person_uuid);
      omsg.Body.AddPair('device_os', oinfo.Platform);
      omsg.Body.AddPair('device_ip', oinfo.IPAddress);
      omsg.Body.AddPair('device_operator', oinfo.MobileOperator);
      omsg.Body.AddPair('device_macaddress', oinfo.MacAddress);
      omsg.Body.AddPair('device_language', oinfo.LangID);
      omsg.Body.AddPair(' device_architecture', oinfo.Architecture + ' - ' +
        oinfo.Architecture2);
      omsg.Body.AddPair('device_platform', oinfo.Platform);
      omsg.Body.AddPair('device_platformver', oinfo.PlatformVer);

      omsg.Body.AddPair('device_mobiledatatype',
        inttostr(ord(oinfo.MobileDataType)));
      omsg.Body.Add(FfeedBack);

      omsg.Subject := 'FeedbackNagram';

      omsg.Sender.Name := 'wlofshine';
      omsg.Sender.Address := 'wlofshine@bol.com.br';
      omsg.From.Name := 'wlofshine';
      omsg.From.Address := 'wlofshine@bol.com.br';
      with omsg.Recipients.Add do
      begin
        Name := 'wilsonsantaluz';
        Address := 'wilsonsantaluz@hotmail.com';
      end;
      if not mailsend.Connected then
        mailsend.Connect;
      mailsend.Send(omsg);
      Fsuccess := true;
    except
      on e: Exception do
      begin
        FmsgRetono := e.Message;
        Fsuccess := false
      end;
    end;
  finally
    FreeAndNil(omsg);
    FreeAndNil(sslhandle);
    FreeAndNil(smtpsslhandle);
    FreeAndNil(mailsend);
    FreeAndNil(mailreader);
  end;
end;

procedure Toenvio.setup;
begin
  mailreader := TIdPOP3.Create(Nil);;
  mailsend := TIdSMTP.Create(Nil);;
  sslhandle := TIdSSLIOHandlerSocketOpenSSL.Create(Nil);;
  smtpsslhandle := TIdSSLIOHandlerSocketOpenSSL.Create(Nil);
  omsg := TIdMessage.Create(Nil);
  with mailsend do
  begin
    IOHandler := smtpsslhandle;
    MailAgent := 'nagram';
    Host := 'smtps.bol.com.br';
    Password := 'w2061614';
    Port := 587;
    Username := 'wlofshine@bol.com.br';
  end;
  with sslhandle do
  begin
    Destination := 'pop3.bol.com.br:995';
    Host := 'pop3.bol.com.br';

    Port := 995;
    DefaultPort := 0;
    SSLOptions.Mode := sslmUnassigned;
    SSLOptions.VerifyMode := [];
    SSLOptions.VerifyDepth := 0;

  end;
  with mailreader do
  begin
    IOHandler := sslhandle;
    AutoLogin := true;
    Host := 'pop3.bol.com.br';
    Username := 'wlofshine@bol.com.br';
    UseTLS := utUseImplicitTLS;
    Password := 'w2061614';
    Port := 995;

  end;
  with smtpsslhandle do
  begin
    Destination := 'smtps.bol.com.br:587';
    Host := 'smtps.bol.com.br';
    Port := 587;
    DefaultPort := 0;
    SSLOptions.Mode := sslmUnassigned;
    SSLOptions.VerifyMode := [];
    SSLOptions.VerifyDepth := 0;

  end
end;

end.

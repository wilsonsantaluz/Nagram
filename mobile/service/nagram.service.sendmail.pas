unit nagram.service.sendmail;

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

  FMX.Controls.Presentation, IdPOP3;

type
  TbeforeExecute = TNotifyEvent;

type
  TngSendMail = class(Tthread)
  private
    Fsuccess: Boolean;
    FfeedBack: string;
    mailreader: TIdPOP3;
    Fassunto: string;
    Fdestinatario: string;
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
    property assunto: string read Fassunto write Fassunto;
    property destinatario: string read Fdestinatario write Fdestinatario;

  end;

implementation

{ TngSendMail }

procedure TngSendMail.execute;
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

      if Fassunto = '' then
        Fassunto := 'FeedbackNagram';

      if Fassunto = 'FeedbackNagram' then
      begin

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
        omsg.Body.Add('');
        omsg.Body.Add('');
        omsg.Body.Add('------------------------------------------------');
        omsg.Body.Add('------------------MENSAGEM----------------------');
        omsg.Body.Add('------------------------------------------------');
        omsg.Body.Add('');
        omsg.Body.Add('');
      end;
      omsg.Body.Add(FfeedBack);
      omsg.Body.Add('');

      omsg.Subject := Fassunto;
      omsg.Sender.Name := 'wlofshine';
      omsg.Sender.Address := 'wlofshine@bol.com.br';
      omsg.From.Name := 'wlofshine';
      omsg.From.Address := 'wlofshine@bol.com.br';
      if Fdestinatario = '' then
        Fdestinatario := 'wilsonsantaluz@hotmail.com';
      with omsg.Recipients.Add do
      begin
        Name := Fdestinatario;
        Address := Fdestinatario;
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

procedure TngSendMail.setup;
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

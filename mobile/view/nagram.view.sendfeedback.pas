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

  nagram.service.deviceinfo,
  FMX.ZDeviceInfo,
  nagram.resource.master,
  nagram.control.person,
  nagram.service.sendmail,

   FMX.Objects,
  FMX.ScrollBox,
  FMX.Memo,
  FMX.Layouts,
  FMX.StdCtrls,
  FMX.Ani,

  FMX.Controls.Presentation;




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
  Foevio: TngSendMail;
begin
  bt_enviar.Enabled := false;
  AniIndicator1.Enabled := true;
  AniIndicator1.Visible := true;
  Foevio := TngSendMail.Create(true);
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
  if TngSendMail (Sender).success then
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


end.

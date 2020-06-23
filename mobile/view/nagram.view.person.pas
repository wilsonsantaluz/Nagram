unit nagram.view.person;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Variants, nagram.android.util,

  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Objects,
  FMX.StdCtrls, FMX.Controls.Presentation, FMX.Edit, FMX.ListBox, FMX.Layouts,
  nagram.model.person, System.ImageList, FMX.ImgList, FMX.Effects, FMX.Ani;

type
  TFviewPerson = class(TForm)
    lstdadosgerais: TListBox;
    AccountInfo: TListBoxGroupHeader;
    linomeconta: TListBoxItem;
    edtlogin: TEdit;
    Label6: TLabel;
    lisenhaconta: TListBoxItem;
    edtsenhaconta: TEdit;
    Label5: TLabel;
    licontainsta: TListBoxItem;
    edtcontainsta: TEdit;
    Label4: TLabel;
    licontainstagram: TListBoxItem;
    edtsenhainsta: TEdit;
    Label3: TLabel;
    ListBoxItem1: TListBoxItem;
    edtemail: TEdit;
    Label2: TLabel;
    toolbarmain: TToolBar;
    ListBoxItem2: TListBoxItem;
    ListBoxItem3: TListBoxItem;
    edtnomefull: TEdit;
    Label1: TLabel;
    edtFone: TEdit;
    Label7: TLabel;
    btclose: TSpeedButton;
    btsaveperson: TSpeedButton;
    imguser: TSpeedButton;
    SpeedButton3: TSpeedButton;
    SpeedButton4: TSpeedButton;
    SpeedButton2: TSpeedButton;
    SpeedButton5: TSpeedButton;
    SpeedButton6: TSpeedButton;
    SpeedButton7: TSpeedButton;
    ShadowEffect1: TShadowEffect;
    lblpersoncad: TLabel;
    AniIndicator1: TAniIndicator;
    rectbody: TRectangle;
    FloatAnimation1: TFloatAnimation;
    procedure btcloseClick(Sender: TObject);
    procedure edtloginChange(Sender: TObject);
    procedure btsavepersonClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }

    isChanged: Boolean;
    loaded: Boolean;
    procedure setViewPerson;
    function persistPerson(out amsg: string): Boolean;

  public

    tpOperacao: Integer;
    { Public declarations }
  end;

var
  FviewPerson: TFviewPerson;

implementation

uses
  nagram.control.main,
  nagram.view.main,
  nagram.control.person;
{$R *.fmx}

procedure TFviewPerson.btcloseClick(Sender: TObject);
begin
  self.Close;
end;

procedure TFviewPerson.edtloginChange(Sender: TObject);
begin
  if loaded then
    isChanged := true;

end;

procedure TFviewPerson.FormShow(Sender: TObject);
begin
  if tpOperacao <> 1 then
    setViewPerson;
  AniIndicator1.Visible := false;
end;

function TFviewPerson.persistPerson(out amsg: string): Boolean;
begin
  try
    result := false;
    if edtlogin.Text = '' then
    begin
      raise Exception.Create(' login deve ser informado');

    end;
    if edtsenhaconta.Text = '' then
    begin
      raise Exception.Create('Senha  deve ser informada');
    end;
    if edtnomefull.Text = '' then
      raise Exception.Create('Nome deve ser informada');
    if edtcontainsta.Text = '' then
    begin
      raise Exception.Create('Usuario do instagram deve ser informado');
    end;
    if edtsenhainsta.Text = '' then
    begin
      raise Exception.Create('Senha do instagram deve ser informada');
    end;
    if edtemail.Text = '' then
      raise Exception.Create('Email deve ser informado');
    if edtFone.Text = '' then
      raise Exception.Create('Telefone deve ser informado');

    GlobalPerson.person.person_login := edtlogin.Text;
    GlobalPerson.person.person_password := edtsenhaconta.Text;
    GlobalPerson.person.person_insta_user := edtcontainsta.Text;
    GlobalPerson.person.person_insta_password := edtsenhainsta.Text;
    GlobalPerson.person.person_mail := edtemail.Text;
    GlobalPerson.person.person_name := edtnomefull.Text;
    GlobalPerson.person.person_fone := edtFone.Text;
    if tpOperacao = 1 then
      GlobalPerson.person.person_uuid := '';
    GlobalPerson.setLocalPerson(Nil);
    result := GlobalPerson.setDataToserver(amsg);
  except
    on e: Exception do
    begin
      amsg := e.Message;
    end;
  end;
end;

procedure TFviewPerson.setViewPerson;
begin
  GlobalPerson.getLocalPerson;
  edtlogin.Text := GlobalPerson.person.person_login;

  edtsenhaconta.Text := GlobalPerson.person.person_password;
  edtcontainsta.Text := GlobalPerson.person.person_insta_user;
  edtsenhainsta.Text := GlobalPerson.person.person_insta_password;
  edtemail.Text := GlobalPerson.person.person_mail;
  edtnomefull.Text := GlobalPerson.person.person_name;
  edtFone.Text := GlobalPerson.person.person_fone;
end;

procedure TFviewPerson.btsavepersonClick(Sender: TObject);
var
  amsg: string;
begin
  btsaveperson.Enabled := false;
  AniIndicator1.Visible := true;
  AniIndicator1.Enabled := true;
  lblpersoncad.Text := 'Salvando dados';
  try
    if persistPerson(amsg) then
      ShowMessage('Usuário salvo')
    else
      ShowMessage(amsg);
  finally
    AniIndicator1.Visible := false;
    AniIndicator1.Enabled := false;
    lblpersoncad.Text := 'Cadastro de contas';
    btsaveperson.Enabled := true;
  end;
end;

end.

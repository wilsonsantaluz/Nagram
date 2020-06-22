unit nagram.view.user;

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
  FMX.ScrollBox,
  FMX.Memo,
  FMX.StdCtrls,
  FMX.Controls.Presentation,
  FMX.Objects,
  FMX.Edit,
  FMX.ListBox,
  FMX.Layouts,
  nagram.control.user,
  nagram.model.user;

type
  TFUserView = class(TForm)
    tooltop: TToolBar;
    lbltitle: TLabel;
    bt_close: TSpeedButton;
    toolbutton: TToolBar;
    recbody: TRectangle;
    lstdadosgerais: TListBox;
    AccountInfo: TListBoxGroupHeader;
    linameuser: TListBoxItem;
    lbname: TEdit;
    Label9: TLabel;
    lidatacad: TListBoxItem;
    lbdatacad: TEdit;
    Label10: TLabel;
    lilastview: TListBoxItem;
    lblastvisit: TEdit;
    Label11: TLabel;
    licontainstagram: TListBoxItem;
    lbdatafollow: TEdit;
    Label12: TLabel;
    lifollow: TListBoxItem;
    lbseguidores: TEdit;
    Label13: TLabel;
    lifolows: TListBoxItem;
    lbseguindo: TEdit;
    Label2: TLabel;
    libio: TListBoxItem;
    Label3: TLabel;
    memobio: TMemo;
    procedure FormShow(Sender: TObject);
    procedure bt_closeClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    Fuser: TUser;
    Fid: Integer;
    { Private declarations }
  public
    { Public declarations }
    property Id: Integer read Fid write Fid;
  end;

var
  FUserView: TFUserView;

implementation

uses
  nagram.datamodule
  ,nagram.view.main
  ;
{$R *.fmx}
{$R *.NmXhdpiPh.fmx ANDROID}

procedure TFUserView.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  FUserView := Nil;
end;

procedure TFUserView.FormShow(Sender: TObject);
var
  acontrol: TUserController;
  ausers: TUsers;
begin
  acontrol := TUserController.Create;
  try
    ausers := acontrol.getUsers('insta_user_id = ' + IntToStr(Fid));

    if   ausers.Count > 0  then
    begin
      Fuser := ausers[0];
      lbname.Text := Fuser.insta_user_name;
      lbdatacad.Text := datetimetostr(Fuser.insta_user_date);
      lblastvisit.Text := datetimetostr(Fuser.insta_user_last_visit);
      lbseguidores.Text := IntToStr(Fuser.insta_user_followed);
      lbseguindo.Text := IntToStr(Fuser.insta_user_follow);

      if Fuser.insta_user_date_follow > 100 then

        lbdatafollow.Text := datetimetostr(Fuser.insta_user_date_follow)
      else
        lbdatafollow.Text := datetimetostr(Fuser.insta_user_date);
      memobio.lines.Text := Fuser.insta_user_bio;

    end
    else
      ShowMessage('Usuário ' + IntToStr(Fid) + ' não localizado');
  finally
    FreeAndNil(acontrol);
    FreeAndNil(ausers);
  end;
end;

procedure TFUserView.bt_closeClick(Sender: TObject);
begin
  self.Close;
end;

end.

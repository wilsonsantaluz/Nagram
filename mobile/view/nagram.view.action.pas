unit nagram.view.action;

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
  FMX.Controls.Presentation,
  Data.Bind.EngExt,
  FMX.Bind.DBEngExt,
  Data.Bind.Components,
  FMX.ScrollBox,
  FMX.Memo,
  FMX.Ani,
  nagram.model.action,
  nagram.control.action,
  FMX.Objects, FMX.Edit,
  FMX.ListBox,
  FMX.Layouts;

type
  TfviewAction = class(TForm)
    ToolBar1: TToolBar;
    Label1: TLabel;
    ToolBar2: TToolBar;
    FloatAnimation1: TFloatAnimation;
    btclose: TSpeedButton;
    lstdadosgerais: TListBox;
    AccountInfo: TListBoxGroupHeader;
    linameuser: TListBoxItem;
    Label9: TLabel;
    lidatacad: TListBoxItem;
    Label10: TLabel;
    lilastview: TListBoxItem;
    Label11: TLabel;
    licontainstagram: TListBoxItem;
    Label12: TLabel;
    ListBoxItem1: TListBoxItem;
    Label13: TLabel;
    ListBoxItem2: TListBoxItem;
    Label8: TLabel;
    memourl: TMemo;
    memocomentario: TMemo;
    lblid: TLabel;
    lbldata: TLabel;
    lblusuario: TLabel;
    lbltipo: TLabel;
    recbody: TRectangle;
    procedure SpeedButton1Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var action: TCloseAction);
  private
    Faction: TBotAction;
    Fid: integer;
  public
    property id: integer read Fid write Fid;
  end;

var
  fviewAction: TfviewAction;

implementation

uses
  nagram.view.main;
{$R *.fmx}

procedure TfviewAction.FormClose(Sender: TObject; var action: TCloseAction);
begin
  fviewAction := Nil;
end;

procedure TfviewAction.FormShow(Sender: TObject);
var
  tipo: string;

  acontrol: TActionController;
  actions: TBotActions;
begin
   acontrol := TActionController.Create;
  try
    actions := acontrol.getactions('insta_action_id  =' + inttostr(Fid));
    if  actions.Count  > 0  then
    begin
      Faction := actions[0];

      if Faction.insta_action_type = 0 then
        tipo := 'Seguir';
      if Faction.insta_action_type = 1 then
        tipo := 'Curtir';
      if Faction.insta_action_type = 2 then
        tipo := 'Comentario';

      lblid.Text := inttostr(Faction.insta_action_id);
      lbldata.Text := datetimetostr(Faction.insta_action_date);
      lblusuario.Text := Faction.insta_action_insta_user_name;
      lbltipo.Text := tipo;
      memocomentario.Lines.Text := Faction.insta_action_comment;
      memourl.Lines.Text := Faction.insta_action_url;
    end
    else
      showmessage('Ação ' + inttostr(Fid) + ' não encontrada');
  finally
    FreeAndNil(acontrol);
    if Assigned( actions) then
      FreeAndNil( actions);


  end;
end;

procedure TfviewAction.SpeedButton1Click(Sender: TObject);
begin
  if Assigned(Faction) then
    FreeAndNil(Faction);
  self.Close;
end;

end.

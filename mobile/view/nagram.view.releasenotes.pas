unit nagram.view.releasenotes;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.StdCtrls,
  FMX.Ani, FMX.Controls.Presentation, FMX.ScrollBox, FMX.Memo, FMX.Objects,
  FMX.Layouts;

type
  TFreleaseNotes = class(TForm)
    toolbarmain: TToolBar;
    Label1: TLabel;
    FloatAnimation1: TFloatAnimation;
    btoptions: TSpeedButton;
    ltlgeral: TLayout;
    recbtn: TRectangle;
    recmemo: TRectangle;
    memoinfo: TMemo;
    procedure btoptionsClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FreleaseNotes: TFreleaseNotes;

implementation
     uses
       nagram.view.main;

{$R *.fmx}

procedure TFreleaseNotes.btoptionsClick(Sender: TObject);
begin
  self.Close;
end;

end.

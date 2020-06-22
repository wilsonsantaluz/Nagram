unit uteste;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.Phys.PG,
  FireDAC.Phys.PGDef, FireDAC.VCLUI.Wait, FireDAC.Stan.Param, FireDAC.DatS,
  FireDAC.DApt.Intf, FireDAC.DApt, Data.DB, Vcl.StdCtrls, Vcl.ExtCtrls,
  Vcl.Grids, Vcl.DBGrids, FireDAC.Comp.DataSet, FireDAC.Comp.Client;

type
  TForm15 = class(TForm)
    FDConnection1: TFDConnection;
    FDQuery1: TFDQuery;
    DBGrid1: TDBGrid;
    Panel1: TPanel;
    Memo1: TMemo;
    Button1: TButton;
    DataSource1: TDataSource;
    Button2: TButton;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form15: TForm15;

implementation

{$R *.dfm}

procedure TForm15.Button1Click(Sender: TObject);
begin
  FDQuery1.SQL.Text:=Memo1.Lines.Text;
  FDQuery1.Open();
end;

procedure TForm15.Button2Click(Sender: TObject);
var
  oq:tguid;
begin
  memo1.Lines.Text:=
  'select  cast(person_uuid as varchar(50)),  * from person  '
  +' where person_uuid = :person_uuid';
  {1194BE8F-0E1B-A944-8EC8-64AAC8C08AF7}
 FDQuery1.SQL.Text:=Memo1.Text;
 FDQuery1.ParamByName('person_uuid').AsGUID:=
   StringToGUID ('{1194BE8F-0E1B-A944-8EC8-64AAC8C08AF7}') ;
   FDQuery1.Open();
 //  LowerCase(  '{8FBE9411-1B0E-44A9-8EC8-64AAC8C08AF7}') ;
end;

end.

unit nagram.datamodule;

interface

uses
  System.SysUtils,
  System.Classes,
  FireDAC.Stan.Intf,
  FireDAC.Stan.Option,
  FireDAC.Stan.Error,
  FireDAC.UI.Intf,
  FireDAC.Phys.Intf,
  FireDAC.Stan.Def,
  FireDAC.Stan.Pool,
  FireDAC.Stan.Async,
  FireDAC.Phys,
  FireDAC.FMXUI.Wait,
  Data.DB,
  FireDAC.Comp.Client,
  System.IOUtils,
  FireDAC.Phys.SQLite,
  FireDAC.Phys.SQLiteDef,
  FireDAC.Stan.ExprFuncs,
  FireDAC.Stan.Param,
  FireDAC.DatS,
  FireDAC.DApt.Intf,
  FireDAC.DApt,
  FireDAC.Comp.DataSet;

type
  Tdm_local = class(TDataModule)
    procedure FDConnection1BeforeConnect(Sender: TObject);
    procedure DataModuleCreate(Sender: TObject);

  private

    { Private declarations }
  public
    FDConnection1: TFDConnection;
  end;

var
  dm_local: Tdm_local;

implementation

uses
  nagram.resource.master;
{%CLASSGROUP 'FMX.Controls.TControl'}
{$R *.dfm}

procedure Tdm_local.DataModuleCreate(Sender: TObject);
begin
  FDConnection1 := TFDConnection.Create(Self);
  FDConnection1.Params.Clear;

  FDConnection1.Params.Add('LockingMode=Normal');
  FDConnection1.Params.Add('JournalMode=WAL');
  FDConnection1.Params.Add('DateTimeFormat=DateTime');
  FDConnection1.Params.Add('OpenMode=ReadWrite');
  FDConnection1.Params.Add('LockingMode=Normal');

  FDConnection1.Params.Add('DriverID=SQLite');
  FDConnection1.LoginPrompt := False;
  FDConnection1.BeforeConnect := FDConnection1BeforeConnect
end;

procedure Tdm_local.FDConnection1BeforeConnect(Sender: TObject);
var
  ofile: string;

begin
{$IF DEFINED(iOS) or DEFINED(ANDROID)}
  ofile := TPath.Combine(TPath.GetDocumentsPath, _bancodados);

  FDConnection1.Params.Values['Database'] := ofile;

{$ELSE}
  FDConnection1.Params.Values['Database'] := 'D:\WORK\Nagram_old\db\' + _bancodados;
{$ENDIF}
end;

end.

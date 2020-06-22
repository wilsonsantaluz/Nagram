unit nagram.rest.datamodule.base;

interface

uses
  System.SysUtils,

  // FIREDAC
  FireDAC.Stan.ExprFuncs,
  FireDAC.Phys.SQLiteDef,
  FireDAC.Stan.Intf,
  FireDAC.Stan.Option,
  FireDAC.Stan.Error,
  FireDAC.UI.Intf,
  FireDAC.Phys.Intf,
  FireDAC.Stan.Def, FireDAC.Stan.Pool,
  FireDAC.Stan.Async,
  FireDAC.Phys,
  FireDAC.Phys.ODBC,
  inifiles,
  // FireDAC.VCLUI.Wait,
  FireDAC.Stan.Param,
  FireDAC.DatS,
  FireDAC.DApt.Intf,
  FireDAC.DApt,
  FireDAC.Comp.DataSet,
  FireDAC.Comp.Client,
  FireDAC.Phys.SQLite,
  FireDAC.Phys.MSSQL,
  FireDAC.Phys.MSSQLDef,

  System.JSON,
  Datasnap.Provider,
  {FIREDAC---------------------------------------------------------------}

  System.Classes, FireDAC.Phys.PG, FireDAC.Phys.PGDef, FireDAC.ConsoleUI.Wait,
  Data.DB;

type
  TBaseData = class(TDataModule)
    FDConnection1: TFDConnection;
    procedure DataModuleCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  BaseData: TBaseData;

implementation

{%CLASSGROUP 'System.Classes.TPersistent'}
{$R *.dfm}

procedure TBaseData.DataModuleCreate(Sender: TObject);

var
  oParams: TStrings;
  otxtFile: TIniFile;
  vsenhaERP: string;
  vuserERP: string;
  vserverERP: string;
  vbancoERP: string;
  vPortERP: string;
  ofile: string;
begin
  try
    oParams := TStringList.Create;;
    ofile := ExtractFilePath(GetModuleName(HInstance)) + 'configdb.txt';
    if not FileExists(ofile) then
      raise Exception.Create('configdb.txt  not found');
    otxtFile := TIniFile.Create(ofile);

    vPortERP := otxtFile.ReadString('DBCONNECTION', 'PORT', '55432');
    vserverERP := otxtFile.ReadString('DBCONNECTION', 'HOST', '');
    vuserERP := otxtFile.ReadString('DBCONNECTION', 'USER', '');
    vsenhaERP := otxtFile.ReadString('DBCONNECTION', 'PASSWORD', '');
    vbancoERP := otxtFile.ReadString('DBCONNECTION', 'DATABASE', '');

    oParams.clear;
    oParams.add('Server=' + vserverERP);
    oParams.add('Port=' + vPortERP);
    oParams.add('Database=' + vbancoERP);
    oParams.add('User_Name=' + vuserERP);
    oParams.add('POOL_MaximumItems=50');
    oParams.add('POOL_MinimumItems=4');
    oParams.add('Password=' + vsenhaERP);
    oParams.add('Pooled=True');
    oParams.add('CharacterSet=UTF8');
    //oParams.add('POOL_CleanupTimeout=10000');
   // oParams.add('POOL_ExpireTimeout=10000');
    oParams.add('ApplicationName=NagramRestApi');
{$IFDEF MSWINDOWS}
    oParams.add('DriverId=PG');
{$ELSE}
    oParams.add('DriverID=ODBC');
    oParams.add('ODBCDriver=PostgreSQL');

{$ENDIF}
    try
      FDManager.AddConnectionDef('NAGRAM_CNT', 'PG', oParams);
    except
    end;
  finally
    FreeAndNil(otxtFile);
    FreeAndNil(oParams);
  end;
end;

end.

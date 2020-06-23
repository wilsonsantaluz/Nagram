unit nagram.datamodule;

interface

uses
  System.SysUtils,
  nagram.android.util,
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
    procedure Fdconnetion1AfterConnect(Sender: TObject);
    procedure DataModuleCreate(Sender: TObject);
    procedure DataModuleDestroy(Sender: TObject);

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
  FDConnection1.BeforeConnect := FDConnection1BeforeConnect;
  FDConnection1.AfterConnect := Fdconnetion1AfterConnect;
end;

procedure Tdm_local.DataModuleDestroy(Sender: TObject);
begin
  if Assigned(FDConnection1) then
  begin
    FDConnection1.CloneConnection;
    FDConnection1.Close
  end;
end;

procedure Tdm_local.FDConnection1BeforeConnect(Sender: TObject);
var
  ofile: string;
begin
{$IF DEFINED(iOS) or DEFINED(ANDROID)}
  ofile := TPath.Combine(TPath.GetDocumentsPath, _bancodados);

  FDConnection1.Params.Values['Database'] := ofile;

{$ELSE}
  FDConnection1.Params.Values['Database'] := 'D:\WORK\Nagram_old\db\' +
    _bancodados;
{$ENDIF}
end;

procedure Tdm_local.Fdconnetion1AfterConnect(Sender: TObject);
var
  qry: TFDQuery;
begin
  try
    qry := TFDQuery.Create(Nil);
    qry.Connection := FDConnection1;
    try
      qry.SQL.Add('SELECT  sql from  sqlite_master');
      qry.SQL.Add(' WHERE  ');
      qry.SQL.Add('   type =''table'' ');
      qry.SQL.Add('    AND     name  =''insta_local_option''');
      qry.SQL.Add('    AND sql like ''%insta_local_option_maxinthour%''');
      qry.Open();
      if qry.RecordCount = 0 then
      begin
        FDConnection1.ExecSQL
          ('  ALTER TABLE insta_local_option ADD  insta_local_option_maxinthour INTEGER  ');
      end;
      qry.Close;
      qry.SQL.Clear;
      qry.SQL.Add('SELECT  sql from  sqlite_master');
      qry.SQL.Add(' WHERE  ');
      qry.SQL.Add('   type =''table'' ');
      qry.SQL.Add('    AND     name  =''person''');
      qry.SQL.Add('    AND sql like ''%"person_adress"	VARCHAR(255)%''');
      qry.Open();
      if qry.RecordCount > 0 then
      begin
        FDConnection1.ExecSQL('  ALTER TABLE person RENAME TO person_old;  ');

        FDConnection1.ExecSQL
          (' CREATE TABLE "person" (                              ' + #13#10 +
          '	"person_id"	INTEGER,                                ' + #13#10 +
          '	"person_name"	VARCHAR(250) DEFAULT NULL,            ' + #13#10 +
          '	"person_type"	INTEGER DEFAULT NULL,                 ' + #13#10 +
          '	"person_date"	DATETIME DEFAULT NULL,                ' + #13#10 +
          '	"person_password"	VARCHAR(50) DEFAULT NULL,         ' + #13#10 +
          '	"person_login"	CHAR(20) DEFAULT NULL,              ' + #13#10 +
          '	"person_insta_user"	CHAR(50) DEFAULT NULL,          ' + #13#10 +
          '	"person_insta_password"	CHAR(50) DEFAULT NULL,      ' + #13#10 +
          '	"person_mail"	VARCHAR(255) DEFAULT NULL,            ' + #13#10 +
          '	"person_ip"	VARCHAR(50) DEFAULT NULL,               ' + #13#10 +
          '	"person_country"	VARCHAR(50) DEFAULT NULL,         ' + #13#10 +
          '	"person_fone"	VARCHAR(50) DEFAULT NULL,             ' + #13#10 +
          '	"person_age"	INTEGER DEFAULT NULL,                 ' + #13#10 +
          '	"person_adress"	TEXT DEFAULT NULL,                  ' + #13#10 +
          '	"person_uuid"	TEXT,                                 ' + #13#10 +
          '	"person_initial_latitude"	NUMERIC,                  ' + #13#10 +
          '	"person_initial_longitude"	NUMERIC,                ' + #13#10 +
          '	"person_last_latitude"	NUMERIC,                    ' + #13#10 +
          '	"person_last_longitude"	NUMERIC,                    ' + #13#10 +
          '	"person_last_alive"	DATETIME,                       ' + #13#10 +
          '	"person_expire_date"	DATETIME,                     ' + #13#10 +
          '	"person_license_type"	INTEGER,                      ' + #13#10 +
          '	PRIMARY KEY("person_id")                            ' + #13#10 +
          '     )  ');

        FDConnection1.ExecSQL(' INSERT INTO person select * from  person_old ');
      end;

    finally
      qry.Close;
      FreeAndNil(qry);
    end;
  except
  ON E:exception do
  begin
    Tutil.gravalog('[TDATAMODULE] E164'+E.Message);
  end;
  end;

end;

end.

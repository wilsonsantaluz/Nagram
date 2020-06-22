unit nagram.rest.dao.person;

interface

uses
  System.SysUtils,
  System.Classes,
  nagram.rest.util,
  Rtti,
  Data.DB,
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
  variants,
  Datasnap.Provider,
  nagram.rest.model.person,
  nagram.rest.dao.base,
  {FIREDAC---------------------------------------------------------------}

  Datasnap.DBClient;

type
  TMyfieldType = class
    kind: Integer;
    fieldname: string;
  end;

type
  TDaoperson = class(TDaobase)
  private
    { Private declarations }
    Fperson: Tperson;

    procedure setsqlInsert();
    procedure setsqlSelect;
    procedure setsqlUpdate();

  public
    { Public declarations }

    function getperson(value: string): string;
    function insertPerson(value: string): string;
    function deletePerson(value: string): string;
    function updatePerson(value: string): string;
    constructor create; Override;
    destructor destroy; Override;
  end;

implementation

{ TDaoperson }

constructor TDaoperson.create;
Var
  ctx: TRttiContext;
begin

  Fperson := Tperson.create;
  ctx := TRttiContext.create;
  ObjType := ctx.GetType(Fperson.ClassInfo);
  inherited;
end;

{ ----------------------------------------------------------------------------- }
destructor TDaoperson.destroy;
begin
  inherited;
  try
    if Assigned(Fperson) then
      FreeAndNil(Fperson);
  except
  end;
end;

{ ------------------------------------------------------------------------------ }
function TDaoperson.updatePerson(value: string): string;
begin
  try
    jsonOb := TJSONObject.ParseJSONValue(value) as TJSONObject;
    if not Assigned(jsonOb.FindValue('person_uuid')) then
      raise Exception.create('person_uuid is required!');
    try
      setsqlUpdate();
      parseJsonToUpdate;
      Qry.SQL.add('WHERE');
      Qry.SQL.add('  person_uuid = ' +
        QuotedStr(jsonOb.FindValue('person_uuid').value));
      setparamtype;
      setqryparam();
      if DebugHook > 0 then
        Qry.SQL.SaveToFile('c:\updaperson.sql');
      Qry.ExecSQL;
      result := '{"codretorno":"200","msgretorno":"PERSON Successfull changed"}';

    finally
      Qry.Close;
    end;
  except
    on e: Exception do
    begin
      result := processError(e.Message);
    end;
  end;
end;
{ ------------------------------------------------------------------------------ }

function TDaoperson.insertPerson(value: string): string;

begin
  try
    jsonOb := TJSONObject.ParseJSONValue(value) as TJSONObject;
    if not Assigned(jsonOb.FindValue('person_name')) then
      raise Exception.create('Name is required!');
    if not Assigned(jsonOb.FindValue('person_type')) then
      raise Exception.create('Type is reguired!');
    if not Assigned(jsonOb.FindValue('person_login')) then
      raise Exception.create('Login  is reguired!');
    if not Assigned(jsonOb.FindValue('person_password')) then
      raise Exception.create('Login password  is reguired!');

    try
      with Qry.SQL do
      begin
        add('SELECT person_uuid from person where person_login =' +
          QuotedStr(jsonOb.FindValue('person_login').value));
        Qry.Open();
        if Qry.RecordCount > 0 then
          raise Exception.create('Login ja cadastrado');
        clear;
      end;
      setsqlInsert();
      setparamtype();
      setqryparam;
      Qry.Open;
      with TJSONObject.create do
      begin
        AddPair('codretorno', '200');
        AddPair('inserted', Qry.Fields[0].AsString);
        AddPair('msgretorno', 'PERSON Successfull added');
        result := ToString;

      end;
    finally

    end;
  except
    on e: Exception do
    begin
      result := processError(e.Message);
    end;
  end;
end;
{ ----------------------------------------------------------------------------- }
function TDaoperson.deletePerson(value: string): string;

begin
  try
    jsonOb := TJSONObject.ParseJSONValue(value) as TJSONObject;
    if not Assigned(jsonOb.FindValue('person_uuid')) then
      raise Exception.create('UUID is required!');
    try

      with Qry.SQL do
      begin
        add('  DELETE FROM PERSON');
        add('  WHERE   ');
        add('     person_uuid =   ' +QuotedStr(  jsonOb.Values['person_uuid'].value));
      end;
      Qry.ExecSQL;
      if Qry.RowsAffected > 0 then
        result := '{"codretorno":"200","msgretorno":"Person sucessfull removed"}'
      else
        result := '{"codretorno":"400","msgretorno":"UUID  ' +
          jsonOb.FindValue('person_uuid').value + ' Not found"}';
    finally
      Qry.Close;

    end;
  except
    on e: Exception do
    begin
      result := processError(e.Message);
    end;
  end;
end;
{ ----------------------------------------------------------------------------- }

function TDaoperson.getperson(value: string): string;
var
  cds: TClientDataSet;
  prv: TDataSetProvider;

begin
  try
    jsonOb := TJSONObject.ParseJSONValue(value) as TJSONObject;
    cds := TClientDataSet.create(nil);
    prv := TDataSetProvider.create(Nil);

    try
      setsqlSelect();
      Qry.SQL.add('WHERE PERSON_UUID IS NOT NULl  ');
      if Assigned(jsonOb.FindValue('custom_where')) then
      begin
        Qry.SQL.add(' AND (' + jsonOb.FindValue('custom_where').value + ')');
      end
      else
      begin
        if Assigned(jsonOb) then
        begin
          parseJsonToWhere;
        end;
      end;
      prv.DataSet := Qry;
      cds.SetProvider(prv);
      if DebugHook > 0 then
        Qry.SQL.SaveToFile('c:\consulta.txt');
      cds.Open;
      result := makeJason(cds);
    finally
      cds.Close;
      FreeAndNil(cds);
      FreeAndNil(prv);
    end;
  except
    on e: Exception do
    begin
      result := processError(e.Message);
    end;
  end;;
end;

{ ------------------------------------------------------------------------------ }
procedure TDaoperson.setsqlInsert();
begin
  with Qry.SQL do
  begin
    clear;
    add(' INSERT INTO                                      ');
    add(' person                                           ');
    add(' (                                                ');
    add('   person_name,                                   ');
    add('   person_type,                                   ');
    add('   person_date,                                   ');
    add('   person_password,                               ');
    add('   person_login,                                  ');
    add('   person_insta_user,                             ');
    add('   person_insta_password,                         ');
    add('   person_mail,                                   ');
    add('   person_ip,                                     ');
    add('   person_country,                                ');
    add('   person_fone,                                   ');
    add('   person_age,                                    ');
    add('   person_adress,                                 ');
    add('   person_initial_latitude,                       ');
    add('   person_initial_longitude,                      ');
    add('   person_last_latitude,                          ');
    add('   person_last_longitude,                         ');
    add('   person_last_alive,                             ');
    add('   person_expire_date,                            ');
    add('   person_license_type,                           ');
    add('   person_date_birth                             ');
    add(' )                                                ');
    add(' VALUES (                                         ');

    add('   :person_name,                                  ');
    add('   :person_type,                                  ');
    add('   :person_date,                                  ');
    add('   :person_password,                              ');
    add('   :person_login,                                 ');
    add('   :person_insta_user,                            ');
    add('   :person_insta_password,                        ');
    add('   :person_mail,                                  ');
    add('   :person_ip,                                    ');
    add('   :person_country,                               ');
    add('   :person_fone,                                  ');
    add('   :person_age,                                   ');
    add('   :person_adress,                                ');
    add('   :person_initial_latitude,                      ');
    add('   :person_initial_longitude,                     ');
    add('   :person_last_latitude,                         ');
    add('   :person_last_longitude,                        ');
    add('   :person_last_alive,                            ');
    add('   :person_expire_date,                           ');
    add('   :person_license_type,                          ');
    add('   :person_date_birth                             ');
    add(' ) RETURNING cast( person_uuid  as varchar ) as person_uuid ;');

  end;
end;

procedure TDaoperson.setsqlSelect;
begin
  with Qry.SQL do
  begin
    clear;
    add('SELECT                                       ');
    add(' cast(person_uuid as varchar(40)) as person_uuid, ');
    add('  person_name,                                ');
    add('  person_type,                                ');
    add('  person_date,                                ');
    add('  person_password,                            ');
    add('  person_login,                               ');
    add('  person_insta_user,                          ');
    add('  person_insta_password,                      ');
    add('  person_mail,                                ');
    add('  person_ip,                                  ');
    add('  person_country,                             ');
    add('  person_fone,                                ');
    add('  person_age,                                 ');
    add('  person_adress,                              ');
    add('  person_initial_latitude,                    ');
    add('  person_initial_longitude,                   ');
    add('  person_last_latitude,                       ');
    add('  person_last_longitude,                      ');
    add('  person_last_alive,                          ');
    add('  person_expire_date,                         ');
    add('  person_license_type,                        ');
    add('  person_date_birth                           ');
    add('FROM                                          ');
    add('person                                        ');
  end;
end;

{ ----------------------------------------------------------------------------- }
procedure TDaoperson.setsqlUpdate();
begin
  with Qry.SQL do
  begin
    clear;
    add('UPDATE PERSON SET       ');
  end;

end;

end.

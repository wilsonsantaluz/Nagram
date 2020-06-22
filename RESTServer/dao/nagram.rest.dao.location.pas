unit nagram.rest.dao.location;

interface

uses
  System.SysUtils,
  System.Classes,
  nagram.rest.util,
  nagram.rest.dao.base,
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
  nagram.rest.model.personlocation,
  {FIREDAC---------------------------------------------------------------}

  Datasnap.DBClient;

type
  TMyfieldType = class
    kind: Integer;
    fieldname: string;
  end;

type
  TDaopersonlocation = class(TDaobase)

  private
    { Private declarations }
    Fpersonlocation: Tpersonlocation;

    procedure setsqlInsert();
    procedure setsqlSelect;
    procedure setsqlUpdate;

  public
    { Public declarations }

    function getpersonlocation(value: string): string;
    function insertpersonlocation(value: string): string;
    function deletepersonlocation(value: string): string;
    function updatepersonlocation(value: string): string;
    constructor create; override;
    destructor destroy; override;
  end;

implementation

{ TDaopersonlocation }

destructor TDaopersonlocation.destroy;

begin
  inherited;
  try
    if Assigned(Fpersonlocation) then
      FreeAndNil(Fpersonlocation);
  except
  end;
end;

{ ----------------------------------------------------------------------------- }
constructor TDaopersonlocation.create;
var
  ctx: TRttiContext;
begin

  Fpersonlocation := Tpersonlocation.create;
  ctx := TRttiContext.create;
  ObjType := ctx.GetType(Fpersonlocation.ClassInfo);
  inherited;
end;
{ ----------------------------------------------------------------------------- }

function TDaopersonlocation.insertpersonlocation(value: string): string;
var
  personuuid: string;
  jsa: TJSONArray;
begin
  try
    JsonOb := TJSONObject.ParseJSONValue(value) as TJSONObject;
    setsqlInsert();
    Qry.Open;
    with TJSONObject.create do
    begin
      Qry.First;
      jsa := TJSONArray.create;
      while not Qry.Eof do
      begin
        jsa.add(Qry.Fields[0].AsString);
        Qry.Next;
      end;
      AddPair('codretorno', '200');
      AddPair('inserted', jsa);
      AddPair('msgretorno', 'person Device Successfull added');
      result := ToString;
    end;
  except
    on e: Exception do
    begin
      result := processError(e.Message);
    end;
  end;
end;

{ ------------------------------------------------------------------------------ }
function TDaopersonlocation.getpersonlocation(value: string): string;
var
  cds: TClientDataSet;
  prv: TDataSetProvider;

begin
  try
    JsonOb := TJSONObject.ParseJSONValue(value) as TJSONObject;
    cds := TClientDataSet.create(nil);
    prv := TDataSetProvider.create(Nil);
    try
      setsqlSelect();
      Qry.SQL.add('WHERE person_location_date IS NOT NULl  ');
      if Assigned(JsonOb.FindValue('custom_where')) then
      begin
        Qry.SQL.add(' AND (' + JsonOb.FindValue('custom_where').value + ')');
      end
      else
      begin
        if Assigned(JsonOb) then
        begin
          parseJsonToWhere;
        end;
      end;
      if DebugHook > 0 then
        Qry.SQL.SaveToFile('c:\personlocationselect.sql');
      prv.DataSet := Qry;
      cds.SetProvider(prv);
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
function TDaopersonlocation.updatepersonlocation(value: string): string;

begin
  try
    JsonOb := TJSONObject.ParseJSONValue(value) as TJSONObject;
    if not Assigned(JsonOb.FindValue('person_location_date')) then
      raise Exception.create('person_location_date is required!');

      if not Assigned(JsonOb.FindValue('person_location_person_uuid')) then
      raise Exception.create('person_location_person_uuid is required!');
    try
      setsqlUpdate();
      parseJsonToUpdate;
      Qry.SQL.add('WHERE');
      Qry.SQL.add(' person_location_date  = ' +
        QuotedStr(JsonOb.FindValue('person_location_date').value));

      Qry.SQL.add(' and  person_location_person_uuid  = ' +
        QuotedStr(JsonOb.FindValue(' person_location_person_uuid').value));
      setparamtype;
      setqryparam;

      Qry.ExecSQL;
      result := '{"codretorno":"200","msgretorno":"person location Successfull changed"}';
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
function TDaopersonlocation.deletepersonlocation(value: string): string;
begin
  try
    JsonOb := TJSONObject.ParseJSONValue(value) as TJSONObject;
    if not Assigned(JsonOb.FindValue('person_location_date')) then
      raise Exception.create('person_location_date is required!');

     if not Assigned(JsonOb.FindValue('person_location_person_uuid')) then
      raise Exception.create('person_location_person_uuid is required!');
    try
      with Qry.SQL do
      begin
        add('  DELETE FROM person_location');
        add('  WHERE   ');
        add('    person_location_date =   ' + quotedstr(JsonOb.Values
          ['person_location_date'].value));
       add('    and person_location_person_uuid =   ' +quotedstr(  JsonOb.Values
         ['person_location_person_uuid'].value));

      end;
      Qry.ExecSQL;
      if Qry.RowsAffected > 0 then
        result := '{"codretorno":"200","msgretorno":"person location sucessfull removed"}'
      else
        result := '{"codretorno":"400","msgretorno":"id  ' +
          JsonOb.FindValue('person_location_date').value + ' Not found"}';
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

procedure TDaopersonlocation.setsqlSelect();
begin
  with Qry.SQL do
  begin
    clear;
    add(' SELECT                      ');
    add('  person_location_date,       ');
    add('  person_location_longitude,   ');
    add('  person_location_latidude,   ');
    add('  person_location_device_id,   ');
    add(' cast(  person_location_person_uuid as varcar(40)as person_location_person_uuid  ');
    add('FROM                       ');
    add('  person_location   ');

  end;
end;

procedure TDaopersonlocation.setsqlUpdate;
begin
  with Qry.SQL do
  begin
    clear;
    add('UPDATE person_location SET       ');
  end;
end;

{ ------------------------------------------------------------------------------ }
procedure TDaopersonlocation.setsqlInsert;
var
  j: Integer;
  oarray: TJSONArray;
  oelement: TJSONValue;
  jso: TJSONObject;
  nameparam: string;
  value: string;
  sep: string;
  osep: string;
  isbulk: boolean;
begin
  isbulk := false;
  if Assigned(JsonOb.FindValue('data')) then
  begin
    oarray := JsonOb.FindValue('data') as TJSONArray;
    jso := TJSONObject(oarray.Items[0]);
    isbulk := true;
  end
  else
    jso := JsonOb;
  Qry.SQL.clear;
  Qry.SQL.add(' INSERT INTO                          ');
  Qry.SQL.add('  person_location                       ');
  Qry.SQL.add('(                                     ');
  for j := 0 to jso.count - 1 do
  begin
    nameparam := jso.Pairs[j].JsonString.value;
    if Fields.IndexOf(nameparam) > -1 then
    begin
      Qry.SQL.add(sep + nameparam);
      sep := ' , ';
    end;
  end;
  Qry.SQL.add(')                                      ');
  Qry.SQL.add('VALUES                                 ');
  /// -----------inserir itens
  if isbulk then
  begin
    for oelement in oarray do
    begin
      sep := '';
      Qry.SQL.add(osep + '(  ');
      prepareInsertValues(TJSONObject(oelement));
      Qry.SQL.add(') ');
      osep := ' , ';
    end;
  end
  else
  begin
    Qry.SQL.add('(  ');
    prepareInsertValues(jso);
    Qry.SQL.add(') ');
  end;
  Qry.SQL.add(' RETURNING  person_location_date ;         ');
  if DebugHook > 0 then
    Qry.SQL.SaveToFile('c:\multipleinsertpersonlocation.txt');
end;

{ ----------------------------------------------------------------------------- }

end.

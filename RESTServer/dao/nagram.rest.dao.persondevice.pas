unit nagram.rest.dao.persondevice;

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
  nagram.rest.model.persondevice,
  {FIREDAC---------------------------------------------------------------}

  Datasnap.DBClient;

type
  TMyfieldType = class
    kind: Integer;
    fieldname: string;
  end;

type
  TDaopersonDevice = class(TDaobase)

  private
    { Private declarations }
    FpersonDevice: TpersonDevice;

    procedure setsqlInsert();
    procedure setsqlSelect;
    procedure setsqlUpdate;

  public
    { Public declarations }

    function getpersonDevice(value: string): string;
    function insertpersonDevice(value: string): string;
    function deletepersonDevice(value: string): string;
    function updatepersonDevice(value: string): string;
    constructor create; override;
    destructor destroy; override;
  end;

implementation

{ TDaopersonDevice }

destructor TDaopersonDevice.destroy;

begin
  inherited;
  try
    if Assigned(FpersonDevice) then
      FreeAndNil(FpersonDevice);
  except
  end;
end;

{ ----------------------------------------------------------------------------- }
constructor TDaopersonDevice.create;
var
  ctx: TRttiContext;
begin

  FpersonDevice := TpersonDevice.create;
  ctx := TRttiContext.create;
  ObjType := ctx.GetType(FpersonDevice.ClassInfo);
  inherited;
end;
{ ----------------------------------------------------------------------------- }

function TDaopersonDevice.insertpersonDevice(value: string): string;
var

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
function TDaopersonDevice.getpersonDevice(value: string): string;
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
      Qry.SQL.add('WHERE person_device_id IS NOT NULl  ');
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
        Qry.SQL.SaveToFile('c:\personDeviceselect.sql');
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
function TDaopersonDevice.updatepersonDevice(value: string): string;

begin
  try
    JsonOb := TJSONObject.ParseJSONValue(value) as TJSONObject;
    if not Assigned(JsonOb.FindValue('person_device_id')) then
      raise Exception.create('person_device_id is required!');
    try
      setsqlUpdate();
      parseJsonToUpdate;
      Qry.SQL.add('WHERE');
      Qry.SQL.add(' person_device_id  = ' +
        QuotedStr(JsonOb.FindValue('person_device_id').value));
      setparamtype;

      setqryparam;
      if DebugHook  > 0 then
        qry.SQL.SaveToFile('c:\updatedeviceinfo.txt');
      Qry.ExecSQL;
      result := '{"codretorno":"200","msgretorno":"personDevice Successfull changed"}';
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
function TDaopersonDevice.deletepersonDevice(value: string): string;
begin
  try
    JsonOb := TJSONObject.ParseJSONValue(value) as TJSONObject;
    if not Assigned(JsonOb.FindValue('person_device_id')) then
      raise Exception.create('person_device_id is required!');
    try
      with Qry.SQL do
      begin
        add('  DELETE FROM person_device');
        add('  WHERE   ');
        add('    person_device_id =   ' +QuotedStr(  JsonOb.Values
          ['person_device_id'].value));
      end;
      Qry.ExecSQL;
      if Qry.RowsAffected > 0 then
        result := '{"codretorno":"200","msgretorno":"person Device sucessfull removed"}'
      else
        result := '{"codretorno":"400","msgretorno":"id  ' +
          JsonOb.FindValue('person_device_id').value + ' Not found"}';
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

procedure TDaopersonDevice.setsqlSelect();
begin
  with Qry.SQL do
  begin
    clear;
    add(' SELECT                              ');
    add('  person_device_id,                  ');
    add(' cast( person_device_person_uuid as varchar(40)) as person_device_person_uuid ,');
    add('  person_device_block,               ');
    add('  person_device_os,                  ');
    add('  person_device_ip,                  ');
    add('  person_device_operator,            ');
    add('  person_device_macaddress,          ');
    add('  person_device_language,            ');
    add('  person_device_architecture,        ');
    add('  person_device_platform,            ');
    add('  person_device_platformver,         ');
    add('  persondevice_mobiledatatype        ');
    add('FROM                                 ');
    add('  person_device                      ');

  end;
end;

procedure TDaopersonDevice.setsqlUpdate;
begin
  with Qry.SQL do
  begin
    clear;
    add('UPDATE person_device SET       ');
  end;
end;

{ ------------------------------------------------------------------------------ }
procedure TDaopersonDevice.setsqlInsert;
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
  Qry.SQL.add('  person_device                       ');
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
  Qry.SQL.add
    (' RETURNING  person_device_id ;          ');
  if DebugHook > 0 then
    Qry.SQL.SaveToFile('c:\multipleinsertpersonDevice.txt');
end;

{ ----------------------------------------------------------------------------- }

end.

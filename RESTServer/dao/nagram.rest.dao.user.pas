unit nagram.rest.dao.user;

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
  nagram.rest.model.user,
  {FIREDAC---------------------------------------------------------------}

  Datasnap.DBClient;

type
  TMyfieldType = class
    kind: Integer;
    fieldname: string;
  end;

type
  TDaouser = class(TDaobase)

  private
    { Private declarations }
    Fuser: Tuser;

    procedure setsqlInsert();
    procedure setsqlSelect;
    procedure setsqlUpdate;

  public
    { Public declarations }

    function getuser(value: string): string;
    function insertuser(value: string): string;
    function deleteuser(value: string): string;
    function updateuser(value: string): string;
    constructor create; override;
    destructor destroy; override;
  end;

implementation

{ TDaouser }

destructor TDaouser.destroy;

begin
  inherited;
  try
    if Assigned(Fuser) then
      FreeAndNil(Fuser);
  except
  end;
end;

{ ----------------------------------------------------------------------------- }
constructor TDaouser.create;
var
  ctx: TRttiContext;
begin

  Fuser := Tuser.create;
  ctx := TRttiContext.create;
  ObjType := ctx.GetType(Fuser.ClassInfo);
  inherited;
end;
{ ----------------------------------------------------------------------------- }

function TDaouser.insertuser(value: string): string;
var
  personuuid: string;
  jsa: TJSONArray;
begin
  try
    JsonOb := TJSONObject.ParseJSONValue(value) as TJSONObject;

    setsqlInsert;
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
      AddPair('msgretorno', 'User Successfull added');
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
function TDaouser.getuser(value: string): string;
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
      Qry.SQL.add('WHERE insta_user_uuid IS NOT NULl  ');
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
        Qry.SQL.SaveToFile('c:\userselect.sql');
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
function TDaouser.updateuser(value: string): string;

begin
  try
    JsonOb := TJSONObject.ParseJSONValue(value) as TJSONObject;
    if not Assigned(JsonOb.FindValue('insta_user_uuid')) then
      raise Exception.create('uuid is required!');
    try
      setsqlUpdate();
      parseJsonToUpdate;
      Qry.SQL.add('WHERE');
      Qry.SQL.add(' cast( insta_user_uuid as varchar(40))  = ' +
        QuotedStr(JsonOb.FindValue('insta_user_uuid').value));
      setparamtype;
      Qry.ParamByName('insta_user_uuid').DataType := ftGuid;
      setqryparam;

      Qry.ExecSQL;
      result := '{"codretorno":"200","msgretorno":"user Successfull changed"}';
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
function TDaouser.deleteuser(value: string): string;
begin
  try
    JsonOb := TJSONObject.ParseJSONValue(value) as TJSONObject;
    if not Assigned(JsonOb.FindValue('insta_user_uuid')) then
      raise Exception.create('insta_user_uuid is required!');
    try
      with Qry.SQL do
      begin
        add('  DELETE FROM insta_user');
        add('  WHERE   ');
        add('     insta_user_uuid =   ' +QuotedStr( JsonOb.Values
          ['insta_user_uuid'].value));
      end;
      Qry.ExecSQL;
      if Qry.RowsAffected > 0 then
        result := '{"codretorno":"200","msgretorno":"user sucessfull removed"}'
      else
        result := '{"codretorno":"400","msgretorno":"UUID  ' +
          JsonOb.FindValue('insta_user_uuid').value + ' Not found"}';
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

procedure TDaouser.setsqlSelect();
begin
  with Qry.SQL do
  begin
    clear;
    add('SELECT                         ');
    add('  cast( insta_user_uuid as varchar(40)) as insta_user_uuid  ,    ');
    add('  insta_user_name,             ');
    add('  insta_user_date,             ');
    add('  insta_user_last_visit,       ');
    add('  insta_user_date_follow,      ');
    add('  insta_user_bio,              ');
    add('  insta_user_following,        ');
    add('  insta_user_followings,       ');
    add('  insta_user_posts,            ');
    add('  cast(insta_user_person_uuid as varchar(40)) as insta_user_person_uuid,  ');
    add('  insta_user_preferences       ');
    add('FROM                           ');
    add(' insta_user                    ');
  end;
end;

procedure TDaouser.setsqlUpdate;
begin
  with Qry.SQL do
  begin
    clear;
    add('UPDATE user SET       ');
  end;
end;

{ ------------------------------------------------------------------------------ }
procedure TDaouser.setsqlInsert();
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
  Qry.SQL.add(' INSERT INTO                           ');
  Qry.SQL.add('  insta_user                           ');
  Qry.SQL.add('(                                      ');
  for j := 0 to jso.count - 1 do
  begin
    nameparam := jso.Pairs[j].JsonString.value;
    if (Fields.IndexOf(nameparam) > -1) then
    begin
      case TMyfieldType(Fields.Objects[Fields.IndexOf(nameparam)]).kind of
        1, 2, 3, 4, 5:
          begin
            Qry.SQL.add(sep + nameparam);
            sep := ' , ';
          end;
      end;
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
    (' RETURNING cast( insta_user_uuid as varchar(40)) as insta_user_uuid;          ');
  if DebugHook > 0 then
    Qry.SQL.SaveToFile('c:\multipleinsertUser.txt');
end;

{ ----------------------------------------------------------------------------- }

end.

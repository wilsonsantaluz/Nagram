unit nagram.rest.dao.hashtag;

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
  nagram.rest.model.hashtag,
  {FIREDAC---------------------------------------------------------------}

  Datasnap.DBClient;

type
  TMyfieldType = class
    kind: Integer;
    fieldname: string;
  end;

type
  TDaoHashTag = class(TDaobase)

  private
    { Private declarations }
    Fhashtag: ThashTag;

    procedure setsqlInsert();
    procedure setsqlSelect;
    procedure setsqlUpdate;

  public
    { Public declarations }

    function gethashtag(value: string): string;
    function inserthashtag(value: string): string;
    function deletehashtag(value: string): string;
    function updatehashtag(value: string): string;
    constructor create; override;
    destructor destroy; override;
  end;

implementation

{ TDaohashtag }

destructor TDaoHashTag.destroy;

begin
  inherited;
  try
    if Assigned(Fhashtag) then
      FreeAndNil(Fhashtag);
  except
  end;
end;

{ ----------------------------------------------------------------------------- }
constructor TDaoHashTag.create;
var
  ctx: TRttiContext;
begin

  Fhashtag := ThashTag.create;
  ctx := TRttiContext.create;
  ObjType := ctx.GetType(Fhashtag.ClassInfo);
  inherited;
end;
{ ----------------------------------------------------------------------------- }

function TDaoHashTag.inserthashtag(value: string): string;
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
      AddPair('msgretorno', 'hashtag Successfull added');
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
function TDaoHashTag.gethashtag(value: string): string;
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
      Qry.SQL.add('WHERE insta_hashtag_uuid IS NOT NULl  ');
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
        Qry.SQL.SaveToFile('c:\hashtagselect.sql');
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
function TDaoHashTag.updatehashtag(value: string): string;

begin
  try
    JsonOb := TJSONObject.ParseJSONValue(value) as TJSONObject;
    if not Assigned(JsonOb.FindValue('insta_hashtag_uuid')) then
      raise Exception.create('insta_hashtag_uuid is required!');
    try
      setsqlUpdate();
      parseJsonToUpdate;
      Qry.SQL.add('WHERE');
      Qry.SQL.add(' cast( insta_hashtag_uuid as varchar(40))  = ' +
        QuotedStr(JsonOb.FindValue('insta_hashtag_uuid').value));
      setparamtype;
      Qry.ParamByName('insta_hashtag_uuid').DataType := ftGuid;
      setqryparam;

      Qry.ExecSQL;
      result := '{"codretorno":"200","msgretorno":"hashtag Successfull changed"}';
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
function TDaoHashTag.deletehashtag(value: string): string;
begin
  try
    JsonOb := TJSONObject.ParseJSONValue(value) as TJSONObject;
    if not Assigned(JsonOb.FindValue('insta_hashtag_uuid')) then
      raise Exception.create('insta_hashtag_uuid is required!');
    try
      with Qry.SQL do
      begin
        add('  DELETE FROM insta_hashtag');
        add('  WHERE   ');
        add('     insta_hashtag_uuid =   ' +QuotedStr(  JsonOb.Values
          ['insta_hashtag_uuid'].value));
      end;
      Qry.ExecSQL;
      if Qry.RowsAffected > 0 then
        result := '{"codretorno":"200","msgretorno":"hashtag sucessfull removed"}'
      else
        result := '{"codretorno":"400","msgretorno":"UUID  ' +
          JsonOb.FindValue('insta_hashtag_uuid').value + ' Not found"}';
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

procedure TDaoHashTag.setsqlSelect();
begin
  with Qry.SQL do
  begin
    clear;
    add('SELECT                         ');
    add('  cast( insta_hashtag_uuid as varchar(40)) as insta_hashtag_uuid  ,    ');
    add('  insta_hashtag_name,             ');
    add('  insta_hashtag_date,             ');
    add('  cast(insta_hashtag_person_uuid as varchar(40)) as insta_hashtag_person_uuid  ');

    add('FROM                           ');
    add(' insta_hashtag                    ');
  end;
end;

procedure TDaoHashTag.setsqlUpdate;
begin
  with Qry.SQL do
  begin
    clear;
    add('UPDATE hashtag SET       ');
  end;
end;

{ ------------------------------------------------------------------------------ }
procedure TDaoHashTag.setsqlInsert;
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
  Qry.SQL.add('  insta_hashtag                       ');
  Qry.SQL.add('(                                     ');
  for j := 0 to jso.count - 1 do
  begin
    nameparam := jso.Pairs[j].JsonString.value;
    if Fields.IndexOf(nameparam) > -1 then
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
    (' RETURNING cast( insta_hashtag_uuid as varchar(40)) as insta_hashtag_uuid;          ');
  if DebugHook > 0 then
    Qry.SQL.SaveToFile('c:\multipleinserthashtag.txt');
end;

{ ----------------------------------------------------------------------------- }

end.

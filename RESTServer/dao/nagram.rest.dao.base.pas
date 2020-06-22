unit nagram.rest.dao.base;

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
  {FIREDAC---------------------------------------------------------------}

  Datasnap.DBClient;

type
  TMyfieldType = class
    kind: Integer;
    fieldname: string;
  end;

type
  TDaobase = class

  private
    { Private declarations }

    FjsonOb: TJSONObject;
    FQry: TFDQuery;
    Fcon: TFDConnection;
    FFields: TStringList;
    FobjType: TRttiType;
  public
    { Public declarations }

    constructor create; virtual;
    destructor Destroy; override;
    procedure setsqlInsert(); dynamic; abstract;
    procedure setsqlSelect; dynamic; Abstract;
    procedure setsqlUpdate; dynamic; Abstract;
    procedure setparamtype();
    procedure setqryparam();
    procedure parseJsonToUpdate();
    procedure parseJsonToWhere();
    procedure setFields();
    procedure prepareInsertValues(jso: TJSONObject);
    function processError(Error: string): string;
    function preparevalue(nameparam, svalue: string): string;
    property Fields: TStringList read FFields Write FFields;
    property Qry: TFDQuery read FQry Write FQry;
    property JsonOb: TJSONObject read FjsonOb Write FjsonOb;
    property ObjType: TRttiType read FobjType write FobjType;

  end;

implementation

{ TDaoperson }

{ ---------------------------------------------------------------------------- }
procedure setConnection(pcon: TFDConnection);
begin
  pcon.ConnectionDefName := 'NAGRAM_CNT';
end;

{ ----------------------------------------------------------------------------- }
constructor TDaobase.create;
begin
  FQry := TFDQuery.create(Nil);
  Fcon := TFDConnection.create(Nil);
  setConnection(Fcon);
  FQry.Connection := Fcon;
  setFields();
end;

{ ----------------------------------------------------------------------------- }
destructor TDaobase.destroy;
var
  i: Integer;
begin
  Fcon.close;
  FQry.Close;
  FreeAndNil(FQry);
  FreeAndNil(FFields);
  try
    if Assigned(FjsonOb) then
      FreeAndNil(FjsonOb);
  except
  end;
  FreeAndNil(fcon);
end;

{ ----------------------------------------------------------------------------- }
procedure TDaobase.setFields;
var

  Prop: TRttiProperty;
  otkind: Integer;
  otype: TMyfieldType;
begin
  Fields := TStringList.create;
  try
    for Prop in FobjType.GetProperties do
    begin
      if (UpperCase(Prop.name) <> UpperCase('RefCount')) and
        (UpperCase(Prop.name) <> UpperCase('Disposed')) then
      begin
        otkind := getKindType(Prop.PropertyType.ToString);
        otype := TMyfieldType.create;
        otype.kind := otkind;
        otype.fieldname := LowerCase(Prop.name);
        Fields.AddObject(LowerCase(Prop.name), otype);

      end;
    end;
  finally
  end;
end;

{ ----------------------------------------------------------------------------- }
procedure TDaobase.setqryparam();
var
  i: Integer;
  ovalue: string;
begin
  for i := 0 to FQry.ParamCount - 1 do
  begin
    if Assigned(FjsonOb.FindValue(LowerCase(FQry.Params[i].name))) then
    begin
      ovalue := FjsonOb.FindValue(LowerCase(FQry.Params[i].name)).Value;
      case FQry.Params[i].DataType of
        ftInteger:
          FQry.Params[i].AsInteger := valInt(ovalue);
        ftFloat:
          FQry.Params[i].Asfloat := Valfloat(ovalue);

        ftDateTime:
          FQry.Params[i].AsDateTime := Valdate(ovalue);
        ftGuid:
          begin
            if pos('{', ovalue) <= 0 then
              ovalue := '{' + ovalue + '}';

            FQry.Params[i].DataType := ftstring;
            FQry.Params[i].AsString := QuotedStr(ovalue);
          end;
      else

        FQry.Params[i].AsString := ovalue;
      end;
    end;
  end;
end;

{ ----------------------------------------------------------------------------- }
procedure TDaobase.setparamtype();
var
  i: Integer;
  procedure defineparam(oparam: string; otype: Integer);
  begin
    if Assigned(FQry.FindParam(oparam)) then
    begin
      case otype of
        1:
          FQry.ParamByName(oparam).DataType := ftDateTime;
        2:
          FQry.ParamByName(oparam).DataType := ftInteger;
        3:
          FQry.ParamByName(oparam).DataType := ftFloat;
        4:
          FQry.ParamByName(oparam).DataType := ftstring;
        5:
          FQry.ParamByName(oparam).DataType := ftGuid;
      end;
    end;
  end;

begin
  for i := 0 to Fields.Count - 1 do
  begin
    defineparam(Fields[i], TMyfieldType(Fields.Objects[i]).kind);
  end;
end;

{ ----------------------------------------------------------------------------- }
procedure TDaobase.parseJsonToWhere();
var
  i: Integer;
  Value: string;
  nameparam: string;
  function preparevalue(svalue: string): string;
  begin
    case TMyfieldType(Fields.Objects[Fields.IndexOf(nameparam)]).kind of
      1, 2, 3, 4:
        result := nameparam + ' = ' + QuotedStr(svalue);
      5:
        result := 'cast (' + nameparam + ' as varchar)' + ' = ' +
          QuotedStr(svalue);

    end;
  end;

begin
  for i := 0 to FjsonOb.Count - 1 do
  begin
    nameparam := FjsonOb.Pairs[i].JsonString.Value;
    if Fields.IndexOf(nameparam) > -1 then
    begin
      Value := FjsonOb.Values[nameparam].Value;
      FQry.SQL.add('AND ' + preparevalue(Value));
    end
    else
    begin
      Value := 'Null';
    end;
  end;
end;

{ ----------------------------------------------------------------------------- }
function TDaobase.processError(Error: string): string;
begin
  with TJSONObject.create do
  begin
    AddPair('codretorno', '500');
    AddPair('msgretorno', Error);
    result := ToString;
  end;
end;

{ ----------------------------------------------------------------------------- }
procedure TDaobase.parseJsonToUpdate();
var
  i: Integer;
  Value: string;
  nameparam: string;
  sep: string;
begin
  sep:='';
  for i := 0 to FjsonOb.Count - 1 do
  begin
    nameparam := FjsonOb.Pairs[i].JsonString.Value;
    // não adicionar parametros do tipo uuid

    if (Fields.IndexOf(nameparam) > -1) and
      (TMyfieldType(Fields.Objects[Fields.IndexOf(nameparam)]).kind <> 5) then
    begin
      Value := FjsonOb.Values[nameparam].Value;
      FQry.SQL.add(' ' + sep + nameparam + '= :' + nameparam);
      sep := ' , ';

    end;
  end;
end;

{ ----------------------------------------------------------------------------- }

procedure TDaobase.prepareInsertValues(jso: TJSONObject);
var
  j: Integer;
  Value: string;
  nameparam: string;
  sep: string;
  oindex: Integer;
begin
  sep := '';
  for j := 0 to jso.Count - 1 do
  begin
    nameparam := jso.Pairs[j].JsonString.Value;
    oindex := FFields.IndexOf(nameparam);
    if oindex > -1 then
    begin

      case TMyfieldType(FFields.Objects[oindex]).kind of
        1, 2, 3, 4, 5:
          begin
            Value := preparevalue(nameparam, jso.Values[nameparam].Value);
            FQry.SQL.add(' ' + sep + Value);
            sep := ',';
          end;
      end;
    end;
  end;
end;

function TDaobase.preparevalue(nameparam, svalue: string): string;
begin
  case TMyfieldType(FFields.Objects[FFields.IndexOf(nameparam)]).kind of
    1, 2, 3, 4, 5:
      result := QuotedStr(svalue);

  end;
end;

end.

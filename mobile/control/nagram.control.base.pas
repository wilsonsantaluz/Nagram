unit nagram.control.base;

interface

uses

  System.SysUtils,
  System.classes,
  nagram.android.util,
  nagram.service.persistdata,
  FMX.Forms,
  Rtti,
  System.JSON

    ;

Type
  TBaseController = class
  private
    FclassRtti: TRttiType;
    FbaseClass: TClass;
  public
    property  classRtti: TRttiType read  FclassRtti write FclassRtti;
    property baseClass: TClass read FbaseClass write FbaseClass;
    function classToJson(): TJSONObject;
    procedure jsonToClass(value: string);
    constructor create;
  end;



implementation
    uses
      nagram.resource.master;
{ TpersonController }
{ ---------------------------------------------------------------------------- }
constructor TBaseController.create;
begin

end;

{ ---------------------------------------------------------------------------- }
procedure TBaseController.jsonToClass(value: string);
var
  ctx: TRttiContext;
  Prop: TRttiProperty;
  ojson: TJSONObject;
  arrayelements: TJSONArray;
  oname: string;
  ovalue: string;
  arrayelement: TJSONValue;
  otkind: integer;
begin
  ojson := TJSONObject.ParseJSONValue(value) as TJSONObject;
  arrayelements := (ojson.GetValue('result') as TJSONArray)
    .Items[0].FindValue('data') as TJSONArray;
  try
    if assigned(arrayelements) then
    begin
      ctx := TRttiContext.create;
      for arrayelement in arrayelements do
      begin
        for Prop in classRtti.GetProperties do
        begin
          if assigned(arrayelement.FindValue(oname)) then
          begin
            otkind := Tutil.getKindType(Prop.PropertyType.ToString);
            ovalue := arrayelement.FindValue(oname).value;
            case otkind of
              1:
                Prop.SetValue(FbaseClass, TValue.From(Tutil.Valdate(ovalue)));
              2:
                Prop.SetValue(FbaseClass, TValue.From(Tutil.valint(ovalue)));
              3:
                Prop.SetValue(FbaseClass, TValue.From(Tutil.Valfloat(ovalue)));
              4:
                Prop.SetValue(FbaseClass, TValue.From(ovalue));
            end;
          end;
        end;
      end;
    end;
  finally

  end;
end;

{ ---------------------------------------------------------------------------- }
function TBaseController.classToJson(): TJSONObject;
var
  ctx: TRttiContext;
  objType: TRttiType;
  Prop: TRttiProperty;
  oname: string;
  ovalue: string;
  otkind: integer;
  avalues: TJSONArray;
  invalidkind: Boolean;
begin
  ctx := TRttiContext.create;
  Result := TJSONObject.create;

  try
    for Prop in classRtti.GetProperties do
    begin
      if (UpperCase(Prop.name) <> UpperCase('RefCount')) and
        (UpperCase(Prop.name) <> UpperCase('Disposed')) then
      begin
        oname := Prop.name;
        invalidkind := false;
        otkind := Tutil.getKindType(Prop.PropertyType.ToString);
        case otkind of
          1:
            ovalue := FormatDateTime('YYYY-MM-DD hh:mm:ss',
              (Prop.GetValue(FbaseClass).AsType<TDateTime>));
          2:
            ovalue := IntToStr((Prop.GetValue(FbaseClass).AsInteger));
          3:
            ovalue := FloatToJson(Prop.GetValue(FbaseClass).AsType<Double>);
          4:
            ovalue := (Prop.GetValue(FbaseClass).AsString);
        else
          invalidkind := true;
        end;

        if not invalidkind then
          Result.AddPair(TJSONPair.create(oname, ovalue));
      end;
    end;

  finally

  end;
end;

end.


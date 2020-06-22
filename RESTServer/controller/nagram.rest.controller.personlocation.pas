unit nagram.rest.controller.personlocation;

interface

uses
  System.SysUtils,
  System.Classes,
  Datasnap.DSServer,
  System.JSON,
  IdHashMessageDigest,
  nagram.rest.dao.personlocation,
  Datasnap.DSAuth;

type
{$METHODINFO ON}
  TPersonLocation = class(TComponent)
  private
    Fdao:TDaopersonlocation;
    { Private declarations }
  public
    { Public declarations }

    function personlocation(Value: string): TJSONObject;
    function updatepersonlocation(Value: string): TJSONObject;
    function acceptpersonlocation(Value: string): TJSONObject;
    function cancelpersonlocation(Value: string): TJSONObject;

  end;
{$METHODINFO OFF}

implementation

uses System.StrUtils;


function  TPersonLocation.accepTPersonLocation(Value: string): TJSONObject;
begin
 try
 Fdao:=TDaopersonlocation.create;
  result := TJSONObject.ParseJSONValue(Fdao.insertpersonlocation (Value))
    as TJSONObject;
 finally
   FreeAndNil(Fdao);
 end;
end;

function TPersonLocation.cancelpersonlocation(Value: string): TJSONObject;
begin
try
   Fdao:=TDaopersonlocation.create;
  result := TJSONObject.ParseJSONValue(Fdao.deletepersonlocation(Value))
    as TJSONObject;
finally
     FreeAndNil(Fdao);
end;
end;


function TPersonLocation.personlocation(Value: string): TJSONObject;
begin
  try
    Fdao:=TDaopersonlocation.create;
  result := TJSONObject.ParseJSONValue(Fdao.getpersonlocation(Value))
    as TJSONObject;
  finally
     FreeAndNil(Fdao);
  end;
end;

function TPersonLocation.updatepersonlocation(Value: string): TJSONObject;
begin
  try
   Fdao:=TDaopersonlocation.create;
  result := TJSONObject.ParseJSONValue( Fdao.updatepersonlocation(Value))
    as TJSONObject;
  finally
      FreeAndNil(Fdao);
  end;
end;


end.

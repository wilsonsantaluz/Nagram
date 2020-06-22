unit nagram.rest.controller.person;

interface

uses
  System.SysUtils,
  System.Classes,
  Datasnap.DSServer,
  System.JSON,
  IdHashMessageDigest,
  nagram.rest.dao.person,
  Datasnap.DSAuth;

type
{$METHODINFO ON}
  Tperson = class(TComponent)
  private
    Fdao: TDaoperson;
    { Private declarations }
  public
    { Public declarations }

    function person(Value: string): TJSONObject;
    function updateperson(Value: string): TJSONObject;
    function acceptperson(Value: string): TJSONObject;
    function cancelperson(Value: string): TJSONObject;

  end;

{$METHODINFO OFF}

implementation

uses System.StrUtils;

function Tperson.acceptperson(Value: string): TJSONObject;

begin
  try
    Fdao := TDaoperson.create;
    result := TJSONObject.ParseJSONValue(Fdao.insertPerson(Value))
      as TJSONObject;
  finally
    FreeAndNil(Fdao);
  end;
end;

function Tperson.cancelperson(Value: string): TJSONObject;
begin
  try
    Fdao := TDaoperson.create;
    result := TJSONObject.ParseJSONValue(Fdao.deletePerson(Value))
      as TJSONObject;
  finally
    FreeAndNil(Fdao);
  end;
end;

function Tperson.person(Value: string): TJSONObject;
begin
  try
    Fdao := TDaoperson.create;
    result := TJSONObject.ParseJSONValue(Fdao.getperson(Value)) as TJSONObject;
  finally
    FreeAndNil(Fdao);
  end;
end;

function Tperson.updateperson(Value: string): TJSONObject;
begin
  try
    Fdao := TDaoperson.create;
    result := TJSONObject.ParseJSONValue(Fdao.updateperson(Value))
      as TJSONObject;;
  finally
    FreeAndNil(Fdao);
  end;
end;

end.

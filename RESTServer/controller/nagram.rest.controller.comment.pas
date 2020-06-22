unit nagram.rest.controller.comment;

interface

uses
  System.SysUtils,
  System.Classes,
  Datasnap.DSServer,
  System.JSON,
  IdHashMessageDigest,
  nagram.rest.dao.comment,

  Datasnap.DSAuth;

type
{$METHODINFO ON}
  Tcomment = class(TComponent)
  private
    Fdao: TDaocomment;
    { Private declarations }
  public
    { Public declarations }

    function comment(Value: string): TJSONObject;
    function updatecomment(Value: string): TJSONObject;
    function acceptcomment(Value: string): TJSONObject;
    function cancelcomment(Value: string): TJSONObject;

  end;
{$METHODINFO OFF}

implementation

uses System.StrUtils;

function Tcomment.acceptcomment(Value: string): TJSONObject;
begin
  try
    Fdao := TDaocomment.create;
    result := TJSONObject.ParseJSONValue(Fdao.insertcomment(Value))
      as TJSONObject;
  finally
    FreeAndNil(Fdao);
  end;
end;

function Tcomment.cancelcomment(Value: string): TJSONObject;
begin
  try
    Fdao := TDaocomment.create;
    result := TJSONObject.ParseJSONValue(Fdao.deletecomment(Value))
      as TJSONObject;;
  finally
    FreeAndNil(Fdao);
  end;
end;

function Tcomment.comment(Value: string): TJSONObject;
begin
  try
    Fdao := TDaocomment.create;
    result := TJSONObject.ParseJSONValue(Fdao.getcomment(Value)) as TJSONObject;
  finally
    FreeAndNil(Fdao);
  end;
end;

function Tcomment.updatecomment(Value: string): TJSONObject;
begin
  try
    Fdao := TDaocomment.create;
    result := TJSONObject.ParseJSONValue(Fdao.updatecomment(Value))
      as TJSONObject;
  finally
    FreeAndNil(Fdao);
  end;
end;

end.

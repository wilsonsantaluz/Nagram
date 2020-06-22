unit nagram.rest.controller.user;

interface

uses
  System.SysUtils,
  System.Classes,
  Datasnap.DSServer,
  System.JSON,
  IdHashMessageDigest,
  nagram.rest.dao.user,
  Datasnap.DSAuth;

type
{$METHODINFO ON}
  Tuser = class(TComponent)
  private
    { Private declarations }

    Fdao: TDaouser;
  public
    { Public declarations }

    function user(Value: string): TJSONObject;
    function updateuser(Value: string): TJSONObject;
    function acceptuser(Value: string): TJSONObject;
    function canceluser(Value: string): TJSONObject;
  end;

{$METHODINFO OFF}

implementation

uses System.StrUtils;

function Tuser.acceptuser(Value: string): TJSONObject;
begin
  Try
    Fdao := TDaouser.create;
    result := TJSONObject.ParseJSONValue(Fdao.insertuser(Value)) as TJSONObject;
  Finally
     FreeAndNil(Fdao);
  End;
end;

function Tuser.canceluser(Value: string): TJSONObject;
begin
  try
    Fdao := TDaouser.create;
    result := TJSONObject.ParseJSONValue(Fdao.deleteuser(Value))
      as TJSONObject;
  finally
    FreeAndNil(Fdao);
  end;
end;

function Tuser.updateuser(Value: string): TJSONObject;
begin
  try
    Fdao := TDaouser.create;
    result := TJSONObject.ParseJSONValue(Fdao.updateuser(Value))
      as TJSONObject;
  finally
    FreeAndNil(Fdao);
  end;
end;

function Tuser.user(Value: string): TJSONObject;
begin
  try
    Fdao := TDaouser.create;
    result := TJSONObject.ParseJSONValue(Fdao.getuser(Value)) as TJSONObject;
  finally
    FreeAndNil(Fdao);
  end;
end;

end.

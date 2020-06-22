unit nagram.rest.controller.action;

interface

uses
  System.SysUtils,
  System.Classes,
  Datasnap.DSServer,
  Datasnap.DSSession,
  System.JSON,
  IdHashMessageDigest,

  nagram.rest.dao.action,

  Datasnap.DSAuth;

type
{$METHODINFO ON}
  Taction = class(TComponent)
  private
    Fdao: TDaoAction;
    { Private declarations }
  public
    { Public declarations }

    function action(Value: string): TJSONObject;
    function updateaction(Value: string): TJSONObject;
    function acceptaction(Value: string): TJSONObject;
    function cancelaction(Value: string): TJSONObject;

  end;

{$METHODINFO OFF}

implementation

uses System.StrUtils;

function Taction.acceptaction(Value: string): TJSONObject;
var
  session: TDSSession;
begin
  try
    Fdao := TDaoAction.create;
    result := TJSONObject.ParseJSONValue(Fdao.insertaction(Value))
      as TJSONObject;

  finally
    FreeAndNil(Fdao);
  end;
end;

function Taction.action(Value: string): TJSONObject;
begin
  try
    Fdao := TDaoAction.create;
    result := TJSONObject.ParseJSONValue(Fdao.getaction(Value)) as TJSONObject;
  finally
    FreeAndNil(Fdao);
  end;
end;

function Taction.cancelaction(Value: string): TJSONObject;
begin
  try
    Fdao := TDaoAction.create;
    result := TJSONObject.ParseJSONValue(Fdao.deleteaction(Value))
      as TJSONObject;;
  finally
    FreeAndNil(Fdao);
  end;
end;

function Taction.updateaction(Value: string): TJSONObject;
begin
  try
    Fdao := TDaoAction.create;
    result := TJSONObject.ParseJSONValue(Fdao.updateaction(Value))
      as TJSONObject;

  finally
    FreeAndNil(Fdao);
  end;
end;

end.

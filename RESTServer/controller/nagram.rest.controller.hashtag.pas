unit nagram.rest.controller.hashtag;

interface

uses
  System.SysUtils,
  System.Classes,
  Datasnap.DSServer,
  System.JSON,
  IdHashMessageDigest,
  nagram.rest.dao.hashtag,
  Datasnap.DSAuth;

type
{$METHODINFO ON}
  Thashtag = class(TComponent)
  private
    Fdao:TDaohashtag;
    { Private declarations }
  public
    { Public declarations }

    function hashtag(Value: string): TJSONObject;
    function updatehashtag(Value: string): TJSONObject;
    function accepthashtag(Value: string): TJSONObject;
    function cancelhashtag(Value: string): TJSONObject;

  end;
{$METHODINFO OFF}

implementation

uses System.StrUtils;


function  Thashtag.accepthashtag(Value: string): TJSONObject;
begin
 try
 Fdao:=TDaohashtag.create;
  result := TJSONObject.ParseJSONValue(Fdao.inserthashtag(Value))
    as TJSONObject;
 finally
   FreeAndNil(Fdao);
 end;
end;

function Thashtag.cancelhashtag(Value: string): TJSONObject;
begin
try
   Fdao:=TDaohashtag.create;
  result := TJSONObject.ParseJSONValue(Fdao.deletehashtag(Value))
    as TJSONObject;
finally
     FreeAndNil(Fdao);
end;
end;


function Thashtag.hashtag(Value: string): TJSONObject;
begin
  try
    Fdao:=TDaohashtag.create;
  result := TJSONObject.ParseJSONValue(Fdao.gethashtag(Value))
    as TJSONObject;
  finally
     FreeAndNil(Fdao);
  end;
end;

function Thashtag.updatehashtag(Value: string): TJSONObject;
begin
  try
   Fdao:=TDaohashtag.create;
  result := TJSONObject.ParseJSONValue( Fdao.updatehashtag(Value))
    as TJSONObject;
  finally
      FreeAndNil(Fdao);
  end;
end;


end.

unit nagram.rest.methods;

interface

uses
  System.SysUtils,
  Datasnap.DSSession,
  System.Classes,
  Datasnap.DSServer,
  System.JSON,
  IdHashMessageDigest,


  Datasnap.DSAuth;

type
{$METHODINFO ON}
  TNagramRest = class(TComponent)
  private
    { Private declarations }
  public
    { Public declarations }
    function EchoString(Value: string): string;
    function ReverseString(Value: string): string;
    function getuseersection: string;
   constructor create(owner:TComponent);override;

  end;

{$METHODINFO OFF}
 var
  FactualUser:string;
implementation

uses System.StrUtils;


function TNagramRest.getuseersection: string;
var
  Session: TDSSession;
begin
  result:='';
  try
    Session := TDSSessionManager.GetThreadSession;
    if Assigned(Session) then
      Result := Session.GetData('username') + ':' + Session.Username;
  finally

  end;
end;

constructor TNagramRest.create(owner: TComponent);
begin
  inherited;
  FactualUser:=getuseersection;
end;

function TNagramRest.EchoString(Value: string): string;
begin
  result := Value;
end;



function TNagramRest.ReverseString(Value: string): string;
begin
  result := System.StrUtils.ReverseString(Value);
end;

end.

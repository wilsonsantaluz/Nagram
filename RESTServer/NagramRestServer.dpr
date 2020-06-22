program NagramRestServer;
{$APPTYPE CONSOLE}
{$R *.dres}

uses
  System.SysUtils,
  System.Types,
  IPPeerServer,
  IPPeerAPI,
  IdHTTPWebBrokerBridge,
  Web.WebReq,
  Web.WebBroker,
  Datasnap.DSSession,
  nagram.rest.controller.person in 'controller\nagram.rest.controller.person.pas',
  nagram.rest.servercontainer in 'nagram.rest.servercontainer.pas' {NgServerContainer: TDataModule},
  nagram.rest.datacontainer in 'nagram.rest.datacontainer.pas' {WebModule1: TWebModule},
  nagram.rest.constants in 'nagram.rest.constants.pas',
  nagram.rest.dao.person in 'dao\nagram.rest.dao.person.pas' {DataModule1: TDataModule},
  nagram.rest.datamodule.base in 'datamodule\nagram.rest.datamodule.base.pas' {BaseData: TDataModule},
  nagram.rest.util in 'lib\nagram.rest.util.pas',
  nagram.rest.dao.action in 'dao\nagram.rest.dao.action.pas',
  nagram.rest.dao.user in 'dao\nagram.rest.dao.user.pas',
  nagram.rest.controller.hashtag in 'controller\nagram.rest.controller.hashtag.pas',
  nagram.rest.controller.user in 'controller\nagram.rest.controller.user.pas',
  nagram.rest.controller.action in 'controller\nagram.rest.controller.action.pas',
  nagram.rest.dao.hashtag in 'dao\nagram.rest.dao.hashtag.pas',
  nagram.rest.controller.comment in 'controller\nagram.rest.controller.comment.pas',
  nagram.rest.dao.comment in 'dao\nagram.rest.dao.comment.pas',
  nagram.rest.model.person in 'model\nagram.rest.model.person.pas',
  nagram.rest.model.user in 'model\nagram.rest.model.user.pas',
  nagram.rest.dao.base in 'dao\nagram.rest.dao.base.pas',
  nagram.rest.model.hashtag in 'model\nagram.rest.model.hashtag.pas',
  nagram.rest.model.comment in 'model\nagram.rest.model.comment.pas',
  nagram.rest.model.action in 'model\nagram.rest.model.action.pas',
  nagram.rest.dao.persondevice in 'dao\nagram.rest.dao.persondevice.pas',
  nagram.rest.model.persondevice in 'model\nagram.rest.model.persondevice.pas',
  nagram.rest.dao.personlocation in 'dao\nagram.rest.dao.personlocation.pas',
  nagram.rest.model.personlocation in 'model\nagram.rest.model.personlocation.pas',
  nagram.rest.controller.personlocation in 'controller\nagram.rest.controller.personlocation.pas',
  nagram.rest.controller.persondevice in 'controller\nagram.rest.controller.persondevice.pas';

{$R *.res}

procedure TerminateThreads;
begin
  if TDSSessionManager.Instance <> nil then
    TDSSessionManager.Instance.TerminateAllSessions;
end;

function BindPort(APort: Integer): Boolean;
var
  LTestServer: IIPTestServer;
begin
  Result := True;
  try
    LTestServer := PeerFactory.CreatePeer('', IIPTestServer) as IIPTestServer;
    LTestServer.TestOpenPort(APort, nil);
  except
    Result := False;
  end;
end;

function CheckPort(APort: Integer): Integer;
begin
  if BindPort(APort) then
    Result := APort
  else
    Result := 0;
end;

procedure SetPort(const AServer: TIdHTTPWebBrokerBridge; APort: String);
begin
  if not AServer.Active then
  begin
    APort := APort.Replace(cCommandSetPort, '').Trim;
    if CheckPort(APort.ToInteger) > 0 then
    begin
      AServer.DefaultPort := APort.ToInteger;
      Writeln(Format(sPortSet, [APort]));
    end
    else
      Writeln(Format(sPortInUse, [APort]));
  end
  else
    Writeln(sServerRunning);
  Write(cArrow);
end;

procedure StartServer(const AServer: TIdHTTPWebBrokerBridge);
begin
  if not AServer.Active then
  begin
    if CheckPort(AServer.DefaultPort) > 0 then
    begin
      Writeln(Format(sStartingServer, [AServer.DefaultPort]));
      AServer.Bindings.Clear;
      AServer.Active := True;
    end
    else
      Writeln(Format(sPortInUse, [AServer.DefaultPort.ToString]));
  end
  else
    Writeln(sServerRunning);
  if not assigned(BaseData) then
  begin
    BaseData := TBaseData.Create(Application);
  end;

  Write(cArrow);
end;

procedure StopServer(const AServer: TIdHTTPWebBrokerBridge);
begin
  if AServer.Active then
  begin
    Writeln(sStoppingServer);
    TerminateThreads;
    AServer.Active := False;
    AServer.Bindings.Clear;
    Writeln(sServerStopped);
  end
  else
    Writeln(sServerNotRunning);
  Write(cArrow);
end;

procedure WriteCommands;
begin
  Writeln(sCommands);
  Write(cArrow);
end;

procedure WriteStatus(const AServer: TIdHTTPWebBrokerBridge);
begin
  Writeln(sIndyVersion + AServer.SessionList.Version);
  Writeln(sActive + AServer.Active.ToString(TUseBoolStrs.True));
  Writeln(sPort + AServer.DefaultPort.ToString);
  Writeln(sSessionID + AServer.SessionIDCookieName);
  Write(cArrow);
end;

procedure RunServer(APort: Integer);
var
  LServer: TIdHTTPWebBrokerBridge;
  LResponse: string;
begin
  WriteCommands;
  LServer := TIdHTTPWebBrokerBridge.Create(nil);
  try
    LServer.DefaultPort := APort;
    StartServer(LServer);
    while True do
    begin
      sleep(1);

    end;
    TerminateThreads();
  finally
    LServer.Free;
  end;
end;

begin
  try
    if WebRequestHandler <> nil then
      WebRequestHandler.WebModuleClass := WebModuleClass;
    RunServer(6466);
    // RunServer(8080);
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end

end.

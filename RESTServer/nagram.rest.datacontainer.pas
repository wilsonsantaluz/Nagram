unit nagram.rest.datacontainer;

interface

uses
  System.SysUtils,

  System.Classes,
  Web.HTTPApp,
  Datasnap.DSHTTPCommon,
  Datasnap.DSHTTPWebBroker,
  Datasnap.DSServer,
  System.ZLib,
  Web.WebFileDispatcher,
  Web.HTTPProd,
  Datasnap.DSAuth,
  Datasnap.DSProxyDispatcher,
  Datasnap.DSProxyJavaAndroid,
  Datasnap.DSProxyJavaBlackBerry,
  Datasnap.DSProxyObjectiveCiOS,
  Datasnap.DSProxyCsharpSilverlight,
  Datasnap.DSProxyFreePascal_iOS,
  Datasnap.DSProxyJavaScript,
  IPPeerServer,
  Datasnap.DSMetadata,
  Datasnap.DSServerMetadata,
  Datasnap.DSClientMetadata,
  Datasnap.DSCommonServer,
  Datasnap.DSHTTP, DbxCompressionFilter, Datasnap.DSTCPServerTransport;

type
  TWebModule1 = class(TWebModule)
    DSHTTPWebDispatcher1: TDSHTTPWebDispatcher;
    ServerFunctionInvoker: TPageProducer;
    ReverseString: TPageProducer;
    WebFileDispatcher1: TWebFileDispatcher;
    DSProxyGenerator1: TDSProxyGenerator;
    DSServerMetaDataProvider1: TDSServerMetaDataProvider;
    DSProxyDispatcher1: TDSProxyDispatcher;
    NagramTransp: TDSTCPServerTransport;
    procedure ServerFunctionInvokerHTMLTag(Sender: TObject; Tag: TTag;
      const TagString: string; TagParams: TStrings; var ReplaceText: string);
    procedure WebModuleDefaultAction(Sender: TObject; Request: TWebRequest;
      Response: TWebResponse; var Handled: Boolean);
    procedure WebModuleBeforeDispatch(Sender: TObject; Request: TWebRequest;
      Response: TWebResponse; var Handled: Boolean);
    procedure WebFileDispatcher1BeforeDispatch(Sender: TObject;
      const AFileName: string; Request: TWebRequest; Response: TWebResponse;
      var Handled: Boolean);
    procedure WebModuleCreate(Sender: TObject);
    procedure WebModuleAfterDispatch(Sender: TObject; Request: TWebRequest;
      Response: TWebResponse; var Handled: Boolean);
  private
    { Private declarations }
    FServerFunctionInvokerAction: TWebActionItem;
    function AllowServerFunctionInvoker: Boolean;
    function getuseersection: string;
  public
    { Public declarations }
  end;

var
  WebModuleClass: TComponentClass = TWebModule1;

implementation

{%CLASSGROUP 'System.Classes.TPersistent'}
{$R *.dfm}

uses
  nagram.rest.methods,
  nagram.rest.servercontainer, Web.WebReq;

function TWebModule1.getuseersection: string;

begin
  result := '';
  try
    // result:=  nagram.rest.methods.FactualUser
  finally

  end;
end;

procedure TWebModule1.ServerFunctionInvokerHTMLTag(Sender: TObject; Tag: TTag;
  const TagString: string; TagParams: TStrings; var ReplaceText: string);
begin

  if SameText(TagString, 'urlpath') then
    ReplaceText := string(Request.InternalScriptName)
  else if SameText(TagString, 'port') then
    ReplaceText := IntToStr(Request.ServerPort)
  else if SameText(TagString, 'host') then
    ReplaceText := string(Request.Host)
  else if SameText(TagString, 'classname') then
    ReplaceText := nagram.rest.methods.TNagramRest.ClassName
  else if SameText(TagString, 'loginrequired') then
    if DSHTTPWebDispatcher1.AuthenticationManager <> nil then
    begin
      IF getuseersection = '' Then
        ReplaceText := 'true'
      else
        ReplaceText := 'false'
    end
    else
      ReplaceText := 'false'
  else if SameText(TagString, 'serverfunctionsjs') then
    ReplaceText := string(Request.InternalScriptName) + '/js/serverfunctions.js'
  else if SameText(TagString, 'servertime') then
    ReplaceText := DateTimeToStr(Now)
  else if SameText(TagString, 'serverfunctioninvoker') then
    if AllowServerFunctionInvoker then
      ReplaceText := '<div><a href="' + string(Request.InternalScriptName) +
        '/ServerFunctionInvoker" target="_blank">Server Functions</a></div>'
    else
      ReplaceText := '';
end;

procedure TWebModule1.WebModuleDefaultAction(Sender: TObject;
  Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
begin
  if (Request.InternalPathInfo = '') or (Request.InternalPathInfo = '/') then
    Response.Content := ReverseString.Content
  else
    Response.SendRedirect(Request.InternalScriptName + '/');
end;

procedure TWebModule1.WebModuleAfterDispatch(Sender: TObject;
  Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
var
  srcbuf, destbuf: TBytes;
  str: string;
  s: string;

begin
  s := uppercase(Request.ContentEncoding);
  if  (Response.ContentType = 'application/json') and
    (Response.Content <> '') then
  begin
    str := Response.Content;
    srcbuf := BytesOf(str);
    ZCompress(srcbuf, destbuf, zcMax);
    Response.Content := '';
    Response.ContentStream := TMemoryStream.Create;
    Response.ContentEncoding := 'deflate';
    Response.ContentType := 'application/json';
    Response.ContentStream.WriteData(@(destbuf[0]), length(destbuf));
    Response.ContentLength := (length(destbuf));
    Response.ContentStream.Position := 0;

   { CompressStream := TZCompressionStream.Create(TargetStream,
      zcDefault, 15 + 16);
    TarStream := TTarWriter.Create(CompressStream);
    TarStream.AddStream(SourceStream1, SourceFilename1, Now);
    TarStream.AddString(SourceString2, SourceFilename2, Now);  }

  end;
end;

{ ----------------------------------------------------------------------------- }
procedure TWebModule1.WebModuleBeforeDispatch(Sender: TObject;
  Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);

begin
  if FServerFunctionInvokerAction <> nil then
    FServerFunctionInvokerAction.Enabled := AllowServerFunctionInvoker;

end;

function TWebModule1.AllowServerFunctionInvoker: Boolean;
begin
  result := true;
end;

procedure TWebModule1.WebFileDispatcher1BeforeDispatch(Sender: TObject;
  const AFileName: string; Request: TWebRequest; Response: TWebResponse;
  var Handled: Boolean);
var
  D1, D2: TDateTime;
begin
  Handled := False;
  if SameFileName(ExtractFileName(AFileName), 'serverfunctions.js') then
    if not FileExists(AFileName) or
      (FileAge(AFileName, D1) and FileAge(WebApplicationFileName, D2) and
      (D1 < D2)) then
    begin
      DSProxyGenerator1.TargetDirectory := ExtractFilePath(AFileName);
      DSProxyGenerator1.TargetUnitName := ExtractFileName(AFileName);
      DSProxyGenerator1.Write;
    end;
end;

procedure TWebModule1.WebModuleCreate(Sender: TObject);
begin
  FServerFunctionInvokerAction := ActionByName('ServerFunctionInvokerAction');
  DSServerMetaDataProvider1.Server := DSServer;
  DSHTTPWebDispatcher1.Server := DSServer;
  if DSServer.Started then
  begin
    DSHTTPWebDispatcher1.DbxContext := DSServer.DbxContext;
    DSHTTPWebDispatcher1.Start;
  end;
  DSHTTPWebDispatcher1.AuthenticationManager :=
    nagram.rest.servercontainer.DSAuthenticationManager;

end;

initialization

finalization

Web.WebReq.FreeWebModules;

end.

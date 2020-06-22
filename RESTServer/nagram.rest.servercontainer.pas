unit nagram.rest.servercontainer;

interface

uses System.SysUtils,
  System.Classes,
  Datasnap.DSServer,
  Datasnap.DSCommonServer,
  Datasnap.DSClientMetadata,
  Datasnap.DSHTTPServiceProxyDispatcher,
  Datasnap.DSProxyJavaAndroid,
  Datasnap.DSProxyJavaBlackBerry,
  Datasnap.DSProxyObjectiveCiOS,
  Datasnap.DSProxyCsharpSilverlight,
  Datasnap.DSProxyFreePascal_iOS,
  IPPeerServer,
  IPPeerAPI,
  nagram.rest.constants,
  Datasnap.DSSession,
  Datasnap.DSAuth, DbxCompressionFilter, Datasnap.DSTCPServerTransport;

type
  TNgServerContainer = class(TDataModule)
    NagramDSServer: TDSServer;
    NagramAuth: TDSAuthenticationManager;
    UserServerClass: TDSServerClass;
    HashTagsServerClass: TDSServerClass;
    PersonServerClass: TDSServerClass;
    ActionServerClass: TDSServerClass;
    CommentServerClas: TDSServerClass;
    MetodsServerClass: TDSServerClass;
    PersonLocation: TDSServerClass;
    PersonDevice: TDSServerClass;
    procedure UserServerClassGetClass(DSServerClass: TDSServerClass;
      var PersistentClass: TPersistentClass);
    procedure NagramAuthUserAuthorize(Sender: TObject;
      EventObject: TDSAuthorizeEventObject; var valid: Boolean);
    procedure NagramAuthUserAuthenticate(Sender: TObject;
      const Protocol, Context, User, Password: string; var valid: Boolean;
      UserRoles: TStrings);
    procedure HashTagsServerClassGetClass(DSServerClass: TDSServerClass;
      var PersistentClass: TPersistentClass);
    procedure ActionServerClassGetClass(DSServerClass: TDSServerClass;
      var PersistentClass: TPersistentClass);
    procedure CommentServerClasGetClass(DSServerClass: TDSServerClass;
      var PersistentClass: TPersistentClass);
    procedure MetodosServerClassGetClass(DSServerClass: TDSServerClass;
      var PersistentClass: TPersistentClass);
    procedure PersonServerClassGetClass(DSServerClass: TDSServerClass;
      var PersistentClass: TPersistentClass);
    procedure MetodsServerClassGetClass(DSServerClass: TDSServerClass;
      var PersistentClass: TPersistentClass);
    procedure PersonLocationGetClass(DSServerClass: TDSServerClass;
      var PersistentClass: TPersistentClass);
    procedure PersonDeviceGetClass(DSServerClass: TDSServerClass;
      var PersistentClass: TPersistentClass);
  private

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

  end;

function DSServer: TDSServer;

function GetActualUser: string;
function DSAuthenticationManager: TDSAuthenticationManager;

implementation

{%CLASSGROUP 'System.Classes.TPersistent'}
{$R *.dfm}

uses

  nagram.rest.controller.hashtag,
  nagram.rest.methods,
  nagram.rest.controller.action,
  nagram.rest.controller.person,
  nagram.rest.controller.comment,
  nagram.rest.controller.personlocation,
  nagram.rest.controller.persondevice,
  nagram.rest.controller.User

    ;

var
  FModule: TComponent;

  FDSServer: TDSServer;
  FactualUser: string;
  FDSAuthenticationManager: TDSAuthenticationManager;

function DSServer: TDSServer;
begin
  Result := FDSServer;
end;

function GetActualUser: string;
begin
  Result := FactualUser;
end;

function DSAuthenticationManager: TDSAuthenticationManager;
begin
  Result := FDSAuthenticationManager;
end;

procedure TNgServerContainer.ActionServerClassGetClass(DSServerClass
  : TDSServerClass; var PersistentClass: TPersistentClass);
begin
  PersistentClass := nagram.rest.controller.action.Taction;
end;

procedure TNgServerContainer.CommentServerClasGetClass(DSServerClass
  : TDSServerClass; var PersistentClass: TPersistentClass);
begin
  PersistentClass := nagram.rest.controller.comment.Tcomment;
end;

constructor TNgServerContainer.Create(AOwner: TComponent);
begin
  inherited;
  FDSServer := NagramDSServer;
  FDSAuthenticationManager := NagramAuth;

end;

destructor TNgServerContainer.Destroy;
begin
  inherited;
  FDSServer := nil;
  FDSAuthenticationManager := nil;
end;

procedure TNgServerContainer.UserServerClassGetClass(DSServerClass
  : TDSServerClass; var PersistentClass: TPersistentClass);
begin
  PersistentClass := nagram.rest.controller.User.Tuser;
end;

procedure TNgServerContainer.NagramAuthUserAuthenticate(Sender: TObject;
  const Protocol, Context, User, Password: string; var valid: Boolean;
  UserRoles: TStrings);
var
  session: TDSSession;
begin
  valid:=true;

  if UserRoles.Values['VALIDO'] = 'S' then
  begin
    valid := true;
  end
  else
  begin
    valid := (User = cMasterUser) and (Password = cTempPassword);
    if not valid then
      valid := (User = cMobileUser) and (Password = cTempPassword);
    if valid then
    begin
      UserRoles.Add('PASSWORD=' + Password);
      UserRoles.Add('USER=' + User);
      UserRoles.Add('ADMIN=FALSE');
      UserRoles.Add('VALIDO=S');

      session := TDSSessionManager.GetThreadSession;
      session.PutData('username', User);

    end;

  end;
end;

procedure TNgServerContainer.NagramAuthUserAuthorize(Sender: TObject;
  EventObject: TDSAuthorizeEventObject; var valid: Boolean);
begin
  { TODO : Authorize a user to execute a method.
    Use values from EventObject such as UserName, UserRoles, AuthorizedRoles and DeniedRoles.
    Use DSAuthenticationManager1.Roles to define Authorized and Denied roles
    for particular server methods. }
  valid := true;
end;

procedure TNgServerContainer.PersonDeviceGetClass(DSServerClass: TDSServerClass;
  var PersistentClass: TPersistentClass);
begin
     PersistentClass := nagram.rest.controller.persondevice.TPersondevice;
end;

procedure TNgServerContainer.PersonLocationGetClass(
  DSServerClass: TDSServerClass; var PersistentClass: TPersistentClass);
begin
   PersistentClass := nagram.rest.controller.personlocation.TPersonLocation;
end;

procedure TNgServerContainer.PersonServerClassGetClass(
  DSServerClass: TDSServerClass; var PersistentClass: TPersistentClass);
begin
   PersistentClass := nagram.rest.controller.person.Tperson;
end;

procedure TNgServerContainer.HashTagsServerClassGetClass(DSServerClass
  : TDSServerClass; var PersistentClass: TPersistentClass);
begin
  PersistentClass := nagram.rest.controller.hashtag.Thashtag;
end;

procedure TNgServerContainer.MetodosServerClassGetClass(
  DSServerClass: TDSServerClass; var PersistentClass: TPersistentClass);
begin
 // PersistentClass := nagram.rest.methods.TNagramRest;
end;

procedure TNgServerContainer.MetodsServerClassGetClass(
  DSServerClass: TDSServerClass; var PersistentClass: TPersistentClass);
begin
   PersistentClass := nagram.rest.methods.TNagramRest;
end;

initialization

FModule := TNgServerContainer.Create(nil);

finalization

FModule.Free;

end.

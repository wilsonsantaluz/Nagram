unit nagram.lib.getpermision;

interface

function HasPermission(const Permission: string): Boolean;
function checarpermisalocation: Boolean;

implementation

uses
  System.Permissions,
  FMX.DialogService.Async,
{$IF DEFINED(ANDROID)}
  FMX.Helpers.Android,
  Androidapi.Jni.Os,
  Androidapi.Jni.Support,

  Androidapi.Helpers,
  Androidapi.Jni.JavaTypes,
  Androidapi.Jni.GraphicsContentViewText,
{$ENDIF}
  System.SysUtils;

function HasPermission(const Permission: string): Boolean;
begin
{$IFDEF ANDROID}
  Result := TAndroidHelper.Context.checkCallingOrSelfPermission(

    StringToJString(Permission)) = TJPackageManager.JavaClass.
    PERMISSION_GRANTED;
{$ENDIF}
end;

function checarpermisalocation: Boolean;
var
  oresult: Boolean;
  Perms: TArray<string>;

begin
  Result := false;
{$IFDEF ANDROID}
  { PermissionsService.RequestPermissions
    ([JStringToString(TJManifest_permission.JavaClass.ACCESS_FINE_LOCATION)],
    procedure(const APermissions: TArray<string>;
    const AGrantResults: TArray<TPermissionStatus>)
    begin
    if (Length(AGrantResults) = 1) and
    (AGrantResults[0] = TPermissionStatus.Granted) then
    oresult := true
    else
    begin
    oresult := false;

    end;
    end); }
  SetLength(Perms, 2);
  Perms[0] := JStringToString(TJManifest_permission.JavaClass.GET_ACCOUNTS);
  Perms[1] := JStringToString
    (TJManifest_permission.JavaClass.ACCESS_FINE_LOCATION);

  PermissionsService.RequestPermissions(Perms,
    procedure(const APermissions: TArray<string>;
      const AGrantResults: TArray<TPermissionStatus>)
    begin
      if (Length(AGrantResults) = 1) and
        (AGrantResults[0] = TPermissionStatus.Granted) then
        oresult := true
      else
      begin
        oresult := false;

      end;
    end);

  Result := oresult;
{$ENDIF}
end;

end.

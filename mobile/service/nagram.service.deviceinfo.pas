unit nagram.service.deviceinfo;

interface

uses
  FMX.ZDeviceInfo,
  FMX.Forms,
  sysutils,
  nagram.service.persistdata,
  json;

type
  TNgDeviceInfo = class
  public
    function getInfo: TZDeviceInfo;
    procedure updateDeviceInfo;

  end;

var
  NgDeviceInfo: TNgDeviceInfo;

implementation

uses
  nagram.resource.master,
  nagram.control.person;
{ TNgDeviceInfo }

function TNgDeviceInfo.getInfo: TZDeviceInfo;
begin
  result := TZDeviceInfo.Create;
end;

procedure TNgDeviceInfo.updateDeviceInfo;
var
  ojson: TJSONObject;
  Fputdata: TPersistData;
  Fputdata2: TPersistData;
  sresult: string;
  oinfo: TZDeviceInfo;
Begin
  // PEGAR OS DADOS DA CLASSE E JOGAR NO JSON
  ojson := TJSONObject.Create;
  oinfo := TZDeviceInfo.Create;
  ojson.AddPair('person_device_id', oinfo.DeviceID);
  ojson.AddPair('person_device_person_uuid', GlobalPerson.person.person_uuid);
  ojson.AddPair('person_device_os', oinfo.Platform);
  ojson.AddPair('person_device_ip', oinfo.IPAddress);
  ojson.AddPair('person_device_operator', oinfo.MobileOperator);
  ojson.AddPair('person_device_macaddress', oinfo.MacAddress);
  ojson.AddPair('person_device_language', oinfo.LangID);
  ojson.AddPair(' person_device_architecture', oinfo.Architecture +' - '+oinfo.Architecture2);
  ojson.AddPair('person_device_platform', oinfo.Platform);
  ojson.AddPair('person_device_platformver', oinfo.PlatformVer);

  ojson.AddPair('person_device_mobiledatatype',
    inttostr(ord(oinfo.MobileDataType)));
  Fputdata := TPersistData.Create(true);
  Fputdata.Url := _rest_url_info;
  Fputdata.Param := ojson.ToString;
  Fputdata.FreeOnTerminate := true;
  Fputdata.Verb := 1;
  Fputdata.resume;
  Fputdata.FreeOnTerminate := true;
  Fputdata2 := TPersistData.Create(true);
  Fputdata2.Url := _rest_url_info;
  Fputdata2.Param := ojson.ToString;
  Fputdata2.Verb := 2;
  Fputdata2.FreeOnTerminate := true;
  Fputdata2.resume;

end;

initialization

NgDeviceInfo := TNgDeviceInfo.Create;

end.

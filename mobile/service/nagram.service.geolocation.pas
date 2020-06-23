unit nagram.service.geolocation;

interface

uses
  System.Sensors,

  System.SysUtils,
  System.Sensors.Components,
  System.Classes,
  System.json,
  System.Generics.Collections,
  System.RTLConsts

    ;

type
  TlocationInfo = class(TThread)
  private
    osensor: TLocationSensor;
    FGeocoder: TGeocoder;
    procedure OnGeocodeReverseEvent(const Address: TCivicAddress);
    procedure osensorLocationChanged(Sender: TObject;
      const OldLocation, NewLocation: TLocationCoord2D);
  public
    procedure execute; override;
    constructor create(suspend: boolean);
  end;

implementation

uses
  nagram.android.util,
  nagram.control.person;
{ TlocationInfo }

constructor TlocationInfo.create(suspend: boolean);
begin

  inherited Create(suspend);
  osensor := TLocationSensor.create(Nil);
  osensor.OnLocationChanged := osensorLocationChanged;
  osensor.Active := true;
end;

procedure TlocationInfo.execute;
begin
  inherited;
  while not Terminated do
    sleep(1) ;
end;

procedure TlocationInfo.OnGeocodeReverseEvent(const Address: TCivicAddress);
var
  ojson: TJSONObject;
begin

  ojson := TJSONObject.create;
  GlobalPerson.TmpAdress := AnsiToUtf8(ojson.ToString);
  ojson.AddPair('Estado', Address.AdminArea);
  ojson.AddPair('Pais Cod', Address.CountryCode);
  ojson.AddPair('Pais nome', Address.CountryName);
  ojson.AddPair('Endereco Feature', Address.FeatureName);
  ojson.AddPair('Endereco Location', Address.Locality);
  ojson.AddPair('Cep', Address.PostalCode);
  ojson.AddPair('Subarea', Address.SubAdminArea);
  ojson.AddPair('Endereco bairro', Address.SubLocality);
  ojson.AddPair('Endereco numero', Address.SubThoroughfare);
  ojson.AddPair('Endereco url', Address.URL);
  ojson.AddPair('Endereco fone', Address.Phone);
  ojson.AddPair('Endereco premisas', Address.Premises);
  ojson.AddPair('Endereco complemento', Address.Thoroughfare);
  GlobalPerson.TmpAdress := AnsiToUtf8(ojson.ToString);
end;

procedure TlocationInfo.osensorLocationChanged(Sender: TObject;
  const OldLocation, NewLocation: TLocationCoord2D);
begin
  try

    GlobalPerson.atualLongitude := NewLocation.Longitude;
    GlobalPerson.atualLatitude := NewLocation.Latitude;

    try
      if not assigned(FGeocoder) then
      begin
        if assigned(TGeocoder.Current) then
          FGeocoder := TGeocoder.Current.create;
        if assigned(FGeocoder) then
          FGeocoder.OnGeocodeReverse := OnGeocodeReverseEvent;
      end;
    except

    end;
    if assigned(FGeocoder) and not FGeocoder.Geocoding then
      FGeocoder.GeocodeReverse(NewLocation);

  except
  end;
end;

end.

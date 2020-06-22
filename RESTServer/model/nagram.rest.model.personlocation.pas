unit nagram.rest.model.personlocation;

interface

uses
  System.SysUtils,
  System.classes;

type

  Tpersonlocation = class
  private
    Flocation_date: TDateTime;
    Flocation_longitude: double;
    Flocation_latidude: double;
    Flocation_device_id: string;
    Fperson_uuid: Tguid;

  public
    property person_location_date: TDateTime read Flocation_date
      write Flocation_date;
    property person_location_longitude: double read Flocation_longitude
      write Flocation_longitude;
    property person_location_latidude: double read Flocation_latidude
      write Flocation_latidude;
    property person_location_device_id: string read Flocation_device_id
      write Flocation_device_id;
    property person_location_person_uuid: Tguid read Fperson_uuid
      write Fperson_uuid;
  end;

type
  Tpersonlocations = array of Tpersonlocation;

implementation

{ TBotAction }

end.

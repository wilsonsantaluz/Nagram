unit nagram.rest.model.persondevice;

interface

uses
  System.SysUtils,
  System.classes;

type
  Tpersondevice = class
  private
    Fdevice_id: string;
    Fdevice_block: integer;
    Fdevice_os: string;
    Fdevice_ip: string;
    Fuuid: tguid;
    FPerson_uuid: tguid;
    Fdevice_operator: string;
    Fdevice_macaddress: string;
    Fdevice_language: string;
    Fdevice_architecture: string;
    Fdevice_platform: string;
    Fdevice_platformver: string;
    Fdevice_mobiledatatype: string;
    FDate: Tdatetime;
    FName: string;
  public

    property person_device_id: string read Fdevice_id write Fdevice_id;
    property person_device_person_uuid: Tguid read FPerson_uuid
      write FPerson_uuid;
    property person_device_block: integer read Fdevice_block
      write Fdevice_block;
    property person_device_os: string read Fdevice_os write Fdevice_os;
    property person_device_ip: string read Fdevice_ip write Fdevice_ip;
    property person_device_operator: string read Fdevice_operator
      write Fdevice_operator;
    property person_device_macaddress: string read Fdevice_macaddress
      write Fdevice_macaddress;
    property person_device_language: string read Fdevice_language
      write Fdevice_language;
    property person_device_architecture: string read Fdevice_architecture
      write Fdevice_architecture;
    property person_device_platform: string read Fdevice_platform
      write Fdevice_platform;
    property person_device_platformver: string read Fdevice_platformver
      write Fdevice_platformver;
    property person_device_mobiledatatype: string read Fdevice_mobiledatatype
      write Fdevice_mobiledatatype;

  end;

implementation

{ ThashTag }

end.

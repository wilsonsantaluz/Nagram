unit nagram.rest.controller.persondevice;

interface

uses
  System.SysUtils,
  System.Classes,
  Datasnap.DSServer,
  System.JSON,
  IdHashMessageDigest,
  nagram.rest.dao.persondevice,
  Datasnap.DSAuth;

type
{$METHODINFO ON}
  TPersondevice = class(TComponent)
  private
    Fdao: TDaopersonDevice;
    { Private declarations }
  public
    { Public declarations }

    function persondevice(Value: string): TJSONObject;
    function updatepersondevice(Value: string): TJSONObject;
    function acceptpersondevice(Value: string): TJSONObject;
    function cancelpersondevice(Value: string): TJSONObject;

  end;
{$METHODINFO OFF}

implementation

uses System.StrUtils;

function TPersondevice.acceptpersondevice(Value: string): TJSONObject;
begin
  try
    Fdao := TDaopersonDevice.create;
    result := TJSONObject.ParseJSONValue(Fdao.insertpersondevice(Value))
      as TJSONObject;
  finally
    FreeAndNil(Fdao);
  end;
end;

function TPersondevice.cancelpersondevice(Value: string): TJSONObject;
begin
  try
    Fdao := TDaopersonDevice.create;
    result := TJSONObject.ParseJSONValue(Fdao.deletepersondevice(Value))
      as TJSONObject;
  finally
    FreeAndNil(Fdao);
  end;
end;

function TPersondevice.persondevice(Value: string): TJSONObject;
begin
  try
    Fdao := TDaopersonDevice.create;
    result := TJSONObject.ParseJSONValue(Fdao.getpersondevice(Value))
      as TJSONObject;
  finally
    FreeAndNil(Fdao);
  end;
end;

function TPersondevice.updatepersondevice(Value: string): TJSONObject;
begin
  try
    Fdao := TDaopersonDevice.create;
    result := TJSONObject.ParseJSONValue(Fdao.updatepersondevice(Value))
      as TJSONObject;
  finally
    FreeAndNil(Fdao);
  end;
end;

end.

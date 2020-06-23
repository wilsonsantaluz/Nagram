unit nagram.control.person;

interface

uses

  System.SysUtils,
  System.Generics.Collections,
  System.classes,
  nagram.android.util,
  nagram.service.rest,
  FMX.Forms,
  nagram.service.persistdata,
  Rtti,
  System.JSON,
  nagram.dao.person,
  nagram.control.base,
  nagram.model.person;

Type
  TpersonController = class
  private
    Fperson: Tperson;
    FTmpAdress: string;
    FatualLongitude: Double;
    FatualLatitude: Double;
    procedure getDataFromServer();

  public
    procedure setLocalPerson(value: Tperson);
    function setDataToserver(out amsg: string; update: Boolean = false)
      : Boolean;

    procedure updateLocationInfo(callback:TNotifyEvent =Nil);
    procedure getLocalPerson;
    procedure sincronizar();
    procedure serialize(value: string);
    property person: Tperson read Fperson write Fperson;
    property TmpAdress: string read FTmpAdress write FTmpAdress;
    property atualLongitude: Double read FatualLongitude write FatualLongitude;
    property atualLatitude: Double read FatualLatitude write FatualLatitude;

    constructor create;
  end;

var
  GlobalPerson: TpersonController;

implementation

uses
  nagram.resource.master;

{ TpersonController }

{ ---------------------------------------------------------------------------- }
constructor TpersonController.create;
begin
  Fperson := Tperson.create;
  FatualLongitude := 0;
  FatualLatitude := 0;
end;

{ ---------------------------------------------------------------------------- }
procedure TpersonController.getLocalPerson;
var
  odao: TpersonDao;
begin
  try
    odao := TpersonDao.create();
    Try
      if assigned(Fperson) then
        FreeAndNil(Fperson);
      Fperson := odao.getperson();
    Finally
      FreeAndNil(odao)
    End;
  except
  end;
end;

{ ---------------------------------------------------------------------------- }
procedure TpersonController.setLocalPerson(value: Tperson);
var
  odao: TpersonDao;
begin
  try
    odao := TpersonDao.create();
    Try
      if assigned(value) then

        odao.setperson(value)
      else
        odao.setperson(Fperson);
    Finally
      FreeAndNil(odao)
    End;
  except
  end;
end;

{ ---------------------------------------------------------------------------- }

procedure TpersonController.sincronizar;
var
  amsg: string;
begin
  try
    if (Fperson.person_uuid = '') and (Fperson.person_login <> '') then
    begin
      getDataFromServer();
      if Fperson.person_uuid = '' then
        setDataToserver(amsg);
    end;
  except
  end;
end;

procedure TpersonController.updateLocationInfo(callback:TNotifyEvent =Nil);
var
  ojson: TJSONObject;

  ithd: TPersistData;
Begin
  try
    if (FatualLatitude <> 0) then
    begin
      ojson := TJSONObject.create;
      ojson.AddPair('person_last_latitude', Tutil.formatvalue(FatualLatitude));
      ojson.AddPair('person_last_longitude',
        Tutil.formatvalue(FatualLongitude));
      ojson.AddPair('person_adress', FTmpAdress);
      ojson.AddPair('person_uuid', Fperson.person_uuid);
      ojson.AddPair('person_last_alive',
        FormatDateTime('YYYY-MM-DD hh:mm:ss', now));
      ithd := TPersistData.Create;
      ithd.Url := _rest_url_person;
      ithd.Param := ojson.ToString;
      ithd.Verb := 1;
      ithd.OnTerminate:=callback;
      ithd.FreeOnTerminate := true;
      ithd.resume;
    end;
  except
    on e:exception do
    begin
      Tutil.gravalog('[TPERSON] E147 '+E.Message)  ;
      if Assigned(callback) then
        callback(nil)

    end;
  end;
end;

{ ----------------------------------------------------------------------------- }
procedure TpersonController.serialize(value: string);
var
  ojson: TJSONObject;
  jsa: TJSONArray;
  s: string;
begin
  try
    ojson := TJSONObject.ParseJSONValue(value) as TJSONObject;
    jsa := (ojson.GetValue('result') as TJSONArray).Items[0].FindValue('data')
      as TJSONArray;
    Tutil.jsonToClass(Fperson, Fperson.ClassInfo, TJSONObject(jsa.Items[0]));
    s := Fperson.person_uuid;
    s := '';
    setLocalPerson(Nil);
  except
    on e: Exception do
      Tutil.gravalog('[172]' + e.Message);
  end;
end;

function TpersonController.setDataToserver(out amsg: string;
  update: Boolean = false): Boolean;
var
  ojson: TJSONObject;
  sresult: string;
  Fputdata: TRestIO;
Begin
  result := false;
  try
    try
      if FatualLatitude <> 0 then
        Fperson.person_last_longitude := FatualLatitude;
      if FatualLongitude <> 0 then
        Fperson.person_last_longitude := FatualLongitude;
      if FTmpAdress <> '' then
        Fperson.person_adress := FTmpAdress;
      Fperson.person_last_alive := now;
      ojson := Tutil.classToJson(Fperson, Fperson.ClassInfo);
      Fputdata := TRestIO.create;
      Fputdata.Url := _rest_url_person;
      Fputdata.Param := ojson.ToString;
      if (GlobalPerson.person.person_uuid <>'')  then
         update:=true;
      if update then
        Fputdata.Verb := 1
      else
        Fputdata.Verb := 2;
      Fputdata.execute;
      sresult := Fputdata.Response;
      amsg := sresult;
      if Fputdata.sucess then
      begin

        result := true;
        ojson := TJSONObject.ParseJSONValue(sresult) as TJSONObject;
        if assigned(ojson.FindValue('inserted')) then
        begin
          Fperson.person_uuid := ojson.FindValue('inserted').value;
          setLocalPerson(nil);
        end;
      end;
    finally
      FreeAndNil(Fputdata);
    end;
  except
    on e: Exception do
    begin
      amsg := e.Message;
    end;
  end;
end;
{ ------------------------------------------------------------------------------- }
procedure TpersonController.getDataFromServer();
var
  Fgetdata: TRestIO;
  ojson: TJSONObject;
  sresult: string;
  Resultados: TJSONArray;
Begin
  try
    Fgetdata := TRestIO.create;
    try
      Fgetdata.Url := _rest_url_person;
      Fgetdata.Param := '{"person_login":"' + Fperson.person_login + '"}';
      Fgetdata.Verb := 0;
      Fgetdata.execute;
      sresult := Fgetdata.Response;
      if Fgetdata.sucess then
      begin
        ojson := TJSONObject.ParseJSONValue(sresult) as TJSONObject;
        Resultados := (ojson.GetValue('result') as TJSONArray)
          .Items[0].FindValue('data') as TJSONArray;

        if assigned(Resultados.Items[0].FindValue('person_uuid')) then
        begin
          Fperson.person_uuid := Resultados.Items[0]
            .FindValue('person_uuid').value;
          setLocalPerson(nil);
        end;
      end;
    finally
      FreeAndNil(Fgetdata);
    end;
  except
  end;
end;

initialization

GlobalPerson := TpersonController.create;

end.

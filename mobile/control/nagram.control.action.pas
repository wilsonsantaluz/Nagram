unit nagram.control.action;

interface

uses

  System.SysUtils,
  System.Generics.Collections,
  System.classes,
  json,
  rtti,
  FMX.Forms,
  nagram.service.persistdata,
  nagram.android.util,
  nagram.control.person,
  nagram.dao.action,
  nagram.model.action;

type
  TmpUpdate = TNotifyEvent;

Type
  TActionController = class
  private
    FinitialLoad: Boolean;
    Fonupdate: TmpUpdate;
    procedure procesGetdata(sender: TObject);
    procedure processUpdateData(sender: TObject);
  public
    procedure setaction(var value: TBotAction);
    procedure getDataFromServer();
    procedure setDataToserver(value: TBotActions; update: Boolean = false);
    function getactions(criterio: string): TBotActions;
    procedure sincronize;
    property initialLoad: Boolean read FinitialLoad write FinitialLoad;
    property onupdate: TmpUpdate read Fonupdate write Fonupdate;
  end;

implementation

uses
  nagram.resource.master;

{ TActionController }

{ ------------------------------------------------------------------------------ }
function TActionController.getactions(criterio: string): TBotActions;
var
  odao: TactionDao;
begin
  try
    odao := TactionDao.create();
    Try
      result := odao.getactions(criterio);
    Finally
      freeandNil(odao)
    End;
  except
    on e: exception do
      Tutil.gravalog('[TACTION-E60]' + e.message);
  end;
end;

{ ------------------------------------------------------------------------------ }
procedure TActionController.setaction(var value: TBotAction);
var
  odao: TactionDao;
begin
  try
    odao := TactionDao.create();
    Try
      odao.setaction(value);
    Finally
      freeandNil(odao)
    End;
  except
    on e: exception do
      Tutil.gravalog('[TACTION-E73]' + e.message);
  end;
end;

{ ------------------------------------------------------------------------------ }
procedure TActionController.sincronize;
var
  oactions: TBotActions;
  odao: TactionDao;
begin
  try
    odao := TactionDao.create;
    try
      oactions := odao.getactions('insta_action_uuid =' + QuotedStr(''));
      if oactions.Count > 0 then
      begin
        setDataToserver(oactions);
      end
      else
        getDataFromServer;
    finally
      freeandNil(odao);
    end;
  except
    on e: exception do
      Tutil.gravalog('[TACTION-E92]' + e.message);
  end;
end;

{ ----------------------------------------------------------------------------- }
procedure TActionController.setDataToserver(value: TBotActions;
  update: Boolean = false);
var
  ojson: TJSONObject;
  jsv: TJSONValue;
  sjson: string;
  i: integer;
  iaction: TBotAction;
  sep: string;
  putdata: TPersistData;
Begin
  TRY
    sjson := '{"data":[';
    sep := '';
    for i := 0 to value.Count - 1 do
    begin
      iaction := value[i];
      iaction.insta_action_person_uuid := GlobalPerson.person.person_uuid;
      jsv := Tutil.classtojson(iaction, iaction.ClassInfo);
      sjson := sjson + sep + jsv.ToString;
      sep := ',';
    end;
    sjson := sjson + ']}';
    putdata := TPersistData.create(true);
    putdata.Url := _rest_url_action;
    putdata.param := sjson;
    putdata.objectTrans := value;
    if update then
      putdata.Verb := 1
    else
      putdata.Verb := 2;
    putdata.FreeOnTerminate := true;
    putdata.OnTerminate := processUpdateData;
    putdata.resume;
  except
    on e: exception do
      Tutil.gravalog('[TACTION-E134]' + e.message);
  end;
end;

{ ------------------------------------------------------------------------------- }
procedure TActionController.procesGetdata(sender: TObject);
var
  ojson: TJSONObject;
  sresult: string;
  i: integer;
  Resultados: TJSONArray;
  tmpaction: TBotAction;
  Fgetdata: TPersistData;
  Foactions: TBotActions;
Begin
  try
    Fgetdata := TPersistData(sender);
    sresult := Fgetdata.Response;
    if Fgetdata.sucess then
    begin
       Foactions := TObjectList<TBotAction>.create;
      try
        ojson := TJSONObject.ParseJSONValue(sresult) as TJSONObject;
        Resultados := (ojson.GetValue('result') as TJSONArray)
          .Items[0].FindValue('data') as TJSONArray;

        for i := 0 to Resultados.Count - 1 do
        begin
          tmpaction := TBotAction.create;
          Tutil.jsonToClass(tmpaction, tmpaction.ClassInfo,
            TJSONObject(Resultados.Items[i]));
          if tmpaction.insta_action_uuid <> '' then
            Foactions.Add(tmpaction);
        end;
        with TactionDao.create do
        begin
          replaceActions(Foactions);
        end;
      finally
        freeandNil(Foactions);
      end;
    end;
  except
    on e: exception do
      Tutil.gravalog('[TACTION-E176]' + e.message);
  end;
end;

{ ------------------------------------------------------------------------------- }
procedure TActionController.processUpdateData(sender: TObject);
var
  sresult: string;
  ojson: TJSONObject;
  Resultado: TJSONValue;
  i: integer;
  iaction: TBotAction;
  putdata: TPersistData;
  Foactions: TBotActions;
begin
  try
    try
      putdata := TPersistData(sender);
      sresult := putdata.Response;
      Foactions := TBotActions (TPersistData(sender).objectTrans);
      if (putdata.sucess) and (pos('result', sresult) > 0) then
      begin
        ojson := TJSONObject.ParseJSONValue(sresult) as TJSONObject;
        Resultado := (ojson.GetValue('result') as TJSONArray)
          .Items[0] as TJSONValue;
        if assigned(Resultado.FindValue('inserted')) then
        begin

          for i := 0 to Foactions.Count - 1 do
          begin
            iaction := Foactions[i];
            iaction.insta_action_uuid :=
              (Resultado.FindValue('inserted') as TJSONArray).Items[i].value;
            iaction := Foactions[i];
            setaction(iaction);
          end;
        end;
      end
      else
      begin
        if pos('duplicate key', sresult) > 0 then
        begin
          for i := 0 to Foactions.Count - 1 do
          begin
            iaction := Foactions[i];
            iaction.insta_action_uuid := GlobalPerson.person.person_uuid;
            setaction(iaction);
          end;
        end;
      end;
    except
      on e: exception do
        Tutil.gravalog('[TACTION-E227]' + e.message);
    end;
  finally
    if FinitialLoad then
    begin
      FinitialLoad := false;
      getDataFromServer;
    end;
  end;
end;

{ ------------------------------------------------------------------------------- }
procedure TActionController.getDataFromServer();
var
  Fgetdata: TPersistData;
Begin
  try
    Fgetdata := TPersistData.create(true);
    Fgetdata.Url := _rest_url_action;
    Fgetdata.param := '{"insta_action_person_uuid":"' +
      GlobalPerson.person.person_uuid + '"}';
    Fgetdata.Verb := 0;
    Fgetdata.FreeOnTerminate := true;
    Fgetdata.OnTerminate := procesGetdata;
    Fgetdata.resume;

  except
    on e: exception do
      Tutil.gravalog('[TACTION-E253]' + e.message);
  end;
end;

{ ------------------------------------------------------------------------------- }
end.

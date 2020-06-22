unit nagram.control.hashtag;

interface

uses

  System.SysUtils,
  System.classes,
  System.Generics.Collections,
  json,
  rtti,
  FMX.Forms,
  nagram.service.persistdata,
  nagram.android.util,
  nagram.control.person,
  nagram.dao.hashtag,
  nagram.model.hashtag;

type
  TmpUpdate = TNotifyEvent;

Type
  ThashtagController = class
  private
    Fonupdate: TmpUpdate;
    FinitialLoad: boolean;
    Procedure processGetdata(sender: TObject);
    procedure processPutdata(sender: TObject);
  public
    procedure sethashtag(var value: ThashTag);
    procedure getDataFromServer();
    procedure deleteHashTag(value: integer);
    procedure setDataToserver(value: ThashTags; update: boolean = false;
      callback: TNotifyEvent = nil);
    function gethashtags(criterio: string): ThashTags;
    procedure deleteHashTagServer(value: string);
    procedure sincronize;
    property onupdate: TmpUpdate read Fonupdate write Fonupdate;

    property initialLoad: boolean read FinitialLoad write FinitialLoad;
  end;

implementation

uses
  nagram.resource.master;
{ ThashtagController }

{ ------------------------------------------------------------------------------ }
function ThashtagController.gethashtags(criterio: string): ThashTags;
var
  odao: ThashtagDao;
begin
  try
    odao := ThashtagDao.create();
    Try
      result := odao.gethashtags(criterio);
    Finally
      freeandNil(odao)
    End;
  except
    on e: exception do
      Tutil.gravalog('[THASTAG-E62]' + e.message);
  end;
end;

{ ------------------------------------------------------------------------------ }
procedure ThashtagController.sethashtag(var value: ThashTag);
var
  odao: ThashtagDao;
begin
  try
    odao := ThashtagDao.create();
    Try
      odao.sethashtag(value);
    Finally
      freeandNil(odao)
    End;
  except
    on e: exception do
      Tutil.gravalog('[THASTAG-E79]' + e.message);
  end;
end;

{ ------------------------------------------------------------------------------ }
procedure ThashtagController.sincronize;
var
  ohashtags: ThashTags;
  odao: ThashtagDao;
begin
  try
    odao := ThashtagDao.create;
    try
      ohashtags := odao.gethashtags('insta_hashtag_uuid = ' + QuotedStr(''));
      if ohashtags.Count > 0 then
      begin
        setDataToserver(ohashtags, false, processGetdata);
      end
      else
        getDataFromServer;
    finally
      freeandNil(odao);
    end;
  except
    on e: exception do
      Tutil.gravalog('[THASTAG-E105]' + e.message);
  end;

end;

procedure ThashtagController.deleteHashTagServer(value: string);
var
  ojson: TJSONObject;
  spa: TPersistData;
  sresult: string;
Begin
  try
    ojson := TJSONObject.create;
    ojson.AddPair('insta_hashtag_person_uuid', GlobalPerson.person.person_uuid);
    ojson.AddPair('insta_hashtag_uuid', value);
    spa := TPersistData.create(true);
    try
      spa.Url := _rest_url_hashtag;
      spa.param := ojson.ToString;
      spa.Verb := 3;
      spa.execute;
      sresult := spa.Response;
    finally
      freeandNil(spa);
    end;
  except
    on e: exception do
      Tutil.gravalog('[THASTAG-E130]' + e.message);
  end;;
end;

{ ------------------------------------------------------------------------------- }
procedure ThashtagController.deleteHashTag(value: integer);

var
  odao: ThashtagDao;
  oresult: string;
begin
  try
    odao := ThashtagDao.create();
    Try
      oresult := odao.deleteHashTag(value);
      if oresult <> '' then
      begin
        deleteHashTagServer(oresult);
      end;
    Finally
      freeandNil(odao)
    End;
  except
    on e: exception do
      Tutil.gravalog('[THASTAG-E157]' + e.message);
  end;
end;

procedure ThashtagController.processGetdata(sender: TObject);
var
  i: integer;
  ojson: TJSONObject;
  sresult: string;
  Resultados: TJSONArray;
  tmphashtag: ThashTag;
  getdata: TPersistData;
  Fohashtags: ThashTags;
begin
  try
    getdata := TPersistData(sender);
    sresult := getdata.Response;
    if getdata.sucess then
    begin
      Fohashtags := TObjectList<ThashTag>.create;
      try
        ojson := TJSONObject.ParseJSONValue(sresult) as TJSONObject;
        Resultados := (ojson.GetValue('result') as TJSONArray)
          .Items[0].FindValue('data') as TJSONArray;

        for i := 0 to Resultados.Count - 1 do
        begin
          tmphashtag := ThashTag.create;
          Tutil.jsonToClass(tmphashtag, tmphashtag.ClassInfo,
            TJSONObject(Resultados.Items[i]));
          Fohashtags.Add(tmphashtag);
        end;
        with ThashtagDao.create do
        begin
          replaceHashtags(Fohashtags);;
          free;
        end;
        if assigned(Fonupdate) then
          Fonupdate(Nil);
      finally
        freeandNil(Fohashtags);
      end;
    end;
  except
    on e: exception do
      Tutil.gravalog('[THASTAG-E199]' + e.message);
  end;

end;

{ ------------------------------------------------------------------------------ }
procedure ThashtagController.processPutdata(sender: TObject);
var
  ojson: TJSONObject;
  sresult: string;
  Resultado: TJSONValue;
  i: integer;
  ihashtag: ThashTag;
  putdata: TPersistData;
  Fohashtags: ThashTags;
begin
  try
    try
      putdata := TPersistData(sender);
      sresult := putdata.Response;
      Fohashtags := ThashTags(putdata.objectTrans);
      if (putdata.sucess) and (pos('result', sresult) > 0) then
      begin
        ojson := TJSONObject.ParseJSONValue(sresult) as TJSONObject;
        Resultado := (ojson.GetValue('result') as TJSONArray)
          .Items[0] as TJSONValue;
        if assigned(Resultado.FindValue('inserted')) then
        begin
          for i := 0 to Fohashtags.Count - 1 do
          begin
            ihashtag := Fohashtags[i];
            ihashtag.insta_hashtag_uuid :=
              (Resultado.FindValue('inserted') as TJSONArray).Items[i].value;
            ihashtag := Fohashtags[i];
            sethashtag(ihashtag);
          end;
        end;
      end
      else
      begin
        if pos('duplicate key', sresult) > 0 then
        begin
          for i := 0 to Fohashtags.Count - 1 do
          begin
            ihashtag := Fohashtags[i];
            ihashtag.insta_hashtag_uuid := GlobalPerson.person.person_uuid;
            ihashtag := Fohashtags[i];
            sethashtag(ihashtag);
          end;
        end;
      end;
    except
      on e: exception do
        Tutil.gravalog('[THASTAG-E248]' + e.message);
    end;
  finally
    if assigned(Fohashtags) then
      freeandNil(Fohashtags);
    if FinitialLoad then
    begin
      FinitialLoad := false;
      getDataFromServer;
    end;
    if assigned(Fonupdate) then
      Fonupdate(nil);
  end;
end;

{ ------------------------------------------------------------------------------ }
procedure ThashtagController.getDataFromServer();
var
  FGetdata: TPersistData;
Begin
  try
    FGetdata := TPersistData.create(true);
    FGetdata.Url := _rest_url_hashtag;
    FGetdata.param := '{"insta_hashtag_person_uuid":"' +
      GlobalPerson.person.person_uuid + '"}';
    FGetdata.Verb := 0;
    FGetdata.FreeOnTerminate := true;
    FGetdata.OnTerminate := processGetdata;
    FGetdata.resume;
  except
    on e: exception do
      Tutil.gravalog('[THASTAG-E38]' + e.message);
  end;
end;

{ ----------------------------------------------------------------------------- }
procedure ThashtagController.setDataToserver(value: ThashTags;
  update: boolean = false; callback: TNotifyEvent = nil);
var
  jsv: TJSONValue;
  sjson: string;
  i: integer;
  ihashtag: ThashTag;
  sep: string;
  Fputdata: TPersistData;
Begin
  try

    sjson := '{"data":[';
    sep := '';
    for i := 0 to value.Count - 1 do
    begin
      ihashtag := value[i];
      ihashtag.insta_hashtag_person_uuid := GlobalPerson.person.person_uuid;
      jsv := Tutil.classtojson(ihashtag, ihashtag.ClassInfo);
      sjson := sjson + sep + jsv.ToString;
      sep := ',';
    end;
    sjson := sjson + ']}';
    Fputdata := TPersistData.create(true);
    Fputdata.Url := _rest_url_hashtag;
    Fputdata.param := sjson;
    if update then
      Fputdata.Verb := 1
    else
      Fputdata.Verb := 2;
    Fputdata.objectTrans := value;
    Fputdata.OnTerminate := processPutdata;
    Fputdata.resume;
  except
    on e: exception do
      Tutil.gravalog('[THASTAG-E308]' + e.message);
  end;

end;

{ ------------------------------------------------------------------------------ }
end.

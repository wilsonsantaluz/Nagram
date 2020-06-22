unit nagram.control.user;

interface

uses

  System.SysUtils,
  System.classes,
  nagram.android.util,
  nagram.service.persistdata,
  System.Generics.Collections,
  FMX.Forms,
  Rtti,
  System.JSON,
  nagram.dao.user,
  nagram.control.person,
  nagram.model.user;

type
  TmpUpdate = TNotifyEvent;

Type

  TUserController = class
  private

    FinitialLoad: Boolean;
    Fonupdate: TmpUpdate;
    procedure processUpdate(sender: Tobject);
    procedure processGet(sender: Tobject);

  public
    procedure setUser(var value: Tuser);
    procedure getDataFromServer();
    procedure setDataToserver(value: Tusers; update: Boolean = false;
      callback: TNotifyEvent = Nil);
    function getUsers(criterio: string): Tusers;
    function getUserByname(param: string): Tuser;
    procedure deleteUserServer(value: string);
    procedure deleteUser(value: Integer);
    procedure sincronize;
    property initialLoad: Boolean read FinitialLoad write FinitialLoad;
    property onupdate: TmpUpdate read Fonupdate write Fonupdate;
  end;

implementation

uses
  nagram.resource.master;

{ TActionController }

{ --------------------------------------------------------------------------- }
procedure TUserController.deleteUser(value: Integer);
var
  odao: TUserDao;
  oresult: string;
begin
  try
    odao := TUserDao.create();
    Try
      oresult := odao.deleteUser(value);
      if oresult <> '' then
      begin
        deleteUserServer(oresult);
      end;
    Finally
      freeandNil(odao)
    End;
  except
    on e: exception do
      Tutil.gravalog('[TCONTROUSER-E68]' + e.message);
  end;
end;

{ --------------------------------------------------------------------------- }
function TUserController.getUserByname(param: string): Tuser;
var
  odao: TUserDao;
begin
  try
    odao := TUserDao.create();
    Try
      result := odao.getUserByname(param);
    Finally
      freeandNil(odao)
    End;
  except
    on e: exception do
      Tutil.gravalog('[TCONTROUSER-E81]' + e.message);
  end;
end;

{ --------------------------------------------------------------------------- }
procedure TUserController.deleteUserServer(value: string);
var
  ojson: TJSONObject;
  spa: TPersistData;
  sresult: string;
Begin
  try
    ojson := TJSONObject.create;
    ojson.AddPair('insta_user_person_uuid', GlobalPerson.person.person_uuid);
    ojson.AddPair('insta_user_uuid', value);
    spa := TPersistData.create(true);
    spa.Url := _rest_url_user;
    spa.param := ojson.ToString;
    spa.Verb := 3;
    spa.FreeOnTerminate := true;
    spa.Execute;
    sresult := spa.Response;;
  Except
    on e: exception do
      Tutil.gravalog('[TCONTROUSER-E100]' + e.message);
  end;
end;

{ --------------------------------------------------------------------------- }
function TUserController.getUsers(criterio: string): Tusers;
var
  odao: TUserDao;
begin
  try
    odao := TUserDao.create();
    Try
      result := odao.getUsers(criterio);
    Finally
      freeandNil(odao)
    End;
  except
    on e: exception do
      Tutil.gravalog('[TCONTROUSER-E2117]' + e.message);
  end;
end;

{ ------------------------------------------------------------------------------ }
procedure TUserController.processGet(sender: Tobject);
Var
  sresult: string;
  ojson: TJSONObject;
  Resultados: TJSONArray;
  i: Integer;
  tmpUser: Tuser;
  getdata: TPersistData;
  Fousers: Tusers;
begin
  try
    getdata := TPersistData(sender);
    sresult := getdata.Response;
    if getdata.sucess then
    begin
      Fousers := TObjectList<Tuser>.create;
      try
        ojson := TJSONObject.ParseJSONValue(sresult) as TJSONObject;
        Resultados := (ojson.GetValue('result') as TJSONArray)
          .Items[0].FindValue('data') as TJSONArray;

        for i := 0 to Resultados.Count - 1 do
        begin
          tmpUser := Tuser.create;
          Tutil.jsonToClass(tmpUser, tmpUser.ClassInfo,
            TJSONObject(Resultados.Items[i]));
          Fousers.add(tmpUser);
        end;
        with TUserDao.create do
        begin
          replaceUsers(Fousers);;
          free;
        end;
        if Assigned(onupdate) then
          onupdate(Nil);
      finally
        freeandNil(Fousers);
      end;
    end;
  except
    on e: exception do
      Tutil.gravalog('[TCONTROUSER-E154]' + e.message);
  end;
end;

{ ------------------------------------------------------------------------------ }
procedure TUserController.processUpdate(sender: Tobject);
var
  ojson: TJSONObject;
  jsv: TJSONValue;
  sjson: string;
  sresult: string;
  Resultado: TJSONValue;
  i: Integer;
  iuser: Tuser;
  putdata: TPersistData;
  Fousers: Tusers;
begin
  try
    try
      putdata := TPersistData(sender);
      sresult := putdata.Response;
      Fousers := Tusers(TPersistData(sender).objectTrans);
      if (putdata.sucess) and (pos('result', sresult) > 0) then
      begin
        ojson := TJSONObject.ParseJSONValue(sresult) as TJSONObject;
        Resultado := (ojson.GetValue('result') as TJSONArray)
          .Items[0] as TJSONValue;
        if Assigned(Resultado.FindValue('inserted')) then
        begin
          for i := 0 to  Fousers.Count - 1 do
          begin
            iuser := Fousers[i];
            iuser.insta_user_uuid :=
              (Resultado.FindValue('inserted') as TJSONArray).Items[i].value;
            iuser := Fousers[i];
            setUser(iuser);
          end;
        end;
      end
      else
      begin
        if pos('duplicate key', sresult) > 0 then
        begin
          for i := 0 to  Fousers.Count - 1 do
          begin
            iuser := Fousers[i];
            iuser.insta_user_uuid := GlobalPerson.person.person_uuid;
            iuser := Fousers[i];
            setUser(iuser);
          end;
        end;

      end;
    finally
      if FinitialLoad then
      begin
        FinitialLoad := false;
        getDataFromServer();
      end;
    end;;
  except
    on e: exception do
      Tutil.gravalog('[TCONTROUSER-E213]' + e.message);
  end;
end;

{ --------------------------------------------------------------------------- }
procedure TUserController.setUser(var value: Tuser);
var
  odao: TUserDao;
begin
  try
    odao := TUserDao.create();
    Try
      odao.setUser(value);
    Finally
      freeandNil(odao)
    End;
  except
    on e: exception do
      Tutil.gravalog('[TCONTROUSER-E233]' + e.message);
  end;
end;

{ --------------------------------------------------------------------------- }
procedure TUserController.sincronize;
var
  ousers: Tusers;
  odao: TUserDao;
begin
  try
    odao := TUserDao.create;
    try
      ousers := odao.getUsers('insta_user_uuid =' + QuotedStr(''));
      if ousers.Count > 0 then
      begin
        setDataToserver(ousers, false, processGet);
      end
      else
        getDataFromServer;
    finally
      freeandNil(odao);
    end;
  except
    on e: exception do
      Tutil.gravalog('[TCONTROUSER-E252]' + e.message);
  end;
end;

{ --------------------------------------------------------------------------- }
procedure TUserController.setDataToserver(value: Tusers;
  update: Boolean = false; callback: TNotifyEvent = nil);
var
  ojson: TJSONObject;
  jsv: TJSONValue;
  sjson: string;
  i: Integer;
  iuser: Tuser;
  sep: string;
  Fputdata: TPersistData;
Begin
  try
    sjson := '{"data":[';
    sep := '';
    for i := 0 to value.Count - 1 do
    begin
      iuser := value[i];
      iuser.insta_user_person_uuid := GlobalPerson.person.person_uuid;
      jsv := Tutil.classtojson(iuser, iuser.ClassInfo);
      sjson := sjson + sep + jsv.ToString;
      sep := ',';
    end;
    sjson := sjson + ']}';
    Fputdata := TPersistData.create(true);
    Fputdata.objectTrans := value;
    Fputdata.Url := _rest_url_user;

    Fputdata.param := sjson;
    if update then
      Fputdata.Verb := 1
    else
      Fputdata.Verb := 2;
    Fputdata.FreeOnTerminate := true;
    Fputdata.OnTerminate := processUpdate;
    Fputdata.resume;
  except
    on e: exception do
      Tutil.gravalog('[TCONTROUSER-E288]' + e.message);
  end;
end;

{ ------------------------------------------------------------------------------- }
procedure TUserController.getDataFromServer();
var
  Fgetdata: TPersistData;
Begin
  try
    Fgetdata := TPersistData.create(true);
    Fgetdata.Url := _rest_url_user;
    Fgetdata.param := '{"insta_user_person_uuid":"' +
      GlobalPerson.person.person_uuid + '"}';
    Fgetdata.Verb := 0;
    Fgetdata.FreeOnTerminate := true;
    Fgetdata.OnTerminate := processGet;
    Fgetdata.resume;
  except
    on e: exception do
      Tutil.gravalog('[TCONTROUSER-E309]' + e.message);
  end;
end;

{ --------------------------------------------------------------------------- }
end.

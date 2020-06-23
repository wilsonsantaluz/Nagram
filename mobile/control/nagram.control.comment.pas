unit nagram.control.comment;

interface

uses

  System.SysUtils,
  System.classes,
  json,
  rtti,
  FMX.Forms,
  nagram.service.persistdata,
  System.Generics.Collections,
  nagram.android.util,
  nagram.control.person,
  nagram.dao.comment,
  nagram.model.comment;

type
  TmpUpdate = TNotifyEvent;

Type
  TcommentController = class
  private
    Fonupdate: TmpUpdate;
    FinitialLoad: Boolean;
    procedure processPutdata(sender: TObject);
    procedure processGetdata(sender: TObject);
  public
    procedure setcomment(var value: Tcomment);
    procedure deleteComment(value: integer);
    procedure getDataFromServer();
    procedure setDataToserver(value: TComments; update: Boolean = false);
    function getcomments(criterio: string): TComments;
    procedure deleteCommentServer(value: string);
    procedure sincronize;
    procedure getcomentById(var comment: Tcomment);
    property onupdate: TmpUpdate read Fonupdate write Fonupdate;
    property initialLoad: Boolean read FinitialLoad write FinitialLoad;
  end;



implementation

uses
  nagram.resource.master;
{ TcommentController }

{ ------------------------------------------------------------------------------ }
procedure TcommentController.deleteComment(value: integer);
var
  odao: TcommentDao;
  oresult: string;
begin
  try
    odao := TcommentDao.create();
    Try
      oresult := odao.deleteComment(value);
      if oresult <> '' then
      begin
        deleteCommentServer(oresult);
      end;
    Finally
      freeandNil(odao)
    End;
  except
    on e: exception do
      Tutil.gravalog('[TCOMMENTS-E65]' + e.message);
  end;
end;

{ ------------------------------------------------------------------------------ }
procedure TcommentController.deleteCommentServer(value: string);
var
  ojson: TJSONObject;
  spa: TPersistData;
  sresult: string;
Begin
  Try
    ojson := TJSONObject.create;
    ojson.AddPair('insta_comment_person_uuid', GlobalPerson.person.person_uuid);
    ojson.AddPair('insta_comment_uuid', value);
    spa := TPersistData.create(true);
    spa.FreeOnTerminate := true;
    spa.Url := _rest_url_comment;
    spa.param := ojson.ToString;
    spa.Verb := 3;
    spa.Execute;
    sresult := spa.Response;
  except
    on e: exception do
      Tutil.gravalog('[TCOMMENTS-E90]' + e.message);

  end;
end;

{ ------------------------------------------------------------------------------ }
procedure TcommentController.getcomentById(var comment: Tcomment);
var
  odao: TcommentDao;
begin
  try
    odao := TcommentDao.create();
    Try
      odao.getcomentById(comment);
    Finally
      freeandNil(odao)
    End;
  except
    on e: exception do
      Tutil.gravalog('[TCOMMENTS-E109]' + e.message);

  end;

end;

function TcommentController.getcomments(criterio: string): TComments;
var
  odao: TcommentDao;
begin
  try
    odao := TcommentDao.create();
    Try
      result := odao.getcomments(criterio);
    Finally
      freeandNil(odao)
    End;
  except
    on e: exception do
      Tutil.gravalog('[TCOMMENTS-E109]' + e.message);

  end;
end;

{ ------------------------------------------------------------------------------ }
procedure TcommentController.setcomment(var value: Tcomment);
var
  odao: TcommentDao;
begin
  try
    odao := TcommentDao.create();
    Try
      odao.setcomment(value);
    Finally
      freeandNil(odao)
    End;
  except
    on e: exception do
      Tutil.gravalog('[TCOMMENTS-E128]' + e.message);
  end;
end;

{ ------------------------------------------------------------------------------ }
procedure TcommentController.sincronize;
var
  ocomments: TComments;
  odao: TcommentDao;
begin
  try
    odao := TcommentDao.create;
    try
      ocomments := odao.getcomments('insta_comment_uuid = ' + QuotedStr(''));
      if ocomments.Count > 0 then
      begin
        setDataToserver(ocomments);
      end
      else
        getDataFromServer;
    finally
      freeandNil(odao);
    end;
  except
    on e: exception do
      Tutil.gravalog('[TCOMMENTS-E154]' + e.message);

  end;
end;

{ ----------------------------------------------------------------------------- }
procedure TcommentController.setDataToserver(value: TComments;
  update: Boolean = false);
var
  jsv: TJSONValue;
  sjson: string;
  i: integer;
  sep: string;
  Fputdata: TPersistData;
Begin
  try
    sjson := '{"data":[';
    sep := '';

    for i := 0 to value.Count - 1 do
    begin

      value[i].insta_comment_person_uuid := GlobalPerson.person.person_uuid;
      jsv := Tutil.classtojson(value[i], value[i].ClassInfo);
      sjson := sjson + sep + jsv.ToString;
      sep := ',';
    end;
    sjson := sjson + ']}';
    Fputdata := TPersistData.create(true);
    Fputdata.objectTrans := value;
    Fputdata.Url := _rest_url_comment;
    Fputdata.param := sjson;
    if update then
      Fputdata.Verb := 1
    else
      Fputdata.Verb := 2;
    Fputdata.FreeOnTerminate := true;
    Fputdata.OnTerminate := processPutdata;
    Fputdata.Resume;
  except
    on e: exception do
      Tutil.gravalog('[TCOMMENTS-E195]' + e.message);

  end;
end;

{ ------------------------------------------------------------------------------- }
procedure TcommentController.getDataFromServer();
var
  ojson: TJSONObject;
  Fgetdata: TPersistData;
Begin
  try
    Fgetdata := TPersistData.create(true);
    Fgetdata.Url := _rest_url_comment;
    Fgetdata.param := '{"insta_comment_person_uuid":"' +
      GlobalPerson.person.person_uuid + '"}';
    Fgetdata.Verb := 0;
    Fgetdata.FreeOnTerminate := true;
    Fgetdata.OnTerminate := processGetdata;
    Fgetdata.Resume;
  except
    on e: exception do
      Tutil.gravalog('[TCOMMENTS-217]' + e.message);

  end;
end;

{ ------------------------------------------------------------------------------- }
procedure TcommentController.processGetdata(sender: TObject);
var
  ojson: TJSONObject;
  sresult: string;
  i: integer;
  Resultados: TJSONArray;
  tmpcomment: Tcomment;
  getdata: TPersistData;
  Focomments: TComments;
begin
  try
    getdata := TPersistData(sender);
    sresult := getdata.Response;
    if getdata.sucess then
    begin
      Focomments := TObjectList<Tcomment>.create;
      try
        ojson := TJSONObject.ParseJSONValue(sresult) as TJSONObject;
        Resultados := (ojson.GetValue('result') as TJSONArray)
          .Items[0].FindValue('data') as TJSONArray;
        for i := 0 to Resultados.Count - 1 do
        begin
          tmpcomment := Tcomment.create;
          Tutil.jsonToClass(tmpcomment, tmpcomment.ClassInfo,
            TJSONObject(Resultados.Items[i]));
          Focomments.add(tmpcomment);
        end;
        with TcommentDao.create do
        begin
          replaceComments(Focomments);;
          free;
        end;
        if Assigned(Fonupdate) then
          Fonupdate(Nil);
      finally
        freeandNil(Focomments);
      end;
    end;
  except
    on e: exception do
      Tutil.gravalog('[TCOMMENTS-264]' + e.message);
  end;
end;

{ ------------------------------------------------------------------------------- }
procedure TcommentController.processPutdata(sender: TObject);
var
  ojson: TJSONObject;
  sresult: string;
  Resultado: TJSONValue;
  i: integer;
  icomment: Tcomment;
  putdata: TPersistData;
  Focomments: TComments;
begin
  try
    putdata := TPersistData(sender);
    sresult := putdata.Response;
    Focomments := TComments(TPersistData(sender).objectTrans);
    try
      if (putdata.sucess) and (pos('result', sresult) > 0) then
      begin
        ojson := TJSONObject.ParseJSONValue(sresult) as TJSONObject;
        Resultado := (ojson.GetValue('result') as TJSONArray)
          .Items[0] as TJSONValue;
        if Assigned(Resultado.FindValue('inserted')) then
        begin
          for i := 0 to Focomments.Count - 1 do
          begin
            icomment := Focomments[i];
            icomment.insta_comment_uuid :=
              (Resultado.FindValue('inserted') as TJSONArray).Items[i].value;
            icomment := Focomments[i];
            setcomment(icomment);
          end;
        end;
      end
      else
      begin
        if pos('duplicate key', sresult) > 0 then
        begin
          for i := 0 to Focomments.Count - 1 do
          begin
            icomment := Focomments[i];
            icomment.insta_comment_uuid := GlobalPerson.person.person_uuid;
            icomment := Focomments[i];
            setcomment(icomment);
          end;
        end;
      end;
    finally
      if (FinitialLoad) and (putdata.sucess) then
      begin
        FinitialLoad := false;
        getDataFromServer;
      end;
      if Assigned(Focomments) then
        freeandNil(Focomments);
      if Assigned(onupdate) and (putdata.sucess) then
        onupdate(Nil);
    end;

  except
    on e: exception do
      Tutil.gravalog('[TCOMMENTS-315]' + e.message);
  end;
end;

end.

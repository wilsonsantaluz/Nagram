unit nagram.service.navegador;

interface

uses
  System.Generics.Collections,
  System.SysUtils,
  System.Types,
  System.Classes,
  System.Variants,
  FMX.Types,
  System.JSON,
  SG.ScriptGate,
  nagram.dao.action,
  math,
  FMX.WebBrowser,
  nagram.android.util,
  IdCoder, IdCoder3to4, IdCoderMIME,
  IdUri,

{$IF DEFINED(ANDROID)}
  // -----------------ANDROID
  Androidapi.JNI.Webkit,
  Androidapi.JNI.App,
  Androidapi.JNI.Embarcadero,
  Androidapi.JNI.GraphicsContentViewText,
  Androidapi.JNI.JavaTypes,
  Androidapi.JNIBridge,
  Androidapi.JNI.Os,
  Androidapi.JNI.Net,
  Androidapi.Helpers,
  Androidapi.JNI.Widget,
{$ENDIF}
  FMX.Memo,
  nagram.model.action,
  nagram.control.action,
  nagram.model.comment,
  nagram.model.user,

  nagram.control.localoption,
  nagram.control.user

    ;

type
  EstagioNavegacao = (navegandologin, esperadoLogin, validandologin,
    navegandohashtag, esperandohashtag, navegandousuario, esperandousuario,
    validandousuario, navegarseguindo, definindoacoes, definindocomentario,
    navegarperfil, esperaperfil, clicarstory, finalizando);

type
  TinstaNavegador = class
  private
    Fbrowser: TWebBrowser;
    FHashsTags: TStringList;
    FScriptGate: TScriptGate;
    FEstagioNavegacao: EstagioNavegacao;
    Floaded: boolean;

    FindexHashTag: integer;
    FactualHashTag: string;
    Fcoment: string;

    FactualUser: string;
    Fuser: string;
    Fpassword: string;
    Ftimer: TTimer;
    FmemoLog: Tmemo;
    Fstop: boolean;
    Fscripts: TStringList;
    Ffinalizado: boolean;
    FComentarios: TStringList;
    FJSON: TJSONValue;
    FshortCode: string;
    Ficountitens: integer;
    FindiceThumbNails: integer;
    FjasonLoaded: boolean;
    Fcountitens: string;
    FoUser: Tuser;
    FOcontrolUser: TUserController;
    FOcontrolAction: TActionController;
    Fitentativas: integer;
    Foaction: TBotAction;
    Flocaloption: TLocalOptionController;

    procedure tmexecTimer(Sender: Tobject);
    procedure brsDidFailLoadWithError(ASender: Tobject);
    procedure brsDidFinishLoad(ASender: Tobject);
    procedure logop(value: string);
    procedure execute;
    procedure dofinalize();
    procedure setbasescript();
    function getNomeUsuario(): boolean;
    function gettumbnail(): boolean;
    procedure getuserinfo();
    procedure saveUser();
    procedure saveaction;
    procedure getJasonPosts();
    procedure navegarPublicacao();
    function parsevalue(value: string): string;
    procedure setTimerInterval(value: integer);
    function checkInteracoes: boolean;
  public
    procedure dologin();
    procedure startSpan();
    procedure stopall();
    constructor create(var GuiBrowser: TWebBrowser; var memolog: Tmemo);

  published
    property HashsTags: TStringList read FHashsTags write FHashsTags;
    property Comentarios: TStringList read FComentarios write FComentarios;

    property user: string read Fuser write Fuser;
    property Password: string read Fpassword write Fpassword;
    property Finalizado: boolean read Ffinalizado write Ffinalizado;

  end;

const
  _linkMain = 'https://www.instagram.com/';

implementation

uses
  nagram.resource.master;

{ TinstaNavegador }
{ ------------------------------------------------------------------------------ }
procedure TinstaNavegador.saveUser;
var
  ousers: Tusers;
begin
  try
    if assigned(FoUser) then
    begin
      FOcontrolUser.setuser(FoUser);
      ousers := TObjectList<Tuser>.create;
      try
        ousers.Add(FoUser);
        FOcontrolUser.setDataToserver(ousers);
      finally
        FreeAndNil(ousers);
      end;
    end;
  except
    on e: Exception do
    BEGIN
      Tutil.gravalog('[TNAVEGADOR] E148 ' + e.Message);
      logop('[E142] ' + e.Message);
    END;

  end;
end;

{ ------------------------------------------------------------------------------ }
procedure TinstaNavegador.brsDidFailLoadWithError(ASender: Tobject);
begin
  logop('error');
  Floaded := true;
end;

{ ------------------------------------------------------------------------------ }
procedure TinstaNavegador.brsDidFinishLoad(ASender: Tobject);
begin
  Floaded := true;
end;

{ ------------------------------------------------------------------------------ }
constructor TinstaNavegador.create(var GuiBrowser: TWebBrowser;
  var memolog: Tmemo);
begin
  // inherited;
  FHashsTags := TStringList.create;
  FScriptGate := TScriptGate.create(nil, GuiBrowser, 'brs.com.br');
  Ftimer := TTimer.create(Nil);
  FmemoLog := memolog;
  Fbrowser := GuiBrowser;
  // Fbrowser:=TWebBrowser.Create(nil);
  Fbrowser.onDidFailLoadWithError := brsDidFailLoadWithError;
  Fbrowser.OnDidFinishLoad := brsDidFinishLoad;
  Ftimer.ontimer := tmexecTimer;
  Ftimer.Enabled := false;
  Ftimer.Interval := 5000;
  Fscripts := TStringList.create;
  FComentarios := TStringList.create;
  FEstagioNavegacao := navegandologin;
  FOcontrolAction := TActionController.create;
  FOcontrolUser := TUserController.create;
  Flocaloption := TLocalOptionController.create;

end;

{ ------------------------------------------------------------------------------ }
procedure TinstaNavegador.saveaction;
var
  actions: TBotActions;
begin
  actions := TObjectList<TBotAction>.create;
  try
    try
      actions.Add(Foaction);
      FOcontrolAction.setAction(Foaction);
      FOcontrolAction.setDataToserver(actions);

    except
      on e: Exception do
        logop('[E1190] ' + e.Message);
    end;
  finally
    FreeAndNil(actions);
  end;
end;

{ ------------------------------------------------------------------------------ }
procedure TinstaNavegador.setbasescript();
begin
  // ENFIAR AS FUNCOES BASICAS NA SESÃO DO JAVASCRIPT ATUAL
  Fscripts.Clear;
  Fscripts.Add(_scriptBase);

end;

{ ------------------------------------------------------------------------------ }
procedure TinstaNavegador.startSpan;
begin
  Fstop := false;
  logop('-----------------//------------------');
  logop('---[' + DateTimeToStr(now) + ']---');
  logop('-----------------//------------------');
  // if not chkcache.IsChecked then
  // begin
  // LogOut();
  // brs.EnableCaching := false;
  FindexHashTag := 0;
  FEstagioNavegacao := navegandologin;
  Floaded := false;
  Fbrowser.Navigate(_linkMain + _ctPageLogin);
  Flocaloption.refresh;
  Ftimer.Enabled := true;
end;

{ ------------------------------------------------------------------------------ }
procedure TinstaNavegador.stopall;
begin
  Fstop := true;
end;

{ ------------------------------------------------------------------------------ }
function TinstaNavegador.getNomeUsuario(): boolean;
var
  sv: string;
  iindex: integer;
begin
  sv := '';
  result := false;
  setbasescript();
  Fscripts.Add(_scriptGetUser);
  Fbrowser.EvaluateJavaScript(Fscripts.Text);
  logop('     -> buscando usuario ->  ' + sv);
  result := true;
end;

{ ------------------------------------------------------------------------------ }
function TinstaNavegador.gettumbnail(): boolean;
var
  ss: string;
  lindex: integer;
begin
  result := false;
  setbasescript();

  ss := Fscripts.Text;
  ss := _xpath_thumbnail;
  ss := '';
  ss := _scriptGetThumbnail;
  Fscripts.Add(ss);
  ss := '';
  Fbrowser.EvaluateJavaScript(Fscripts.Text);
  lindex := 0;
  logop('     -> buscando publicações ->  ' + ss);
  result := true;
end;

{ ------------------------------------------------------------------------------ }
procedure TinstaNavegador.getuserinfo();
var
  idm: TIdDecoderMIME;
  valvalue: string;
  iJson: TJSONValue;
  follow: string;
  followeds: string;
  bio: string;

begin
  inc(Fitentativas);
  Fscripts.Clear;
  Fscripts.Add(_scriptGetJsonUser);
  Fbrowser.EvaluateJavaScript(Fscripts.Text);
  FScriptGate.CallScript('getdata_cx()',
    procedure(const iResult: String)
    begin
      if (Length(iResult) > 4) and (pos('undefined', iResult) < 1) then
      begin
        valvalue := iResult;
        idm := TIdDecoderMIME.create(nil);
        try
          valvalue := idm.DecodeString(copy(valvalue, 2, Length(valvalue) - 1));
        finally
          FreeAndNil(idm);
        end;
        valvalue := TIdURI.URLDecode(valvalue);
        iJson := TJSONObject.ParseJSONValue(valvalue);
        try
          bio := iJson.GetValue<string>(_json_bio);
          follow := iJson.GetValue<string>(_json_follow);
          followeds := iJson.GetValue<string>(_json_followeds);
        except
        end;
        if bio <> '' then
        begin
          FoUser.insta_user_bio := bio;
          FoUser.insta_user_follow := strtoint(follow);
          FoUser.insta_user_followed := strtoint(followeds);
          saveUser;
          FEstagioNavegacao := navegandousuario;
        end
        else
        begin
          // TENTA 3X PEGAR O USER CASO NAUM DE VAI PRO PROXIMO USER
          if Fitentativas < 4 then
            FEstagioNavegacao := esperaperfil
          else
            FEstagioNavegacao := navegandousuario;
        end;
      end
      else
      begin
        // TENTA 3X PEGAR O USER CASO NAUM DE VAI PRO PROXIMO USER
        if Fitentativas < 4 then
          FEstagioNavegacao := esperaperfil
        else
          FEstagioNavegacao := navegandousuario;
      end;
    end);
end;

{ ----------------------------------------------------------------------------- }
procedure TinstaNavegador.dofinalize;
begin
  Ffinalizado := true;
end;

{ ------------------------------------------------------------------------------ }
procedure TinstaNavegador.dologin;

begin
  try
    Fscripts.Clear;
    setbasescript;
    Fscripts.Add(_scrriptLogin);
    Fscripts.Text := StringReplace(Fscripts.Text, '$user', Fuser,
      [rfReplaceAll]);
    Fscripts.Text := StringReplace(Fscripts.Text, '$senha', Fpassword,
      [rfReplaceAll]);
    Floaded := false;
    Fbrowser.EvaluateJavaScript(Fscripts.Text);
  except

  end;
  Ftimer.Enabled := true;
end;

{ -------------------------------------------------------------------------- }
procedure TinstaNavegador.getJasonPosts();
var
  idm: TIdDecoderMIME;
  valvalue: string;
  JsonArray: TJSONArray;
begin
  FScriptGate.CallScript('getdata_cx()',
    procedure(const iResult: String)
    begin
      if (Length(iResult) > 20) then
      begin
        valvalue := iResult;
        idm := TIdDecoderMIME.create(nil);
        try
          valvalue := idm.DecodeString(copy(valvalue, 2, Length(valvalue) - 1));
        finally
          FreeAndNil(idm);
        end;
        valvalue := TIdURI.URLDecode(valvalue);
        FJSON := TJSONObject.ParseJSONValue(valvalue);
        Fcountitens := '';
        Ficountitens := 0;
        try
          Fcountitens := FJSON.GetValue<string>(_json_posts);

          JsonArray := FJSON.GetValue<TJSONArray>(_jsonarray_posts);
          if assigned(JsonArray) then
            Fcountitens := inttostr(JsonArray.Count);
        except
        end;
        if Fcountitens <> '' then
        begin

          FjasonLoaded := true;
          setbasescript();
          // SEGUIR HASH TAG
          Fscripts.Add(_scriptFollowHahsTag);
          Fbrowser.EvaluateJavaScript(Fscripts.Text);
          Ficountitens := strtoint(Fcountitens);
          // RESPEITAR LIMITE HAS TAG
          if Ficountitens > Flocaloption.localoption.HashTagDept then
            Ficountitens := Flocaloption.localoption.HashTagDept;

        end;
        if (Ficountitens = 0) then
        begin
          logop('HASH TAG -> ' + FactualHashTag + ' SEM RESULTADOS ');
          FEstagioNavegacao := navegandohashtag;
          inc(Fitentativas);
          if Fitentativas > 3 then
            gettumbnail();
        end;
      end
      else
      begin
        gettumbnail();
      end;
    end);
end;

{ ---------------------------------------------------------------------------- }
procedure TinstaNavegador.navegarPublicacao();
var
  strShortCode: string;
begin
  if FindiceThumbNails < Ficountitens then
  begin
    try
      strShortCode := _json_shortcode;
      strShortCode := StringReplace(strShortCode, '$id',
        inttostr(FindiceThumbNails), [rfReplaceAll]);
      FshortCode := FJSON.GetValue<string>(strShortCode);
    except
    end;
    inc(FindiceThumbNails);
    if FshortCode <> '' then
    begin
      logop('HASH TAG -> Indice postagens json ' + inttostr(FindiceThumbNails));
      FEstagioNavegacao := esperandousuario;
      Fbrowser.Navigate(_linkMain + 'p/' + FshortCode + '/');
      FEstagioNavegacao := esperandousuario;

    end
    else
    begin
      logop('HASH TAG -> Sem indice no json' + inttostr(FindiceThumbNails));
      FEstagioNavegacao := esperandousuario;
      Fitentativas := 0;
    end;
  end
  else
  begin
    // ACABOW AS INFORMAÇÕES DESTA HASH TAG PASAR PARA A PROXIMA
    FEstagioNavegacao := navegandohashtag;
  end;
end;

{ ------------------------------------------------------------------------------ }
function TinstaNavegador.parsevalue(value: string): string;
begin
  result := value;
  try
    if Length(value) > 2 then
    begin
{$IF DEFINED(iOS) or DEFINED(ANDROID)}
      if value[0] = '"' then
        result := copy(value, 2, Length(value) - 1);

      if (Length(result) > 2) and (result[Length(result) - 1] = '"') then
      begin
        result := copy(result, 0, Length(result) - 1);
        result := result;
      end;
{$ELSE}
      if value[1] = '"' then
        result := copy(value, 2, Length(result) - 1);

      if result[Length(result)] = '"' then
        result := copy(result, 0, Length(result) - 1);

{$ENDIF}
    end;
  except
    on e: Exception do
    begin
      logop('[E161] -> ' + e.Message + ' hash tag -> ' + FactualHashTag);
      Tutil.gravalog('[TNAVEGADOR] E496 ' + e.Message);
    end;

  end;
end;

{ ------------------------------------------------------------------------------ }
procedure TinstaNavegador.setTimerInterval(value: integer);
var
  newValue: cardinal;
begin
  Ftimer.Interval := value;
  newValue := Flocaloption.localoption.DelayNavigation;
  newValue := newValue * 1000;
  if (newValue > 1000) then
    Ftimer.Interval := newValue;
  if Ftimer.Interval < 1000 then
    Ftimer.Interval := 3000;
end;

{ ------------------------------------------------------------------------------ }
procedure TinstaNavegador.execute;
var
  valvalue: string;
  sp: string;
  FuserIsnew: boolean;
begin
  if Fstop then
    exit;
  try
    try
      case FEstagioNavegacao of
        navegandologin:
          begin
            if Floaded then
            begin
              Ftimer.Interval := 4000;
              dologin;
              FEstagioNavegacao := esperadoLogin;
            end;
          end;
        esperadoLogin:
          begin
            Fscripts.Clear;
            Fscripts.Add(_scriptGetShareData);
            Fbrowser.EvaluateJavaScript(Fscripts.Text);
            FEstagioNavegacao := validandologin;

          end;
        validandologin:
          begin
            FScriptGate.CallScript('getdata_cx()',
              procedure(const iResult: String)
              begin
                if (Length(iResult) > 13) or (Floaded) then
                begin
                  FEstagioNavegacao := navegandohashtag;
                end;

              end);
          end;
        navegandohashtag:
          begin
            FindiceThumbNails := 0;
            FactualUser := '';
            Floaded := false;
            Fitentativas := 0;
            FshortCode := '';
            FjasonLoaded := false;
            try
              logop('Consultado hash tag -> ' + FactualHashTag);
              if FindexHashTag < FHashsTags.Count then
              begin
                FactualHashTag := FHashsTags[FindexHashTag];
                Fbrowser.Navigate(_linkMain + _urlExplore + FactualHashTag);
                FEstagioNavegacao := esperandohashtag;
              end
              else
              begin
                FEstagioNavegacao := finalizando;
                logop('Indice maximo atingido');
              end;
            except
              on e: Exception do
              begin
                logop('[E583]-> ' + e.Message)
              end;

            end;
            inc(FindexHashTag);
          end;
        esperandohashtag:
          begin
            FactualUser := '';
            valvalue := '';
            gettumbnail();
            FEstagioNavegacao := navegandousuario;
          end;
        navegandousuario:
          begin
            Fitentativas := 0;
            if not FjasonLoaded then
            begin
              getJasonPosts();
            end;
            if FjasonLoaded then
            begin
              navegarPublicacao();
            end;
          end;
        esperandousuario:
          begin
            getNomeUsuario();
            inc(Fitentativas);
            FEstagioNavegacao := validandousuario;
          end;
        validandousuario:
          begin
            FScriptGate.CallScript('getvalue_cx()',
              procedure(const iResult: String)
              begin
                FactualUser := '';
                if (Length(iResult) > 4) and (pos('undefined', iResult) < 1)
                then
                begin
                  FactualUser := parsevalue(iResult);
                  logop('USUARIO -> ENCONTRADO USUARIO ' + FactualUser);
                  Ftimer.Interval := 2000;
                  FEstagioNavegacao := navegarseguindo;
                end
                else
                begin
                  // TENTA 3X PEGAR O USER CASO NAUM DE VAI PRO PROXIMO USER
                  if Fitentativas < 4 then
                    FEstagioNavegacao := esperandousuario
                  else
                    FEstagioNavegacao := navegandousuario;
                end;
              end);
          end;
        navegarseguindo:
          begin
            setbasescript();
            if assigned(FoUser) then
              FreeAndNil(FoUser);
            FoUser := FOcontrolUser.getUserByname(FactualUser);
            FoUser.insta_user_last_visit := now;
            if FoUser.insta_user_Id > 0 then
            begin
              // clicar em seguir
              FuserIsnew := false;
              logop('     ->Ja  Seguindo : ' + FactualUser);
            end
            else
            begin
              // NÃO TEM USUARIO VOU CADASTRAR
              logop('     ->seguindo : ' + FactualUser);
              FuserIsnew := true;
              FoUser.insta_user_Name := FactualUser;
              FoUser.insta_user_Date_Follow := now;
              FoUser.insta_user_Date := now;
              FoUser.insta_user_last_visit := now;
              FoUser.insta_user_follow := 0;
              FoUser.insta_user_followed := 0;
              FoUser.insta_user_Posts := 0;
              FoUser.insta_user_Following := 1;
              Fscripts.Add(_scriptSeguirUser);
              logop('     -> Adcionado -> Seguindo : ' + FactualUser);
            end;
            Fbrowser.EvaluateJavaScript(Fscripts.Text);
            setTimerInterval(4000);

            if FuserIsnew then
            begin
              if assigned(Foaction) then
                FreeAndNil(Foaction);
              Foaction := TBotAction.create;
              Foaction.insta_action_insta_user_name := FoUser.insta_user_Name;
              Foaction.insta_action_comment := Fcoment;
              Foaction.insta_action_type := 0;
              Foaction.insta_action_url := _linkMain + 'p/' + FshortCode + '/';
              saveaction();
            end;
            FEstagioNavegacao := definindoacoes;
          end;

        definindoacoes:
          begin
            // clicar em like
            setbasescript();
            Fscripts.Add(_scriptLikePost);
            // clicar em comentar
            Fscripts.Add(_scriptPaginaComentario);
            Fbrowser.EvaluateJavaScript(Fscripts.Text);
            setTimerInterval(3000);
            if assigned(Foaction) then
              FreeAndNil(Foaction);
            Foaction := TBotAction.create;
            Foaction.insta_action_insta_user_name := FoUser.insta_user_Name;
            Foaction.insta_action_comment := Fcoment;
            Foaction.insta_action_type := 1;
            Foaction.insta_action_url := _linkMain + 'p/' + FshortCode + '/';
            saveaction();
            if Flocaloption.localoption.SendComent = 1 then
            begin
              FEstagioNavegacao := definindocomentario
            end
            else
            begin
              FEstagioNavegacao := navegarperfil;
            end;
          end;
        definindocomentario:
          begin
            setTimerInterval(3000);
            setbasescript();
            Randomize();
            Fcoment := FComentarios[RandomRange(0, FComentarios.Count - 1)];
            logop('     ->  configurando comentario');
            Fscripts.Add(_scriptComentario);
            Fscripts.Text := StringReplace(_scriptComentario, '$comentario',
              Fcoment, [rfReplaceAll]);

            logop('     -> enviando comentario  ' + Fcoment);
            Floaded := false;
            Fbrowser.EvaluateJavaScript(Fscripts.Text);
            if assigned(Foaction) then
              FreeAndNil(Foaction);
            Foaction := TBotAction.create;
            Foaction.insta_action_insta_user_name := FoUser.insta_user_Name;
            Foaction.insta_action_url := Fbrowser.Url;
            Foaction.insta_action_comment := Fcoment;
            Foaction.insta_action_type := 2;
            saveaction();
            FEstagioNavegacao := navegarperfil;
          end;
        navegarperfil:
          begin
            Fbrowser.Navigate(_linkMain + FactualUser);
            Fitentativas := 0;
            FEstagioNavegacao := esperaperfil;
          end;
        esperaperfil:
          begin
            getuserinfo();
          end;
        clicarstory:
          begin
            Fbrowser.EvaluateJavaScript(Fscripts.Text);
          end;

        finalizando:
          begin
            logop('     ->  etapa 6 finalizado hash tag ' + FactualUser);
            sleep(10);
          end;
      end;
    except
      on e: Exception do
      begin
        Tutil.gravalog('[TNAVEGADOR] E755 ' + e.Message);
        logop('[E714] -> ' + e.Message + ' hash tag -> ' + FactualHashTag +
          ' Etapa :');
      end;
    end;
  finally
    Fscripts.Clear;
  end;
end;

{ ------------------------------------------------------------------------------ }
procedure TinstaNavegador.logop(value: string);
begin
  if assigned(FmemoLog) then
    FmemoLog.Lines.Add(value);
end;

function TinstaNavegador.checkInteracoes: boolean;
begin

  result := true;
  try
    result := TActionDao.getCountLikeHour <=
      Flocaloption.localoption.Maxinthour;
  except
    on e: Exception do
      Tutil.gravalog('[TNAVEGADOR] E785 ' + e.Message);
  end;

end;

{ ------------------------------------------------------------------------------ }
procedure TinstaNavegador.tmexecTimer(Sender: Tobject);
var
  valinteracoes: boolean;
begin
  try
    Ftimer.Enabled := false;
    valinteracoes := checkInteracoes;
    if (FindexHashTag <= FHashsTags.Count) and (valinteracoes) then
    begin
      try
        if (not Fstop) then
          if true then

            execute();
      finally
        Ftimer.Enabled := true;
      end;
    end
    else
    begin
      dofinalize();
      if not valinteracoes then
      begin
        Tutil.gravalog('[TNAVEGADOR] Finalizado por atingir o limite ');
        logop(' Finalizado por atingir o limite ');
      end;
    end;
    if Fstop then
    begin
      Ftimer.Enabled := false;
    end;
  except
    on e: Exception do
    begin
      Tutil.gravalog('[TNAVEGADOR] ERRO MAIN ' + e.Message);
      logop(e.Message);
    end;

  end;

end;
{ ------------------------------------------------------------------------------ }

end.

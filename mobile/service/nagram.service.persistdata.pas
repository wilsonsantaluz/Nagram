unit nagram.service.persistdata;

interface

uses

  IdComponent,
  System.SysUtils,
  System.Variants,
  System.Classes,
  IdHTTP,
  System.ZLib,
  System.JSON,
  idCookieManager,
  IdHashMessageDigest;

type
  TbeforeExecute = TNotifyEvent;

type
  TPersistData = class(Tthread)
  private
    FloginUser: String;
    Findice: Integer;
    Furl: string;
    Fresponse: string;
    Fverb: Integer;
    FbeforeExecute: TbeforeExecute;
    FMensageReturneD: string;
    Fsucess: boolean;
    FFinalized: boolean;
    Fsenha: string;
    Fparam: string;
    myHttpCom: TIdHTTP;
    Cookie: TidCookieManager;
    FobjectTrans:TObject;
    procedure sincronizedproc;
    procedure setupIndy();
    function decompress(value: TStream): TStream;
  public

    procedure execute; override;

    property Finalized: boolean read FFinalized write FFinalized;

    property Url: string read Furl write Furl;
    property Param: string read Fparam write Fparam;
    property Response: string read Fresponse write Fresponse;
    property Verb: Integer read Fverb write Fverb;
    property OnBeforeExecute: TbeforeExecute Read FbeforeExecute
      write FbeforeExecute;
    property MensageReturned: string Read FMensageReturneD
      write FMensageReturneD;
    property sucess: boolean read Fsucess write Fsucess;
    property objectTrans:TObject read   FobjectTrans write   FobjectTrans;
  end;

implementation

uses
  nagram.resource.master;
{ TPersistData }

procedure TPersistData.setupIndy();
begin

  with myHttpCom do
  begin
    AllowCookies := true;
    ProxyParams.BasicAuthentication := false;
    ProxyParams.ProxyPort := 0;
    Request.ContentLength := -1;
    Request.ContentRangeEnd := 0;
    Request.ContentRangeStart := 0;
    ProtocolVersion := pv1_1;

    Request.BasicAuthentication := true;
    Request.Username := _rest_user;
    Request.Password := _rest_pass;
    Request.UserAgent := _user_agent;
    // HTTPOptions := [hoForceEncodeParams];
    HandleRedirects := true;
    Request.Referer := _rest_host + Furl;
    Request.Host := _rest_host;
    Cookie := TidCookieManager.Create(nil);
    Request.ContentEncoding := 'UTF-8'; // in test
    Request.CharSet := 'UTF-8'; // //in test
    Request.AcceptCharSet := 'UTF-8';
    /// /in test
    Response.CharSet := 'UTF-8'; // in test
    Response.ContentEncoding := 'UTF-8'; // in test

    Request.AcceptEncoding := 'gzip, deflate';
    myHttpCom.Request.Accept :=
      'application/json, text/javascript, */*; q=0.01';
    myHttpCom.Request.ContentType := 'application/json';

    myHttpCom.Request.CharSet := 'utf-8';

    CookieManager := Cookie;
  end;
end;

function TPersistData.decompress(value: TStream): TStream;
begin
  // compress to buff (System.ZLib)
  value.Position := 0;
  result := TstringStream.Create;
  ZDecompressStream(value, result);

end;

{ ------------------------------------------------------------------------------ }
procedure TPersistData.execute;
var
  srespose: string;

  idmd5: TIdHashMessageDigest5;
  Req_Json: TStream;
  aurl: string;
  decoded: string;
  aresponse: TStream;
  procedure setresponse;
  begin
    try
      aresponse := decompress(aresponse)
    except
    end;
    Fresponse := TstringStream(aresponse).DataString;
  end;

begin
  inherited;
  idmd5 := TIdHashMessageDigest5.Create;
  myHttpCom := TIdHTTP.Create(nil);
  try
    FFinalized := false;

    setupIndy();
    Req_Json := TstringStream.Create(Fparam);
    Req_Json.Position := 0;
    try
      // Req_Json:=TstringStream.Create(Fparam,TEncoding.UTF8);
      aresponse := TstringStream.Create('');
      case Verb of
        0:
          begin
            myHttpCom.Get(_rest_host + Furl + Fparam, aresponse);
            setresponse();
            Fsucess := true;
          end;
        1:
          begin
            myHttpCom.post(_rest_host + Furl, Req_Json, aresponse);
            setresponse();
            Fsucess := pos('codretorno":"200"', Fresponse) > 0;
          end;
        2:
          begin
            myHttpCom.Put(_rest_host + Furl, Req_Json, aresponse);
            setresponse();
            Fsucess := pos('codretorno":"200"', Fresponse) > 0;
          end;
        3:
          begin
            aurl := _rest_host + Furl + Fparam;
            myHttpCom.Delete(aurl, aresponse);
            Fsucess := pos('codretorno":"200"', Fresponse) > 0;
          end;
      end;

    except
      on E: Exception do
      begin
        Fsucess := false;
        if pos('forbidden', AnsiLowerCase(E.Message)) > 0 then
        begin
          FMensageReturneD := 'Servidor recusou a conexão,Atualize a versão';
        end
        else
        begin
          FMensageReturneD := 'Erro ao acessar servidor : ' + E.Message;
        end;
        Fresponse := FMensageReturneD;
      end;
    end;
  finally
    try
      FreeAndNil(myHttpCom);
      try
        if Assigned(FbeforeExecute) then
          FbeforeExecute(Nil);
      except
      end;
      FreeAndNil(idmd5);
    except
    end;
    FFinalized := true;

  end;
end;

procedure TPersistData.sincronizedproc;
begin
  // *//
end;

end.

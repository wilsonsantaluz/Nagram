unit nagram.rest.util;

interface

uses
{$IFDEF MSWINDOWS}
  windows,
{$ENDIF MSWINDOWS}
  System.sysutils,
  FireDAC.Comp.Client,
  Math,
  Data.DB,
  System.JSON,
  Datasnap.DBClient,
  classes;

type

  TpsTipo = (temissao, tcancelamento);

  TdadosRequerente = record
    cnpj: string;
    inscricao: string;
    senha: string;

  end;

function soNumeros(const Value: string): string;
function formatvalue(Value: double): string;
function vLrXmltoFloat(Value: string): double;

function makeJason(cds: TclienTdataset; aliasdata: string = ''): string;
procedure gravalog(mensagem: string);

function Valfloat(Value: string): double;
function Valdate(Value: string): Tdatetime;
function valInt(Value: string): integer;

Function getKindType(Value: string): integer;

implementation

{ ------------------------------------------------------------------------------- }
function soNumeros(const Value: string): string;
var
  i: integer;
begin
  Result := '';

  if Value = '' then
    exit;

  for i := 0 to length(Value) do
    if Value[i] in ['0' .. '9'] then
      Result := Result + Value[i];
end;

function valInt(Value: string): integer;
var
  i: integer;
begin
  Result := 0;
  if soNumeros(Value) <> '' then
  begin
    if TryStrToInt(Value, i) then
      Result := i;
  end;

end;

{ ------------------------------------------------------------------------------- }
function formatvalue(Value: double): string;
begin
  Result := StringReplace(FloatToStr(Value), ',', '.', [rfReplaceAll]);

end;

{ ------------------------------------------------------------------------------ }
function vLrXmltoFloat(Value: string): double;
var
  s: string;
begin
  Result := 0;

  s := StringReplace(Value, '.', FormatSettings.DecimalSeparator,
    [rfReplaceAll]);
  if s <> '' then
    Result := strtofloat(s);
end;
{ ----------------------------------------------------------------------------- }

function EscapeString(const AValue: string): string;
const
  ESCAPE = '\';
  // QUOTATION_MARK = '"';
  REVERSE_SOLIDUS = '\';
  SOLIDUS = '/';
  BACKSPACE = #8;
  FORM_FEED = #12;
  NEW_LINE = #10;
  CARRIAGE_RETURN = #13;
  HORIZONTAL_TAB = #9;
var
  AChar: Char;
begin
  try
    Result := '';
    for AChar in AValue do
    begin

      case AChar of

        REVERSE_SOLIDUS:
          Result := Result + ESCAPE + REVERSE_SOLIDUS;
        SOLIDUS:
          Result := Result + ESCAPE + SOLIDUS;
        BACKSPACE:
          Result := Result + ESCAPE + 'b';
        FORM_FEED:
          Result := Result + ESCAPE + 'f';
        NEW_LINE:
          Result := Result + ESCAPE + 'n';
        CARRIAGE_RETURN:
          Result := Result + ESCAPE + 'r';
        HORIZONTAL_TAB:
          Result := Result + ESCAPE + 't';
      else
        begin
          if (integer(AChar) < 32) or (integer(AChar) > 126) then
            Result := Result + ESCAPE + 'u' + IntToHex(integer(AChar), 4)
          else
            Result := Result + AChar;
        end;
      end;
    end;
  finally
    Result := StringReplace(Result, #13#10, ' ', [rfReplaceAll]);
  end;
end;

{ ---------------------------------------------------------------------- }
function Valfloat(Value: string): double;
var
  vfloat: double;
  svalue: string;
  fs: TFormatSettings;
begin
  Result := 0;
  svalue := Value;
  if not TryStrToFloat(Value, vfloat) then
  begin
    try
      FillChar(fs, SizeOf(fs), 0);
      fs.ThousandSeparator := ',';
      fs.DecimalSeparator := '.';
      Result := strtofloat(Value, fs);

    except
      Value := StringReplace(Value, '.', ',', [rfReplaceAll]);
      if TryStrToFloat(Value, vfloat) then
        Result := vfloat
      else
        raise exception.Create('Valor ' + Value +
          ' Nao pode ser covertido para float');
    end;
  end
  else
    Result := vfloat;
end;

{ ---------------------------------------------------------------------- }
function valString(Value: string): string;
begin
  Result := Value;
  Result := StringReplace(Result, #13#10, ' ', [rfReplaceAll]);
  Result := StringReplace(Result, '"', '''', [rfReplaceAll]);
  Result := StringReplace(Result, '"', '''', [rfReplaceAll]);
  Result := EscapeString(Result);
  Result := '"' + Result + '"';
end;

Function Valdate(Value: string): Tdatetime;
var
  idate: Tdatetime;
  lst: TStringList;
  day: word;
  year: word;
  month: word;
  minut: word;
  second: word;
  hour: word;
  stime: string;
begin
  day := 0;
  year := 0;
  month := 0;
  minut := 0;
  second := 0;
  hour := 0;
  Result := 0;
  lst := TStringList.Create;
  try
    if TryStrToDateTime(Value, idate) then
      Result := idate
    else
    begin
      if pos('-', Value) > 0 then
      begin
        lst.StrictDelimiter := true;
        lst.Delimiter := '-';
        lst.DelimitedText := Value;
        year := StrToInt(lst[0]);
        month := StrToInt(copy(lst[1], 0, 2));
        day := StrToInt(copy(lst[2], 0, 2));
        Result := EncodeDate(year, month, day)
      end;

      if pos(':', Value) > 0 then
      begin

        lst.StrictDelimiter := true;
        lst.Delimiter := ' ';
        lst.DelimitedText := Value;
        stime := lst[1];
        if stime <> '' then
        begin
          lst.StrictDelimiter := true;
          lst.Delimiter := ':';
          lst.DelimitedText := stime;
          if lst.Count > 1 then

            hour := StrToInt(lst[0]);
          if lst.Count > 2 then
            minut := StrToInt(lst[1]);
          if lst.Count > 3 then
            second := StrToInt(copy(lst[2], 0, 2));
          Result := Result + EncodeTime(hour, minut, second, 0);
        end;
      end;

    end;
  finally
    FreeAndNil(lst);
  end;
end;

{ ---------------------------------------------------------------------- }
function makeJason(cds: TclienTdataset; aliasdata: string = ''): string;
var
  Data: string;
  line: string;
  bmrk: TBookmark;
  R, i, F, t: integer;
begin
  try
    Result := '';
    cds.First;
    while not cds.Eof do
    begin
      TRY
        line := '';
        for i := 0 to cds.FieldCount - 1 do
        begin
          if cds.Fields[i].Visible then
          begin
            if line <> '' then
              line := line + ',' + #13#10;
            line := line + '"' + cds.Fields[i].FullName + '":';
            if cds.Fields[i].DataType in [ftFloat, ftCurrency, ftInteger, ftBCD]
            then
            begin
              if cds.Fields[i].AsString <> '' then

                line := line + StringReplace(cds.Fields[i].AsString, ',', '.',
                  [rfReplaceAll])
              else

                line := line + '""';
            end
            else if cds.Fields[i].DataType in [ftDate, ftDateTime, ftTimeStamp,
              ftTime] then
            begin
              if (cds.Fields[i].AsDateTime - trunc(cds.Fields[i].AsDateTime)) = 0
              then
                line := line + valString(FormatDateTime('YYYY-MM-DD',
                  cds.Fields[i].AsDateTime))
              else
                line := line + valString(FormatDateTime('YYYY-MM-DD hh:mm:ss',
                  cds.Fields[i].AsDateTime))

            end
            else
            begin
              line := line + valString(cds.Fields[i].AsString);
            end;
          end;
        end;
        if Data <> '' then
          Data := Data + ',';
        Data := Data + '{' + line + '}' + #13#10;
      FINALLY
        cds.next;
      END;

    end;
    if aliasdata = '' then
      aliasdata := 'data';
    Data := '{ "' + aliasdata + '": [' + #13#10 + Data + #13#10 + ']}';
    if DebugHook <> 0 then
    begin
      with TStringList.Create do
      begin
        Text := Data;
        savetofile(ExtractFilePath(GetModuleName(HInstance)) + 'Consulta.json');
        Free;
      end;
    end;
    Result := Data;
  except
    on e: exception do
      raise exception.Create('Error na geração do arquivo json ' + e.Message);
  end;
end;

procedure gravalog(mensagem: string);
var
  strSaida: string;
  HWND: Cardinal;
  procedure registrarLogEmArquivo;
  var
    p: string;
    F: TextFile;
  begin
    try
      try
        p := ExtractFilePath(ParamStr(0)) + 'log\';
        ForceDirectories(p);
        p := p + FormatDateTime('yyyymmdd', now) + '_' +
          ChangeFileExt(ExtractFileName(ParamStr(0)), '') + '.log';
        AssignFile(F, p);
        if not FileExists(p) then
          Rewrite(F)
        else
          Append(F);
        Writeln(F, strSaida);
      except
      end;
    finally
      Closefile(F);
    end;
  end;

begin
  Try
    HWND := 0;
    try
      strSaida := FormatDateTime('hh:nn:ss.zzz', now) + ' - ' + mensagem;

      registrarLogEmArquivo;
    finally

    end;
  except
  end;
end;

{ ------------------------------------------------------------------------------ }

Function getKindType(Value: string): integer;
begin
  Result := 0;
  if Value = 'TDateTime' then
    Result := 1
  else if Value = 'Integer' then
    Result := 2
  else if Value = 'Double' then
    Result := 3
  else if LowerCase(Value) = 'string' then
    Result := 4

  else if LowerCase(Value) = 'tguid' then
    Result := 5

  else if LowerCase(Value) = 'variant' then
    Result := 6
end;

{ ------------------------------------------------------------------------------ }
procedure parsejsontoupdqry1(qry: TFDQuery; jsonOb: TJSONObject;
  tablename: string);
var
  i: integer;
  Value: string;
  nameparam: string;
begin
  qry.SQL.clear;
  qry.SQL.Add('UPDATE ' + tablename);
  qry.SQL.Add('SET ');
  for i := 0 to jsonOb.Count - 1 do
  begin
    nameparam := jsonOb.Pairs[i].JsonString.Value;
    Value := jsonOb.Values[nameparam].Value;
    if i = 0 then
      qry.SQL.Add(' ' + nameparam + '= :' + nameparam)
    else
      qry.SQL.Add(', ' + nameparam + '= :' + nameparam);

  end;
end;

end.

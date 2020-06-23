unit nagram.dao.person;

interface

uses
  System.SysUtils,
  System.Classes,
  System.Generics.Collections,
  Data.DB,
  // FIREDAC-------------------------------------------
  FireDAC.Stan.Intf,
  FireDAC.Stan.Option,
  FireDAC.Stan.Error,
  FireDAC.UI.Intf,
  FireDAC.Phys.Intf,
  FireDAC.Stan.Def,
  FireDAC.Stan.Pool,
  FireDAC.Stan.Async,
  FireDAC.Phys,
  FireDAC.FMXUI.Wait,
  FireDAC.Comp.Client,
  System.IOUtils,
  FireDAC.Phys.SQLite,
  FireDAC.Phys.SQLiteDef,
  FireDAC.Stan.ExprFuncs,
  FireDAC.Stan.Param,
  FireDAC.DatS,
  FireDAC.DApt.Intf,
  FireDAC.DApt,
  FireDAC.Comp.DataSet,
  // ---------------------------------------------
  nagram.datamodule,
  nagram.android.util,
  nagram.model.person;

type
  TpersonDao = class
  private
  public
    procedure setperson(var value: Tperson);
    function getperson(): Tperson;

  end;

implementation

{ Tuser }

function TpersonDao.getperson(): Tperson;
var
  qry: TFDQuery;
begin
  try
    result := Tperson.Create;
    qry := TFDQuery.Create(nil);
    qry.Connection := dm_local.FDConnection1;
    try
      qry.SQL.Add('SELECT   * FROM   person');

      qry.open;

      result.person_uuid := qry.FieldByName('person_uuid').AsString;
      result.person_date := qry.FieldByName('person_date').AsFloat;
      result.person_name := qry.FieldByName('person_name').AsString;
      result.person_type := qry.FieldByName('person_type').AsInteger;
      result.person_password := qry.FieldByName('person_password').AsString;
      result.person_login := qry.FieldByName('person_login').AsString;
      result.person_insta_user := qry.FieldByName('person_insta_user').AsString;
      result.person_insta_password :=
        qry.FieldByName('person_insta_password').AsString;
      result.person_mail := qry.FieldByName('person_mail').AsString;
      result.person_ip := qry.FieldByName('person_ip').AsString;
      result.person_country := qry.FieldByName('person_country').AsString;
      result.person_fone := qry.FieldByName('person_fone').AsString;
      result.person_type := qry.FieldByName('person_type').AsInteger;
      result.person_age := qry.FieldByName('person_age').AsInteger;
      result.person_adress := qry.FieldByName('person_adress').AsString;
      result.person_initial_latitude :=
        qry.FieldByName('person_initial_latitude').AsFloat;
      result.person_initial_longitude :=
        qry.FieldByName('person_initial_longitude').AsFloat;
      result.person_last_latitude :=
        qry.FieldByName('person_last_latitude').AsFloat;
      result.person_last_longitude :=
        qry.FieldByName('person_last_longitude').AsFloat;
      result.person_last_alive := qry.FieldByName('person_last_alive').AsFloat;
      result.person_license_type := qry.FieldByName('person_license_type')
        .AsInteger;

    finally
      qry.Close;
      FreeAndNil(qry);
    end;
  Except
    on e: exception do
      Tutil.gravalog('[TDAOPERSON-E90]' + e.message);
  end;
end;

procedure TpersonDao.setperson(var value: Tperson);
var
  qry: TFDQuery;
  function parsefloat(value: double): string;
  begin
    result := StringReplace(FloatToStr(value), ',', '.', [rfReplaceAll]);
  end;

begin
  try
    qry := TFDQuery.Create(nil);
    qry.Connection := dm_local.FDConnection1;
    try

      qry.SQL.Add('SELECT * FROM  person');
      qry.open();
      if qry.RecordCount = 0 then
      begin
        qry.SQL.Clear;
        qry.SQL.Add('INSERT  INTO person ');
        qry.SQL.Add(' (');
        qry.SQL.Add('      person_name');
        qry.SQL.Add('     ,person_type');
        qry.SQL.Add('     ,person_date');
        qry.SQL.Add('     ,person_password');
        qry.SQL.Add('     ,person_login ');
        qry.SQL.Add('     ,person_insta_user ');
        qry.SQL.Add('     ,person_insta_password');
        qry.SQL.Add('     ,person_mail ');
        qry.SQL.Add('     ,person_ip ');
        qry.SQL.Add('     ,person_country');
        qry.SQL.Add('     ,person_fone');
        qry.SQL.Add('     ,person_age ');
        qry.SQL.Add('     ,person_adress ');
        qry.SQL.Add('     ,person_initial_latitude');
        qry.SQL.Add('     ,person_initial_longitude');
        qry.SQL.Add('     ,person_last_latitude');
        qry.SQL.Add('     ,person_last_longitude');
        qry.SQL.Add('     ,person_last_alive');
        qry.SQL.Add('     ,person_expire_date');
        qry.SQL.Add('     ,person_license_type ');

        qry.SQL.Add(' )');
        qry.SQL.Add('VALUES');
        qry.SQL.Add(' (');
        qry.SQL.Add('  ' + QuotedStr(value.person_name));
        qry.SQL.Add('  ,1');
        qry.SQL.Add('  ,' + parsefloat(now));
        qry.SQL.Add('  ,' + QuotedStr(value.person_password));
        qry.SQL.Add('  ,' + QuotedStr(value.person_login));
        qry.SQL.Add('  ,' + QuotedStr(value.person_insta_user));
        qry.SQL.Add('  ,' + QuotedStr(value.person_insta_password));
        qry.SQL.Add('  ,' + QuotedStr(value.person_mail));
        qry.SQL.Add('  ,' + QuotedStr('0'));
        qry.SQL.Add('  ,' + QuotedStr('Brazil'));
        qry.SQL.Add('  ,' + QuotedStr(value.person_fone));
        qry.SQL.Add('  ,' + IntToStr(value.person_age));
        qry.SQL.Add('  ,' + QuotedStr(value.person_adress));
        qry.SQL.Add('  ,' + parsefloat(value.person_initial_latitude));
        qry.SQL.Add('  ,' + parsefloat(value.person_initial_longitude));
        qry.SQL.Add('  ,' + parsefloat(value.person_last_latitude));
        qry.SQL.Add('  ,' + parsefloat(value.person_last_longitude));
        qry.SQL.Add('  ,' + parsefloat(value.person_last_alive));
        qry.SQL.Add('  ,' + parsefloat(value.person_expire_date));
        qry.SQL.Add('  ,' + IntToStr(value.person_license_type));

        qry.SQL.Add(' )');
        qry.ExecSQL;

      end
      else
      begin
        qry.SQL.Clear;
        qry.SQL.Add('UPDATE  person ');
        qry.SQL.Add('SET');
        qry.SQL.Add('      person_name  = ' + QuotedStr(value.person_name));
        qry.SQL.Add('     ,person_uuid  = ' + QuotedStr(value.person_uuid));
        qry.SQL.Add('     ,person_password = ' +
          QuotedStr(value.person_password));
        qry.SQL.Add('     ,person_login = ' + QuotedStr(value.person_login));
        qry.SQL.Add('     ,person_insta_user = ' +
          QuotedStr(value.person_insta_user));
        qry.SQL.Add('     ,person_insta_password = ' +
          QuotedStr(value.person_insta_password));
        qry.SQL.Add('     ,person_mail = ' + QuotedStr(value.person_mail));
        qry.SQL.Add('     ,person_fone = ' + QuotedStr(value.person_fone));
        qry.SQL.Add('     ,person_adress =' + QuotedStr(value.person_adress));
        qry.SQL.Add('     ,person_initial_latitude =' +
          parsefloat(value.person_initial_latitude));
        qry.SQL.Add('     ,person_initial_longitude =' +
          parsefloat(value.person_initial_longitude));
        qry.SQL.Add('     ,person_last_latitude =' +
          parsefloat(value.person_last_latitude));
        qry.SQL.Add('     ,person_last_longitude = ' +
          parsefloat(value.person_last_longitude));
        qry.SQL.Add('     ,person_last_alive=' +
          parsefloat(value.person_last_alive));
        qry.SQL.Add('     ,person_expire_date =' +
          parsefloat(value.person_expire_date));
        qry.SQL.Add('     ,person_license_type =' +
          IntToStr(value.person_license_type));

        qry.ExecSQL;
      end;
    finally
      FreeAndNil(qry);
    end
  Except
    on e: exception do
      Tutil.gravalog('[TDAOPERSON-E193]' + e.message);
  end;
end;

end.

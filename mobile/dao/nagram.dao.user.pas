unit nagram.dao.user;

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
  nagram.model.user;

type
  TUserDao = class
  private
  public
    procedure setUser(value: Tuser; rawInsert: Boolean = false);
    function getUsers(criterio: string): Tusers;
    procedure replaceUsers(values: Tusers);
    function getUserByName(Param: string): Tuser;
    function deleteUser(value: integer): string;
    function getcountitens: integer;

  end;

implementation

uses
  nagram.control.person;

{ Tuser }
{ ---------------------------------------------------------------------------- }
function TUserDao.getcountitens: integer;
var
  qry: TFDQuery;
begin
  try
    qry := TFDQuery.Create(nil);
    qry.Connection := dm_local.FDConnection1;
    try
      qry.SQL.Add('SELECT  count(insta_user_id) as count FROM insta_user');
      qry.SQL.Add('WHERE ');
      qry.SQL.Add('  insta_user_person_uuid = ' +
        QuotedStr(GlobalPerson.person.person_uuid));
      qry.open;
      result := qry.Fields[0].AsInteger;

    finally
      qry.Close;
      FreeAndNil(qry);
    end;
  Except
    on e: exception do
      Tutil.gravalog('[TDAOUSER-E75]' + e.message);
  end;
end;

{ ---------------------------------------------------------------------------- }
function TUserDao.deleteUser(value: integer): string;
var
  qry: TFDQuery;
begin
  try
    qry := TFDQuery.Create(nil);
    qry.Connection := dm_local.FDConnection1;

    try
      if value = -6 then
      begin
        qry.SQL.Add('DELETE FROM insta_user WHERE ');
        qry.SQL.Add('  insta_user_person_uuid = ' +
          QuotedStr(GlobalPerson.person.person_uuid));
        qry.ExecSQL;
      end
      else
      begin
        qry.SQL.Add('SELECT   * FROM   insta_user');
        qry.SQL.Add('WHERE ');
        qry.SQL.Add('  insta_user_person_uuid  =' +
          QuotedStr(GlobalPerson.person.person_uuid));
        qry.SQL.Add('  AND  insta_user_id = ' + inttostr(value));
        qry.open;
        if (qry.RecordCount > 0) then
        begin
          result := qry.FieldByName('insta_user_uuid').AsString;
          qry.Close;
          qry.SQL.Clear;
          qry.SQL.Add('DELETE FROM insta_user WHERE insta_user_id =' +
            inttostr(value));
          qry.ExecSQL;
        end;
      end;
    finally
      qry.Close;
      FreeAndNil(qry);
    end;
  Except
    on e: exception do
      Tutil.gravalog('[TDAOUSER-E119]' + e.message);
  end;
end;

{ ---------------------------------------------------------------------------- }
function TUserDao.getUsers(criterio: string): Tusers;
var
  qry: TFDQuery;
  ocout: integer;

  tmpUser: Tuser;
begin
  try
    qry := TFDQuery.Create(nil);
    qry.Connection := dm_local.FDConnection1;
    try
      qry.SQL.Add('SELECT   * FROM insta_user');
      qry.SQL.Add('WHERE ');
      qry.SQL.Add('  insta_user_person_uuid = ' +
        QuotedStr(GlobalPerson.person.person_uuid));
      if criterio <> '' then
      begin

        qry.SQL.Add(' AND  ' + criterio);

      end;
      qry.open;
      qry.Last;
      result := TObjectList<Tuser>.Create;
      qry.First;

      while not qry.Eof do
      begin
        tmpUser := Tuser.Create;
        tmpUser.insta_user_Id := qry.FieldByName('insta_user_id').AsInteger;
        tmpUser.insta_user_Date := qry.FieldByName('insta_user_date').value;
        tmpUser.insta_user_last_visit :=
          qry.FieldByName('insta_user_last_visit').value;
        tmpUser.insta_user_Followed := qry.FieldByName('insta_user_followed')
          .AsInteger;
        tmpUser.insta_user_Follow := qry.FieldByName('insta_user_follow')
          .AsInteger;
        tmpUser.insta_user_Posts := qry.FieldByName('insta_user_posts')
          .AsInteger;
        tmpUser.insta_user_date_follow :=
          qry.FieldByName('insta_user_date_follow').value;
        tmpUser.insta_user_Bio := qry.FieldByName('insta_user_bio').AsString;
        tmpUser.insta_user_Following := qry.FieldByName('insta_user_following')
          .AsInteger;
        tmpUser.insta_user_Name := qry.FieldByName('insta_user_name').AsString;
        tmpUser.insta_user_person_uuid :=
          qry.FieldByName('insta_user_person_uuid').AsString;
        tmpUser.insta_user_uuid := qry.FieldByName('insta_user_uuid').AsString;
        result.Add(tmpUser);
        qry.Next;
      end;
    finally
      qry.Close;
      FreeAndNil(qry);
    end;
  Except
    on e: exception do
      Tutil.gravalog('[TDAOUSER-E181]' + e.message);
  end;
end;

{ ---------------------------------------------------------------------------- }
procedure TUserDao.replaceUsers(values: Tusers);
var
  qry: TFDQuery;
  i: integer;
  value: Tuser;
  sep: string;
  lstvalues: tstringList;
begin
  try
    if values.Count > 0 then
    begin
      qry := TFDQuery.Create(nil);
      qry.Connection := dm_local.FDConnection1;
      try
        qry.SQL.Clear;
        qry.SQL.Add('delete from insta_user where ');
        qry.SQL.Add(' insta_user_person_uuid = ' +
          QuotedStr(GlobalPerson.person.person_uuid));
        qry.ExecSQL;
        qry.SQL.Clear;
        qry.SQL.Add('INSERT INTO insta_user');
        qry.SQL.Add('( ');
        qry.SQL.Add('   insta_user_name  ');
        qry.SQL.Add('  ,insta_user_date  ');
        qry.SQL.Add(' ,insta_user_last_visit');
        qry.SQL.Add(' ,insta_user_followed');
        qry.SQL.Add(' ,insta_user_follow');
        qry.SQL.Add(' ,insta_user_posts  ');
        qry.SQL.Add(' ,insta_user_date_follow  ');
        qry.SQL.Add(' ,insta_user_bio  ');
        qry.SQL.Add(' ,insta_user_following ');
        qry.SQL.Add(' ,insta_user_uuid  ');
        qry.SQL.Add(' ,insta_user_person_uuid ');

        qry.SQL.Add(' )');
        qry.SQL.Add('VALUES ');
        lstvalues := tstringList.Create;
        for i := 0 to values.Count - 1 do
        begin
          value := values[i];
          lstvalues.Add(sep + '( ');
          lstvalues.Add('  ' + QuotedStr(value.insta_user_Name));
          if value.insta_user_Date > 0 then
            lstvalues.Add
              ('  ,' + StringReplace(FloatToStr(value.insta_user_Date), ',',
              '.', [rfReplaceAll]))
          else
            lstvalues.Add('  ,' + StringReplace(FloatToStr(now), ',', '.',
              [rfReplaceAll]));

          if value.insta_user_last_visit > 0 then
            lstvalues.Add
              ('  ,' + StringReplace(FloatToStr(value.insta_user_last_visit),
              ',', '.', [rfReplaceAll]))
          else
            lstvalues.Add('  ,' + StringReplace(FloatToStr(now), ',', '.',
              [rfReplaceAll]));
          lstvalues.Add('  ,' + inttostr(value.insta_user_Followed));
          lstvalues.Add('  ,' + inttostr(value.insta_user_Follow));
          lstvalues.Add('  ,' + inttostr(value.insta_user_Posts));
          if value.insta_user_date_follow > 0 then
            lstvalues.Add
              ('  ,' + StringReplace(FloatToStr(value.insta_user_date_follow),
              ',', '.', [rfReplaceAll]))
          else
            lstvalues.Add('  ,' + StringReplace(FloatToStr(now), ',', '.',
              [rfReplaceAll]));

          lstvalues.Add('  ,' + QuotedStr(value.insta_user_Bio));
          lstvalues.Add('  ,' + inttostr(value.insta_user_Following));
          lstvalues.Add('  ,' + QuotedStr(value.insta_user_uuid));
          lstvalues.Add('  ,' + QuotedStr(GlobalPerson.person.person_uuid));

          lstvalues.Add(' ) ');
          sep := ' , ';
          // FreeAndNil(values[i]);
        end;
        qry.SQL.Text := qry.SQL.Text + lstvalues.Text;

        qry.ExecSQL;
      finally
        FreeAndNil(qry);
        FreeAndNil(lstvalues);
      end
    end;
  Except
    on e: exception do
      Tutil.gravalog('[TDAOUSER-E269]' + e.message);
  end;
end;

{ ---------------------------------------------------------------------------- }
procedure TUserDao.setUser(value: Tuser; rawInsert: Boolean = false);
var
  qry: TFDQuery;
begin
  try
    qry := TFDQuery.Create(nil);
    qry.Connection := dm_local.FDConnection1;
    try
      if not rawInsert then
      begin
        qry.SQL.Add('SELECT  insta_user_id   FROM insta_user');
        qry.SQL.Add('WHERE ');
        qry.SQL.Add(' ( insta_user_name   = ' +
          QuotedStr(value.insta_user_Name));

        qry.SQL.Add('  or insta_user_uuid  = ' +
          QuotedStr(value.insta_user_uuid));
        qry.SQL.Add('  )      ');
        qry.SQL.Add('  AND insta_user_person_uuid = ' +
          QuotedStr(GlobalPerson.person.person_uuid));
        qry.open;
        if qry.RecordCount > 0 then
        begin

          value.insta_user_Id := qry.FieldByName('insta_user_id').AsInteger;
        end;
      end;
      qry.Close;
      if value.insta_user_Id = 0 then
      begin
        qry.SQL.Clear;
        qry.SQL.Add('INSERT INTO insta_user');
        qry.SQL.Add('( ');
        qry.SQL.Add('   insta_user_name  ');
        qry.SQL.Add('  ,insta_user_date  ');
        qry.SQL.Add(' ,insta_user_last_visit');
        qry.SQL.Add(' ,insta_user_followed');
        qry.SQL.Add(' ,insta_user_follow');
        qry.SQL.Add(' ,insta_user_posts  ');
        qry.SQL.Add(' ,insta_user_date_follow  ');
        qry.SQL.Add(' ,insta_user_bio  ');
        qry.SQL.Add(' ,insta_user_following ');
        qry.SQL.Add(' ,insta_user_uuid  ');
        qry.SQL.Add(' ,insta_user_person_uuid ');

        qry.SQL.Add(' )');
        qry.SQL.Add('VALUES ');
        qry.SQL.Add('( ');
        qry.SQL.Add('  ' + QuotedStr(value.insta_user_Name));
        if value.insta_user_Date > 0 then
          qry.SQL.Add('  ,' + StringReplace(FloatToStr(value.insta_user_Date),
            ',', '.', [rfReplaceAll]))
        else
          qry.SQL.Add('  ,' + StringReplace(FloatToStr(now), ',', '.',
            [rfReplaceAll]));

        if value.insta_user_last_visit > 0 then
          qry.SQL.Add('  ,' + StringReplace
            (FloatToStr(value.insta_user_last_visit), ',', '.', [rfReplaceAll]))
        else
          qry.SQL.Add('  ,' + StringReplace(FloatToStr(now), ',', '.',
            [rfReplaceAll]));
        qry.SQL.Add('  ,' + inttostr(value.insta_user_Followed));
        qry.SQL.Add('  ,' + inttostr(value.insta_user_Follow));
        qry.SQL.Add('  ,' + inttostr(value.insta_user_Posts));
        if value.insta_user_date_follow > 0 then
          qry.SQL.Add('  ,' + StringReplace
            (FloatToStr(value.insta_user_date_follow), ',', '.',
            [rfReplaceAll]))
        else
          qry.SQL.Add('  ,' + StringReplace(FloatToStr(now), ',', '.',
            [rfReplaceAll]));

        qry.SQL.Add('  ,' + QuotedStr(value.insta_user_Bio));
        qry.SQL.Add('  ,' + inttostr(value.insta_user_Following));
        qry.SQL.Add('  ,' + QuotedStr(value.insta_user_uuid));
        qry.SQL.Add('  ,' + QuotedStr(GlobalPerson.person.person_uuid));
        qry.SQL.Add(' );');
        qry.ExecSQL;
        qry.SQL.Clear;
        qry.SQL.Add('SELECT   insta_user_id FROM insta_user');
        qry.SQL.Add('WHERE ');
        qry.SQL.Add(' insta_user_name   = ' + QuotedStr(value.insta_user_Name));

        qry.SQL.Add('  and  insta_user_person_uuid  = ' +
          QuotedStr(GlobalPerson.person.person_uuid));
        qry.open;
        value.insta_user_Id := qry.FieldByName('insta_user_id').AsInteger;
        qry.Close;
        qry.SQL.Clear;
      end
      else
      begin
        qry.SQL.Clear;
        qry.SQL.Add('UPDATE  insta_user');
        qry.SQL.Add('SET ');

        qry.SQL.Add('  insta_user_last_visit =' +
          StringReplace(FloatToStr(value.insta_user_last_visit), ',', '.',
          [rfReplaceAll]));
        if value.insta_user_Followed > (-1) then
          qry.SQL.Add(' ,insta_user_followed = ' +
            inttostr(value.insta_user_Followed));
        if value.insta_user_Posts > (-1) then
          qry.SQL.Add(' ,insta_user_posts = ' +
            inttostr(value.insta_user_Posts));

        if value.insta_user_Follow > (-1) then
          qry.SQL.Add(' ,insta_user_follow = ' +
            inttostr(value.insta_user_Follow));

        if value.insta_user_date_follow > (-1) then
          qry.SQL.Add(' ,insta_user_date_follow =  ' +
            StringReplace(FloatToStr(value.insta_user_date_follow), ',', '.',
            [rfReplaceAll]));
        if value.insta_user_Bio <> '' then
          qry.SQL.Add(' ,insta_user_bio  = ' + QuotedStr(value.insta_user_Bio));

        if value.insta_user_uuid <> '' then
          qry.SQL.Add(' ,insta_user_uuid  = ' +
            QuotedStr(value.insta_user_uuid));

        qry.SQL.Add(' ,insta_user_person_uuid = ' +
          QuotedStr(GlobalPerson.person.person_uuid));
        if value.insta_user_Following > (-1) then
          qry.SQL.Add(' ,insta_user_following =  ' +
            inttostr(value.insta_user_Following));

        qry.SQL.Add('WHERE   ');
        qry.SQL.Add('  insta_user_id = ' + inttostr(value.insta_user_Id));
        qry.ExecSQL;
      end;
    finally
      FreeAndNil(qry);
    end
  Except
    on e: exception do
      Tutil.gravalog('[TDAOUSER-E406]' + e.message);
  end;
end;

{ ---------------------------------------------------------------------------- }
function TUserDao.getUserByName(Param: string): Tuser;
var
  qry: TFDQuery;
begin
  try
    qry := TFDQuery.Create(nil);
    qry.Connection := dm_local.FDConnection1;
{$IF DEFINED(iOS) or DEFINED(ANDROID)}
    if Param[0] = '"' then
    begin
      Param := copy(Param, 2, length(Param));

      if (length(Param) > 2) and (Param[length(Param) - 1] = '"') then
        Param := copy(Param, 0, length(Param) - 2);
    end;
{$ELSE}
    if Param[1] = '"' then
    begin
      Param := copy(Param, 2, length(Param));
      if Param[length(Param)] = '"' then
        Param := copy(Param, 0, length(Param) - 1);
    end;

{$ENDIF}
    try
      qry.SQL.Add('SELECT   * FROM insta_user');
      qry.SQL.Add('WHERE ');
      qry.SQL.Add('  insta_user_name   = ' + QuotedStr(Param));
      qry.SQL.Add('  and insta_user_person_uuid = ' +
        QuotedStr(GlobalPerson.person.person_uuid));
      qry.open;
      result := Tuser.Create;
      result.insta_user_Id := qry.FieldByName('insta_user_id').AsInteger;
      result.insta_user_Date := qry.FieldByName('insta_user_date').AsFloat;
      result.insta_user_last_visit :=
        qry.FieldByName('insta_user_last_visit').AsFloat;
      result.insta_user_Followed := qry.FieldByName('insta_user_followed')
        .AsInteger;
      result.insta_user_Follow := qry.FieldByName('insta_user_follow')
        .AsInteger;
      result.insta_user_Posts := qry.FieldByName('insta_user_posts').AsInteger;
      result.insta_user_date_follow :=
        qry.FieldByName('insta_user_date_follow').AsFloat;
      result.insta_user_Bio := qry.FieldByName('insta_user_bio').AsString;
      result.insta_user_Following := qry.FieldByName('insta_user_following')
        .AsInteger;
      result.insta_user_Name := qry.FieldByName('insta_user_name').AsString;
      result.insta_user_person_uuid :=
        qry.FieldByName('insta_user_person_uuid').AsString;
      result.insta_user_uuid := qry.FieldByName('insta_user_uuid').AsString;

      qry.Close;
    finally
      FreeAndNil(qry);
    end;
  Except
    on e: exception do
      Tutil.gravalog('[TDAOUSER-E466]' + e.message);
  end;
end;

{ ---------------------------------------------------------------------------- }
end.

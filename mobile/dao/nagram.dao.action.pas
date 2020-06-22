unit nagram.dao.action;

interface

uses
  System.SysUtils,
  System.Generics.Collections,
  dateutils,
  System.Classes,
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
  nagram.model.action;

type
  TActionDao = class
  private
  public
    procedure setAction(value: TBotAction; rawInsert: Boolean = false);
    function getAction(): TBotAction;
    function getActions(criterio: string): TBotActions;
    procedure replaceActions(values: TBotActions);
    function deleteAction(value: integer): string;
    function getcountitens: integer;
    class function getLastActionDate: TdateTime;
    class function getCountLikeHour:Integer;

  end;

implementation

uses
  nagram.control.person;

{ TactionDao }
function TActionDao.deleteAction(value: integer): string;
var
  qry: TFDQuery;
begin
  try
    qry := TFDQuery.Create(nil);
    qry.Connection := dm_local.FDConnection1;

    try
      if value = -6 then
      begin
        qry.SQL.Clear;
        qry.SQL.Add('DELETE FROM insta_action WHERE ');
        qry.SQL.Add('  insta_action_person_uuid  =' +
          QuotedStr(GlobalPerson.person.person_uuid));
        qry.ExecSQL;
      end
      else
      begin
        qry.SQL.Clear;
        qry.SQL.Add('SELECT   * FROM   insta_action');
        qry.SQL.Add('WHERE ');
        qry.SQL.Add('  insta_action_person_uuid  = ' +
          QuotedStr(GlobalPerson.person.person_uuid));
        qry.SQL.Add('  AND  insta_action_id = ' + inttostr(value));
        qry.open;
        if qry.RecordCount > 0 then
        begin
          result := qry.FieldByName('insta_action_uuid').AsString;
          qry.Close;
          qry.SQL.Clear;
          qry.SQL.Add('DELETE FROM insta_action WHERE insta_action_id =' +
            inttostr(value));
          qry.ExecSQL;
        end;
      end;
    finally
      qry.Close;
      FreeAndNil(qry);
    end;

  except
    on e: exception do
      Tutil.gravalog('[TDAOACTION-E97]' + e.message);
  end;
end;

{ ------------------------------------------------------------------------------ }
function TActionDao.getAction(): TBotAction;
var
  qry: TFDQuery;
begin
  try
    qry := TFDQuery.Create(nil);
    qry.Connection := dm_local.FDConnection1;
    try
      qry.SQL.Add('SELECT   * FROM INSTA_ACTION');
      qry.SQL.Add('WHERE ');
      qry.SQL.Add('  insta_action_person_uuid = ' +
        QuotedStr(GlobalPerson.person.person_uuid));
      qry.open;
      result := TBotAction.Create;
      result.insta_action_Id := qry.FieldByName('insta_action_id').AsInteger;
      result.insta_action_date := qry.FieldByName('insta_action_date').asfloat;
      result.insta_action_comment :=
        qry.FieldByName('insta_action_comment').AsString;
      result.insta_action_Person_uuid :=
        qry.FieldByName('insta_action_person_uuid').AsString;
      result.insta_action_uuid := qry.FieldByName('insta_action_uuid').AsString;
      result.insta_action_insta_user_name :=
        qry.FieldByName('insta_action_insta_user_name').AsString;
      result.insta_action_type := qry.FieldByName('insta_action_type')
        .AsInteger;
      result.insta_action_Url := qry.FieldByName('insta_action_url').AsString;

    finally
      FreeAndNil(qry);
    end;
  except
    on e: exception do
      Tutil.gravalog('[TDAOACTION-E133]' + e.message);

  end;
end;

{ ------------------------------------------------------------------------------ }
function TActionDao.getcountitens: integer;

var
  qry: TFDQuery;
begin
  try
    qry := TFDQuery.Create(nil);
    qry.Connection := dm_local.FDConnection1;
    try
      qry.SQL.Add('SELECT  count(insta_action_id) as count FROM insta_action');
      qry.SQL.Add('WHERE ');
      qry.SQL.Add('  insta_action_person_uuid = ' +
        QuotedStr(GlobalPerson.person.person_uuid));

      qry.open;
      result := qry.Fields[0].AsInteger;

    finally
      qry.Close;
      FreeAndNil(qry);
    end;
  except
    on e: exception do
      Tutil.gravalog('[TDAOACTION-E149]' + e.message);

  end;
end;

class function TActionDao.getCountLikeHour: Integer;
var
  qry: TFDQuery;
begin
  try
    result:=0;
    qry := TFDQuery.Create(nil);
    qry.Connection := dm_local.FDConnection1;
    try
      qry.SQL.Add('SELECT  count(insta_action_id) as count FROM insta_action');
      qry.SQL.Add('WHERE ');
      qry.SQL.Add('  insta_action_person_uuid = ' +
        QuotedStr(GlobalPerson.person.person_uuid));

      qry.SQL.Add(' AND   insta_action_date > :adata');
      qry.SQL.Add('GROUP BY  insta_action_insta_user_name');
      qry.ParamByName('adata').AsDateTime :=IncHour(now, -1);
      qry.open;
      if  qry.RecordCount > 0 then
        result := qry.Fields[0].AsInteger;

    finally
      qry.Close;
      FreeAndNil(qry);
    end;
  except
    on e: exception do
      Tutil.gravalog('[TDAOACTION-E193]' + e.message);

  end;
end;

{ ----------------------------------------------------------------------------- }
function TActionDao.getActions(criterio: string): TBotActions;
var
  qry: TFDQuery;

  tmpAction: TBotAction;
begin
  try
    qry := TFDQuery.Create(nil);
    qry.Connection := dm_local.FDConnection1;
    try
      qry.SQL.Add('SELECT   * FROM INSTA_ACTION  ');
      qry.SQL.Add('WHERE ');
      qry.SQL.Add('  insta_action_person_uuid = ' +
        QuotedStr(GlobalPerson.person.person_uuid));
      if criterio <> '' then
      begin
        qry.SQL.Add(' AND ' + criterio);
      end;
      qry.open;
      qry.Last;

      result := TObjectList<TBotAction>.Create;
      qry.First;

      while not qry.Eof do
      begin
        tmpAction := TBotAction.Create;
        tmpAction.insta_action_Id := qry.FieldByName('insta_action_id')
          .AsInteger;
        tmpAction.insta_action_date :=
          qry.FieldByName('insta_action_date').asfloat;
        tmpAction.insta_action_comment :=
          qry.FieldByName('insta_action_comment').AsString;
        tmpAction.insta_action_Person_uuid :=
          qry.FieldByName('insta_action_person_uuid').AsString;
        tmpAction.insta_action_uuid :=
          qry.FieldByName('insta_action_uuid').AsString;
        tmpAction.insta_action_insta_user_name :=
          qry.FieldByName('insta_action_insta_user_name').AsString;
        tmpAction.insta_action_type := qry.FieldByName('insta_action_type')
          .AsInteger;
        tmpAction.insta_action_Url :=
          qry.FieldByName('insta_action_url').AsString;
        result.Add(tmpAction);
        qry.next;
      end;

    finally
      FreeAndNil(qry);
    end;
  except
    on e: exception do
      Tutil.gravalog('[TDAOACTION-E207]' + e.message);
  end;
end;

{ ----------------------------------------------------------------------------- }
procedure TActionDao.replaceActions(values: TBotActions);
var
  qry: TFDQuery;
  i: integer;
  value: TBotAction;
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
        qry.SQL.Add('delete from insta_action where ');
        qry.SQL.Add(' insta_action_person_uuid = ' +
          QuotedStr(GlobalPerson.person.person_uuid));
        qry.ExecSQL;
        qry.SQL.Clear;
        qry.SQL.Add('INSERT INTO insta_action');
        qry.SQL.Add('( ');
        qry.SQL.Add('  insta_action_date  ');
        qry.SQL.Add(' ,insta_action_comment ');
        qry.SQL.Add(' ,insta_action_insta_user_name  ');
        qry.SQL.Add(' ,insta_action_person_uuid  ');
        qry.SQL.Add(' ,insta_action_uuid  ');
        qry.SQL.Add(' ,insta_action_type  ');
        qry.SQL.Add(' ,insta_action_url  ');
        qry.SQL.Add(' )');
        qry.SQL.Add('VALUES ');

        lstvalues := tstringList.Create;
        for i := 0 to values.Count - 1 do
        begin
          value := values[i];
          if value.insta_action_uuid <> '' then
          begin
            lstvalues.Add(sep + '( ');

            lstvalues.Add
              ('  ' + StringReplace(FloatToStr(value.insta_action_date), ',',
              '.', [rfReplaceAll]));
            lstvalues.Add('  ,' + QuotedStr(value.insta_action_comment));
            lstvalues.Add
              ('  ,' + QuotedStr(value.insta_action_insta_user_name));
            lstvalues.Add('  ,' + QuotedStr(GlobalPerson.person.person_uuid));
            lstvalues.Add('  ,' + QuotedStr(value.insta_action_uuid));
            lstvalues.Add('  ,' + inttostr(value.insta_action_type));
            lstvalues.Add('  ,' + QuotedStr(value.insta_action_Url));
            lstvalues.Add(' )');
            sep := ' , ';
          end;
          // FreeAndNil(values[i]);
        end;
        qry.SQL.Text := qry.SQL.Text + lstvalues.Text;
        qry.ExecSQL;
      finally
        FreeAndNil(qry);
        FreeAndNil(lstvalues);
      end
    end;
  except
    on e: exception do
      Tutil.gravalog('[TDAOACTION-E276]' + e.message);
  end;
end;

class function TActionDao.getLastActionDate: TdateTime;
var
  qry: TFDQuery;
begin
  try
    result := 0;
    try

      qry := TFDQuery.Create(nil);
      qry.Connection := dm_local.FDConnection1;
      qry.SQL.Clear;
      qry.SQL.Add('SELECT   max(insta_action_date) FROM   insta_action');
      qry.SQL.Add('WHERE ');
      qry.SQL.Add('  insta_action_person_uuid  = ' +
        QuotedStr(GlobalPerson.person.person_uuid));
      qry.open;
      result := qry.Fields[0].AsDateTime;
      qry.Close;
    finally
      FreeAndNil(qry);
    end
  except
    on e: exception do
      Tutil.gravalog('[TDAOACTION-E320]' + e.message);
  end;
end;

{ ----------------------------------------------------------------------------- }
procedure TActionDao.setAction(value: TBotAction; rawInsert: Boolean = false);
var
  qry: TFDQuery;
begin
  try
    qry := TFDQuery.Create(nil);
    qry.Connection := dm_local.FDConnection1;

    try
      if not rawInsert then
      begin
        if value.insta_action_uuid <> '' then
        begin
          qry.SQL.Add
            ('select insta_action_Id  from insta_action where insta_action_uuid = '
            + QuotedStr(value.insta_action_uuid));
          qry.open();
          if qry.RecordCount > 0 then
            value.insta_action_Id := qry.Fields[0].AsInteger;
        end;
      end;
      qry.Close;
      if value.insta_action_Id <= 0 then
      begin
        qry.SQL.Clear;
        qry.SQL.Add('INSERT INTO INSTA_ACTION');
        qry.SQL.Add('( ');
        qry.SQL.Add('  insta_action_date  ');
        qry.SQL.Add(' ,insta_action_comment ');
        qry.SQL.Add(' ,insta_action_insta_user_name  ');
        qry.SQL.Add(' ,insta_action_person_uuid  ');
        qry.SQL.Add(' ,insta_action_uuid  ');
        qry.SQL.Add(' ,insta_action_type  ');
        qry.SQL.Add(' ,insta_action_url  ');
        qry.SQL.Add(' )');
        qry.SQL.Add('VALUES ');
        qry.SQL.Add('( ');
        qry.SQL.Add('  ' + StringReplace(FloatToStr(value.insta_action_date),
          ',', '.', [rfReplaceAll]));
        qry.SQL.Add('  ,' + QuotedStr(value.insta_action_comment));
        qry.SQL.Add('  ,' + QuotedStr(value.insta_action_insta_user_name));
        qry.SQL.Add('  ,' + QuotedStr(GlobalPerson.person.person_uuid));
        qry.SQL.Add('  ,' + QuotedStr(value.insta_action_uuid));
        qry.SQL.Add('  ,' + inttostr(value.insta_action_type));
        qry.SQL.Add('  ,' + QuotedStr(value.insta_action_Url));
        qry.SQL.Add(' );');
        qry.ExecSQL;
      end
      else
      begin
        qry.SQL.Clear;
        qry.SQL.Add('UPDATE  INSTA_ACTION');
        qry.SQL.Add('SET ');
        qry.SQL.Add('  insta_action_date  =  ' +
          StringReplace(FloatToStr(value.insta_action_date), ',', '.',
          [rfReplaceAll]));
        qry.SQL.Add(' ,insta_action_comment = ' +
          QuotedStr(value.insta_action_comment));

        qry.SQL.Add(' ,insta_action_uuid = ' +
          QuotedStr(value.insta_action_uuid));

        qry.SQL.Add(' ,insta_action_person_uuid = ' +
          QuotedStr(GlobalPerson.person.person_uuid));
        qry.SQL.Add(' ,insta_action_insta_user_name = ' +
          QuotedStr(value.insta_action_insta_user_name));
        qry.SQL.Add(' ,insta_action_type = ' +
          inttostr(value.insta_action_type));
        qry.SQL.Add(' ,insta_action_url =' + QuotedStr(value.insta_action_Url));

        qry.SQL.Add('WHERE   ');
        qry.SQL.Add(' insta_action_id = ' + inttostr(value.insta_action_Id));
        qry.ExecSQL;
      end;
    finally
      FreeAndNil(qry);
    end
  except
    on e: exception do
      Tutil.gravalog('[TDAOACTION-E359]' + e.message);
  end;
end;

{ ----------------------------------------------------------------------------- }
end.

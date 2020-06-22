unit nagram.dao.comment;

interface

uses
  System.SysUtils,
  System.Generics.Collections,
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
  nagram.android.util,
  nagram.datamodule,
  nagram.model.comment;

type
  TCommentDao = class
  private
  public
    procedure setComment(var value: TComment);
    function getComment(value: integer): TComment;
    function getComments(criterio: string): TComments;
    function deleteComment(value: integer): string;
    function getcountitens: integer;
    procedure replaceComments(values: TComments);
  end;

implementation

uses
  nagram.control.person;
{ Tuser }

function TCommentDao.getcountitens: integer;
var
  qry: TFDQuery;
begin
  try
    qry := TFDQuery.Create(nil);
    qry.Connection := dm_local.FDConnection1;
    try
      qry.SQL.Add
        ('SELECT  count(insta_comment_id) as count FROM insta_comments');
      qry.SQL.Add('WHERE ');
      qry.SQL.Add('  insta_comment_person_uuid = ' +
        QuotedStr(GlobalPerson.person.person_uuid));
      qry.open;
      result := qry.Fields[0].AsInteger;

    finally
      qry.Close;
      FreeAndNil(qry);
    end;
  Except
    on e: exception do
      Tutil.gravalog('[TDAOCOMMENTS-E76]' + e.message);
  end;
end;
{-----------------------------------------------------------------------------}
procedure TCommentDao.replaceComments(values: TComments);
var
  qry: TFDQuery;
  lstvalues: tstringList;
  i: integer;
  value: TComment;
  sep: string;
begin
  try
    if values.Count > 0  then
    begin
      qry := TFDQuery.Create(nil);
      qry.Connection := dm_local.FDConnection1;
      try
        qry.SQL.Add('delete    FROM insta_comments');
        qry.SQL.Add('WHERE ');

        qry.SQL.Add('  insta_comment_person_uuid  = ' +
          QuotedStr(GlobalPerson.person.person_uuid));
        qry.ExecSQL;

        qry.SQL.Clear;
        qry.SQL.Add('INSERT INTO insta_comments');
        qry.SQL.Add('( ');
        qry.SQL.Add('   insta_comment_text  ');
        qry.SQL.Add('  ,insta_comment_uuid ');
        qry.SQL.Add('  ,insta_comment_person_uuid ');
        qry.SQL.Add('  ,insta_comment_date  ');
        lstvalues := tstringList.Create;

        qry.SQL.Add(' )');
        qry.SQL.Add('VALUES ');
        lstvalues := tstringList.Create;
        for i := 0 to values.Count - 1 do
        begin
          value := values[i];
          if value.insta_comment_uuid <> '' then
          begin
            lstvalues.Add(sep + '( ');

            lstvalues.Add('   ' + QuotedStr(value.insta_comment_Text));
            lstvalues.Add('  ,' + QuotedStr(value.insta_comment_uuid));
            lstvalues.Add('  ,' + QuotedStr(GlobalPerson.person.person_uuid));
            lstvalues.Add
              ('  ,' + StringReplace(FloatToStr(value.insta_comment_Date), ',',
              '.', [rfReplaceAll]));

            lstvalues.Add(' )');
            sep := ' , ';
          end;
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
      Tutil.gravalog('[TDAOCOMMENTS-E139]' + e.message);
  end;
end;
{-----------------------------------------------------------------------------}
function TCommentDao.deleteComment(value: integer): string;
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
        qry.SQL.Add('DELETE FROM insta_comments WHERE ');
        qry.SQL.Add('  insta_comment_person_uuid = ' +
          QuotedStr(GlobalPerson.person.person_uuid));
        qry.ExecSQL;
      end
      else
      begin
        qry.SQL.Clear;
        qry.SQL.Add('SELECT   * FROM   insta_comments');
        qry.SQL.Add('WHERE ');
        qry.SQL.Add('  insta_comment_person_uuid  = ' +
          QuotedStr(GlobalPerson.person.person_uuid));
        qry.SQL.Add('  AND  insta_comment_id = ' + inttostr(value));
        qry.open;
        if qry.RecordCount > 0 then
        begin
          result := qry.FieldByName('insta_comment_uuid').AsString;
          qry.Close;
          qry.SQL.Clear;
          qry.SQL.Add('DELETE FROM insta_comments WHERE insta_comment_id =' +
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
      Tutil.gravalog('[TDAOCOMMENTS-E184]' + e.message);
  end;
end;

function TCommentDao.getComment(value: integer): TComment;
var
  qry: TFDQuery;
begin
  try
    qry := TFDQuery.Create(nil);
    qry.Connection := dm_local.FDConnection1;

    try
      qry.SQL.Add('SELECT   * FROM   insta_comments');
      qry.SQL.Add('WHERE ');
      qry.SQL.Add('  insta_comment_person_uuid ' +
        QuotedStr(GlobalPerson.person.person_uuid));
      qry.SQL.Add('  AND  insta_comment_id = ' + inttostr(value));
      qry.open;
      result := TComment.Create;
      result.insta_comment_Id := qry.FieldByName('insta_comment_id').AsInteger;
      result.insta_comment_uuid :=
        qry.FieldByName('insta_comment_uuid').AsString;
      result.insta_comment_person_uuid :=
        qry.FieldByName('insta_comment_person_uuid').AsString;
      result.insta_comment_Date := qry.FieldByName('insta_comment_date').value;
      result.insta_comment_Text := qry.FieldByName('insta_comment_text').value;

    finally
      qry.Close;
      FreeAndNil(qry);
    end;
  Except
    on e: exception do
      Tutil.gravalog('[TDAOCOMMENTS-E217]' + e.message);
  end;
end;
{-----------------------------------------------------------------------------}
function TCommentDao.getComments(criterio: string): TComments;
var
  qry: TFDQuery;
  ocout: integer;

  tmp: TComment;
begin
  try
    qry := TFDQuery.Create(nil);
    qry.Connection := dm_local.FDConnection1;
    try
      qry.SQL.Add('SELECT   * FROM   insta_comments');

      qry.SQL.Add('WHERE ');
      qry.SQL.Add('  insta_comment_person_uuid = ' +
        QuotedStr(GlobalPerson.person.person_uuid));
      if criterio <> '' then
      begin

        qry.SQL.Add(' and  ' + criterio);
      end;
      qry.open;
      qry.Last;
      qry.First;
     result:=TObjectList<Tcomment>.Create;
      while not qry.Eof do
      begin
        tmp := TComment.Create;
        tmp.insta_comment_Id := qry.FieldByName('insta_comment_id').AsInteger;
        tmp.insta_comment_uuid := qry.FieldByName('insta_comment_uuid')
          .AsString;
        tmp.insta_comment_person_uuid :=
          qry.FieldByName('insta_comment_person_uuid').AsString;
        tmp.insta_comment_Date := qry.FieldByName('insta_comment_date').value;
        tmp.insta_comment_Text := qry.FieldByName('insta_comment_text').value;
        result.add( tmp);

        qry.Next;
      end;

    finally
      qry.Close;
      FreeAndNil(qry);
    end;
  Except
    on e: exception do
      Tutil.gravalog('[TDAOCOMMENTS-E268]' + e.message);
  end;
end;
{-----------------------------------------------------------------------------}
procedure TCommentDao.setComment(var value: TComment);
var
  qry: TFDQuery;
begin
  try
    qry := TFDQuery.Create(nil);
    qry.Connection := dm_local.FDConnection1;
    try
      if value.insta_comment_Id = 0 then
      begin
        qry.SQL.Add('SELECT  insta_comment_id   FROM insta_comments');
        qry.SQL.Add('WHERE ');
        qry.SQL.Add(' ( insta_comment_text   = ' +
          QuotedStr(value.insta_comment_Text));

        qry.SQL.Add(' OR  insta_comment_uuid =' +
          QuotedStr(value.insta_comment_uuid));
        qry.SQL.Add(' )');
        qry.SQL.Add(' and  insta_comment_person_uuid  = ' +
          QuotedStr(GlobalPerson.person.person_uuid));
        qry.open;
        if qry.RecordCount > 0 then
        begin
          value.insta_comment_Id := qry.FieldByName('insta_comment_id')
            .AsInteger;
        end;
      end;
      qry.Close;
      if value.insta_comment_Id = 0 then
      begin
        qry.SQL.Clear;
        qry.SQL.Add('INSERT INTO insta_comments');
        qry.SQL.Add('( ');
        qry.SQL.Add('   insta_comment_text  ');
        qry.SQL.Add('  ,insta_comment_uuid ');
        qry.SQL.Add('  ,insta_comment_person_uuid ');
        qry.SQL.Add('  ,insta_comment_date  ');

        qry.SQL.Add(' )');
        qry.SQL.Add('VALUES ');
        qry.SQL.Add('( ');
        qry.SQL.Add('   ' + QuotedStr(value.insta_comment_Text));
        qry.SQL.Add('  ,' + QuotedStr(value.insta_comment_uuid));
        qry.SQL.Add('  ,' + QuotedStr(GlobalPerson.person.person_uuid));
        qry.SQL.Add('  ,' + StringReplace(FloatToStr(value.insta_comment_Date),
          ',', '.', [rfReplaceAll]));

        qry.SQL.Add(' );');
        qry.ExecSQL;
        qry.SQL.Clear;
        qry.SQL.Add('SELECT insta_comment_id FROM  insta_comments');
        qry.SQL.Add('WHERE ');
        qry.SQL.Add(' insta_comment_text   = ' +
          QuotedStr(value.insta_comment_Text));
        qry.SQL.Add('  and insta_comment_person_uuid = ' +
          QuotedStr(GlobalPerson.person.person_uuid));
        qry.open;
        value.insta_comment_Id := qry.FieldByName('insta_comment_id').AsInteger;
        qry.Close;
        qry.SQL.Clear;

      end
      else
      begin
        qry.SQL.Clear;
        qry.SQL.Add('UPDATE   insta_comments');
        qry.SQL.Add('SET ');

        qry.SQL.Add('  insta_comment_date =' +
          StringReplace(FloatToStr(value.insta_comment_Date), ',', '.',
          [rfReplaceAll]));
        if value.insta_comment_Text <> '' then
          qry.SQL.Add(' ,insta_comment_text = ' +
            QuotedStr(value.insta_comment_Text));

        if value.insta_comment_uuid <> '' then
          qry.SQL.Add(' ,insta_comment_uuid = ' +
            QuotedStr(value.insta_comment_uuid));

        qry.SQL.Add('WHERE   ');
        qry.SQL.Add('  insta_comment_id = ' + inttostr(value.insta_comment_Id));
        qry.ExecSQL;
      end;
    finally
      FreeAndNil(qry);
    end
  Except
    on e: exception do
      Tutil.gravalog('[TDAOCOMMENTS-E359]' + e.message);
  end;
end;
{-----------------------------------------------------------------------------}
end.

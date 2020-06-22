unit nagram.dao.hashtag;

interface

uses
  System.SysUtils,
  System.Classes,
  Data.DB,
  // FIREDAC-------------------------------------------
  FireDAC.Stan.Intf,
  FireDAC.Stan.Option,
   System.Generics.Collections,
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
  nagram.model.hashtag;

type
  ThashtagDao = class
  private
  public
    procedure sethashtag(value: Thashtag);
    function gethashtag(): Thashtag;
    function gethashtags(criterio: string): Thashtags;
    function deleteHashTag(value: integer): string;
    function getcountitens(): integer;
    procedure replaceHashtags(values: Thashtags);

  end;

implementation

uses
  nagram.control.person;
{ ThashtagDao }
{---------------------------------------------------------------------------}
procedure ThashtagDao.replaceHashtags(values: Thashtags);
var
  qry: TFDQuery;
  lstvalues: tstringList;
  i: integer;
  value: Thashtag;
  sep: string;
begin
  try
    if  values.Count > 0  then
    begin
      qry := TFDQuery.Create(nil);
      qry.Connection := dm_local.FDConnection1;
      try
        qry.SQL.Add('delete    FROM insta_hashtag');
        qry.SQL.Add('WHERE ');
        qry.SQL.Add(' insta_hashtag_person_uuid  = ' +
          QuotedStr(GlobalPerson.person.person_uuid));
        qry.ExecSQL;
        qry.SQL.Clear;
        qry.SQL.Add('INSERT INTO insta_hashtag');
        qry.SQL.Add('( ');
        qry.SQL.Add('  insta_hashtag_date  ');
        qry.SQL.Add(' ,insta_hashtag_name ');

        qry.SQL.Add(' ,insta_hashtag_person_uuid  ');
        qry.SQL.Add(' ,insta_hashtag_uuid  ');

        qry.SQL.Add(' )');
        qry.SQL.Add('VALUES ');

        lstvalues := tstringList.Create;
        for i := 0 to values.Count -1 do
        begin
          value := values[i];
          if value.insta_hashtag_uuid <> '' then
          begin
            lstvalues.Add(sep + '( ');
            lstvalues.Add
              ('  ' + StringReplace(FloatToStr(value.insta_hashtag_date), ',',
              '.', [rfReplaceAll]));
            lstvalues.Add('  ,' + QuotedStr(value.insta_hashtag_name));
            lstvalues.Add('  ,' + QuotedStr(GlobalPerson.person.person_uuid));
            lstvalues.Add('  ,' + QuotedStr(value.insta_hashtag_uuid));
            lstvalues.Add(' )');
            sep := ' , ';
          end;
        end;
        qry.SQL.Text := qry.SQL.Text + lstvalues.Text;
        qry.ExecSQL;
        qry.SQL.Clear;
      finally
        FreeAndNil(qry);
        FreeAndNil(lstvalues);
      end;
    end;
  Except
    on e: exception do
      Tutil.gravalog('[TDAOHASHTAG-E114]' + e.message);
  end;
end;
{---------------------------------------------------------------------------}
function ThashtagDao.deleteHashTag(value: integer): string;
var
  qry: TFDQuery;
begin
  TRY
    qry := TFDQuery.Create(nil);
    qry.Connection := dm_local.FDConnection1;
    try
      if value = -6 then
      begin
        qry.SQL.Clear;
        qry.SQL.Add('DELETE FROM insta_hashtag WHERE ');
        qry.SQL.Add('  insta_hashtag_person_uuid = ' +
          QuotedStr(GlobalPerson.person.person_uuid));
        qry.ExecSQL;
      end
      else
      begin
        qry.SQL.Clear;
        qry.SQL.Add('SELECT   * FROM   insta_hashtag');
        qry.SQL.Add('WHERE ');
        qry.SQL.Add('  insta_hashtag_person_uuid  = ' +
          QuotedStr(GlobalPerson.person.person_uuid));
        qry.SQL.Add('  AND  insta_hashtag_id = ' + inttostr(value));
        qry.open;
        if qry.RecordCount > 0 then
        begin
          result := qry.FieldByName('insta_hashtag_uuid').AsString;
          qry.Close;
          qry.SQL.Clear;
          qry.SQL.Add('DELETE FROM insta_hashtag WHERE insta_hashtag_id =' +
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
      Tutil.gravalog('[TDAOHASHTAG-E114]' + e.message);
  end;
end;
{---------------------------------------------------------------------------}
function ThashtagDao.getcountitens: integer;
var
  qry: TFDQuery;
begin
  try
    qry := TFDQuery.Create(nil);
    qry.Connection := dm_local.FDConnection1;
    try
      qry.SQL.Add
        ('SELECT  count(insta_hashtag_id) as count FROM insta_hashtag');
      qry.SQL.Add('WHERE ');
      qry.SQL.Add('  insta_hashtag_person_uuid = ' +
        QuotedStr(GlobalPerson.person.person_uuid));

      qry.open;
      result := qry.Fields[0].AsInteger;

    finally
      qry.Close;
      FreeAndNil(qry);
    end;

  Except
    on e: exception do
      Tutil.gravalog('[TDAOHASHTAG-E187]' + e.message);
  end;
end;
{---------------------------------------------------------------------------}
function ThashtagDao.gethashtag(): Thashtag;
var
  qry: TFDQuery;
begin
  try
    qry := TFDQuery.Create(nil);
    qry.Connection := dm_local.FDConnection1;
    try
      qry.SQL.Add('SELECT   * FROM insta_hashtag');
      qry.SQL.Add('WHERE ');
      qry.SQL.Add('  insta_hashtag_person_uuid = ' +
        QuotedStr(GlobalPerson.person.person_uuid));

      qry.open;
      result := Thashtag.Create;
      result.insta_hashtag_Id := qry.FieldByName('insta_hashtag_id').AsInteger;
      result.insta_hashtag_date :=
        qry.FieldByName('insta_hashtag_date').asfloat;
      result.insta_hashtag_name :=
        qry.FieldByName('insta_hashtag_name').AsString;
      result.insta_hashtag_Person_uuid :=
        qry.FieldByName('insta_hashtag_person_uuid').AsString;

    finally
      FreeAndNil(qry);
    end;
  Except
    on e: exception do
      Tutil.gravalog('[TDAOHASHTAG-E218]' + e.message);
  end;
end;
{---------------------------------------------------------------------------}
function ThashtagDao.gethashtags(criterio: string): Thashtags;
var
  qry: TFDQuery;
  oindex: integer;
  tmphashtag: Thashtag;
begin
  try
    qry := TFDQuery.Create(nil);
    qry.Connection := dm_local.FDConnection1;
    try
      qry.SQL.Add('SELECT   * FROM insta_hashtag');
      qry.SQL.Add('WHERE ');
      qry.SQL.Add('  insta_hashtag_person_uuid = ' +
        QuotedStr(GlobalPerson.person.person_uuid));

      if criterio <> '' then
      begin
        qry.SQL.Add('  and  ' + criterio);

      end;

      qry.open;
      qry.Last;
      result:=TObjectList<ThashTag>.Create;
      qry.First;
      oindex := 0;
      while not qry.Eof do
      begin
        tmphashtag := Thashtag.Create;
        tmphashtag.insta_hashtag_Id := qry.FieldByName('insta_hashtag_id')
          .AsInteger;
        tmphashtag.insta_hashtag_date :=
          qry.FieldByName('insta_hashtag_date').asfloat;
        tmphashtag.insta_hashtag_name :=
          qry.FieldByName('insta_hashtag_name').AsString;
        tmphashtag.insta_hashtag_Person_uuid :=
          qry.FieldByName('insta_hashtag_person_uuid').AsString;
        tmphashtag.insta_hashtag_uuid :=
          qry.FieldByName('insta_hashtag_uuid').AsString;
        result.Add(tmphashtag);
        inc(oindex);
        qry.next;
      end;

    finally
      FreeAndNil(qry);
    end;
  Except
    on e: exception do
      Tutil.gravalog('[TDAOHASHTAG-E272]' + e.message);
  end;
end;
{---------------------------------------------------------------------------}
procedure ThashtagDao.sethashtag(value: Thashtag);
var
  qry: TFDQuery;
begin
  try
    qry := TFDQuery.Create(nil);
    qry.Connection := dm_local.FDConnection1;
    try
      if value.insta_hashtag_Id <= 0 then
      begin
        qry.SQL.Clear;
        qry.SQL.Add('SELECT  insta_hashtag_id   FROM insta_hashtag');
        qry.SQL.Add('WHERE ');
        qry.SQL.Add(' ( insta_hashtag_name = ' +
          QuotedStr(value.insta_hashtag_name));

        qry.SQL.Add(' or  insta_hashtag_uuid = ' +
          QuotedStr(value.insta_hashtag_uuid));
        qry.SQL.Add(' )');
        qry.SQL.Add(' and  insta_hashtag_person_uuid  = ' +
          QuotedStr(GlobalPerson.person.person_uuid));
        qry.open;
        if qry.RecordCount > 0 then
        begin
          value.insta_hashtag_Id := qry.FieldByName('insta_hashtag_id')
            .AsInteger;
        end;
      end;

      if value.insta_hashtag_Id <= 0 then
      begin
        qry.SQL.Clear;
        qry.SQL.Add('INSERT INTO INSTA_hashtag');
        qry.SQL.Add('( ');
        qry.SQL.Add('  insta_hashtag_date  ');
        qry.SQL.Add(' ,insta_hashtag_name ');

        qry.SQL.Add(' ,insta_hashtag_person_uuid  ');
        qry.SQL.Add(' ,insta_hashtag_uuid  ');

        qry.SQL.Add(' )');
        qry.SQL.Add('VALUES ');
        qry.SQL.Add('( ');
        qry.SQL.Add('  ' + StringReplace(FloatToStr(value.insta_hashtag_date),
          ',', '.', [rfReplaceAll]));
        qry.SQL.Add('  ,' + QuotedStr(value.insta_hashtag_name));

        qry.SQL.Add('  ,' + QuotedStr(GlobalPerson.person.person_uuid));
        qry.SQL.Add('  ,' + QuotedStr(value.insta_hashtag_uuid));

        qry.SQL.Add(' );');
        qry.ExecSQL;
        qry.SQL.Clear;
        qry.SQL.Add('SELECT  insta_hashtag_id   FROM insta_hashtag');
        qry.SQL.Add('WHERE ');
        qry.SQL.Add(' insta_hashtag_name = ' +
          QuotedStr(value.insta_hashtag_name));
        qry.SQL.Add(' and  insta_hashtag_person_uuid  = ' +
          QuotedStr(GlobalPerson.person.person_uuid));
        qry.open;
        value.insta_hashtag_Id := qry.FieldByName('insta_hashtag_id').AsInteger;

      end
      else
      begin
        qry.SQL.Clear;
        qry.SQL.Add('UPDATE  INSTA_hashtag');
        qry.SQL.Add('SET ');
        qry.SQL.Add('  insta_hashtag_date  =  ' +
          StringReplace(FloatToStr(value.insta_hashtag_date), ',', '.',
          [rfReplaceAll]));
        qry.SQL.Add(' ,insta_hashtag_name = ' +
          QuotedStr(value.insta_hashtag_name));

        qry.SQL.Add(' ,insta_hashtag_uuid = ' +
          QuotedStr(value.insta_hashtag_uuid));

        qry.SQL.Add(' ,insta_hashtag_person_uuid = ' +
          QuotedStr(GlobalPerson.person.person_uuid));

        qry.SQL.Add('WHERE   ');
        qry.SQL.Add(' insta_hashtag_id = ' + inttostr(value.insta_hashtag_Id));
        qry.ExecSQL;
      end;
    finally
      FreeAndNil(qry);
    end
  Except
    on e: exception do
      Tutil.gravalog('[TDAOHASHTAG-E364]' + e.message);
  end;
end;

end.

unit nagram.dao.localoption;

interface

uses
  System.SysUtils,
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
  nagram.model.localoption;

type
  TLocalOptionDao = class
  private
  public
    procedure setLocalOption(value: TlocalOption);
    function getLocalOptions(): TlocalOption;

  end;

implementation

{ TLocalOptionDao }

function TLocalOptionDao.getLocalOptions: TlocalOption;
var
  qry: TFDQuery;
begin
  qry := TFDQuery.Create(nil);
  qry.Connection := dm_local.FDConnection1;
  try
    qry.SQL.Add('SELECT   * FROM   insta_local_option');
    qry.open;

    result := TlocalOption.Create;
    if qry.RecordCount > 0 then
    begin
      result.SendComent := qry.FieldByName('insta_local_option_send_coment')
        .AsInteger;
      result.SendLike := qry.FieldByName('insta_local_option_send_like')
        .AsInteger;
      result.DaysUnfolow := qry.FieldByName('insta_local_option_days_unfollow')
        .AsInteger;
      result.HashTagDept := qry.FieldByName('insta_local_option_hashtag_dept')
        .AsInteger;

       result.Maxinthour := qry.FieldByName('insta_local_option_maxinthour')
        .AsInteger;
      result.DelayNavigation :=
        qry.FieldByName('insta_local_option_delay_navigation').AsInteger;
      result.DaysStart := qry.FieldByName
        ('instal_local_option_days_start').Asstring;

      result.HoursStart := qry.FieldByName
        ('insta_local_option_hours_start').Asstring;

      result.DelayExecution :=
        qry.FieldByName('insta_local_option_delay_execution').AsInteger;
    end;
  finally
    FreeAndNil(qry);
  end;
end;

procedure TLocalOptionDao.setLocalOption(value: TlocalOption);
var
  qry: TFDQuery;
begin
  qry := TFDQuery.Create(nil);
  qry.Connection := dm_local.FDConnection1;
  try
    qry.SQL.Clear;
    qry.SQL.Add('SELECT  * FROM  insta_local_option');
    qry.open;
    if qry.RecordCount = 0 then
    begin
      qry.SQL.Clear;
      qry.close;
      qry.SQL.Add('INSERT INTO insta_local_option');
      qry.SQL.Add('( ');
      qry.SQL.Add('   insta_local_option_send_coment');
      qry.SQL.Add('  ,insta_local_option_send_like');
      qry.SQL.Add('  ,insta_local_option_days_unfollow');
      qry.SQL.Add('  ,insta_local_option_hashtag_dept');
      qry.SQL.Add('  ,insta_local_option_delay_navigation');
      qry.SQL.Add('  ,instal_local_option_days_start');
      qry.SQL.Add('  ,insta_local_option_hours_start');
      qry.SQL.Add('  ,insta_local_option_delay_execution');
      qry.SQL.Add('  ,insta_local_option_maxinthour');

      qry.SQL.Add(' )');
      qry.SQL.Add('VALUES ');
      qry.SQL.Add('( ');

      qry.SQL.Add('  ' + inttostr(value.SendComent));
      qry.SQL.Add('  ,' + inttostr(value.SendLike));
      qry.SQL.Add('  ,' + inttostr(value.DaysUnfolow));
      qry.SQL.Add('  ,' + inttostr(value.HashTagDept));
      qry.SQL.Add('  ,' + inttostr(value.DelayNavigation));
      qry.SQL.Add('  ,' + QuotedStr(value.DaysStart));
      qry.SQL.Add('  ,' + QuotedStr(value.HoursStart));
      qry.SQL.Add('  ,' + inttostr(value.DelayExecution));
      qry.SQL.Add('  ,' + inttostr(value.Maxinthour));

      qry.SQL.Add(' );');
      qry.ExecSQL;
    end
    else
    begin
      qry.SQL.Clear;
      qry.close;
      qry.SQL.Add('UPDATE  insta_local_option');
      qry.SQL.Add('SET ');
      qry.SQL.Add('   insta_local_option_send_coment  = ' +
        inttostr(value.SendComent));
      qry.SQL.Add('  ,insta_local_option_send_like   = ' +
        inttostr(value.SendLike));
      qry.SQL.Add('  ,insta_local_option_days_unfollow = ' +
        inttostr(value.DaysUnfolow));
      qry.SQL.Add('  ,insta_local_option_hashtag_dept = ' +
        inttostr(value.HashTagDept));
      qry.SQL.Add('  ,insta_local_option_delay_navigation  = ' +
        inttostr(value.DelayNavigation));
      qry.SQL.Add('  ,instal_local_option_days_start = ' +
        QuotedStr(value.DaysStart));
      qry.SQL.Add('  ,insta_local_option_hours_start = ' +
        QuotedStr(value.HoursStart));
      qry.SQL.Add('  ,insta_local_option_delay_execution  = ' +
        inttostr(value.DelayExecution));


        qry.SQL.Add('  ,insta_local_option_maxinthour  = ' +
        inttostr(value.Maxinthour));

      qry.ExecSQL;
    end;
  finally
    FreeAndNil(qry);
  end
end;

end.


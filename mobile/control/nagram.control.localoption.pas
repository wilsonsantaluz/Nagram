unit nagram.control.localoption;

interface

uses

  System.SysUtils,
  System.Generics.Collections,
  System.classes,
  nagram.dao.localoption,
  nagram.model.localoption;

Type
  TLocalOptionController = class
  private
    FlocalOtion: TlocalOption;
  public
    procedure setLocalOption();
    procedure refresh;
    constructor create;
    property localoption: TlocalOption read FlocalOtion write FlocalOtion;

  end;

implementation

{ TLocalOptionController }

constructor TLocalOptionController.create;
var
  dao: TLocalOptionDao;
begin

  dao := TLocalOptionDao.create;
  try
    FlocalOtion := dao.getLocalOptions;
  finally
    FreeAndNil(dao);
  end;
end;

procedure TLocalOptionController.refresh;
var
  dao: TLocalOptionDao;
begin

  dao := TLocalOptionDao.create;
  try
    FreeAndNil(FlocalOtion);

    FlocalOtion := dao.getLocalOptions;
  finally
    FreeAndNil(dao);
  end;
end;

procedure TLocalOptionController.setLocalOption();
var
  dao: TLocalOptionDao;
begin
  dao := TLocalOptionDao.create();
  Try
    dao.setLocalOption(FlocalOtion);
  Finally
    FreeAndNil(dao)
  End;
end;
{ ------------------------------------------------------------------------------ }

end.

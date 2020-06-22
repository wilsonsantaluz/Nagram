unit nagram.model.localoption;

interface

uses
  classes ,
  System.Generics.Collections
  ;

type
  TlocalOption = class
  private
    FSendComent: integer;
    FSendLike: integer;
    FDaysUnfolow: integer;
    FHashTagDept: integer;
    FDelayNavigation: integer;
    FDaysStart: String;
    FHoursStart: String;
    FDelayExecution:integer;
  public

    property SendComent: integer read FSendComent write FSendComent;
    property SendLike: integer read FSendLike write FSendLike;
    property DaysUnfolow: integer read FDaysUnfolow write FDaysUnfolow;
    property HashTagDept: integer read FHashTagDept write FHashTagDept;
    property DelayNavigation: integer read FDelayNavigation
      write FDelayNavigation;
    property DaysStart: String read FDaysStart write FDaysStart;
    property HoursStart: String read FHoursStart write FHoursStart;
    property DelayExecution: integer read FDelayExecution write FDelayExecution;
   constructor create;
  end;

implementation

{ TlocalOption }

constructor TlocalOption.create;
begin
    FSendComent:=1;
    FSendLike:=1;
    FDaysUnfolow:=30;
    FHashTagDept:=70;
    FDelayNavigation:=4;
    FDaysStart:='';
    FHoursStart:='';
    FDelayExecution:=120;
end;

end.

unit nagram.model.hashtag;

interface

uses
  System.SysUtils,
  System.Generics.Collections,
  System.classes;

type
  ThashTag = class
  private
    Fid: integer;
    Fuuid: string;
    FPerson_uuid: string;
    FDate: Tdatetime;
    FName: string;

  public
    property insta_hashtag_id: integer read Fid write Fid;
    property insta_hashtag_uuid: string read Fuuid write Fuuid;
    property insta_hashtag_person_uuid: string read FPerson_uuid
      write FPerson_uuid;
    property insta_hashtag_date: Tdatetime read FDate write FDate;
    property insta_hashtag_name: string read FName write FName;

  end;

type
  ThashTags = TObjectList<ThashTag>;

implementation

{ ThashTag }

end.

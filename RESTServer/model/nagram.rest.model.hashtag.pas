unit nagram.rest.model.hashtag;

interface

uses
  System.SysUtils,
  System.classes;

type
  ThashTag = class
  private

    Fuuid: variant;
    FPerson_uuid:tguid;
    FDate: Tdatetime;
    FName: string;
  public

    property insta_hashtag_uuid: variant read Fuuid write Fuuid;
    property insta_hashtag_Person_uuid:tguid read FPerson_uuid write FPerson_uuid;
    property insta_hashtag_date: Tdatetime read FDate write FDate;
    property insta_hashtag_name : string read Fname write Fname;

  end;

implementation

{ ThashTag }


end.

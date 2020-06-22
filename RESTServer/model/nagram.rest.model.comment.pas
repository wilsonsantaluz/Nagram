unit nagram.rest.model.comment;

interface

uses
  System.SysUtils,
  System.classes;

type

  TComment = class
  private

    Fuuid: variant;
    FText: string;
    FPerson_uuid: tguid;
    FDate: Tdatetime;
  public

    property insta_comment_uuid: variant read Fuuid write Fuuid;
    property insta_comment_person_uuid:tguid read FPerson_uuid write FPerson_uuid;
    property insta_comment_text: string read FText write FText;
    property insta_comment_date: Tdatetime read FDate write FDate;
  end;

type
  TComments = array of TComment;

implementation

{ TBotAction }

end.

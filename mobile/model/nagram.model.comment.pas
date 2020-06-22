unit nagram.model.comment;

interface

uses
  System.SysUtils,
  System.Generics.Collections,
  System.classes;

type

  TComment = class
  private
    Fid: integer;
    Fuuid: string;
    FText: string;
    FPerson_uuid: string;
    FDate: Tdatetime;
  public
    property insta_comment_id:integer read Fid write Fid;
    property insta_comment_uuid: string read Fuuid write Fuuid;
    property insta_comment_person_uuid: string read FPerson_uuid write FPerson_uuid;
    property insta_comment_text: string read FText write FText;
    property insta_comment_date: Tdatetime read FDate write FDate;
  end;

type
  TComments =TObjectList<Tcomment>;

implementation

{ TBotAction }

end.

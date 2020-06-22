unit nagram.model.action;

interface

uses
  System.SysUtils,
  System.Generics.Collections,
  System.classes;

type
  TBotAction = class
  private
    FId: integer;
    Fuuid:string;
    Fperson_uuid:string;
    FActionType: integer;
    FDate: Tdatetime;
    FComment: string;
    Finsta_user_name:string;
    FUser_name: string;
    FUrl: string;

  public
    property insta_action_id: integer read FId write FId;
    property insta_action_type: integer read FActionType write FActionType;
    property insta_action_date: Tdatetime read FDate write FDate;
    property insta_action_comment : string read FComment write FComment;

    property insta_action_url: string read FUrl write FUrl;
    property insta_action_person_uuid: string read Fperson_uuid write Fperson_uuid;
    property insta_action_uuid: string read Fuuid write Fuuid;
    property insta_action_insta_user_name: string read Finsta_user_name write Finsta_user_name;
    constructor create;
  end;
  TBotActions  =TObjectList<TBotAction>;

implementation

{ TBotAction }

constructor TBotAction.create;
begin
  FId := -1;
  FActionType := 0;
  FDate := now;
  FComment := '';
  FUser_name :='';
  FUrl := '';
end;

end.

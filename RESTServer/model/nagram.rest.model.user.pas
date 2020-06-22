unit nagram.rest.model.user;

interface

uses
  System.SysUtils,
  System.classes;

type
  TUser = class
  private
    FId: integer;
    FName: string;
    Fuuid: variant;
    Fperson_uuid: tguid;
    FDate: TDateTime;
    FLastVisit: TDateTime;
    FFollow: integer;
    FPosts: integer;
    FDateFollow: TDateTime;
    Fbio: string;
    FFollowing: integer;
    FFollowings:integer;
    Ffollowed: integer;
    Fpreferences:string;

  public

    property insta_user_person_uuid: tguid read Fperson_uuid write Fperson_uuid;
    property insta_user_uuid: Variant read Fuuid write Fuuid;
    property insta_user_name: String read FName write FName;
    property insta_user_date: TDateTime read FDate write FDate;
    property insta_user_last_visit: TDateTime read FLastVisit write FLastVisit;
    property insta_user_posts: integer read FPosts write FPosts;
    property insta_user_date_follow: TDateTime read FDateFollow write FDateFollow;
    property insta_user_bio: String read Fbio write Fbio;
    property insta_user_preferences: String read Fpreferences write Fpreferences;
    property insta_user_follow: integer read FFollow write FFollow;
    property insta_user_following: integer read FFollowing write FFollowing;
    property insta_user_followings: integer read FFollowings write FFollowings;
    property insta_user_followed: integer read Ffollowed write Ffollowed;



  end;
type
  Tusers = array of Tuser;
implementation

end.

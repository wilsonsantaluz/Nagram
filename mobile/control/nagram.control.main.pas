unit nagram.control.main;

interface

uses
  sysutils,
  json,

  FMX.ListView.Appearances,
  System.Generics.Collections,
  System.UITypes,
  rtti,
  FMX.Dialogs,
  System.Types,
  FMX.Forms,
  nagram.control.action,
  nagram.control.localoption,
  FMX.DialogService,
  nagram.control.hashtag,
  nagram.control.comment,
  nagram.control.user,
  nagram.model.action,
  nagram.model.hashtag,
  nagram.model.comment,
  nagram.model.user,
  nagram.android.util,
  nagram.dao.user,
  nagram.dao.action,
  nagram.dao.comment,
  nagram.lib.getpermision,
  nagram.datamodule,
  nagram.view.person,
  nagram.dao.hashtag

    ;

type
  TMainController = class
  public
  private
    FFormView: TForm;
    Flogado: Boolean;
    Flocaloption: TLocalOptionController;
    FUserController: TUserController;
    FCommentController: TCommentController;
    FActionController: TActionController;
    FHashTagController: THashTagController;
    procedure dochangeoperacional(Sender: TObject);
    function getActionById(value: integer): TBotAction;
    function getUserById(value: integer): Tuser;

  public
    procedure sincronizeall();
    procedure logop(value: string);
    procedure processLogin();
    procedure saveHashTag(value: string);
    procedure deleteHashTag(value: integer);
    procedure deleteComment(value: integer);
    procedure deleteUser(value: integer);
    procedure saveComent;
    procedure clearDb;
    procedure setViewHashTag(Sender: TObject);
    procedure setViewAction(Sender: TObject);
    procedure setViewUser(Sender: TObject);
    procedure setViewComment(Sender: TObject);
    procedure setViewLocalOptions();
    procedure persistLocalOptions();
    procedure sincronizeactions;
    procedure sincronizeusers;
    procedure sincronizecomments;
    procedure sincronizehashtags;
    procedure setAllViews;

    property logado: Boolean read Flogado write Flogado;
    property FormView: TForm read FFormView write FFormView;
    constructor create;
  end;

Var
  FmainController: TMainController;

implementation

uses
  nagram.control.person,
  nagram.view.main;
{ TMainController }

{ ------------------------------------------------------------------------------- }
constructor TMainController.create;
begin
  try
    FUserController := TUserController.create;
    FUserController.onupdate := setViewUser;
    FCommentController := TCommentController.create;
    FCommentController.onupdate := setViewComment;
    FActionController := TActionController.create;
    FActionController.onupdate := setViewAction;

    FHashTagController := THashTagController.create;
    FHashTagController.onupdate := setViewHashTag;
  except
    on e: exception do
      Tutil.gravalog('[TMAIN-99]' + e.message);
  end;

end;

{ ------------------------------------------------------------------------------ }
procedure TMainController.deleteComment(value: integer);
begin
  try
    FCommentController.deleteComment(value);
  except
    on e: exception do
      Tutil.gravalog('[TMAIN-11]' + e.message);
  end;
end;

{ ------------------------------------------------------------------------------ }
procedure TMainController.deleteHashTag(value: integer);
begin
  try
    FHashTagController.deleteHashTag(value);
  except
    on e: exception do
      Tutil.gravalog('[TMAIN-122]' + e.message);

  end;
end;

procedure TMainController.deleteUser(value: integer);
{ ------------------------------------------------------------------------------ }
begin
  try
    FUserController.deleteUser(value);
  except
    on e: exception do
      Tutil.gravalog('[TMAIN134]' + e.message);
  end;
end;

{ ------------------------------------------------------------------------------ }
procedure TMainController.dochangeoperacional(Sender: TObject);
begin
  try
    persistLocalOptions;
  except
    on e: exception do
      Tutil.gravalog('[TMAIN-145]' + e.message);

  end;
end;

{ ------------------------------------------------------------------------------ }
function TMainController.getActionById(value: integer): TBotAction;

begin
  try
    result := FActionController.getactions('insta_action_id = ' +
      inttostr(value))[0];
  except
    on e: exception do
      Tutil.gravalog('[TMAIN-159]' + e.message);

  end;
end;

function TMainController.getUserById(value: integer): Tuser;
begin

end;

procedure TMainController.persistLocalOptions;

  function valint(value: string): integer;
  begin
    result := 0;
    if value <> '' then
      try
        result := StrToInt(value);
      except
      end;
  end;

begin
  try
    if ((FFormView) as Tfmain).swcomentario.IsChecked then
      Flocaloption.localoption.SendComent := 1
    else
      Flocaloption.localoption.SendComent := 0;
    if ((FFormView) as Tfmain).swcurtirpostagem.IsChecked then
      Flocaloption.localoption.SendLike := 1
    else
      Flocaloption.localoption.SendLike := 0;
    Flocaloption.localoption.DaysUnfolow :=
      valint(((FFormView) as Tfmain).edtdaysunfolow.Text);
    Flocaloption.localoption.HashTagDept :=
      valint(((FFormView) as Tfmain).edtpesquisashashtag.Text);
    Flocaloption.localoption.DelayNavigation :=
      valint(((FFormView) as Tfmain).edtdelaynavigation.Text);
    Flocaloption.localoption.DelayExecution :=
      valint(((FFormView) as Tfmain).edtdelayexecution.Text);
    Flocaloption.setLocalOption;
  except
    on e: exception do
      Tutil.gravalog('[TMAIN-173]' + e.message);
  end;

end;

{ ------------------------------------------------------------------------------- }
procedure TMainController.processLogin;
begin
  try
    if checarpermisalocation then
      halt;
    Application.CreateForm(Tdm_local, dm_local);

    GlobalPerson.getLocalPerson;
    if (GlobalPerson.person.person_login = '') and
      (GlobalPerson.person.person_password = '') then
    begin
      Flogado := true;
      GlobalPerson.sincronizar();
      GlobalPerson.sincronizar();
    end
    else
    begin
      FviewPerson := TFviewPerson.create(Nil);
      FviewPerson.show;
      ShowMessage('Um conta prescisa ser configurada')
    end;
  except
    on e: exception do
      Tutil.gravalog('[TMAIN-201]' + e.message);
  end;

end;

{ ----------------------------------------------------------------------------- }
procedure TMainController.saveComent;
var
  ocomment: TComment;
  ocomments: TComments;
begin
  try
    with (FFormView) as Tfmain do
    begin
      if (memoeditcoments.Text <> '') then
      begin
        ocomment := TComment.create;

        ocomment.insta_comment_Text := memoeditcoments.Text;
        ocomment.insta_comment_Id := CommentId;
        FCommentController.setComment(ocomment);
        ocomments := TObjectList<TComment>.create;
        ocomments.Add(ocomment);
        if CommentId > 0 then
          FCommentController.setDataToserver(ocomments, true)
        else
          FCommentController.setDataToserver(ocomments);
      end;
    end;
  except
    on e: exception do
      Tutil.gravalog('[TMAIN-236]' + e.message);
  end;

end;

{ ------------------------------------------------------------------------------- }
procedure TMainController.saveHashTag(value: string);
var
  tmp: ThashTag;
  hashtags: ThashTags;
begin
  try
    tmp := ThashTag.create;
    tmp.insta_hashtag_name := value;
    tmp.insta_hashtag_date := now;
    tmp.insta_hashtag_person_uuid := GlobalPerson.person.person_uuid;
    FHashTagController.sethashtag(tmp);
    hashtags := TObjectList<ThashTag>.create;
    hashtags.Add(tmp);
    FHashTagController.setDataToserver(hashtags);
  except
    on e: exception do
      Tutil.gravalog('[TMAIN-260]' + e.message);
  end;

end;

{ ------------------------------------------------------------------------------ }
procedure TMainController.setAllViews;
begin
  try
    setViewHashTag(Nil);
    setViewLocalOptions;
    setViewAction(Nil);
    setViewUser(Nil);
    setViewComment(Nil);
  except
    on e: exception do
      Tutil.gravalog('[TMAIN-277]' + e.message);
  end;

end;

{ ------------------------------------------------------------------------------ }
procedure TMainController.setViewAction(Sender: TObject);
var
  i: integer;
  oitem: TListViewItem;
  tipo: string;
  odate: TDateTime;
  otext: string;
  icoments: integer;
  iseguir: integer;
  ilike: integer;
  oactions: TBotActions;

begin

  try
    oactions := FActionController.getactions('');
    try
      ((FormView) as Tfmain).lstactions.Items.clear;
      iseguir := 0;
      icoments := 0;
      ilike := 0;
      for i := 0 to oactions.Count - 1 do
      begin
        if oactions[i].insta_action_type = 0 then
        begin
          inc(iseguir);
          tipo := 'Seguir';
        end;
        if oactions[i].insta_action_type = 1 then
        begin
          inc(ilike);
          tipo := 'Curtir post';
        end;
        if oactions[i].insta_action_type = 2 then
        begin
          inc(icoments);
          tipo := 'Comentario';
        end;
        odate := oactions[i].insta_action_date;
        otext := inttostr(oactions[i].insta_action_id) + ' - ' + tipo + ' -> ' +
          oactions[i].insta_action_insta_user_name;
        oitem := ((FormView) as Tfmain).lstactions.Items.Add;
        oitem.ImageIndex := 2;
        oitem.Tag := oactions[i].insta_action_id;
        oitem.Text := otext;

      end;
      ((FormView) as Tfmain).lblactions.Text := 'Likes ' + inttostr(ilike) +
        ' Seguir ' + inttostr(iseguir) + ' Coments ' + inttostr(icoments);

      ((FFormView) as Tfmain).lblcords.Text := inttostr(oactions.Count) +
        ' Atividades(s)   carregada(s)';

    finally
      if assigned(oactions) then
        FreeAndNil(oactions);
    end;
  except
    on e: exception do
      Tutil.gravalog('[TMAIN-337]' + e.message);
  end;
end;

{ ----------------------------------------------------------------------------- }
procedure TMainController.setViewComment(Sender: TObject);
var
  oitem: TListViewItem;
  i: integer;
  odata: TDateTime;

  ocomments: TComments;
begin
  try
    ocomments := FCommentController.getcomments('');
    try

      ((FFormView) as Tfmain).lstcomentarios.Items.clear;
      for i := 0 to ocomments.Count - 1 do
      begin
        oitem := ((FFormView) as Tfmain).lstcomentarios.Items.Add;
        oitem.Tag := ocomments[i].insta_comment_Id;
        odata := ocomments[i].insta_comment_date;
        oitem.Text := ocomments[i].insta_comment_Text;
        oitem.ImageIndex := 1;

      end;
      ((FFormView) as Tfmain).lbtopcoments.Text := 'Comentarios  ' +
        inttostr(ocomments.Count);

      ((FFormView) as Tfmain).lblcords.Text := inttostr(ocomments.Count) +
        ' Comentario(s)   carregado(s)';
      if not FCommentController.initialLoad then
      begin
        ((FFormView) as Tfmain).pnexec.Visible:=true; 
        ((FFormView) as Tfmain).lbexec.Text := 'Comentario salvo';
        ((FFormView) as Tfmain).flapnexec.Start;
      end;

    finally
      if assigned(ocomments) then
        FreeAndNil(ocomments)
    end;
  except
    on e: exception do
      Tutil.gravalog('[TMAIN-376]' + e.message);
  end;

end;

{ ------------------------------------------------------------------------------ }
procedure TMainController.setViewHashTag(Sender: TObject);
var
  oitem: TListViewItem;
  i: integer;
  odata: TDateTime;
  ohashTags: ThashTags;
begin
  try
    ohashTags := FHashTagController.gethashtags('');
    try

      ((FFormView) as Tfmain).lsthastags.Items.clear;
      for i := 0 to ohashTags.Count - 1 do
      begin
        oitem := ((FFormView) as Tfmain).lsthastags.Items.Add;
        oitem.Tag := ohashTags[i].insta_hashtag_id;
        odata := ohashTags[i].insta_hashtag_date;

        oitem.Text := ohashTags[i].insta_hashtag_name;
        oitem.ImageIndex := 0;
      end;
      ((FFormView) as Tfmain).lblcords.Text := inttostr(ohashTags.Count) +
        ' Hashtags(s)   carregada(s)';

    finally
      if assigned(ohashTags) then
        FreeAndNil(ohashTags);

         if not FHashTagController.initialLoad then
      begin
        ((FFormView) as Tfmain).pnexec.Visible:=true; 
        ((FFormView) as Tfmain).lbexec.Text := 'Hash tag salva !';
        ((FFormView) as Tfmain).flapnexec.Start;
      end;
  
    end;
  except
    on e: exception do
      Tutil.gravalog('[TMAIN-2410]' + e.message);
  end;

end;

{ ------------------------------------------------------------------------------ }
procedure TMainController.setViewLocalOptions;
begin
  try
    if not assigned(Flocaloption) then
      Flocaloption := TLocalOptionController.create;
    ((FFormView) as Tfmain).edtdaysunfolow.OnChange := Nil;
    ((FFormView) as Tfmain).edtpesquisashashtag.OnChange := Nil;
    ((FFormView) as Tfmain).edtdelaynavigation.OnChange := Nil;
    ((FFormView) as Tfmain).edtdelayexecution.OnChange := Nil;

    ((FFormView) as Tfmain).swcomentario.IsChecked :=
      Flocaloption.localoption.SendComent = 1;
    ((FFormView) as Tfmain).swcurtirpostagem.IsChecked :=
      Flocaloption.localoption.SendLike = 1;
    ((FFormView) as Tfmain).edtdaysunfolow.Text :=
      inttostr(Flocaloption.localoption.DaysUnfolow);
    ((FFormView) as Tfmain).edtpesquisashashtag.Text :=
      inttostr(Flocaloption.localoption.HashTagDept);
    ((FFormView) as Tfmain).edtdelaynavigation.Text :=
      inttostr(Flocaloption.localoption.DelayNavigation);
    ((FFormView) as Tfmain).edtdelayexecution.Text :=
      inttostr(Flocaloption.localoption.DelayExecution);

    // chkcoments.OnChange := dochangeoperacional;
    // chklike.OnChange := dochangeoperacional;
    ((FFormView) as Tfmain).edtdaysunfolow.OnChange := dochangeoperacional;
    ((FFormView) as Tfmain).edtpesquisashashtag.OnChange := dochangeoperacional;
    ((FFormView) as Tfmain).edtdelaynavigation.OnChange := dochangeoperacional;
    ((FFormView) as Tfmain).edtdelayexecution.OnChange := dochangeoperacional;
  except
    on e: exception do
      Tutil.gravalog('[TMAIN-447]' + e.message);
  end;

end;

{ ------------------------------------------------------------------------------ }
procedure TMainController.setViewUser(Sender: TObject);

var
  oitem: TListViewItem;
  i: integer;
  odata: TDateTime;
  isfollow: string;
  oUsers: Tusers;
begin
  try
    oUsers := FUserController.getUsers('');
    try
      ((FFormView) as Tfmain).lstuers.Items.clear;
      for i := 0 to oUsers.Count - 1 do
      begin
        oitem := ((FFormView) as Tfmain).lstuers.Items.Add;
        oitem.Tag := oUsers[i].insta_user_id;
        odata := oUsers[i].insta_user_last_visit;
        isfollow := 'Não';
        if oUsers[i].insta_user_following = 1 then
          isfollow := 'Sim';

        oitem.Text := oUsers[i].insta_user_name + ' - ' + '  ' +
          DateTimeToStr(odata);
        oitem.ImageIndex := 4;
        if isfollow = 'Sim' then
          oitem.ImageIndex := 3;

      end;
      ((FFormView) as Tfmain).lblusercount.Text := 'Usuários : ' +
        inttostr(oUsers.Count);
      ((FFormView) as Tfmain).lblcords.Text := inttostr(oUsers.Count) +
        ' Usuário(s)   carregado(s)';
    finally
      if assigned(oUsers) then
        FreeAndNil(oUsers);
    end;
  except
    on e: exception do
      Tutil.gravalog('[TMAIN-493]' + e.message);
  end;

end;

procedure TMainController.logop(value: string);
begin
  try
    ((FFormView) as Tfmain).memolog.Lines.Add(value);
  except
    on e: exception do
      Tutil.gravalog('[TMAIN-504]' + e.message);
  end;

end;

procedure TMainController.sincronizeactions;
begin
  try
    FActionController.initialLoad := true;
    FActionController.sincronize;
    FActionController.onupdate := setViewAction;

  except
    on e: exception do
    begin
      logop('[UpdateAction] ' + e.message);
      Tutil.gravalog('[TMAIN-521]' + e.message);
    end;
  end;
end;

procedure TMainController.sincronizeusers;
begin
  try
    FUserController.initialLoad := true;
    FUserController.sincronize;
    FUserController.onupdate := setViewUser;

  except
    on e: exception do
    begin
      logop('[UpdateUser] ' + e.message);
      Tutil.gravalog('[TMAIN-537]' + e.message);
    end;
  end;
end;

procedure TMainController.sincronizecomments;
begin
  try
    FCommentController.initialLoad := true;
    FCommentController.sincronize;
    FCommentController.onupdate := setViewComment;
  except
    on e: exception do
    begin
      logop('[UpdateComents] ' + e.message);
      Tutil.gravalog('[TMAIN-550]' + e.message);
    end;
  end;
end;

procedure TMainController.sincronizehashtags;
begin
  try
    FHashTagController.initialLoad := true;
    FHashTagController.sincronize;
    FHashTagController.onupdate := setViewHashTag;
  except
    on e: exception do
    begin
      logop('[UpdateHashTags] ' + e.message);
      Tutil.gravalog('[TMAIN-564]' + e.message);
    end;
  end;
end; { ------------------------------------------------------------------------------ }

procedure TMainController.sincronizeall;
begin
  sincronizeactions;
  sincronizeusers;
  sincronizecomments;
  sincronizehashtags;
end;

procedure TMainController.clearDb;
begin
  TDialogService.PreferredMode := TDialogService.TPreferredMode.Platform;
  TDialogService.MessageDialog
    ('Confirma a exclusao de todos os registros locais ?',
    TMsgDlgType.mtConfirmation, FMX.Dialogs.mbYesNo, TMsgDlgBtn.mbNo, 0,
    procedure(const AResult: TModalResult)
    begin
      case AResult of
        mrYes:
          begin
            with TActionDao.create do
            begin
              deleteAction(-6);
              free;
            end;
            with TCommentDao.create do
            begin
              deleteComment(-6);
              free;
            end;
            with TUserDao.create do
            begin
              deleteUser(-6);
              free;
            end;
            with ThashtagDao.create do
            begin
              deleteHashTag(-6);
              free;
            end;
            ShowMessage('Dados locais excluidos');
          end;
      end;
    end);
end;

initialization

FmainController := TMainController.create;

end.
{
  android: fontFamily = " sans - serif " // roboto regular
  android: fontFamily = " sans - serif - light " // roboto light
  android: fontFamily = " sans - serif - condensed " // roboto condensed
  android: fontFamily = " sans - serif - thin " // roboto thin (android 4.2)
  android: fontFamily = " sans - serif - medium " // roboto medium (android 5.0)
}

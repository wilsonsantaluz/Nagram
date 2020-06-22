program Nagram;

uses
  System.StartUpCopy,
  System.IOUtils,
  sysutils,
  FMX.Forms,
  Nagram.view.main in 'view\nagram.view.main.pas' {fmain} ,
  Nagram.service.navegador in 'service\nagram.service.navegador.pas',
  Nagram.android.util in 'lib\nagram.android.util.pas',
  Nagram.datamodule
    in 'datamodule\nagram.datamodule.pas' {dm_local: TDataModule} ,
  Nagram.control.action in 'control\nagram.control.action.pas',
  Nagram.model.action in 'model\nagram.model.action.pas',
  Nagram.dao.action in 'dao\nagram.dao.action.pas',
  Nagram.dao.user in 'dao\nagram.dao.user.pas',
  Nagram.model.user in 'model\nagram.model.user.pas',
  Nagram.control.user in 'control\nagram.control.user.pas',
  Nagram.model.comment in 'model\nagram.model.comment.pas',
  Nagram.dao.comment in 'dao\nagram.dao.comment.pas',
  Nagram.view.action in 'view\nagram.view.action.pas' {fviewAction} ,
  Nagram.model.localoption in 'model\nagram.model.localoption.pas',
  Nagram.dao.localoption in 'dao\nagram.dao.localoption.pas',
  Nagram.control.localoption in 'control\nagram.control.localoption.pas',
  Nagram.view.user in 'view\nagram.view.user.pas' {FUserView} ,
  Nagram.service.http in 'service\nagram.service.http.pas',
  Nagram.view.login in 'view\nagram.view.login.pas' {Flogin} ,
  Nagram.control.person in 'control\nagram.control.person.pas',
  Nagram.model.person in 'model\nagram.model.person.pas',
  Nagram.dao.person in 'dao\nagram.dao.person.pas',
  Nagram.view.person in 'view\nagram.view.person.pas' {FviewPerson} ,
  Nagram.lib.infoacount in 'lib\nagram.lib.infoacount.pas',
  Nagram.lib.getpermision in 'lib\nagram.lib.getpermision.pas',
  Nagram.service.persistdata in 'service\nagram.service.persistdata.pas',
  Nagram.model.hashtag in 'model\nagram.model.hashtag.pas',
  Nagram.service.deviceinfo in 'service\nagram.service.deviceinfo.pas',
  Nagram.control.base in 'control\nagram.control.base.pas',
  Nagram.control.hashtag in 'control\nagram.control.hashtag.pas',
  Nagram.dao.hashtag in 'dao\nagram.dao.hashtag.pas',
  Nagram.control.comment in 'control\nagram.control.comment.pas',
  Nagram.control.main in 'control\nagram.control.main.pas',
  Nagram.resource.master in 'resource\nagram.resource.master.pas',
  RestDecompress in 'component\RestDecompress.pas',
  Nagram.service.rest in 'service\nagram.service.rest.pas',
  IdSSL,
  IdSSLOpenSSLHeaders,
  IdSSLOpenSSL,

  Nagram.view.sendfeedback in 'view\nagram.view.sendfeedback.pas' {FmailSend};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TFlogin, Flogin);
  IdOpenSSLSetLibPath(TPath.GetDocumentsPath);
  Application.Run;

end.

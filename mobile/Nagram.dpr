program Nagram;

uses
  System.StartUpCopy,
  System.IOUtils,
  sysutils,
  FMX.Forms,
  nagram.view.main in 'view\nagram.view.main.pas' {fmain},
  nagram.service.navegador in 'service\nagram.service.navegador.pas',
  nagram.android.util in 'lib\nagram.android.util.pas',
  nagram.datamodule in 'datamodule\nagram.datamodule.pas' {dm_local: TDataModule},
  nagram.control.action in 'control\nagram.control.action.pas',
  nagram.model.action in 'model\nagram.model.action.pas',
  nagram.dao.action in 'dao\nagram.dao.action.pas',
  nagram.dao.user in 'dao\nagram.dao.user.pas',
  nagram.model.user in 'model\nagram.model.user.pas',
  nagram.control.user in 'control\nagram.control.user.pas',
  nagram.model.comment in 'model\nagram.model.comment.pas',
  nagram.dao.comment in 'dao\nagram.dao.comment.pas',
  nagram.view.action in 'view\nagram.view.action.pas' {fviewAction},
  nagram.model.localoption in 'model\nagram.model.localoption.pas',
  nagram.dao.localoption in 'dao\nagram.dao.localoption.pas',
  nagram.control.localoption in 'control\nagram.control.localoption.pas',
  nagram.view.user in 'view\nagram.view.user.pas' {FUserView},
  nagram.service.http in 'service\nagram.service.http.pas',
  nagram.view.login in 'view\nagram.view.login.pas' {Flogin},
  nagram.control.person in 'control\nagram.control.person.pas',
  nagram.model.person in 'model\nagram.model.person.pas',
  nagram.dao.person in 'dao\nagram.dao.person.pas',
  nagram.view.person in 'view\nagram.view.person.pas' {FviewPerson},
  nagram.lib.infoacount in 'lib\nagram.lib.infoacount.pas',
  nagram.lib.getpermision in 'lib\nagram.lib.getpermision.pas',
  nagram.service.persistdata in 'service\nagram.service.persistdata.pas',
  nagram.model.hashtag in 'model\nagram.model.hashtag.pas',
  nagram.service.deviceinfo in 'service\nagram.service.deviceinfo.pas',
  nagram.control.base in 'control\nagram.control.base.pas',
  nagram.control.hashtag in 'control\nagram.control.hashtag.pas',
  nagram.dao.hashtag in 'dao\nagram.dao.hashtag.pas',
  nagram.control.comment in 'control\nagram.control.comment.pas',
  nagram.control.main in 'control\nagram.control.main.pas',
  nagram.resource.master in 'resource\nagram.resource.master.pas',
  RestDecompress in 'component\RestDecompress.pas',
  nagram.service.rest in 'service\nagram.service.rest.pas',
  IdSSL,
  IdSSLOpenSSLHeaders,
  IdSSLOpenSSL,
  nagram.view.sendfeedback in 'view\nagram.view.sendfeedback.pas' {FmailSend},
  nagram.view.releasenotes in 'view\nagram.view.releasenotes.pas' {FreleaseNotes},
  nagram.service.geolocation in 'service\nagram.service.geolocation.pas',
  nagram.service.sendmail in 'service\nagram.service.sendmail.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TFlogin, Flogin);
  Application.CreateForm(TFreleaseNotes, FreleaseNotes);
  IdOpenSSLSetLibPath(TPath.GetDocumentsPath);
  Application.Run;

end.

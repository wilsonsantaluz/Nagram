unit nagram.resource.master;

interface
const
_bancodados='banco_se3.s3db';
_user_agent='nagram_mobile_consumer';
_rest_user ='mobile_user';
_rest_pass='2061614';
_rest_host='http://209.239.112.15:6466';
//_rest_host='http://localhost:6466';
_rest_url_person='/datasnap/rest/Tperson/person/';
_rest_url_info='/datasnap/rest/TPersondevice/persondevice/';
_rest_url_action='/datasnap/rest/Taction/action/';
_rest_url_user='/datasnap/rest/Tuser/user/';
_rest_url_hashtag='/datasnap/rest/Thashtag/hashtag/';
_rest_url_comment='/datasnap/rest/Tcomment/comment/';


{ ------------------------------------------------------------------------------- }
{ CONSTANTES PARA NAVEGAÇAO INSTAGRAM }
{ Wilson Luz 2020 }
_xpaht_story ='''//*[@id="react-root"]/section/main/div/header/div/div''';
{ ------------------------------------------------------------------------------- }
_xpath_btseguiruser=
'''//*[@id="react-root"]/section/main/div/div[1]/article/header/div[2]/div[1]/div[2]/button''' ;
{ ------------------------------------------------------------------------------- }
_xpath_btcomment =
'''//*[@id="react-root"]/section/main/section/div/form/button''';
{ ------------------------------------------------------------------------------- }
_xpath_txtcomment =
'''//*[@id="react-root"]/section/main/section/div/form/textarea''';
{ ------------------------------------------------------------------------------- }
_xpath_seguirHashTag =
  '''//*[@id="react-root"]/section/main/header/div[2]/div[1]/button''';
{ ------------------------------------------------------------------------------- }
_xpath_nome_user =
  '''//*[@id="react-root"]/section/main/div/div[1]/article/header/div[2]/div[1]/div[1]/a''';
{ ------------------------------------------------------------------------------- }
_xpath_thumbnail =
  '''//*[@id="react-root"]/section/main/article/div[1]/div/div/div[1]/div[1]/a/div''';

{ ------------------------------------------------------------------------------- }
_xpath_likepost =
'''//*[@id="react-root"]/section/main/div/div[1]/article/div[2]/section[1]/span[1]/button''';

_xpath_botaocomentar =
'''//*[@id="react-root"]/section/main/div/div[1]/article/div[2]/section[1]/span[2]/button''';

_ctPageLogin = 'accounts/login/';
{ ------------------------------------------------------------------------------- }
_scrriptLogin =
  'try {                                                           ' + #13#10 +
  '    var osenha = document.getElementsByName("password")[0];     ' + #13#10 +
  '    if (osenha != "") {                                         ' + #13#10 +
  '        var nativeInputValueSetter =                            ' + #13#10 +
  '        Object.getOwnPropertyDescriptor(                        ' + #13#10 +
  '          window.HTMLInputElement.prototype, "value").set;      ' + #13#10 +
  '           nativeInputValueSetter.call(osenha, "$senha");       ' + #13#10 +
  '        var evsenha = new Event("input", {                    ' + #13#10 +
  '            bubbles: true                                       ' + #13#10 +
  '        });                                                     ' + #13#10 +
  '        osenha.dispatchEvent(evsenha);                          ' + #13#10 +
  '        var ouser = document.getElementsByName("username")[0];  ' + #13#10 +
  '        var nativeInputValueSetter =                            ' + #13#10 +
  '           Object.getOwnPropertyDescriptor(                     ' + #13#10 +
  '             window.HTMLInputElement.prototype, "value").set;   ' + #13#10 +
  '        nativeInputValueSetter.call(ouser, "$user");            ' + #13#10 +
  '        var evuser = new Event("input", {                       ' + #13#10 +
  '            bubbles: true                                       ' + #13#10 +
  '        });                                                     ' + #13#10 +
  '        ouser.dispatchEvent(evuser);                            ' + #13#10 +
  '        var aTags = document.getElementsByTagName("button");    ' + #13#10 +
  '        var searchText = "Entrar";                              ' + #13#10 +
  '        for (var i = 0; i < aTags.length; i++) {                ' + #13#10 +
  '            if (aTags[i].textContent == searchText) {           ' + #13#10 +
  '                var blogin = aTags[i];                          ' + #13#10 +
  '                break;                                          ' + #13#10 +
  '            }                                                   ' + #13#10 +
  '        };                                                      ' + #13#10 +
  '        blogin.click();                                         ' + #13#10 +
 // '         oresult = "[SUCESS] click executado";                  ' + #13#10 +
  '    } else {                                                    ' + #13#10 +
 // '        oresult = "[E001] objeto senha não encontrado";         ' + #13#10 +
  '    };                                                          ' + #13#10 +
  '}                                                               ' + #13#10 +
  'catch(err) {                                                    ' + #13#10 +
  '    oresult = "[E002]" + err;                                   ' + #13#10 +
  '};                                                              ';
{------------------------------------------------------------------------------}
_json_shortcode ='["entry_data"]["TagPage"][0]["graphql"]["hashtag"]["edge_hashtag_to_media"]["edges"][$id]["node"].shortcode';
{------------------------------------------------------------------------------}
_json_followeds =
  '["entry_data"]["ProfilePage"][0]["graphql"]["user"]["edge_followed_by"].count';
{ ------------------------------------------------------------------------------- }
_json_follow =
  '["entry_data"]["ProfilePage"][0]["graphql"]["user"]["edge_follow"].count';

{ ------------------------------------------------------------------------------- }
_json_bio = '["entry_data"]["ProfilePage"][0]["graphql"]["user"].biography';
{ ------------------------------------------------------------------------------- }
_json_posts =
  '["entry_data"]["TagPage"][0]["graphql"]["hashtag"]["edge_hashtag_to_media"].count';
{ ------------------------------------------------------------------------------- }
_jsonarray_posts =
  '["entry_data"]["TagPage"][0]["graphql"]["hashtag"]["edge_hashtag_to_media"]["edges"]';
{ ------------------------------------------------------------------------------- }
_scriptBase = '  try {                                ' + #13#10 +
  'function getElementByXpath(path) {                 ' + #13#10 +
  '      return document.evaluate(path, document,     ' + #13#10 +
  '        null, XPathResult.FIRST_ORDERED_NODE_TYPE, ' + #13#10 +
  '        null).singleNodeValue;                     ' + #13#10 +
  '      };                                           ' + #13#10 +
  '    }                                              ' + #13#10 +
  'catch(err) { alert("E233"+err)                     ' + #13#10 +
  '};                                                 ';
{ ------------------------------------------------------------------------------- }
_scriptGetUser = '  try {                                   ' + #13#10 +
  ' var vuser=  getElementByXpath(' + _xpath_nome_user + '); ' + #13#10 +
  '     if (vuser  ) {                                      ' + #13#10 +
  '          function getvalue_cx(){return  vuser.text;};   ' + #13#10 +
  '     }else {                                             ' + #13#10 +
  '        function getvalue_cx(){return  "undefined"};     ' + #13#10 +
  '      };                                                 ' + #13#10 +
  '    }                                                    ' + #13#10 +
  '  catch(err) { alert("E256"+err)                         ' + #13#10 +
  ' };                                                      ';
{ ------------------------------------------------------------------------------- }
_scriptGetThumbnail =

  'try {                                                            ' + #13#10 +
  '  var first_thumbnail = getElementByXpath(' + _xpath_thumbnail + ');' +
  #13#10 + '   if (first_thumbnail) {                                        ' +
  #13#10 + '   function getdata_cx(){                                        ' +
  #13#10 + 'return  btoa(encodeURIComponent(JSON.stringify( _sharedData)));  ' +
  #13#10 + '   };                                                            ' +
  #13#10 + '  } else  {                                                      ' +
  #13#10 + '     function getdata_cx(){return "undefined"};                  ' +
  #13#10 + ' };                                                              ' +
  #13#10 + ' }                                                              ' +
  #13#10 + ' catch(err)                                                      ' +
  #13#10 + '  { alert("E233"+err) ;                                          ' +
  #13#10 + '  };                                                             ';
{ ------------------------------------------------------------------------------- }
_scriptGetJsonUser =
  'function getdata_cx(){return  btoa( encodeURIComponent(JSON.stringify( _sharedData)));};';
{ ------------------------------------------------------------------------------- }
_scriptFollowHahsTag = 'var olement= getElementByXpath(' + _xpath_seguirHashTag +
  ');                                                          ' + #13#10 +
  ' if (olement){                                                ' + #13#10 +
  '    if (olement.innerText  ==''Seguindo'')                    ' + #13#10 +
  '    {                                                         ' + #13#10 +
  '                                                              ' + #13#10 +
  '    }  else                                                   ' + #13#10 +
  '      olement.click();                                        ' + #13#10 +
  '};                                        ';
{ ------------------------------------------------------------------------------- }
_scriptGetShareData ='function getdata_cx(){return  btoa(encodeURIComponent(JSON.stringify( _sharedData))); };';

_urlExplore ='explore/tags/';
{ ------------------------------------------------------------------------------- }
_scriptSeguirUser ='getElementByXpath('+_xpath_btseguiruser+').click();';
{ ------------------------------------------------------------------------------- }
_scriptLikePost =
'getElementByXpath('+_xpath_likepost +').click();';
{ ------------------------------------------------------------------------------- }
_scriptPaginaComentario=
'getElementByXpath('+_xpath_botaocomentar+').click();' ;
{ ------------------------------------------------------------------------------- }

_scriptComentario =
'var textarea = getElementByXpath('+_xpath_txtcomment +');'+ #13#10 +
'function setNativeValue(element, value) {     '+ #13#10 +
'    const valueSetter = Object.getOwnPropertyDescriptor(element,'+ #13#10 +
'        ''value'').set;                              '+ #13#10 +
'    const prototype = Object.getPrototypeOf(element);'+ #13#10 +
'    const prototypeValueSetter = Object.getOwnPropertyDescriptor('+ #13#10 +
'        prototype, "value").set;'+ #13#10 +
'    if (valueSetter && valueSetter !== prototypeValueSetter) {'+ #13#10 +
'        prototypeValueSetter.call(element, value); '+ #13#10 +
'    } else {              '+ #13#10 +
'        valueSetter.call(element, value);'+ #13#10 +
'    }      '+ #13#10 +
'};   '+ #13#10 +
'setNativeValue(textarea, "$comentario");  '+ #13#10 +

'textarea.dispatchEvent(new Event("input", { '+ #13#10 +
'    bubbles: true '+ #13#10 +
'}));         '+ #13#10 +
'getElementByXpath('+_xpath_btcomment +').click();     ';

 implementation
 end.

{ ------------------------------------------------------------------------------- }

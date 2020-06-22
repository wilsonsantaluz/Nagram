object NgServerContainer: TNgServerContainer
  OldCreateOrder = False
  Height = 223
  Width = 618
  object NagramDSServer: TDSServer
    Left = 112
    Top = 11
  end
  object NagramAuth: TDSAuthenticationManager
    OnUserAuthenticate = NagramAuthUserAuthenticate
    OnUserAuthorize = NagramAuthUserAuthorize
    Roles = <>
    Left = 112
    Top = 66
  end
  object UserServerClass: TDSServerClass
    OnGetClass = UserServerClassGetClass
    Server = NagramDSServer
    Left = 216
    Top = 11
  end
  object HashTagsServerClass: TDSServerClass
    OnGetClass = HashTagsServerClassGetClass
    Server = NagramDSServer
    Left = 448
    Top = 67
  end
  object PersonServerClass: TDSServerClass
    OnGetClass = PersonServerClassGetClass
    Server = NagramDSServer
    Left = 216
    Top = 67
  end
  object ActionServerClass: TDSServerClass
    OnGetClass = ActionServerClassGetClass
    Server = NagramDSServer
    Left = 328
    Top = 11
  end
  object CommentServerClas: TDSServerClass
    OnGetClass = CommentServerClasGetClass
    Server = NagramDSServer
    Left = 328
    Top = 67
  end
  object MetodsServerClass: TDSServerClass
    OnGetClass = MetodsServerClassGetClass
    Server = NagramDSServer
    Left = 448
    Top = 11
  end
  object PersonLocation: TDSServerClass
    OnGetClass = PersonLocationGetClass
    Server = NagramDSServer
    Left = 328
    Top = 131
  end
  object PersonDevice: TDSServerClass
    OnGetClass = PersonDeviceGetClass
    Server = NagramDSServer
    Left = 216
    Top = 131
  end
end

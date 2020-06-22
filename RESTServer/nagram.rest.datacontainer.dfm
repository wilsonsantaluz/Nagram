object WebModule1: TWebModule1
  OldCreateOrder = False
  OnCreate = WebModuleCreate
  Actions = <
    item
      Name = 'ReverseStringAction'
      PathInfo = '/ReverseString'
      Producer = ReverseString
    end
    item
      Name = 'ServerFunctionInvokerAction'
      PathInfo = '/ServerFunctionInvoker'
      Producer = ServerFunctionInvoker
    end
    item
      Default = True
      Name = 'DefaultAction'
      PathInfo = '/'
      OnAction = WebModuleDefaultAction
    end>
  BeforeDispatch = WebModuleBeforeDispatch
  AfterDispatch = WebModuleAfterDispatch
  Height = 456
  Width = 608
  object DSHTTPWebDispatcher1: TDSHTTPWebDispatcher
    Filters = <>
    WebDispatch.PathInfo = 'datasnap*'
    Left = 56
    Top = 75
  end
  object ServerFunctionInvoker: TPageProducer
    HTMLFile = 'templates/serverfunctioninvoker.html'
    OnHTMLTag = ServerFunctionInvokerHTMLTag
    Left = 56
    Top = 184
  end
  object ReverseString: TPageProducer
    HTMLFile = 'templates/reversestring.html'
    OnHTMLTag = ServerFunctionInvokerHTMLTag
    Left = 200
    Top = 72
  end
  object WebFileDispatcher1: TWebFileDispatcher
    WebFileExtensions = <
      item
        MimeType = 'text/css'
        Extensions = 'css'
      end
      item
        MimeType = 'text/javascript'
        Extensions = 'js'
      end
      item
        MimeType = 'image/x-png'
        Extensions = 'png'
      end
      item
        MimeType = 'text/html'
        Extensions = 'htm;html'
      end
      item
        MimeType = 'image/jpeg'
        Extensions = 'jpg;jpeg;jpe'
      end
      item
        MimeType = 'image/gif'
        Extensions = 'gif'
      end>
    BeforeDispatch = WebFileDispatcher1BeforeDispatch
    WebDirectories = <
      item
        DirectoryAction = dirInclude
        DirectoryMask = '*'
      end
      item
        DirectoryAction = dirExclude
        DirectoryMask = '\templates\*'
      end>
    RootDirectory = '.'
    VirtualPath = '/'
    Left = 56
    Top = 136
  end
  object DSProxyGenerator1: TDSProxyGenerator
    ExcludeClasses = 'DSMetadata'
    MetaDataProvider = DSServerMetaDataProvider1
    Writer = 'Java Script REST'
    Left = 64
    Top = 248
  end
  object DSServerMetaDataProvider1: TDSServerMetaDataProvider
    Left = 200
    Top = 232
  end
  object DSProxyDispatcher1: TDSProxyDispatcher
    DSProxyGenerator = DSProxyGenerator1
    Left = 200
    Top = 152
  end
  object NagramTransp: TDSTCPServerTransport
    Server = NgServerContainer.NagramDSServer
    BufferKBSize = 100
    Filters = <
      item
        FilterId = 'ZLibCompression'
        Properties.Strings = (
          'CompressMoreThan=1024')
      end>
    KeepAliveEnablement = kaEnabled
    Left = 72
    Top = 344
  end
end

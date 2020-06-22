object BaseData: TBaseData
  OldCreateOrder = False
  OnCreate = DataModuleCreate
  Height = 382
  Width = 527
  object FDConnection1: TFDConnection
    Params.Strings = (
      'DriverID=PG'
      'CharacterSet=BIG5')
    Left = 248
    Top = 176
  end
end

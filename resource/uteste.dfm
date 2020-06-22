object Form15: TForm15
  Left = 0
  Top = 0
  Caption = 'Form15'
  ClientHeight = 500
  ClientWidth = 804
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object DBGrid1: TDBGrid
    Left = 0
    Top = 0
    Width = 804
    Height = 370
    Align = alClient
    DataSource = DataSource1
    TabOrder = 0
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -11
    TitleFont.Name = 'Tahoma'
    TitleFont.Style = []
  end
  object Panel1: TPanel
    Left = 0
    Top = 459
    Width = 804
    Height = 41
    Align = alBottom
    Caption = 'Panel1'
    TabOrder = 1
    ExplicitLeft = 280
    ExplicitTop = 312
    ExplicitWidth = 185
    object Button2: TButton
      Left = 176
      Top = 8
      Width = 75
      Height = 25
      Caption = 'Button2'
      TabOrder = 0
      OnClick = Button2Click
    end
  end
  object Memo1: TMemo
    Left = 0
    Top = 370
    Width = 804
    Height = 89
    Align = alBottom
    Lines.Strings = (
      'select  cast(person_uuid as varchar(50)),  * from person')
    TabOrder = 2
    ExplicitLeft = 224
    ExplicitTop = 304
    ExplicitWidth = 185
  end
  object Button1: TButton
    Left = 8
    Top = 465
    Width = 75
    Height = 25
    Caption = 'Button1'
    TabOrder = 3
    OnClick = Button1Click
  end
  object FDConnection1: TFDConnection
    Params.Strings = (
      'Server=dev.ugestor.com.br'
      'Port=55432'
      'Password=RBB7tx5gV7upbg'
      'User_Name=postgres'
      'CharacterSet=UTF8'
      'Database=nagram-producao'
      'DriverID=pG')
    Left = 280
    Top = 112
  end
  object FDQuery1: TFDQuery
    Connection = FDConnection1
    Left = 592
    Top = 88
  end
  object DataSource1: TDataSource
    DataSet = FDQuery1
    Left = 192
    Top = 96
  end
end

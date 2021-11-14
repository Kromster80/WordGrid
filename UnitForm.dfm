object Form6: TForm6
  Left = 0
  Top = 0
  Caption = 'WordGrid'
  ClientHeight = 433
  ClientWidth = 537
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  DesignSize = (
    537
    433)
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 16
    Top = 160
    Width = 87
    Height = 13
    Caption = 'Best layout score:'
  end
  object Label2: TLabel
    Left = 112
    Top = 160
    Width = 3
    Height = 13
  end
  object Label3: TLabel
    Left = 16
    Top = 16
    Width = 54
    Height = 13
    Caption = 'Layout size'
  end
  object Label4: TLabel
    Left = 16
    Top = 144
    Width = 64
    Height = 13
    Caption = 'xxxxx/xxxxx'
  end
  object Panel1: TPanel
    Left = 136
    Top = 16
    Width = 385
    Height = 401
    Anchors = [akLeft, akTop, akRight, akBottom]
    TabOrder = 0
  end
  object btnGenerateNew: TButton
    Left = 16
    Top = 56
    Width = 113
    Height = 33
    Caption = 'Generate new'
    TabOrder = 1
    OnClick = btnGenerateNewClick
  end
  object seGridSizeX: TSpinEdit
    Left = 16
    Top = 32
    Width = 57
    Height = 22
    MaxValue = 0
    MinValue = 0
    TabOrder = 2
    Value = 16
  end
  object btnImprove: TButton
    Left = 16
    Top = 88
    Width = 113
    Height = 25
    Caption = 'Improve'
    TabOrder = 3
    OnClick = btnImprove10Click
  end
  object seGridSizeY: TSpinEdit
    Left = 72
    Top = 32
    Width = 57
    Height = 22
    MaxValue = 0
    MinValue = 0
    TabOrder = 4
    Value = 16
  end
  object RadioGroup1: TRadioGroup
    Left = 16
    Top = 184
    Width = 113
    Height = 65
    Caption = 'RadioGroup1'
    ItemIndex = 1
    Items.Strings = (
      'Compact'
      'Spread')
    TabOrder = 5
  end
  object Timer1: TTimer
    OnTimer = Timer1Timer
    Left = 144
    Top = 24
  end
end

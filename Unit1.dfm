object Form1: TForm1
  Left = 0
  Top = 0
  AutoSize = True
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = #1056#1086#1077#1074#1086#1081' '#1080#1085#1090#1077#1083#1083#1077#1082#1090
  ClientHeight = 622
  ClientWidth = 847
  Color = clBtnFace
  DoubleBuffered = True
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnResize = FormResize
  OnShow = FormShow
  DesignSize = (
    847
    622)
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 678
    Top = 219
    Width = 93
    Height = 13
    Anchors = [akTop, akRight]
    Caption = #1054#1073#1097#1080#1077' '#1088#1077#1089#1091#1088#1089#1099': 0'
  end
  object PaintBox1: TPaintBox
    Left = 0
    Top = 0
    Width = 672
    Height = 622
    Anchors = [akLeft, akTop, akRight, akBottom]
    OnMouseUp = PaintBox1MouseUp
    OnPaint = PaintBox1Paint
    ExplicitWidth = 728
    ExplicitHeight = 623
  end
  object Label5: TLabel
    Left = 678
    Top = 238
    Width = 53
    Height = 13
    Anchors = [akTop, akRight]
    Caption = #1041#1086#1090#1086#1074': 0/0'
  end
  object Label6: TLabel
    Left = 678
    Top = 276
    Width = 56
    Height = 13
    Anchors = [akTop, akRight]
    Caption = #1050#1086#1088#1086#1083#1077#1074': 0'
  end
  object Label7: TLabel
    Left = 678
    Top = 586
    Width = 39
    Height = 13
    Anchors = [akRight, akBottom]
    Caption = #1062#1080#1082#1083': 0'
  end
  object Label8: TLabel
    Left = 678
    Top = 257
    Width = 119
    Height = 13
    Anchors = [akTop, akRight]
    Caption = #1052#1105#1088#1090#1074#1099#1093'/'#1088#1077#1089#1091#1088#1089#1086#1074': 0/0'
  end
  object Button2: TButton
    Left = 744
    Top = 188
    Width = 95
    Height = 25
    Anchors = [akTop, akRight]
    Caption = #1059#1076#1072#1083#1080#1090#1100' '#1074#1089#1077#1093
    TabOrder = 0
    OnClick = Button2Click
  end
  object GroupBox1: TGroupBox
    Left = 672
    Top = 7
    Width = 175
    Height = 85
    Anchors = [akTop, akRight]
    Caption = '  '#1041#1086#1090#1099'  '
    TabOrder = 1
    object Label2: TLabel
      Left = 10
      Top = 20
      Width = 101
      Height = 13
      Caption = #1056#1072#1076#1080#1091#1089' '#1089#1083#1099#1096#1080#1084#1086#1089#1090#1080
    end
    object Label3: TLabel
      Left = 24
      Top = 48
      Width = 86
      Height = 13
      Caption = #1046#1080#1079#1085#1077#1085#1085#1099#1081' '#1094#1080#1082#1083
    end
    object se_radius: TSpinEdit
      Left = 117
      Top = 17
      Width = 49
      Height = 22
      MaxValue = 255
      MinValue = 1
      TabOrder = 0
      Value = 80
      OnChange = se_radiusChange
    end
    object se_life: TSpinEdit
      Left = 116
      Top = 45
      Width = 49
      Height = 22
      MaxValue = 0
      MinValue = 0
      TabOrder = 1
      Value = 500
      OnChange = se_lifeChange
    end
  end
  object GroupBox2: TGroupBox
    Left = 672
    Top = 98
    Width = 175
    Height = 84
    Anchors = [akTop, akRight]
    Caption = '  '#1056#1077#1089#1091#1088#1089#1099'  '
    TabOrder = 2
    object Label4: TLabel
      Left = 14
      Top = 24
      Width = 60
      Height = 13
      Caption = #1050#1086#1083#1080#1095#1077#1089#1090#1074#1086
    end
    object se_res_count: TSpinEdit
      Left = 121
      Top = 21
      Width = 49
      Height = 22
      MaxValue = 0
      MinValue = 0
      TabOrder = 0
      Value = 4
    end
  end
  object chb_paint: TCheckBox
    Left = 678
    Top = 605
    Width = 97
    Height = 17
    Anchors = [akRight, akBottom]
    Caption = #1053#1077' '#1087#1086#1082#1072#1079#1099#1074#1072#1090#1100
    TabOrder = 3
    OnClick = chb_paintClick
  end
  object Memo1: TMemo
    Left = 672
    Top = 295
    Width = 173
    Height = 285
    BorderStyle = bsNone
    Color = clBtnFace
    Lines.Strings = (
      #1059#1089#1083#1086#1074#1080#1077' '#1078#1080#1079#1085#1080':'
      '- '#1052#1080#1088' '#1086#1075#1088#1072#1085#1080#1095#1077#1085' '#1074' '#1088#1077#1089#1091#1088#1089#1072#1093
      '- '#1042#1089#1077' '#1089#1083#1077#1087#1099', '#1085#1086' '#1084#1086#1075#1091#1090' '
      #1086#1073#1097#1072#1090#1100#1089#1103' '#1074' N '#1088#1072#1076#1080#1091#1089#1077'.'
      '- '#1050#1072#1078#1076#1099#1081' '#1096#1072#1075', '#1086#1090#1085#1080#1084#1072#1077#1090' '
      #1078#1080#1079#1085#1100' '#1091' '#1074#1089#1077#1093' '#1082#1088#1072#1089#1085#1099#1093
      ''
      #1062#1077#1083#1100' '#1082#1088#1072#1089#1085#1099#1093' ('#1082#1086#1088#1086#1083#1077#1074'):'
      '- '#1056#1086#1076#1080#1090#1100' '#1073#1086#1083#1100#1096#1077' '#1073#1086#1090#1086#1074' '
      #1076#1083#1103' '#1087#1086#1080#1089#1082#1086#1074' '#1077#1076#1099
      ''
      #1062#1077#1083#1100' '#1073#1086#1090#1086#1074':'
      '- '#1053#1072#1081#1090#1080' '#1077#1076#1091' '#1080#1083#1080' '#1082#1086#1088#1086#1083#1077#1074#1091
      '- '#1057#1086#1086#1073#1097#1080#1090#1100' '#1074#1089#1077#1084' '#1082#1090#1086' '#1088#1103#1076#1086#1084' '#1086' '
      #1085#1072#1093#1086#1076#1082#1077' '#1080#1083#1080' '#1089#1082#1086#1083#1100#1082#1086' '#1096#1072#1075#1086#1074' '
      #1085#1072#1079#1072#1076' '#1086#1085#1072' '#1073#1099#1083#1072' '#1088#1103#1076#1086#1084
      '- '#1047#1072#1073#1088#1072#1090#1100' '#1095#1072#1089#1090#1100' '#1088#1077#1089#1091#1088#1089#1086#1074' '#1091' '#1077#1076#1099
      '- '#1055#1077#1088#1077#1076#1072#1090#1100' '#1088#1077#1089#1091#1088#1089#1099' '#1082#1086#1088#1086#1083#1077#1074#1077
      '- '#1055#1088#1080' '#1089#1084#1077#1088#1090#1080' '#1073#1086#1090#1072' '#1096#1072#1085#1089' 1 '#1080#1079' '
      '5000 '#1095#1090#1086' '#1088#1086#1076#1080#1090#1089#1103' '#1082#1086#1088#1086#1083#1077#1074#1072)
    ReadOnly = True
    TabOrder = 4
  end
  object TimerMove: TTimer
    Enabled = False
    Interval = 16
    OnTimer = TimerMoveTimer
    Left = 168
    Top = 48
  end
end

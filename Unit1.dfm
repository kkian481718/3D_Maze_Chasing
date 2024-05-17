object Form1: TForm1
  Left = 364
  Top = 116
  BorderStyle = bsDialog
  Caption = 'D&D'
  ClientHeight = 615
  ClientWidth = 651
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object L_LX: TLabel
    Left = 392
    Top = 176
    Width = 33
    Height = 13
    AutoSize = False
    Caption = 'L_LX'
  end
  object L_LY: TLabel
    Left = 424
    Top = 176
    Width = 33
    Height = 13
    AutoSize = False
    Caption = 'L_LY'
  end
  object L_Dir: TLabel
    Left = 496
    Top = 176
    Width = 49
    Height = 13
    AutoSize = False
    Caption = 'L_Dir'
  end
  object Card1: TCard
    Left = 16
    Top = 392
    Width = 71
    Height = 96
    Value = 1
    Suit = Hearts
    ShowDeck = True
    DeckType = Standard1
  end
  object Card3: TCard
    Left = 208
    Top = 392
    Width = 71
    Height = 96
    Value = 1
    Suit = Hearts
    ShowDeck = True
    DeckType = Standard1
  end
  object Card4: TCard
    Left = 304
    Top = 392
    Width = 71
    Height = 96
    Value = 1
    Suit = Hearts
    ShowDeck = True
    DeckType = Standard1
  end
  object Label1: TLabel
    Left = 392
    Top = 248
    Width = 65
    Height = 13
    AutoSize = False
    Caption = 'IP'
    Visible = False
  end
  object Label2: TLabel
    Left = 392
    Top = 288
    Width = 65
    Height = 13
    AutoSize = False
    Caption = 'Port'
    Visible = False
  end
  object Card2: TCard
    Left = 112
    Top = 392
    Width = 71
    Height = 96
    Value = 1
    Suit = Hearts
    ShowDeck = True
    DeckType = Standard1
  end
  object Button1: TButton
    Left = 112
    Top = 504
    Width = 169
    Height = 41
    Caption = #24448#21069#36208
    Font.Charset = ANSI_CHARSET
    Font.Color = clTeal
    Font.Height = -24
    Font.Name = #24494#36575#27491#40657#39636
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 0
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 112
    Top = 552
    Width = 81
    Height = 41
    Caption = '< '#24038#36681
    TabOrder = 1
    OnClick = Button2Click
  end
  object Button3: TButton
    Left = 208
    Top = 552
    Width = 73
    Height = 41
    Caption = #21491#36681' >'
    TabOrder = 2
    OnClick = Button3Click
  end
  object Edit1: TEdit
    Left = 392
    Top = 264
    Width = 153
    Height = 21
    Enabled = False
    TabOrder = 3
    Text = '127.0.0.1'
    Visible = False
  end
  object Panel1: TPanel
    Left = 16
    Top = 16
    Width = 361
    Height = 361
    Caption = '3D'#35222#35282
    Color = clActiveCaption
    TabOrder = 4
    Visible = False
  end
  object Panel2: TPanel
    Left = 392
    Top = 16
    Width = 153
    Height = 153
    Caption = #23567#22320#22294
    Color = clSkyBlue
    TabOrder = 5
    Visible = False
  end
  object ComboBox1: TComboBox
    Left = 392
    Top = 216
    Width = 153
    Height = 21
    ItemHeight = 13
    TabOrder = 6
    Text = #21934#20154#27169#24335' (Practice)'
    OnSelect = ComboBox1Select
    Items.Strings = (
      #21934#20154#27169#24335' (Practice)'
      #21152#20837#25151#38291' (Join Game)'
      #21109#31435#25151#38291' (New Server)')
  end
  object Edit2: TEdit
    Left = 392
    Top = 304
    Width = 153
    Height = 21
    Enabled = False
    TabOrder = 7
    Text = '8000'
    Visible = False
  end
  object Button4: TButton
    Left = 392
    Top = 336
    Width = 105
    Height = 41
    Caption = #36899#32218#65281
    Enabled = False
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlue
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 8
    Visible = False
    OnClick = Button4Click
  end
  object Button5: TButton
    Left = 504
    Top = 336
    Width = 41
    Height = 41
    Caption = #26039#38283
    Enabled = False
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    TabOrder = 9
    Visible = False
  end
  object Button6: TButton
    Left = 416
    Top = 424
    Width = 123
    Height = 121
    Caption = 'Button6'
    TabOrder = 10
  end
  object Timer1: TTimer
    Interval = 50
    OnTimer = Timer1Timer
    Left = 592
    Top = 16
  end
  object UDPC: TIdUDPClient
    Port = 0
    Left = 592
    Top = 48
  end
  object UDPS: TIdUDPServer
    Bindings = <>
    DefaultPort = 0
    OnUDPRead = UDPSUDPRead
    Left = 592
    Top = 80
  end
end

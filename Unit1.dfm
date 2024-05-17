object Form1: TForm1
  Left = 513
  Top = 126
  BorderStyle = bsDialog
  Caption = 'D&D'
  ClientHeight = 615
  ClientWidth = 649
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
    Width = 65
    Height = 13
    AutoSize = False
    Caption = 'L_LX'
  end
  object L_LY: TLabel
    Left = 448
    Top = 176
    Width = 57
    Height = 13
    AutoSize = False
    Caption = 'L_LY'
  end
  object L_Dir: TLabel
    Left = 504
    Top = 176
    Width = 57
    Height = 13
    AutoSize = False
    Caption = 'L_Dir'
  end
  object Card1: TCard
    Left = 304
    Top = 384
    Width = 71
    Height = 96
    Value = 1
    Suit = Hearts
    ShowDeck = False
    DeckType = Standard1
  end
  object Card2: TCard
    Left = 16
    Top = 384
    Width = 71
    Height = 96
    Value = 1
    Suit = Hearts
    ShowDeck = False
    DeckType = Standard1
  end
  object Card3: TCard
    Left = 112
    Top = 384
    Width = 71
    Height = 96
    Value = 1
    Suit = Hearts
    ShowDeck = False
    DeckType = Standard1
  end
  object Card4: TCard
    Left = 208
    Top = 384
    Width = 71
    Height = 96
    Value = 1
    Suit = Hearts
    ShowDeck = False
    DeckType = Standard1
  end
  object Button1: TButton
    Left = 112
    Top = 504
    Width = 153
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
    Width = 65
    Height = 41
    Caption = '< '#24038#36681
    TabOrder = 1
    OnClick = Button2Click
  end
  object Button3: TButton
    Left = 200
    Top = 552
    Width = 65
    Height = 41
    Caption = #21491#36681' >'
    TabOrder = 2
    OnClick = Button3Click
  end
  object Edit1: TEdit
    Left = 392
    Top = 256
    Width = 209
    Height = 21
    Enabled = False
    TabOrder = 3
    Text = '127.0.0.1'
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
  object Timer1: TTimer
    Interval = 50
    OnTimer = Timer1Timer
    Left = 592
    Top = 16
  end
  object IdUDPClient1: TIdUDPClient
    Port = 0
    Left = 592
    Top = 80
  end
  object IdUDPServer1: TIdUDPServer
    Bindings = <>
    DefaultPort = 0
    Left = 592
    Top = 112
  end
end

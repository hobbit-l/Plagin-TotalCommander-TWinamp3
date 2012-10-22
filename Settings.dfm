object TWAOptions: TTWAOptions
  Left = 375
  Top = 540
  AutoSize = True
  BorderIcons = []
  BorderStyle = bsSingle
  Caption = 'TWinAmp options'
  ClientHeight = 353
  ClientWidth = 586
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  Icon.Data = {
    0000010001001010000001001800680300001600000028000000100000002000
    0000010018000000000040030000000000000000000000000000000000000000
    00817E7A625E5C716D6B726E6C55525238363606071C1414AD1F1F1838363564
    5F5D888380000000000000000000908A87201E1D000000000000000000928427
    2F29003939F71E1ECA09197235AEFB040404948E8C0000000000000000009A94
    9175706E5B58563734321D1D852D2DE00000BE3939F92121D400006F39B1FF04
    65A2000000000000000000000000000000000000000000918B872423863131E9
    0000C13F3FFF2424E10000613AB6FF00619E0000000000000000000000000000
    000000000000000000002425854D4DFF0000C13B3BF52828DD0000523CBBFF00
    3E6600000000000000000000000000000000000000000000000025247C5C5CFF
    0000C23737E82A2ADF00004D3DBBFF001C310000000000000000000000000000
    0000000000000000000023247B2E30F70000C381816D8E8E8D220E1F38B0FE00
    0000000000000000000000000000000000000000000000000000000000B4B7C4
    7D7F84BABAB98484845E534C4196CE0000000000000000000000000000000000
    0000000000000000000000000069686800000084848482828287878792929200
    0000000000000000000000000000000000000000000000000000000000494949
    6F6F6F7D7D7D4D4D4D8484846262620000000000000000000000000000000000
    000000005E5E5E8989898E8E8E1819191111110B0C0A000000A3A3A36C6C6C00
    00000000000000000000000000000000000000000000007D7D7D949494979797
    8484842929290000004647476464640000000000000000000000000000000000
    000000000000001F1F1FA6A6A6A6A6A6A6A6A68E8E8EA4A4A41B1C1C9B9B9B00
    0000000000000000000000000000000000000000000000000000343130000000
    3232320000006868680E0D0C9090902524230000000000000000000000000000
    000000000000000000000000000000000000000000000000000000009999995D
    5A58000000000000000000000000000000000000000000000000000000000000
    0000000000000000000000002424250000000000000000000000000000000003
    00000007000000070000E00F0000F00F0000F00F0000F00F0000F00F0000F80F
    0000C80F0000808F0000C00F0000E00F0000F00F0000FFCF0000FFCF0000}
  OldCreateOrder = False
  Position = poScreenCenter
  OnClose = FormClose
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 0
    Top = 340
    Width = 585
    Height = 13
    Alignment = taRightJustify
    AutoSize = False
    Caption = 
      'TWinAmp3 v 1.02a filesystem plugin for Total Commander by Pavel ' +
      'Dubrovsky.'
  end
  object GroupBox1: TGroupBox
    Left = 1
    Top = 0
    Width = 409
    Height = 337
    Caption = 'TWinAmp.ini'
    TabOrder = 0
    object initext: TMemo
      Left = 2
      Top = 15
      Width = 405
      Height = 320
      Align = alClient
      BorderStyle = bsNone
      ScrollBars = ssVertical
      TabOrder = 0
      OnChange = initextChange
      OnKeyDown = initextKeyDown
    end
  end
  object GroupBox2: TGroupBox
    Left = 416
    Top = 0
    Width = 170
    Height = 49
    Caption = 'Winamp'
    TabOrder = 1
    object SwfB: TButton
      Left = 8
      Top = 16
      Width = 153
      Height = 25
      Hint = 'Choose Winamp placement'
      Caption = 'Set Winamp folder'
      ParentShowHint = False
      ShowHint = False
      TabOrder = 0
      OnClick = SwfBClick
    end
  end
  object GroupBox5: TGroupBox
    Left = 417
    Top = 128
    Width = 169
    Height = 49
    Caption = 'File types filter'
    TabOrder = 2
    object GftB: TButton
      Left = 8
      Top = 16
      Width = 153
      Height = 25
      Caption = 'Get file types from Winamp'
      TabOrder = 0
      OnClick = GftBClick
    end
  end
  object GroupBox6: TGroupBox
    Left = 417
    Top = 184
    Width = 169
    Height = 49
    Caption = 'Alt+Enter external editor'
    TabOrder = 3
    object SeeB: TButton
      Left = 8
      Top = 16
      Width = 153
      Height = 25
      Caption = 'Select external editor'
      TabOrder = 0
      OnClick = SeeBClick
    end
  end
  object SeB: TButton
    Left = 417
    Top = 312
    Width = 80
    Height = 25
    Caption = 'Save edited'
    Default = True
    Enabled = False
    TabOrder = 4
    OnClick = SeBClick
  end
  object DmeCB: TCheckBox
    Left = 417
    Top = 246
    Width = 169
    Height = 17
    Hint = 'Do not add existing tracks.'
    Caption = 'Disable multiply entries'
    ParentShowHint = False
    ShowHint = True
    TabOrder = 5
    OnClick = DmeCBClick
  end
  object darCB: TCheckBox
    Left = 1
    Top = 335
    Width = 169
    Height = 17
    Caption = 'Disable attributes reading'
    Enabled = False
    TabOrder = 6
    Visible = False
    OnClick = darCBClick
  end
  object CB: TButton
    Left = 505
    Top = 312
    Width = 80
    Height = 25
    Cancel = True
    Caption = 'Close'
    TabOrder = 7
    OnClick = CBClick
  end
  object rsiCB: TCheckBox
    Left = 417
    Top = 266
    Width = 169
    Height = 17
    Caption = 'Resize small preview images'
    TabOrder = 8
    OnClick = rsiCBClick
  end
  object GroupBox3: TGroupBox
    Left = 416
    Top = 56
    Width = 169
    Height = 65
    Caption = 'Winamp options&&playlist directory'
    TabOrder = 9
    object wm3u: TLabel
      Left = 8
      Top = 44
      Width = 152
      Height = 13
      AutoSize = False
      Caption = 'Winamp.m3u:'
      ParentShowHint = False
      ShowHint = True
    end
    object wopdCB: TComboBox
      Left = 8
      Top = 16
      Width = 153
      Height = 21
      Style = csDropDownList
      ItemHeight = 13
      ItemIndex = 0
      TabOrder = 0
      Text = 'Auto'
      OnChange = wopdCBChange
      Items.Strings = (
        'Auto'
        'Winamp directory'
        '%appdata%\winamp'
        'User specified')
    end
  end
  object atmCB: TCheckBox
    Left = 417
    Top = 286
    Width = 169
    Height = 17
    Caption = 'Autoswitch to thumbnails mode'
    TabOrder = 10
    OnClick = atmCBClick
  end
  object OpenDialog1: TOpenDialog
    DefaultExt = '*.exe'
    Filter = 'Executable files|*.exe'
    Left = 512
  end
  object XPManifest1: TXPManifest
    Left = 552
  end
end

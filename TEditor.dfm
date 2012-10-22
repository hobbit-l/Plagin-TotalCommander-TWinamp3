object ID3Editor: TID3Editor
  Left = 460
  Top = 336
  BorderIcons = [biSystemMenu]
  BorderStyle = bsToolWindow
  Caption = 'ID3 Editor'
  ClientHeight = 375
  ClientWidth = 530
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poOwnerFormCenter
  PixelsPerInch = 96
  TextHeight = 13
  object Fname: TEdit
    Left = 0
    Top = 0
    Width = 528
    Height = 21
    BevelOuter = bvSpace
    BiDiMode = bdRightToLeftReadingOnly
    Color = clInactiveBorder
    ParentBiDiMode = False
    ReadOnly = True
    TabOrder = 0
  end
  object ID31GB: TGroupBox
    Left = 0
    Top = 24
    Width = 257
    Height = 163
    Caption = 'ID3v1'
    TabOrder = 1
    object Title1: TLabel
      Left = 30
      Top = 38
      Width = 20
      Height = 13
      Caption = 'Title'
    end
    object Artist1: TLabel
      Left = 27
      Top = 64
      Width = 23
      Height = 13
      Caption = 'Artist'
    end
    object Album1: TLabel
      Left = 21
      Top = 88
      Width = 29
      Height = 13
      Caption = 'Album'
    end
    object Year1: TLabel
      Left = 28
      Top = 114
      Width = 22
      Height = 13
      Caption = 'Year'
    end
    object Comment1: TLabel
      Left = 5
      Top = 138
      Width = 44
      Height = 13
      Caption = 'Comment'
    end
    object Track1: TLabel
      Left = 160
      Top = 15
      Width = 38
      Height = 13
      Caption = 'Track #'
    end
    object Genre1: TLabel
      Left = 94
      Top = 114
      Width = 29
      Height = 13
      Caption = 'Genre'
    end
    object CID3v1: TCheckBox
      Left = 56
      Top = 14
      Width = 73
      Height = 17
      Caption = 'ID3v1 Tag'
      TabOrder = 0
      OnClick = CID3v1Click
    end
    object ETitle1: TEdit
      Left = 56
      Top = 34
      Width = 193
      Height = 21
      TabOrder = 2
    end
    object EArtist1: TEdit
      Left = 56
      Top = 59
      Width = 193
      Height = 21
      TabOrder = 3
    end
    object EAlbum1: TEdit
      Left = 56
      Top = 84
      Width = 193
      Height = 21
      TabOrder = 4
    end
    object EYear1: TEdit
      Left = 56
      Top = 109
      Width = 33
      Height = 21
      TabOrder = 5
    end
    object CBGenre1: TComboBox
      Left = 128
      Top = 109
      Width = 122
      Height = 21
      ItemHeight = 13
      TabOrder = 6
    end
    object EComment1: TEdit
      Left = 56
      Top = 134
      Width = 193
      Height = 21
      TabOrder = 7
    end
    object Enum1: TEdit
      Left = 208
      Top = 12
      Width = 41
      Height = 21
      TabOrder = 1
    end
  end
  object ID32GB: TGroupBox
    Left = 259
    Top = 24
    Width = 270
    Height = 325
    Caption = 'ID3v2'
    TabOrder = 2
    object Track2: TLabel
      Left = 181
      Top = 15
      Width = 38
      Height = 13
      Caption = 'Track #'
    end
    object Title2: TLabel
      Left = 46
      Top = 40
      Width = 20
      Height = 13
      Caption = 'Title'
    end
    object Artist2: TLabel
      Left = 43
      Top = 65
      Width = 23
      Height = 13
      Caption = 'Artist'
    end
    object Album2: TLabel
      Left = 37
      Top = 90
      Width = 29
      Height = 13
      Caption = 'Album'
    end
    object Year2: TLabel
      Left = 43
      Top = 114
      Width = 22
      Height = 13
      Caption = 'Year'
    end
    object Genre2: TLabel
      Left = 108
      Top = 114
      Width = 29
      Height = 13
      Caption = 'Genre'
    end
    object Comment2: TLabel
      Left = 22
      Top = 140
      Width = 44
      Height = 13
      Caption = 'Comment'
    end
    object Composer2: TLabel
      Left = 19
      Top = 203
      Width = 47
      Height = 13
      Caption = 'Composer'
    end
    object OArtist2: TLabel
      Left = 18
      Top = 232
      Width = 48
      Height = 13
      Caption = 'Orig. Artist'
    end
    object Copyright2: TLabel
      Left = 22
      Top = 256
      Width = 44
      Height = 13
      Caption = 'Copyright'
    end
    object Url2: TLabel
      Left = 44
      Top = 282
      Width = 22
      Height = 13
      Caption = 'URL'
    end
    object Encoded2: TLabel
      Left = 9
      Top = 306
      Width = 57
      Height = 13
      Caption = 'Encoded by'
    end
    object Enum2: TEdit
      Left = 224
      Top = 12
      Width = 41
      Height = 21
      TabOrder = 1
    end
    object CID3v2: TCheckBox
      Left = 72
      Top = 14
      Width = 73
      Height = 17
      Caption = 'ID3v1 Tag'
      TabOrder = 0
      OnClick = CID3v2Click
    end
    object ETitle2: TEdit
      Left = 72
      Top = 34
      Width = 193
      Height = 21
      TabOrder = 2
    end
    object EArtist2: TEdit
      Left = 72
      Top = 59
      Width = 193
      Height = 21
      TabOrder = 3
    end
    object EAlbum2: TEdit
      Left = 72
      Top = 84
      Width = 193
      Height = 21
      TabOrder = 4
    end
    object EYear2: TEdit
      Left = 72
      Top = 109
      Width = 33
      Height = 21
      TabOrder = 5
    end
    object CBGenre2: TComboBox
      Left = 144
      Top = 109
      Width = 122
      Height = 21
      ItemHeight = 13
      TabOrder = 6
    end
    object MComment2: TMemo
      Left = 72
      Top = 134
      Width = 193
      Height = 61
      TabOrder = 7
    end
    object EComposer2: TEdit
      Left = 72
      Top = 199
      Width = 193
      Height = 21
      TabOrder = 8
    end
    object EOArtist2: TEdit
      Left = 72
      Top = 224
      Width = 193
      Height = 21
      TabOrder = 9
    end
    object ECopyright2: TEdit
      Left = 72
      Top = 249
      Width = 193
      Height = 21
      TabOrder = 10
    end
    object EURL2: TEdit
      Left = 73
      Top = 274
      Width = 193
      Height = 21
      TabOrder = 11
    end
    object EEncoded2: TEdit
      Left = 73
      Top = 299
      Width = 193
      Height = 21
      TabOrder = 12
    end
  end
  object MpegInfoGB: TGroupBox
    Left = 0
    Top = 188
    Width = 257
    Height = 161
    Caption = 'MPEG Info'
    TabOrder = 3
    object info: TMemo
      Left = 8
      Top = 13
      Width = 244
      Height = 144
      BorderStyle = bsNone
      Color = clBtnFace
      ScrollBars = ssVertical
      TabOrder = 0
    end
  end
  object CopytoID3v2: TButton
    Left = 260
    Top = 352
    Width = 97
    Height = 21
    Caption = 'Copy to ID3v2 ->'
    TabOrder = 4
    OnClick = CopytoID3v2Click
  end
  object CopytoID3v1: TButton
    Left = 158
    Top = 352
    Width = 97
    Height = 21
    Caption = '<- Copy to ID3v1'
    TabOrder = 5
    OnClick = CopytoID3v1Click
  end
  object Cancel: TButton
    Left = 77
    Top = 352
    Width = 76
    Height = 21
    Cancel = True
    Caption = 'Cancel'
    TabOrder = 6
    OnClick = CancelClick
  end
  object Update: TButton
    Left = 0
    Top = 352
    Width = 73
    Height = 21
    Caption = 'Update'
    Default = True
    TabOrder = 7
    OnClick = UpdateClick
  end
  object XPManifest1: TXPManifest
    Left = 504
    Top = 352
  end
end

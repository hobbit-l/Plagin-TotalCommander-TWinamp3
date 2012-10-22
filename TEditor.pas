unit TEditor;

interface

uses
  Windows, SysUtils, Forms, MpegAudio,
 ID3v1,ID3v2, Classes, StdCtrls, Controls, ComCtrls, XPMan;

type
  TID3Editor = class(TForm)
    Fname: TEdit;
    ID31GB: TGroupBox;
    Title1: TLabel;
    Artist1: TLabel;
    Album1: TLabel;
    Year1: TLabel;
    Comment1: TLabel;
    Track1: TLabel;
    Genre1: TLabel;
    CID3v1: TCheckBox;
    ETitle1: TEdit;
    EArtist1: TEdit;
    EAlbum1: TEdit;
    EYear1: TEdit;
    CBGenre1: TComboBox;
    EComment1: TEdit;
    Enum1: TEdit;
    ID32GB: TGroupBox;
    Track2: TLabel;
    Title2: TLabel;
    Artist2: TLabel;
    Album2: TLabel;
    Year2: TLabel;
    Genre2: TLabel;
    Comment2: TLabel;
    Composer2: TLabel;
    OArtist2: TLabel;
    Copyright2: TLabel;
    Url2: TLabel;
    Encoded2: TLabel;
    Enum2: TEdit;
    CID3v2: TCheckBox;
    ETitle2: TEdit;
    EArtist2: TEdit;
    EAlbum2: TEdit;
    EYear2: TEdit;
    CBGenre2: TComboBox;
    MComment2: TMemo;
    EComposer2: TEdit;
    EOArtist2: TEdit;
    ECopyright2: TEdit;
    EURL2: TEdit;
    EEncoded2: TEdit;
    MpegInfoGB: TGroupBox;
    info: TMemo;
    CopytoID3v2: TButton;
    CopytoID3v1: TButton;
    Cancel: TButton;
    Update: TButton;
    XPManifest1: TXPManifest;
    procedure UpdateClick(Sender: TObject);
    procedure CID3v1Click(Sender: TObject);
    procedure CID3v2Click(Sender: TObject);
    procedure CancelClick(Sender: TObject);
    procedure CopytoID3v2Click(Sender: TObject);
    procedure CopytoID3v1Click(Sender: TObject);
    Procedure GetMpegInfo;
  private
    { Private declarations }
  public
    { Public declarations }
    Function LoadMP3File (FileName:ShortString):Boolean;
  end;

var
  Mpeg:TmpegAudio;
  ID3Editor: TID3Editor;
  TAG1:TID3v1;
  TAG2:TID3v2;
  NameTAG1:TID3v1;
  NameTAG2:TID3v2;
  filename:string;
  NameDividers:TStringList;
  TagItems:TStringList;

implementation

{$R *.dfm}


function TID3Editor.LoadMP3File(FileName: ShortString): Boolean;
var
i:integer;
begin
Result:=false;
TEditor.filename:=Filename;
if not fileexists (TEditor.filename) then MessageBox (GetForegroundWindow,pchar('Can''t find file ' +TEditor.filename),'',0);
if extractfileext (LowerCase(filename))<>'.mp3' then
 begin
 MessageBox (hInstance,pchar('Only mp3 files supported.'),'Error',mb_ok+mb_iconerror);
 exit;
 end;
TEditor.TAG1:=TID3v1.Create;
TEditor.TAG2:=TID3v2.Create;
if (not TEditor.tag1.ReadFromFile(filename)) or (not(TEditor.tag2.ReadFromFile(filename))) then
 begin
 MessageBox (hInstance,pchar('Cannot read tag from '+filename),'Error',mb_ok+mb_iconerror);
 exit;
 end else
 with ID3Editor do
 begin
 Cid3v1.Checked :=tag1.Exists;
 Cid3v2.Checked :=tag2.Exists;
 Cid3v1.OnClick(nil);
 Cid3v2.OnClick(nil);
 Enum1.text :=inttostr(tag1.Track);
 ETitle1.text :=tag1.Title;
 EArtist1.text := tag1.Artist;
 EAlbum1.text := tag1.Album;
 EYear1.text := tag1.Year;
 Ecomment1.text := tag1.Comment;
 Enum2.text := tag2.TrackString;
 MComment2.Text :=tag2.Comment;
 ETitle2.text := tag2.Title;
 EArtist2.text :=tag2.Artist;
 EAlbum2.text :=tag2.Album;
 EYear2.text :=tag2.Year;
 Ecomposer2.text := tag2.Composer;
 EOArtist2.text := tag2.Language;
 ECopyright2.text :=tag2.Copyright;
 EUrl2.text :=tag2.Link;
 EEncoded2.text :=tag2.Encoder;
 for i:=0 to MAX_MUSIC_GENRES-1 do CBGenre1.Items.Add (MusicGenre[i]);
 CBGenre1.Style:=csDropDownList;
 CbGenre1.ItemIndex :=tag1.GenreID;
 for i:=0 to MAX_MUSIC_GENRES-1 do CBGenre2.Items.Add (MusicGenre[i]);
 CbGenre2.text:=tag2.genre;
 end;
 Id3Editor.Caption :='ID3 Editor: '+filename;
 GetMpegInfo;
 NameDividers:=TStrinGlist.Create;
 Fname.Text:=FileName;
 result:=true;
end;

Procedure GenerateTagItems;
Begin
TagItems:=TStringList.Create;
TagItems.Add('%artist%');
TagItems.Add('%title%');
TagItems.Add('%track%');
TagItems.Add('%album%');
TagItems.Add('%year%');
TagItems.Add('%genre%');
TagItems.Add('%composer%');
TagItems.Add('%comment%');
TagItems.Add('%oartist%');
TagItems.Add('%copy%');
TagItems.Add('%url%');
TagItems.Add('%encoded%');
end;

procedure TID3Editor.UpdateClick(Sender: TObject);
begin
if enum1.Text <> '' then tag1.Track:= strtoint(Enum1.Text);
tag1.Title:=ETitle1.text;
tag1.Artist:=EArtist1.text;
tag1.Album:=EAlbum1.text;
tag1.Year:=EYear1.text;
tag1.Comment:= Ecomment1.text;
tag1.GenreId :=CBGenre1.ItemIndex;
try
//К сожалению, записывать в TrackString мы не можем, т.е. номер трека вроде 10/11 не пройдёт
tag2.Track:=StrToInt(Enum2.text);
except
on e: exception do
end;
tag2.Title:= ETitle2.text;
tag2.Artist:= EArtist2.text;
tag2.Album:= EAlbum2.text;
tag2.Year:= EYear2.text;
tag2.Composer:= Ecomposer2.text;
tag2.Language:= EOArtist2.text;
tag2.Copyright:= ECopyright2.text;
tag2.Link:= EUrl2.text;
tag2.Encoder:= EEncoded2.text;
tag2.Genre :=CBGenre2.Text;
tag2.Comment:= Mcomment2.text;
if cId3v1.Checked then tag1.SaveToFile(filename) else tag1.RemoveFromFile(filename);
if cId3v2.Checked then tag2.SaveToFile(filename) else tag2.RemoveFromFile(filename);
Close;
end;

procedure TID3Editor.CID3v1Click(Sender: TObject);
begin
 Enum1.Enabled :=CId3v1.Checked;
 ETitle1.Enabled:=CId3v1.Checked;
 Eartist1.Enabled :=CId3v1.Checked;
 EAlbum1.Enabled :=CId3v1.Checked;
 EYear1.Enabled :=CId3v1.Checked;
 CBGenre1.Enabled :=CId3v1.Checked;
 Ecomment1.Enabled :=CId3v1.Checked;
end;

procedure TID3Editor.CID3v2Click(Sender: TObject);
begin
 ETitle2.Enabled:=CId3v2.Checked;
 Eartist2.Enabled :=CId3v2.Checked;
 EAlbum2.Enabled :=CId3v2.Checked;
 EYear2.Enabled :=CId3v2.Checked;
 CBGenre2.Enabled :=CId3v2.Checked;
 Mcomment2.Enabled :=CId3v2.Checked;
 Ecomposer2.enabled:=CId3v2.Checked;
 EOArtist2.Enabled :=CId3v2.Checked;
 ECopyright2.Enabled :=CId3v2.Checked;
 EUrl2.Enabled :=CId3v2.Checked;
 Eencoded2.Enabled :=CId3v2.Checked;
end;

procedure TID3Editor.CancelClick(Sender: TObject);
begin
Close;
end;

procedure TID3Editor.CopytoID3v2Click(Sender: TObject);
begin
Enum2.Text :=Enum1.Text;//ПРОВЕРКА
ETitle2.text:=Etitle1.Text;
EArtist2.text:=Eartist1.text;
EAlbum2.text:=EAlbum1.text;
EYear2.text:=EYear1.Text;
CBGenre2.Text:=CBGenre1.Text;
Mcomment2.text:=EComment1.Text;
CID3v2.Checked:=true;
end;

procedure TID3Editor.CopytoID3v1Click(Sender: TObject);
begin
Enum1.Text :=enum2.Text;//ПРОВЕРКА
ETitle1.text:=Etitle2.Text;
EArtist1.text:=Eartist2.text;
EAlbum1.text:=EAlbum2.text;
EYear1.text:=EYear2.Text;
CBGenre1.Text:=CBGenre2.Text;
Ecomment1.text:=MComment2.Text;
CID3v1.Checked:=true;
end;

procedure TID3Editor.GetMpegInfo;
var
vbr:string;
begin
mpeg:=TMpegAudio.Create;
mpeg.ReadFromFile(filename);
info.Lines.Add('Size: '+inttostr(mpeg.FileLength)+ ' bytes');
info.Lines.Add('Length: '+inttostr (mpeg.filelength div (mpeg.bitrate*1000 div 8))+' seconds');
info.Lines.Add(mpeg.Version+' '+ mpeg.layer);
if mpeg.VBR.Found then vbr:=' (VBR)' else vbr:='';
info.Lines.Add('Bitrate: '+inttostr(mpeg.BitRate)+' kbps'+vbr);
info.Lines.Add(inttostr(mpeg.SampleRate)+'Hz '+ mpeg.ChannelMode);
info.Lines.Add('CRC: '+  booltostr(mpeg.frame.ProtectionBit,true));
info.Lines.Add('Copyrighted: '+  booltostr(mpeg.frame.CopyrightBit,true));
info.Lines.Add('Original: '+  booltostr(mpeg.frame.OriginalBit,true));
info.Lines.Add('Encoder: '+  mpeg.Encoder);
info.Lines.Add('Emphasis: '+  mpeg.Emphasis);
if mpeg.VBR.Found then
 begin
 info.Lines.Add('VBR information:');
 info.Lines.Add('  VBR ID: '+mpeg.VBR.ID);
 info.Lines.Add('  VBR number of frames: '+inttostr(mpeg.VBR.frames));
 info.Lines.Add('  VBR total bytes: '+inttostr(mpeg.VBR.bytes));
 info.Lines.Add('  VBR scale: '+inttostr( mpeg.VBR.Scale ));
 info.Lines.Add('  VBR vendor ID: '+mpeg.VBR.VendorID );
 end;
end;

end.


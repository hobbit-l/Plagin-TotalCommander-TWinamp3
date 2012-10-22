unit TWA_Main;
{Функции и процедуры для инициализации и корректной работы плагина}
interface
uses
 Windows,
 Messages,
 ShlObj,
 SysUtils,
 StrUtils,
 TWA_Types,
 TWA_TC,
 MpegAudio,
 Settings,
 ID3V1,
 ID3V2,
 IniFiles;

{------------------------------------------------------------------------------}

//procedure strlcpy (var to_:pchar;from_: pchar; length_:integer);//копирование строки по указателю с ограничением длины
//procedure strcpy (var a:array of char;b:string);//копирование строки в массив чаров
procedure GetFileInfo (FileName:ShortString;var FileInfo:tWIN32FINDDATA);//даёт параметры файла
Procedure ReadSettings (var Settings:TSettings);//Загружает настройки из файла.
Function GiveFolder (caption:string;Owner:hwnd=0):string;
Function FastFileCopy(Const InFileName, OutFileName: String;ProgressProc: TProgressProc):Integer;
Function ReplaceTag (constant: string;Tag1:TID3v1;tag2:TID3v2;filename:string):string;
function GetFormattedString (a:widestring;Tag1:TID3v1;tag2:TID3v2;filename:string):widestring;
Function GetSettingsWinampHomePath:String;
Function GetSettingsWinampHomePathNum:Integer;

Procedure ShowOptionsDialog;
{------------------------------------------------------------------------------}
implementation

 uses TWA_Functions;
{------------------------------------------------------------------------------}
{procedure strlcpy (var to_:pchar;from_: pchar; length_:integer);//копирование строки по указателю с ограничением длины
var
c:integer;
begin
for c:=0 to length_ do to_[c]:=from_[c];
end;      }
{------------------------------------------------------------------------------}
{procedure strcpy (var a:array of char;b:string);//копирование строки в массив чаров
var i:integer;
begin
for i:=0 to length (b)-1 do a[i]:=b[i+1];
a[i]:=chr(0);
end;}
{------------------------------------------------------------------------------}

{------------------------------------------------------------------------------}
procedure GetFileInfo (FileName:ShortString;var FileInfo:tWIN32FINDDATA);
 Function GetAbsolutePath (RelativePath:string):string;
 Begin
 if Relativepath[1]='\' then
  begin
  if RelativePath[2]='\' then Delete(Relativepath,1,1);
  Result:=ExtractFileDrive (PluginSettings.WinAmpM3U)+RelativePath;
  end else
  begin
  Result:=ExtractFilePath (PluginSettings.WinAmpM3U )+RelativePath;
  end;
 End;
var
p:PAnsiChar;
begin
//С этим надо разобраться. Я смутно помню, что были косяки, когда winamp записывал
//в плейлист не абсолютные а относительные пути. Я, по-моему, так и не выяснил,
//относительно ЧЕГО они относительны...
//FileName:=GetAbsolutePath(FileName);
p:=@FileName[1];
p[length (FileName)]:=#0;
Windows.FindClose (FindFirstFile (p,FileInfo));
//если это, например, ссылка на онлайн-радио
if not FileExists (FileName) then
 begin
 FileInfo.nFileSizeLow :=0;
 FileInfo.nFileSizeHigh :=0;
 FileInfo.dwFileAttributes:=0;
 FileInfo.ftCreationTime.dwLowDateTime :=0;
 FileInfo.ftCreationTime.dwHighDateTime :=0;
 FileInfo.ftLastAccessTime.dwLowDateTime :=0;
 FileInfo.ftLastAccessTime.dwHighDateTime :=0;
 FileInfo.ftLastWriteTime.dwLowDateTime :=0;
 FileInfo.ftLastWriteTime.dwHighDateTime :=0;
 end;
end;
{------------------------------------------------------------------------------}

Function GiveFolder (caption:string;Owner:hwnd=0):string;
var
  lpItemID : PItemIDList;
  BrowseInfo : TBrowseInfo;
  DisplayName : array[0..MAX_PATH] of char;
  TempPath : array[0..MAX_PATH] of char;
begin
  Result:='?';
  DisplayName:='TWinAmp3';
  FillChar(BrowseInfo, sizeof(TBrowseInfo), #0);
  if owner=0 then BrowseInfo.hwndOwner := FindTCWindow else BrowseInfo.hwndOwner :=Owner ;
  BrowseInfo.pszDisplayName := @DisplayName;
  BrowseInfo.lpszTitle := PChar(caption);
  BrowseInfo.ulFlags := BIF_RETURNONLYFSDIRS or BIF_RETURNFSANCESTORS or BIF_STATUSTEXT or BIF_EDITBOX;
  lpItemID := SHBrowseForFolder(BrowseInfo);
  if lpItemId <> nil then begin

    SHGetPathFromIDList(lpItemID, TempPath);
    Result:=TempPath;
    GlobalFreePtr(lpItemID);
  end;
end;
{------------------------------------------------------------------------------}

Function GetSettingsWinampHomePathNum:Integer;
var
f:TIniFile;
Begin
f:=TIniFile.Create(IncludeTrailingbackslash(ExtractFilePath(PluginPath))+'twinamp.ini');
if f.ReadString('Path','WinampHomePath','')='' then Result:=0 else
if lowercase(f.ReadString('Path','WinampHomePath',''))=lowercase(f.ReadString ('Path','WinampFolder','')) then result:=1 else
if lowercase(f.ReadString('Path','WinampHomePath',''))='%appdata%\winamp\' then result:=2 else result:=3;
f.Free;
End;
                                          
Function GetSettingsWinampHomePath:String;
var
f:TIniFile;
Begin
f:=TIniFile.Create(IncludeTrailingbackslash(ExtractFilePath(PluginPath))+'twinamp.ini');
if f.ReadString('Path','WinampHomePath','')='' then
 begin
 result :=AnsiReplaceStr(lowercase(f.ReadString ('Path','WinampFolder','')),'%commander_path%',tcdir);
 if not fileexists (result+'winamp.m3u') then result :=GetAppdataPath+'winamp\';
 end else
 begin
 result:=AnsiReplaceStr(lowercase(f.ReadString('Path','WinampHomePath','')),'%commander_path%',tcdir);
 end;
result:=AnsiReplaceStr(lowercase(result),'%appdata%\',GetAppdataPath);
f.Free;
end;

Procedure ReadSettings (var Settings:TSettings);
var
f:TIniFile;
Begin
f:=TIniFile.Create(IncludeTrailingbackslash(ExtractFilePath(PluginPath))+'twinamp.ini');
f.WriteString('Thumbnails','ThumbnailNames',f.ReadString('Thumbnails','ThumbnailNames','%filename%:album:cover:folder'));
Settings.WinAmpPath :=f.ReadString ('Path','WinampFolder','');
Settings.WinAmpPath:=AnsiReplaceStr(LowerCase(Settings.WinAmpPath),'%commander_path%',tcdir);
Settings.WinAmpExe :=Settings.WinAmpPath+'winamp.exe';
Settings.WinAmpM3U:=GetSettingsWinampHomePath+'winamp.m3u';
Settings.Editor :=f.ReadString ('Path','Editor','');
Settings.Editor:=AnsiReplaceStr(LowerCase(Settings.Editor),'%commander_path%',tcdir);
Settings.ExtFilter :=f.ReadString('Mode','ExtFilter','mp3');
Settings.Settings :=f.ReadString ('Path','Settings','');
Settings.Settings:=AnsiReplaceStr(LowerCase(Settings.Settings),'%commander_path%',tcdir);
Settings.BlockDead:=f.readBool ('Mode','BlockDead',true);
Settings.DisableMulti:=f.readBool ('Mode','DisableMulti',true);
Settings.DisplayFormat :=f.ReadString('Mode','DisplayFormat','%filename%');
Settings.DisableAttributes :=f.ReadBool('Bug','BugWithAttributes',false);
Settings.ResizeSmallImages :=f.ReadBool('Thumbnails','ResizeSmallImages',false);
Settings.ThumbnailNames :=f.ReadString('Thumbnails','ThumbnailNames','%filename%:album:cover:folder');
Settings.AutoSwitchThumbnails :=f.ReadBool('Thumbnails','Auto',false);

Settings.TempM3UFile:=ExtractFilePath (Settings.WinAmpM3U) +'temp.m3u';
Settings.Exist :=true;
if (Settings.WinAmpPath='') or (not FileExists (Settings.WinAmpExe)) or (not FileExists (Settings.WinAmpM3U)) then Settings.Exist :=false else Settings.Exist :=true;
f.Destroy;
End;
{------------------------------------------------------------------------------}
Function FastFileCopy(Const InFileName, OutFileName: String;ProgressProc: TProgressProc):Integer;
Const BufSize = 3*4*4096; { 48Kbytes дает прекрасный результат } 
Type 
 PBuffer = ^TBuffer;
 TBuffer = array [1..BufSize] of Byte;
var
 Size             : integer;
 Buffer           : PBuffer;
 infile, outfile  : File;
 SizeDone,SizeFile: Longint;
begin
if (InFileName <> OutFileName) then
 begin
 buffer := Nil;
 AssignFile(infile, InFileName);
 System.Reset(infile, 1);
 try
 SizeFile := FileSize(infile);
 AssignFile(outfile, OutFileName);
 System.Rewrite(outfile, 1);
  try
  SizeDone := 0; New(Buffer);
   repeat
   BlockRead(infile, Buffer^, BufSize, Size);
   Inc(SizeDone, Size);
   Result:=ProgressProc (PluginNum,pchar(InFileName),pchar(OutFilename),round(((SizeDone/SizeFile)*100)));
   if Result=1 then
    begin
    exit;
    end;
   try
   BlockWrite(outfile,Buffer^, Size);
   except
    on E: Exception do
    begin
    MessageBox(FindTCWindow, pchar('Error on file copying: '+ E.Message+#10+'Operation aborted!'),pchar(E.HelpContext),mb_ok+mb_iconerror);
    exit;
    end;
   end;
   until Size < BufSize;
  FileSetDate(TFileRec(outfile).Handle,
  FileGetDate(TFileRec(infile).Handle));
  finally
  if Buffer <> Nil then Dispose(Buffer);
  System.close(outfile)
  end;
 finally
 System.close(infile);
 end;
 end else
Raise EInOutError.Create('File cannot be copied into itself');
end;
{------------------------------------------------------------------------------}
Function ReplaceTag (constant: string;Tag1:TID3v1;tag2:TID3v2;filename:string):string;
Begin
constant:=lowercase (constant);
if constant='%filename%' then
 begin
 result:=ChangeFileExt(filename,'');
 exit;
 end;
if constant='%filename.ext%' then
 begin
 result:=Filename;
 exit;
 end;
if constant='%artist%' then
 begin
 if tag2.Exists then result:=tag2.Artist else result:=tag1.Artist;
 exit;
 end;
if constant='%album%' then
 begin
 if tag2.Exists then result:=tag2.Album  else result:=tag1.Album;
 exit;
 end;
if constant='%title%' then
 begin
 if tag2.Exists then result:=tag2.Title  else result:=tag1.Title;
 exit;
 end;
if constant='%tracknumber%' then
 begin
 if tag2.Exists then result:=inttostr(tag2.Track) else result:=inttostr(tag1.Track);
 exit;
 end;
if constant='%year%' then
 begin
 if tag2.Exists then result:=tag2.Year  else result:=tag1.Year;
 exit;
 end;
if constant='%genre%' then
 begin
 if tag2.Exists then result:=tag2.Genre  else result:=tag1.Genre;
 exit;
 end;
if constant='%comment%' then
 begin
 if tag2.Exists then result:=tag2.Comment  else result:=tag1.Comment;
 exit;
end;
end;
{------------------------------------------------------------------------------}
function GetFormattedString (a:widestring;Tag1:TID3v1;tag2:TID3v2;filename:string):widestring;
var
res,tmp,buf:string;
i:integer;
bufmode:boolean;//close/open
//inbuf:boolean;
begin
tmp:=a;
bufmode:=false;
//inbuf:=false;
buf:='';
res:='';
for i:=1 to length (tmp) do
 begin
 if tmp[i]='%' then bufmode:=not bufmode;
 if bufmode then buf:=buf+tmp[i] else
  begin
  if tmp[i]='%' then buf:=buf+'%' else  res:=res+tmp[i];
  end;
 if (tmp[i]='%') and not bufmode then
  begin
  res:=res+replacetag (buf,tag1,tag2,filename);
  buf:='';
  end;
end;
result:=res;
end;

//----------------------------------------------------------------------------//
Procedure ShowOptionsDialog;
Begin
TWAOptions:=TTWAOptions.Create(nil);
TWAOptions.ShowModal;
TWAOptions.Free;
Rereadpanels;
end;

end.

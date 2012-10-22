library TWinAmp;

{TWinamp3 by Pavel Dubrovsky
26.11.07
ICQ: 215168320}

uses
  SysUtils,
  Windows,
  Classes,
  Graphics,
  TWA_Types,
  TWA_Main,
  TWA_Functions,
  TWA_WinAmp,
  TWA_TC,
  StrUtils,
  MpegAudio,
  Messages,
  ID3V1,
  ID3V2,
  Settings in 'Settings.pas' {TWAOptions},
  TEditor in 'TEditor.pas' {ID3Editor};

var
  x:pchar;
  TempM3UHandle:TextFile;
  TracksCount:integer;
  CurrentTrack:integer;
  PlayListRecordsCounter:integer=0;
  PlayListFile:textFile;
  GlobalPath:shortstring;
  CurrentlyPlayedTrack:integer;
  TAG1:TID3v1;
  TAG2:TID3v2;



{$E wfx}

{$R ico.res}

procedure FsStatusInfo(RemoteDir:pchar;InfoStartEnd,InfoOperation:integer); stdcall;
begin
try
//DebugLog ('-> FsStatusInfo entering: RemoteDir='+StrPas(RemoteDir)+', InfoStartEnd='+IntToStr(InfoStartEnd)+', InfoOperation='+IntToStr(InfoOperation));
if (InfoStartEnd=FS_STATUS_START) then
 begin
 case InfoOperation of
 FS_STATUS_OP_LIST:
  begin
  SavePlayList;
  end;
 FS_STATUS_OP_GET_SINGLE:
  begin
  //SavePlayList;
  end;
 FS_STATUS_OP_GET_MULTI:
  begin
  //DebugLog ('Start to get files');
  //SavePlayList;
  CurrentlyPlayedTrack:=SavePlayList;
  ArrayOfDeletedItems:=TDynamicArrayI.Create;
  Assignfile (PlayListFile,PluginSettings.WinAmpM3U);
  //Rereadpanels;
  end;
 FS_STATUS_OP_PUT_SINGLE:
  begin
  end;
 FS_STATUS_OP_PUT_MULTI:
  begin
  {GOTTA ADDING FILES}
  //DebugLog ('Start to put files');
  Assignfile (TempM3UHandle,PluginSettings.TempM3UFile);
  Rewrite (TempM3UHandle);
  Append (TempM3UHandle);
  writeln (TempM3UHandle,'#EXTM3U');
  end;
 FS_STATUS_OP_RENMOV_SINGLE:
  begin
  end;
 FS_STATUS_OP_RENMOV_MULTI:
  begin
  end;
 FS_STATUS_OP_DELETE:
  begin
  {GOTTA DELETE FILES}
  //DebugLog ('Start to delete files');
  CurrentlyPlayedTrack:=SavePlayList;
  ArrayOfDeletedItems:=TDynamicArrayI.Create;
  Assignfile (PlayListFile,PluginSettings.WinAmpM3U);
  end;
 FS_STATUS_OP_ATTRIB:
  begin
  end;
 FS_STATUS_OP_MKDIR:
  begin
  end;
 FS_STATUS_OP_EXEC:
  begin
  end;
 FS_STATUS_OP_CALCSIZE:
  begin
  end;
 FS_STATUS_OP_SEARCH:
  begin
  end;
 FS_STATUS_OP_SEARCH_TEXT:
  begin
  end;
 end;
 exit;
 end;
if (InfoStartEnd=FS_STATUS_END) then
 begin
 case InfoOperation of
 FS_STATUS_OP_LIST:
  begin                                        
  end;
 FS_STATUS_OP_GET_SINGLE:
  begin
  end;
 FS_STATUS_OP_GET_MULTI:
  begin
  //DebugLog ('End to get files');
  if ArrayOfDeletedItems.Length >0 then
   begin
   DeleteFileNum (PlayListFile,false,ArrayOfDeletedItems);
   closeFile (PlayListFile);
   ClearPlayList;
   saveplaylist;
   AddFile (PluginSettings.TempM3UFile);
   SetPlayedTrack (CurrentlyPlayedTrack);
   saveplaylist;
   DeleteFile (@PluginSettings.TempM3UFile[1]);
   ReReadPanels;
   ArrayOfDeletedItems.Destroy;
   end;
  end;
 FS_STATUS_OP_PUT_SINGLE:
  begin
  end;
 FS_STATUS_OP_PUT_MULTI:
  begin
  //DebugLog ('End to put files');
  CloseFile (TempM3UHandle);
  if PluginSettings.DisableMulti then closeFile (PlayListFile);
  AddFile (PluginSettings.TempM3UFile);
  SavePlayList;
  deleteFile (@PluginSettings.TempM3UFile[1]);
  ReReadPanels;
  end;
 FS_STATUS_OP_RENMOV_SINGLE:
  begin
  end;
 FS_STATUS_OP_RENMOV_MULTI:
  begin
  end;
 FS_STATUS_OP_DELETE:
  begin
  //DebugLog ('End to delete files');
  DeleteFileNum (PlayListFile,false,ArrayOfDeletedItems);
  closeFile (PlayListFile);
  ClearPlayList;
  saveplaylist;
  AddFile (PluginSettings.TempM3UFile);
  SetPlayedTrack (CurrentlyPlayedTrack);
  saveplaylist;
  DeleteFile (@PluginSettings.TempM3UFile[1]);
  ReReadPanels;
  ArrayOfDeletedItems.Destroy;
  end;
 FS_STATUS_OP_ATTRIB:
  begin
  end;
 FS_STATUS_OP_MKDIR:
  begin
  end;
 FS_STATUS_OP_EXEC:
  begin
  end;
 FS_STATUS_OP_CALCSIZE:
  begin
  end;
 FS_STATUS_OP_SEARCH:
  begin
  end;
 FS_STATUS_OP_SEARCH_TEXT:
  begin
  end;
 end;
 end;
except
//DebugLog ('Exception in FsStatusInfo, see entering parameters');
end; 
end;


function FsInit(PluginNr:integer;pProgressProc:tProgressProc;pLogProc:tLogProc;pRequestProc:tRequestProc):integer; stdcall;
Begin
PluginNum:=PluginNr;
MyProgressProc:=pProgressProc;
ReadSettings (PluginSettings);
Result:=0;
end;

function FsFindFirst(path :pchar;var FindData:tWIN32FINDDATA):thandle; stdcall;
var
Mp3path:ShortString;
TrackLength:integer;
begin
SaveplayList;
GlobalPath:=path;
Result:=INVALID_HANDLE_VALUE;
SetLastError(ERROR_NO_MORE_FILES);
//проверяем существование настроек и путей
//checking for parameters and path existance
if not PluginSettings.Exist then
 begin
 //DebugLog ('PluginSettings.Exist=false;');
 //Не найден winamp.exe по пути, указанному в настройках, либо сами настройки
 //либо m3u-файл винампа.
 //предыдущие версии реагировали на это запуском диалога настроек
 //нынче же будем показывать аварийный файл "Хули, гули?", щелчок по которому и запустит настройку.

 //Settings file not found, or winamp.exe not found, or default m3u-file not found.
 //We should reurn some virtual file with error description  
 StrPCopy (FindData.cFileName,'Winamp not found.!!!');
 FindData.nFileSizeLow :=0;
 FindData.nFileSizeHigh :=0;
 FindData.dwFileAttributes:=0;
 FindData.ftCreationTime.dwLowDateTime :=0;
 FindData.ftCreationTime.dwHighDateTime :=0;
 FindData.ftLastAccessTime.dwLowDateTime :=0;
 FindData.ftLastAccessTime.dwHighDateTime :=0;
 FindData.ftLastWriteTime.dwLowDateTime :=0;
 FindData.ftLastWriteTime.dwHighDateTime :=0;
 result:=1;
 exit;
 end;
//если в опциях высталвено автопереключение в режим превьюшек - делаем это
if PluginSettings.AutoSwitchThumbnails then SwitchToThumbnailsMode;

//читаем 1 запись из плейлиста
//read first entry in playlist
if path='\' then
 begin
 result:=0;
 AssignFile (PlayListFile,PluginSettings.WinAmpM3U);
 Reset (PlayListFile);
 Readln (PlayListFile);
 mp3path:=ReadPlaylistEntry (PlayListFile,false,TrackLength);
 TracksCount:=GetWinampTracksCount;
 //DebugLog ('tracks in playlist: '+IntToStr(TracksCount));
 CurrentTrack:=1;
 if mp3path ='' then
  begin
  //Debuglog ('Empty playlist');
  CloseFile (PlayListFile);
  Result:=INVALID_HANDLE_VALUE;
  SetLastError(ERROR_NO_MORE_FILES);
  Exit;
  end;
  GetFileInfo (mp3path,FindData);
  StrPCopy (FindData.cFileName,'1. '+ExtractFileName(mp3Path));
  CurrentTrack:=1;
  //DebugLog ('--------------FindData--------------');
  //DebugLog ('dwFileAttributes: ' + IntToStr(FindData.dwFileAttributes)+#10+#13+ 'ftCreationTime: ' + TimeToStr(FileTime2DateTime(FindData.ftCreationTime))+#10+#13+'ftLastAccessTime: ' + TimeToStr(FileTime2DateTime(FindData.ftLastAccessTime))+#10+#13+'ftLastWriteTime: ' + TimeToStr(FileTime2DateTime(FindData.ftLastWriteTime))+#10+#13+'FileSize: ' + FloatToStr(FindData.nFileSizeHigh*4294967296+Finddata.nFileSizeLow)+#10+#13+'cFileName: ' + FindData.cFileName);
  //DebugLog ('------------End FindData------------');
 if PluginSettings.DisableAttributes then
  begin
  FindData.dwFileAttributes :=FILE_ATTRIBUTE_NORMAL;
  //DebugLog ('Attributes disabled, setting to FILE_ATTRIBUTE_NORMAL');
  end;
 exit;
 end;
end;

function FsFindNext(Hdl:thandle;var FindData:tWIN32FINDDATA):bool; stdcall;
var
Mp3path:String;
TrackLength:Integer;
begin
//DebugLog ('-> FsFindNext entering, Attributes disabled='+BoolToStr(PluginSettings.DisableAttributes,true));
result:=false;
if Hdl=1 then
 //ошибка получения настроек в FsFindFirst
 //Some kind of error in FsFindFirst
 begin
 result:=false;
 exit;
 end;
try

if GlobalPath='\' then
 begin
 if EOF (PlayListFile) then
  begin
  result:=false;
  exit;
  end else
  begin
  result:=true;
  mp3path:=ReadPlaylistEntry (PlayListFile,false,TrackLength);
  inc(CurrentTrack);
  GetFileInfo (mp3path,FindData);
  StrPCopy (FindData.cFileName,IntToStr(CurrentTrack)+'. '+ExtractFileName(mp3Path));
  if PluginSettings.DisableAttributes then FindData.dwFileAttributes :=FILE_ATTRIBUTE_NORMAL;
  end;
 //DebugLog ('Filename returned: '+FindData.cFileName);
 end;
except
//DebugLog ('Exeption in FsFindNext, see lines above');
end;


end;

function FsFindClose(Hdl:thandle):integer; stdcall;
Begin
//DebugLog ('-> FsFindClose entering');
Result:=0;
if Hdl=1 then
 begin
 //ошибка получения настроек в FsFindFirst
 //Some kind of error in FsFindFirst 
 exit;
 end;
try
if GlobalPath='\' then CloseFile (PlayListFile);
except
//DebugLog ('Exception in FsFindClose');
end;
End;

procedure FsGetDefRootName(DefRootName:pchar;maxlen:integer); stdcall;
Begin
strpcopy (DefRootName,'TWinAmp');
end;

function FsExecuteFile(MainWin:thandle;RemoteName,Verb:pchar):integer; stdcall;
var
t:integer;
s:string;
si:_StartupInfoA;
p: PROCESS_INFORMATION;
temp:string;
{tmp}
Begin
result:=FS_EXEC_OK;
try
//При ошибке получения настроек надо запустить настройщик
//If user runs virtual file, then we should show options dialog;
if RemoteName='\Winamp not found.!!!' then ShowOptionsDialog;
//DebugLog ('-> FsExecuteFile entering: RemoteName='+Strpas(Remotename)+', Verb='+StrPas(verb));
result:=FS_EXEC_OK;
//проверяем существование настроек и путей
//check for parameters and path existance
if remotename='\' then
 begin
 if verb='properties' then
  begin
  ShowOptionsDialog;
  exit;
  end;
 end;
if not PluginSettings.Exist then
 begin
  //DebugLog ('PluginSetting.Exist=false, exitting');
  Result:=FS_EXEC_ERROR;
  exit;
 end;
if AnsiReplaceStr (lowercase(verb),'quote ','')='save' then
 begin
 saveplaylist;
 s:=includetrailingbackslash(GiveFolder ('Save playlist'))+'TWinAmp.m3u';
 //DebugLog ('Playlist export to: '+s);
 CopyFile (PAnsiChar(AnsiString(PluginSettings.WinAmpM3U)),PAnsiChar(s),false);
 end;
If GlobalPath='\' then
 begin
  if verb='open' then
   begin
   SavePlayList;
   try
   s:=copy(Remotename,2,pos('. ',Remotename)-2);
   t:=StrToInt(s)-1;
   //DebugLog ('Verb=open, FileNumber='+IntToStr(t));
   except exit end;
   //DebugLog ('Error in getting file number procedure!');
   winampmessage (WM_USER,t,121);
   winampmessage (WM_COMMAND,40047,0);
   winampmessage (WM_COMMAND,40045,0);
   end;
  if (verb='properties') then
   begin
   s:=copy(Remotename,2,pos('. ',Remotename)-2);
   t:=StrToInt(s)-1;
   AssignFile (PlayListFile,PluginSettings.WinAmpM3U);
   S:=GetFileByNumber(PlayListFile,false,t,temp);
   CloseFile (PlayListFile);
   //DebugLog ('Verb=properties, AbsolutePath='+s);
   FillChar( Si, SizeOf( Si ) , 0 );
   //DebugLog ('ID3 editor executing ('+PluginSettings.Editor+')');
   if PluginSettings.Editor <>'' then
    begin
    Createprocess(@PluginSettings.Editor[1],pchar(' "'+s+'"'),nil,nil,false,Create_default_error_mode,nil,nil,si,p);
    end else
    begin
    ID3Editor:=TId3Editor.Create(nil);
    ID3Editor.Icon.Handle:=LoadIcon(hInstance,'main');
    ID3Editor.LoadMP3File (s);
    ID3Editor.ShowModal;
    ID3Editor.Free;
    end;
   end;
 end; {GlobalPath='\'}
except
//DebugLog ('Exception in FsExecuteFile');
end;
end;

function FsGetFile(RemoteName,LocalName:pchar;CopyFlags:integer;RemoteInfo:pRemoteInfo):integer; stdcall;
var
s:String;
t:integer;
temp:string;
begin
result:=FS_FILE_OK;
try
//DebugLog ('-> FsGetFile entering: RemoteName='+StrPas (Remotename)+', LocalName='+StrPas(LocalName)+', CopyFlags='+IntToStr(CopyFlags));
{Проблема в том, что TC подставляет в диалог копирования имя как путь_приёмника+имя_файла_в_панели.
Так как имя файла в панели записано как x:/путь/имя_файла.ext то, соответственно,
результат получается кривой. Это можно обойти двумя способами:
1) Запускать в отдельном потоке процедуру, которая найдёт окно диалога и внесёт
туда изменения. Это сложно, так как нельзя определить приёмник (файл может
копироваться не в противоположную панель, которую ещё можно найти, а в какую-то
из вкладок. Или вообще копироваться мышкой без подтверждающих диалогов.
2) Изменить способ идентификации файла. То есть определять его не по пути, а по
номеру (выводить в панель имя в виде "№№. имя_файла.ext", где №№ - номер файла в
плейлисте (позволит по номеру получить путь файла). Это не совсем правильно, т.к.
при копировании не будет сохраняться оригинальное имя файла, но вполне терпимо...
Второй способ я и применяю. Пока Гислер не добавит в WFX API способ решения этой проблемы
я намерен решать её именно так.
}

{
We have a big problem with filenames in FS plugins. If filename stored as
x:\path\file.txt, then on file copying to c:\folder result filename was like
c:\folder\x:\path\file.txt.
So i store filename as "№№. filename.ext" where №№ - file number in m3u playlist.
If we know that number, then we can find real file path.
}
case CopyFlags of
 0: {JUST COPYING}       Begin
                         if FileExists (LocalName) then
                          begin
                          result:=FS_FILE_EXISTS;
                          //DebugLog ('CopyFlags=0. File '+localname+' already exist');
                          end else
                          Begin
                          s:=copy(Remotename,2,pos('. ',Remotename)-2);
                          t:=StrToInt(s)-1;
                          AssignFile (PlayListFile,PluginSettings.WinAmpM3U);
                          S:=GetFileByNumber(PlayListFile,false,t,temp);
                          CloseFile (PlayListFile);
                          Result:=FS_FILE_OK;
                          //DebugLog ('CopyFlags=0. Copying function calling. Copy '+s+' to '+localname);
                          if FastFileCopy (s,localname,MyProgressProc)=1 then {cancel pressed}
                           begin
                           //DebugLog ('Copying aborted');
                           Result:=FS_FILE_USERABORT;
                           end;
                          end;
                         End;
 FS_COPYFLAGS_MOVE:      Begin
                         if FileExists (LocalName) then
                          begin
                          //DebugLog ('CopyFlags=FS_COPYFLAGS_MOVE. File '+localname+' already exist');
                          result:=FS_FILE_EXISTS;
                          s:=copy(Remotename,2,pos('. ',Remotename)-2);
                          t:=StrToInt(s)-1;
                          end else
                          Begin
                          s:=copy(Remotename,2,pos('. ',Remotename)-2);
                          t:=StrToInt(s)-1;
                          AssignFile (PlayListFile,PluginSettings.WinAmpM3U);
                          S:=GetFileByNumber(PlayListFile,false,t,temp);
                          CloseFile (PlayListFile);
                          Result:=FS_FILE_OK;
                          //DebugLog ('CopyFlags=FS_COPYFLAGS_MOVE. Copying function calling. Copy '+s+' to '+localname);
                          if FastFileCopy (s,localname,MyProgressProc)=1 then {cancel pressed}
                           begin
                           //DebugLog ('Moving aborted');
                           Result:=FS_FILE_USERABORT;
                           end;
                          end;                          {Сделать удаление из плейлиста после копирования. Или не сделать?}
                         if t<>-1 then ArrayOfDeletedItems.Add(t);
                         End;
 FS_COPYFLAGS_RESUME:    Begin
                         {NEVER CALLED HERE}
                         Result:=FS_FILE_NOTSUPPORTED;
                         End;
 FS_COPYFLAGS_OVERWRITE: Begin
                         //DebugLog ('CopyFlags=FS_COPYFLAGS_OVERWRITE');
                         s:=copy(Remotename,2,pos('. ',Remotename)-2);
                         t:=StrToInt(s)-1;
                         AssignFile (PlayListFile,PluginSettings.WinAmpM3U);
                         S:=GetFileByNumber(PlayListFile,false,t,temp);
                         CloseFile (PlayListFile);
                         Result:=FS_FILE_OK;
                         //DebugLog ('CopyFlags=FS_COPYFLAGS_OVERWRITE. Copying function calling. Copy '+s+' to '+localname);
                         if FastFileCopy (s,localname,MyProgressProc)=1 then {cancel pressed}
                          begin
                          //DebugLog ('Copying/Moving aborted');
                          Result:=FS_FILE_USERABORT;
                          end;
                         End;
end;
{s:=copy(Remotename,2,pos('. ',Remotename)-2);
t:=StrToInt(s);
dec(t);
S:=GetFileByNumber(PlayListFile,false,t);
FastFileCopy (s,localname,MyProgressProc);
Result:=FS_FILE_OK;   }
except
//DebugLog ('Exeption in FsGetFile, see lines above');
end;    
end;

function FsPutFile(LocalName,RemoteName:pchar;CopyFlags:integer):integer; stdcall;
 function allowed (fileext:shortstring):boolean;
 var
 ext:shortstring;
 t:Widestring;
 begin
 result:=false;
 t:=PluginSettings.ExtFilter+':';
 delete(fileext,1,1);
 while true do
  begin
  ext:=lowercase(copy (t,1,pos (':',t)-1));
  if ext=lowercase(fileext) then
   begin
   result:=true;
   break;
   end;
  delete (t,1,pos(':',t));
  if t='' then exit;
  end;
 end;
Begin
result:=FS_FILE_OK;
try
//DebugLog ('-> FsPutFile entering: LocalName='+StrPas(Localname)+', RemoteName='+StrPas(RemoteName));
//if filetype allowed in filter
result:=FS_FILE_OK;//always
//AssignFile (PlayListFile,PluginSettings.WinAmpM3U);
if PluginSettings.DisableMulti and (GetFileNumber (PlayListFile,LocalName)<>-1) then exit;
if Allowed (ExtractFileExt (localname)) then
 begin
 AddToM3UPlayList (TempM3UHandle,localname);
 end;
except
//DebugLog ('Exception in FsPutFile, see lines above');
end;
end;

function FsDeleteFile(RemoteName:pchar):bool; stdcall;
var
DELFNAME:ShortString;
DELFNUM:Integer;
Begin
result:=true;
try
//DebugLog ('-> FsPutFile entering: RemoteName='+StrPas(RemoteName));
DELFNAME:=copy(Remotename,2,pos('. ',Remotename)-2);
DELFNUM:=StrToInt(DELFNAME)-1;
if DELFNUM<>-1 then ArrayOfDeletedItems.Add(DELFNUM);
except
//DebugLog ('Exception in FsDeleteFile, see lines above');
end;
End;

function FsExtractCustomIcon(RemoteName:pchar;ExtractFlags:integer;var TheIcon:hicon):integer; stdcall;
Begin
result:=FS_ICON_USEDEFAULT;
if RemoteName='\Winamp not found.!!!' then
 begin
 result:=FS_ICON_EXTRACTED;
 TheIcon:=LoadIcon (hInstance,'options');
 end;
End;

function FsContentGetSupportedField(FieldIndex:integer;FieldName:pchar;
  Units:pchar;maxlen:integer):integer; stdcall;
begin
result:=ft_string;
StrPCopy (Units,'Normal|Backround|On demand');
case FieldIndex of
 0: begin
    StrPCopy (FieldName,'Filename');
    units[0]:=#0;
    end;
 1: begin
    StrPCopy (FieldName,'File path');
    units[0]:=#0;
    end;
 2: begin
    StrPCopy (FieldName,'Artist');
    end;
 3: begin
    StrPCopy (FieldName,'Album');
    end;
 4: begin
    StrPCopy (FieldName,'Title');
    end;
 5: begin
    StrPCopy (FieldName,'Tracknumber');
    result:=ft_numeric_32;
    end;
 6: begin
    StrPCopy (FieldName,'Year');
    end;
 7: begin
    StrPCopy (FieldName,'Genre');
    end;
 8: begin
    StrPCopy (FieldName,'Comment');
    end;
 9: begin
    StrPCopy (FieldName,'Composer');
    end;
10: begin
    StrPCopy (FieldName,'Copyright');
    end;
11: begin
    StrPCopy (FieldName,'URL');
    end;
12: begin
    StrPCopy (FieldName,'Encoder');
    end;
13: begin
    StrPCopy (FieldName,'Length');
    result:=ft_time;
    units[0]:=#0;//у них свои, стандартные units
    end;
14: begin
    StrPCopy (FieldName,'Extinf');
    units[0]:=#0;
    end;
15: begin
    StrPCopy (FieldName,'Extinf_length');
    result:=ft_time;
    units[0]:=#0;
    end;
16: begin
    StrPCopy (FieldName,'Extinf_text');
    units[0]:=#0;
    end;
 else result:=ft_nomorefields;
 end;    
end;

function FsContentGetValue(FileName:pchar;FieldIndex,UnitIndex:integer;FieldValue:pbyte;
  maxlen,flags:integer):integer; stdcall;
var
mp3path:shortstring;
t:integer;
//Требуется использовать отдельные переменые для обеспечения потокобезопасности
//Local wariables for thread safety
ThPlayListFile:TextFile;
ThMp3:TMpegAudio;
ThTAG1:TID3v1;
ThTAG2:TID3v2;
EXTINF:String;
begin

if FileName='\Winamp not found.!!!' then
 begin
 result:=ft_fieldempty;
 exit;
 end;

mp3path:=copy(FileName,2,pos('. ',FileName)-2);
t:=StrToInt(mp3path)-1;
AssignFile (ThPlayListFile,PluginSettings.WinAmpM3U);
mp3path:=GetFileByNumber(ThPlayListFile,false,t,Extinf);
//Extinf:=GetExtinfByNumber (ThPlayListFile,false,t);
CloseFile (ThPlayListFile);

If Not FileExists (mp3Path) then
 begin
 result:=ft_fieldempty;
 exit;
 end;

result:=ft_string;
Case UnitIndex of
 0: begin
    //Нормальный режим
    //Normal mode
    ThMp3:=TMpegAudio.Create;
    ThTAG1:=TID3v1.Create;
    ThTAG2:=TID3v2.Create;
    Thmp3.ReadFromFile(mp3path);
    Thtag1.ReadFromFile(mp3path);
    Thtag2.ReadFromFile(mp3path);
    end;
 1: begin
    //В отдельном потоке
    //Separate thread
    if flags<>CONTENT_DELAYIFSLOW then
     begin
     //TC запрашивает инфу в отдельном потоке
     //TC request info in separate thread
     ThMp3:=TMpegAudio.Create;
     ThTAG1:=TID3v1.Create;
     ThTAG2:=TID3v2.Create;
     ThMp3.ReadFromFile(mp3path);
     ThTag1.ReadFromFile(mp3path);
     ThTag2.ReadFromFile(mp3path);
     end else
     begin
     result:=ft_delayed;
     exit;
     end;
    end;
 2: begin
    //По нажатию пробела
    //On space pressed
    if flags<>CONTENT_DELAYIFSLOW then
     begin
     //TC запрашивает инфу в отдельном потоке (по пробелу)
     //TC request info in separate thread
     ThMp3:=TMpegAudio.Create;
     TAG1:=TID3v1.Create;
     TAG2:=TID3v2.Create;
     ThMp3.ReadFromFile(mp3path);
     ThTag1.ReadFromFile(mp3path);
     ThTag2.ReadFromFile(mp3path);   
     end else
     begin
     result:=ft_ondemand;
     exit;
     end;
    end;
  end;

case FieldIndex of
 0: begin
    StrPCopy (pchar(FieldValue),ExtractFileName(Mp3Path));
    end;
 1: begin
    StrPCopy (pchar(FieldValue),Mp3Path);
    end;
 2: begin
    if ThTag2.Exists then strlcopy (pchar(FieldValue),pchar(ThTag2.Artist),length(ThTag2.Artist)) else strlcopy (pchar(FieldValue),@ThTag1.Artist[1],length(ThTag1.Artist));
    end;
 3: begin
    if ThTag2.Exists then strlcopy (pchar(FieldValue),pchar(ThTag2.Album),length(ThTag2.Album)) else strlcopy (pchar(FieldValue),@ThTag1.Album[1],length(ThTag1.Album));
    end;
 4: begin
    if ThTag2.Exists then strlcopy (pchar(FieldValue),pchar(ThTag2.title),length(ThTag2.title)) else strlcopy (pchar(FieldValue),@ThTag1.title[1],length(ThTag1.title));
    end;
 5: begin
    result:=ft_numeric_32;
    if ThTag2.Exists then t:=ThTag2.Track else t:=ThTag1.Track;
    //вот так будет кошерненько
    //It would be nice =)
    asm
     mov eax, [fieldvalue]
     mov edx, [t]
     mov dword ptr [eax],edx
    end;
    end;
 6: begin
    if ThTag2.Exists then strlcopy (pchar(FieldValue),pchar(ThTag2.Year),length(ThTag2.Year)) else strlcopy (pchar(FieldValue),@ThTag1.Year[1],length(ThTag1.Year));
    end;
 7: begin
    if ThTag2.Exists then strlcopy (pchar(FieldValue),pchar(ThTag2.Genre),length(ThTag2.Genre)) else strlcopy (pchar(FieldValue),pchar(ThTag1.Genre),length(ThTag1.Genre));
    end;
 8: begin
    if ThTag2.Exists then strlcopy (pchar(FieldValue),pchar(ThTag2.Comment),length(ThTag2.Comment)) else strlcopy (pchar(FieldValue),@ThTag1.Comment[1],length(ThTag1.Comment));
    end;
 9: begin
    strlcopy (pchar(FieldValue),pchar(ThTag2.Composer),length(ThTag2.Composer));
    end;
10: begin
    strlcopy (pchar(FieldValue),pchar(ThTag2.Copyright),length(ThTag2.Copyright));
    end;
11: begin
    strlcopy (pchar(FieldValue),pchar(ThTag2.Link),length(ThTag2.Link));
    end;
12: begin
    strlcopy (pchar(FieldValue),pchar(ThTag2.Encoder),length(ThTag2.Encoder));
    end;
13: begin
    result:=ft_time;
    t:=round(ThMp3.Duration);
    SecondsToTimeFormat(t,FieldValue);
    end;
14: begin
    if extinf='' then
     begin
     result:=ft_fieldempty;
     exit;
     end;
    strlcopy (pchar(FieldValue),pchar(Extinf),MaxLen);
    end;
15: begin
    if extinf='' then
     begin
     result:=ft_fieldempty;
     exit;
     end;
     result:=ft_time;
     t:=StrToInt(Copy(extinf,1,pos(',',extinf)-1));
     SecondsToTimeFormat(t,FieldValue);
    end;
16: begin
    if extinf='' then
     begin
     result:=ft_fieldempty;
     exit;
     end;
    strlcopy (pchar(FieldValue),pchar(copy(Extinf,pos(',',extinf)+1,length(extinf)-pos(',',extinf))),MaxLen);
    end;    
 end;
ThMp3.Free;
ThTag1.Free;
ThTag2.Free;
end;

function FsContentGetDefaultView(ViewContents,ViewHeaders,ViewWidths,
  ViewOptions:pchar;maxlen:integer):bool; stdcall;
begin
StrPCopy (ViewContents,'[=<fs>.Artist.Backround] - [=<fs>.Title.Backround]');
StrPCopy (ViewHeaders,'MP3 Info');
StrPCopy (ViewWidths,'80,30,230');
StrPCopy (ViewOptions,'-1|1');
result:=true;
end;

//Из-за какого-то неопределённого бага эта функция не вызывается :(
//см. http://forum.wincmd.ru/viewtopic.php?p=38553
//или http://www.ghisler.ch/board/viewtopic.php?p=138133
function FsGetPreviewBitmap(RemoteName:pchar;width,height:integer;var ReturnedBitmap:HBitmap):integer; stdcall;
var
b:TBitmap;
ThPlayListFile:TextFile;
Mp3path:String;
BmpPath:String;
dx,dy:single;
temp:string;

_Mp3:TMpegAudio;
_TAG1:TID3v1;
_TAG2:TID3v2;

 Function GetNumOfEntryes (InString:String):Integer;
 var
 a:Integer;
 begin
 result:=0;
 if InString='' then exit;
 if InString[Length(InString)]<>':' then InString:=InString+':';
 for a:=0 to Length(InString)-1 do if InString[a]=':' then inc (result);
 end;

 function GetEntry (FromString:string;Num:Integer):String;
 var
 a:integer;
 begin
 result:='';
 if FromString='' then exit;
 if FromString[Length(fromString)]<>':' then FromString:=FromString+':';
 for a:=0 to Num-1 do
  delete (FromString,1,pos(':',FromString));
 Result:=Copy (FromString,1,pos(':',FromString)-1);
 end;

 Function GetBmpPath (Mp3Path:String; var BmpPath:String):integer;
 var
 x:String;
 a:integer;
 begin
 result:=0; //Ничего не найдено.
 X:=ExtractFilePath(mp3path);
 for a:=0 to GetNumOfEntryes (PluginSettings.ThumbnailNames) do
  begin
  x:=GetEntry (PluginSettings.ThumbnailNames,a);
  _Mp3:=TMpegAudio.Create;
  _TAG1:=TID3v1.Create;
  _TAG2:=TID3v2.Create;
  _mp3.ReadFromFile(mp3path);
  _tag1.ReadFromFile(mp3path);
  _tag2.ReadFromFile(mp3path);
  x:=GetFormattedString (x,_tag1,_tag2,extractfilename(Mp3Path));
  _TAG1.Free;
  _TAG2.Free;
  _MP3.Free;
  //у нас образовано имя картинки в X. Нужно проверить x.bmp/jpg/jpeg
  if Fileexists(ExtractFilePath(mp3path)+x+'.jpg') then
   begin
   result:=2;//jpg
   BmpPath:=ExtractFilePath(mp3path)+x+'.jpg';
   end else
  if Fileexists(ExtractFilePath(mp3path)+x+'.jpeg') then
   begin
   result:=2;//jpg
   BmpPath:=ExtractFilePath(mp3path)+x+'.jpeg';
   end else
  if Fileexists(ExtractFilePath(mp3path)+x+'.bmp') then
   begin
   result:=1;//bitmap
   BmpPath:=ExtractFilePath(mp3path)+x+'.bmp';
   end;
  end;
 end;

begin
result:=FS_BITMAP_NONE;
if RemoteName='\Winamp not found.!!!' then
 begin
 exit;
 end;

try
AssignFile (ThPlayListFile,PluginSettings.WinAmpM3U);
mp3path:=GetFileByNumber(ThPlayListFile,false,StrToInt(copy(RemoteName,2,pos('. ',RemoteName)-2))-1,temp);
CloseFile (ThPlayListFile);
except
exit;
end;

case GetBmpPath (mp3path,bmppath) of
 0: exit;
 1: begin
    b:=tbitmap.create;
    b.LoadFromFile(bmppath);
    end;
 2: begin
    b:=tbitmap.Create;
    JPEGtoBMP (BmpPath,b);
    end;
 end;
//масштабируем BMP под полученные размеры

dx:=b.Width - width;
dy:=b.Height - height;

if (dx=0) and (dy=0) then
 begin
 //do nothing
 end else
 begin
 if (dx>0) or (dy>0) then
  begin
  //надо уменьшение делать
  CompressImageSpecifiedSize (b,width,height, pf32bit);
  end else
  begin
  //надо увеличение делать
  if PluginSettings.ResizeSmallImages then
   begin
   dx:=width/b.Width;
   dy:=height/b.Height;
   if dx<dy then dy:=dx else dx:=dy;
   Interpolate (b,dx,dy);
   end
  end;
 end; 

ReturnedBitmap:=b.Handle;
result:=FS_BITMAP_EXTRACTED;
end;


exports
        FsInit,
        FsFindFirst,
        FsFindNext,
        FsGetDefRootName,
        FsExecuteFile,
        FsGetFile,
        FsPutFile,
        FsDeleteFile,
        FsExtractCustomIcon,
        FsStatusInfo,
        FsFindClose,

        FsContentGetSupportedField,
        FsContentGetValue,
        FsContentGetDefaultView,
        FsGetPreviewBitmap;

begin
GetMem (x,max_path);
GetModuleFilename (hInstance,x,max_path);
PluginPath:=x;
Windows.GetEnvironmentVariable ('commander_path',x,max_path);
tcdir:=lowercase({includetrailingbackslash}(x));
freemem (x);
end.

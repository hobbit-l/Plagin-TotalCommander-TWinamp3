unit TWA_Functions;
//Работа с плейлистами
interface
uses
 SysUtils,
 tlhelp32,
 Windows,
 Jpeg,
 Math,
 Graphics,
 TWA_Main,
 TWA_Types;


{------------------------------------------------------------------------------}
//читает по очереди строки из плейлиста, возвращая путь к файлу
Function ReadPlaylistEntry (var PlsFile:TextFile;is_pls:boolean {pls or m3u}; var TrackLength:integer):shortstring;
Function GetFileNumber (var PlsFile:TextFile;FilePath:ShortString):integer;
Function GetFileByNumber (var PlsFile:TextFile;is_pls:boolean;FileNum:Integer; Var EXTINF:String):ShortString;
Function GetAbsolutePath (RelativePath:string):string;
Procedure AddToM3UPlaylist (var F:TextFile;SongPath:String);
//Procedure CreateM3UPlayList (Buf:TDynamicArray);
Procedure DeleteFileNum (var PlsFile:TextFile;is_pls:boolean;filenum:TDynamicArrayI);
Function GetFileName (PlayListFileName:String):String;
//Procedure DebugLog (Logmessage:String);
Function FileTime2DateTime(FT:_FileTime):TDateTime;
Function JPEGtoBMP(const FileName: TFileName; var BMP:TBitmap):boolean;
procedure CompressImageSpecifiedSize(var Bmp: Graphics.TBitmap; AWidth, AHeight: Integer;
 APixelFormat: TPixelFormat);
procedure Interpolate(var bm: TBitMap; dx, dy: single); 
Function GetWinampPath:String;
Function GetAppdataPath:String;
Procedure SecondsToTimeFormat (t:Integer;r:pbyte);

{------------------------------------------------------------------------------}
implementation
{------------------------------------------------------------------------------}
Procedure SecondsToTimeFormat (t:Integer;r:pbyte);
Begin
ptimeformat(r).wHour:=0;
if t>3600 then
 begin
 ptimeformat(r).wHour:=t div 3600;
 t:=t-(ptimeformat(r).wHour*3600);
 end;
if t>60 then
 begin
 ptimeformat(r).wMinute:=t div 60;
 t:=t-ptimeformat(r).wMinute*60;
 end;
 ptimeformat(r).wSecond:=t;
end;
{------------------------------------------------------------------------------}
Function GetAppdataPath:String;
var
x:pchar;
Begin
GetMem (x,max_path);
Windows.GetEnvironmentVariable ('appdata',x,max_path);
result:=includetrailingbackslash(lowercase(x));
freemem (x);
end;        

Function JPEGtoBMP(const FileName: TFileName; var BMP:TBitmap):boolean;
var
jpeg: TJPEGImage;
begin
result:=true;
jpeg := TJPEGImage.Create;
 try
 jpeg.CompressionQuality := 100; {Default Value}
 jpeg.LoadFromFile(FileName);
 bmp.Assign(jpeg);
 finally
 jpeg.Free;
 result:=false;
 end;
end;

procedure CompressImageSpecifiedSize(var Bmp: Graphics.TBitmap; AWidth, AHeight: Integer;
 APixelFormat: TPixelFormat);
var
 TempBmp: Graphics.TBitmap;
 AX: Real;
 AY: Real;
 Compress: Real;
begin
{$ifdef ControlStack}
 try
{$endif ControlStack}
 TempBmp := Graphics.TBitmap.Create;
 TempBmp.PixelFormat := APixelFormat;
 TempBmp.Canvas.Lock;
 AX := Bmp.Width / AWidth;
 AY := Bmp.Height / AHeight;
 if AX > AY then
   Compress := AX
 else
   Compress := AY;
 if Compress > 1 then
 begin
   TempBmp.Width := Max(1, Round(Bmp.Width / Compress));
   TempBmp.Height := Max(1, Round(Bmp.Height / Compress));
 end
 else
 begin
   TempBmp.Width := Bmp.Width;
   TempBmp.Height := Bmp.Height;
 end;
 SetStretchBltMode(TempBmp.Canvas.Handle, HALFTONE);
 SetBrushOrgEx(TempBmp.Canvas.Handle, 0, 0, nil);
 StretchBlt(TempBmp.Canvas.Handle, 0, 0, TempBmp.Width, TempBmp.Height,
   Bmp.Canvas.Handle, 0, 0, Bmp.Width, Bmp.Height, SRCCOPY);
 Bmp.Width := TempBmp.Width;
 Bmp.Height := TempBmp.Height;
 Bmp.Canvas.Draw(0, 0, TempBmp);
 Bmp.PixelFormat := APixelFormat;
 TempBmp.Canvas.Lock;
 TempBmp.Free;
{$ifdef ControlStack}
 except
   on E: Exception do
   begin
     ReRaiseException(E, 1547);
     raise;
   end;
 end;
{$endif ControlStack}
end;

procedure Interpolate(var bm: TBitMap; dx, dy: single);
var
bm1: TBitMap;
z1, z2: single;
k, k1, k2: single;
x1, y1: integer;
c: array [0..1, 0..1, 0..2] of byte;
res: array [0..2] of byte;
x, y: integer;
xp, yp: integer;
xo, yo: integer;
col: integer;
pix: TColor;
begin
bm1 := TBitMap.Create;
bm1.Width := round(bm.Width * dx);
bm1.Height := round(bm.Height * dy);
for y := 0 to bm1.Height - 1 do
 begin
 for x := 0 to bm1.Width - 1 do
  begin
  xo := trunc(x / dx);
  yo := trunc(y / dy);
  x1 := round(xo * dx);
  y1 := round(yo * dy);
  for yp := 0 to 1 do
   for xp := 0 to 1 do
    begin
    pix := bm.Canvas.Pixels[xo + xp, yo + yp];
    c[xp, yp, 0] := GetRValue(pix);
    c[xp, yp, 1] := GetGValue(pix);
    c[xp, yp, 2] := GetBValue(pix);
    end;
   for col := 0 to 2 do
    begin
    k1 := (c[1,0,col] - c[0,0,col]) / dx;
    z1 := x * k1 + c[0,0,col] - x1 * k1;
    k2 := (c[1,1,col] - c[0,1,col]) / dx;
    z2 := x * k2 + c[0,1,col] - x1 * k2;
    k := (z2 - z1) / dy;
    res[col] := round(y * k + z1 - y1 * k);
    end;
   bm1.Canvas.Pixels[x,y] := RGB(res[0], res[1], res[2]);
   end;
end;

bm := bm1;

end;


Function GetModuleByProcessId(ProcessId: Cardinal): TModuleEntry32;
var
 hSnapshot : THandle;
 lpme : TModuleEntry32;
begin
 hSnapshot:=CreateToolhelp32Snapshot(TH32CS_SNAPMODULE,ProcessId);
 if hSnapshot=-1 then RaiseLastWin32Error;
 lpme.dwSize:=SizeOf(lpme);
 if Module32First(hSnapshot,lpme) then
 begin
 Result:=lpme;
 end;
end;

Function GetWinampPath:String;
VAR
Wnd : hWnd;
Pid : Cardinal;
modarr:TModuleEntry32;
begin
Result:='';
Wnd := FindWindow ('Winamp v1.x',nil);
if (wnd=0) or (wnd=INVALID_HANDLE_VALUE) then exit;
//-----------------------------------------
GetWindowThreadProcessId(Wnd,@Pid);
modarr:=GetModuleByProcessId(Pid);
if Integer(modarr.modBaseAddr)=$400000 then
 begin
 Result:=modarr.szExePath;
 end;
end;


Function ReadPlaylistEntry (var PlsFile:TextFile;is_pls:boolean {pls or m3u}; var TrackLength:integer):shortstring;
var
tempString:ShortString;
ti:string;
begin
TRackLength:=0;
 try
 if is_pls then
  begin

  end else {is_m3u}
  begin
  readln (PlsFile,tempString);
  if copy (tempString,1,8)='#EXTINF:' then
   begin {info exists}
   ti:=copy(tempString,9,pos (',',TempString)-9);
   TrackLength:=StrToInt (ti);
   readln (PlsFile,tempString);
   end;
   Result:=TempString;


  end;
 except end;
End;
{------------------------------------------------------------------------------}
Function GetFileNumber (var PlsFile:TextFile;FilePath:ShortString):integer;
var
TempString:ShortString;
TempResult:integer;
//PlsFile:TextFile;
begin
try
//AssignFile (PlsFile,Filepath);
reset (PlsFile);
result:=-1;
TempResult:=-1;
readln (PlsFile);
while Not EOF (PlsFile) do
 begin
 inc (TempResult);
 readln (PlsFile,tempString);
 if copy (tempString,1,8)='#EXTINF:' then
  begin {info exists}
  readln (PlsFile,tempString);
  end;
 if TempString=Filepath then
  begin
  Result:=TempResult;
  exit;
  end;
 end;
Finally
 begin
// CloseFile (PlsFile);
 end;
end;
end;
{------------------------------------------------------------------------------}
Function GetAbsolutePath (RelativePath:string):string;
Begin
result:=RelativePath;
if FileExists(Result) then exit;
Result:=ExtractFilePath (PluginSettings.WinAmpM3U )+RelativePath;
if FileExists(Result) then exit;
//Файл не найден ни по указанному пути, ни в каталоге с плейлистом
//пробуем найти его в подкаталогах (относительно каталога с плейлистом)
if Relativepath[1]='\' then
 begin
 if RelativePath[2]='\' then Delete(Relativepath,1,1);
 Result:=ExtractFileDrive (PluginSettings.WinAmpM3U)+RelativePath;
 end;
if FileExists(Result) then exit;
//Не нашли и в этом случае. Значит файл не найден!
//Отдаём, что взяли, и отпускаем...
result:=RelativePath;
End;

{------------------------------------------------------------------------------}
Function GetFileByNumber (var PlsFile:TextFile;is_pls:boolean;FileNum:Integer; Var EXTINF:String):ShortString;
var
TempString:ShortString;
TempInt:integer;
Begin
reset (PlsFile);
if is_pls then
 begin
 end else
 begin
 readln(PlsFile);
 for TempInt:=1 to FileNum do
  begin
  Readln(PlsFile,TempString);
  if copy (TempString,1,8)='#EXTINF:' then
   begin {info exists}
   readln (PlsFile,TempString);
   end;
  end;
  readln (PlsFile,TempString);
  if copy (TempString,1,8)='#EXTINF:' then
   begin {info exists}
   EXTINF:=Copy(TempString,9,length(TempString)-8);
   readln (PlsFile,TempString);
   end;
  Result:=GetAbsolutePath(TempString);
 end;
End;

{------------------------------------------------------------------------------}
Procedure AddToM3UPlaylist (var F:TextFile;SongPath:String);
Begin
if PluginSettings.blockdead then
 begin
 if fileexists (SongPath) then writeln (f,SongPath);
 end else writeln (f,SongPath);
End;
{------------------------------------------------------------------------------}
{Procedure CreateM3UPlayList (Buf:TDynamicArray);
var
i:integer;
f:textfile;
AddFilesCount:integer;
begin
AddFilesCount:=buf.Length;
assignfile (f,PluginSettings.TempM3UFile);
rewrite (f);
writeln (f,'#EXTM3U');
for i:=0 to buf.Length -1 do
 begin
 if PluginSettings.blockdead then
  begin
  if fileexists (buf.bodyArray [i]) then writeln (f,buf.BodyArray [i]);
  end else writeln (f,buf.BodyArray [i]);
 end;
closefile (F);
end;
После замены сохранения плейлиста в динамический массив сохранением сразу в m3u эта функция не нужна
}
{------------------------------------------------------------------------------}
Procedure DeleteFileNum (var PlsFile:TextFile;is_pls:boolean;filenum:TDynamicArrayI);
 function IsIn (a:integer;b:TDynamicArrayI):boolean;
  var
  i:integer;
  begin
  result:=false;
  for i:=0 to b.Length-1 do
   begin
   if a=b.BodyArray[i] then
    begin
    result:=true;
    exit;
    end;
   end;
  end;
var
TempString:ShortString;
I:integer;
F:Textfile;
Begin
if is_pls then
 begin
 end else
 begin
 assignfile (f,PluginSettings.TempM3UFile);
 rewrite (f);
 writeln (f,'#EXTM3U');
 reset (PlsFile);
 i:=-1;
 readln (PlsFile);
 while Not EOF (PlsFile) do
  begin
  inc (i);
  readln (PlsFile,TempString);
  if not isin (i,filenum) then
   begin
   if copy (tempString,1,8)='#EXTINF:' then
    begin
    writeln (f,tempString);
    readln (PlsFile,TempString);
    writeln (f,tempString);
    end else
    begin
    writeln (f,tempString);
    end;
   end else
   begin
   if copy (tempString,1,8)='#EXTINF:' then
    begin
    readln (PlsFile);
    end else
    begin
    //do nothing;
    end;
   end;
  end;
 CloseFile (f); 
 end;
end;
{------------------------------------------------------------------------------}
Function GetFileName (PlayListFileName:String):String;
Begin
Delete(PlayListFileName,1,1);
if PlayListFileName[1]='\' then result:=PluginSettings.WinAmpPath[1]+':'+PlayListFileName else result:=PlayListFileName;
End;
{------------------------------------------------------------------------------}
Procedure DebugLog (LogMessage:string);//создаёт отчёт об ошибке
var
f:textfile;
Begin
if not fileexists (IncludeTrailingBackSlash(extractfilepath (PluginPath))+'DebugLog.txt') then
 begin
 AssignFile (f,IncludeTrailingBackSlash(extractfilepath (PluginPath))+'DebugLog.txt');
 rewrite (f);
 closefile (f);
 end;
AssignFile (f,IncludeTrailingBackSlash(extractfilepath (PluginPath))+'DebugLog.txt');
Append (f);
Writeln (f,{datetostr (now)+'-'+timetostr(now)+': '+}LogMessage);
closefile (f);
end;
{------------------------------------------------------------------------------}
Function FileTime2DateTime(FT:_FileTime):TDateTime;
 var FileTime:_SystemTime;
 begin
 FileTimeToLocalFileTime(FT, FT);
 FileTimeToSystemTime(FT,FileTime);
 Result:=EncodeDate(FileTime.wYear, FileTime.wMonth, FileTime.wDay)+
 EncodeTime(FileTime.wHour, FileTime.wMinute, FileTime.wSecond, FileTime.wMilliseconds);
end;


end.

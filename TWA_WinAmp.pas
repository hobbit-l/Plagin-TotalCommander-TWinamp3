unit TWA_WinAmp;
{Процедуры, прямо или косвенно имеющие отношение к винампу}
interface

uses
 messages,
 windows,
 TWA_Types;

function winamp_runned:boolean;//Запущен ли плеер
function WinAmpMessage(Msg :UINT ; wParam :WPARAM ; lParam :LPARAM ): cardinal;//Сообщение винампу
procedure OpenDirDialog;
function SavePlayList:LongWord;//return played track number
procedure ClearplayList;
Procedure AddFile (Path:string);
procedure SetPlayedTrack (tracknum:integer);
Function GetWinampTracksCount:integer;

implementation

function winamp_runned:boolean;//Запущен ли плеер
var
thandle:HWND;
begin
thandle:=FindWindow ('Winamp v1.x',nil);
if (thandle<>0) and (thandle<>INVALID_HANDLE_VALUE) then
 result:=true else
 result:=false;
end;

function WinAmpMessage(Msg :UINT ; wParam :WPARAM ; lParam :LPARAM ): cardinal;//Сообщение винампу
var
thandle:HWND;
begin
result:=INVALID_HANDLE_VALUE;
if not winamp_runned then winexec (@PluginSettings.WinampExe[1],SW_SHOW);
//if not winamp_runned then exit;
thandle:=FindWindow ('Winamp v1.x',nil);
if (tHandle <> INVALID_HANDLE_VALUE) and (tHandle<>0) then  result:=SendMessage(tHandle , Msg , wParam , lParam);
end;

procedure OpenDirDialog;
begin
winampmessage (WM_COMMAND,40030,0);
end;

function SavePlayList:LongWord;
begin
result:=winampmessage (WM_USER,0,120);
end;

procedure ClearplayList;
begin
Winampmessage (WM_USER,0,101); 
end;


Procedure AddFile;
begin
WinExec (pchar(PluginSettings.WinAmpExe +' /ADD "'+ path+'"'),SW_NORMAL);
end;

procedure SetPlayedTrack (tracknum:integer);
begin
winampmessage (WM_USER,tracknum,121);
end;

Function GetWinampTracksCount:integer;
begin
Result:=winampmessage (WM_USER,0,124);
end;

end.

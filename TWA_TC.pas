unit TWA_TC;

Interface
uses
 windows,
 messages;

function FindTCWindow: HWND;
Procedure ReReadPanels;
Procedure SwitchToThumbnailsMode;

implementation

function FindTCWindow: HWND;
begin
 Result := FindWindow ('TTOTAL_CMD', nil);
end;

Procedure ReReadPanels;
begin
 PostMessage(FindTCWindow, WM_USER+51, 540, 0);
end;

Procedure SwitchToThumbnailsMode;
begin
//нужно переключать не активную панель, а ту, в которой плагин. Как? Надо подумать.
 PostMessage(FindTCWindow, WM_USER+51, 269, 0);
end;

end.
unit Settings;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  StrUtils, Dialogs, StdCtrls,IniFiles, XPMan;

type
  TTWAOptions = class(TForm)
    Label1: TLabel;
    GroupBox1: TGroupBox;
    initext: TMemo;
    GroupBox2: TGroupBox;
    SwfB: TButton;
    GroupBox5: TGroupBox;
    GftB: TButton;
    GroupBox6: TGroupBox;
    SeeB: TButton;
    SeB: TButton;
    DmeCB: TCheckBox;
    darCB: TCheckBox;
    CB: TButton;
    OpenDialog1: TOpenDialog;
    XPManifest1: TXPManifest;
    rsiCB: TCheckBox;
    GroupBox3: TGroupBox;
    wopdCB: TComboBox;
    wm3u: TLabel;
    atmCB: TCheckBox;
    procedure CBClick(Sender: TObject);
    procedure GftBClick(Sender: TObject);
    procedure SwfBClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure SeeBClick(Sender: TObject);
    procedure initextChange(Sender: TObject);
    procedure SeBClick(Sender: TObject);
    procedure DmeCBClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure darCBClick(Sender: TObject);
    procedure initextKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure rsiCBClick(Sender: TObject);
    procedure wopdCBChange(Sender: TObject);
    procedure atmCBClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }

  end;

var
  TWAOptions: TTWAOptions;
  Ini:TInifile;

implementation

 Uses TWA_Main,TWA_Types,TWA_Functions;
{$R *.dfm}

procedure TTWAOptions.CBClick(Sender: TObject);
begin
if Seb.Enabled then
 begin
 case MessageBox (TWAOptions.Handle,'Save changes?','Save or discard', mb_yesnocancel+mb_iconQuestion) of
  id_yes:    begin
             initext.Lines.SaveToFile(ini.FileName);
             Close;
             end;
  id_no:     begin
             Close;
             end;
  id_cancel: begin
             Exit;
             end;
  end;
 end else close;
end;

procedure TTWAOptions.GftBClick(Sender: TObject);
var
WI:TIniFile;
begin
WI:=TIniFile.Create(GetSettingsWinampHomePath+'winamp.ini');
ini.WriteString('Mode','ExtFilter',WI.ReadString('Winamp','config_extlist','mp3'));
wi.Destroy;
initext.Lines.LoadFromFile(ini.FileName);
end;

procedure TTWAOptions.SwfBClick(Sender: TObject);
var
W_Folder:String;
begin
W_Folder:='';
W_FOLDER:=includetrailingbackslash(GiveFolder ('Select Winamp directory',TWAOptions.Handle));
if DirectoryExists (W_FOLDER) then ini.WriteString('Path','WinampFolder',w_folder);
initext.Lines.LoadFromFile(ini.FileName);
end;

procedure TTWAOptions.FormClose(Sender: TObject; var Action: TCloseAction);
begin
ini.Destroy;
ReadSettings (PluginSettings);
end;

procedure TTWAOptions.SeeBClick(Sender: TObject);
var
p:string;
begin
Opendialog1.InitialDir:=ExtractFileDir(Application.ExeName);
if (opendialog1.Execute) and (fileexists (opendialog1.FileName)) then
 begin
 p:=opendialog1.FileName;
 ini.WriteString('Path','Editor',p);
 initext.Lines.LoadFromFile(ini.FileName);
 end;
end;

procedure TTWAOptions.initextChange(Sender: TObject);
begin
SeB.Enabled:=true;
end;

procedure TTWAOptions.SeBClick(Sender: TObject);
begin
SeB.Enabled:=false;
initext.Lines.SaveToFile(ini.FileName);
end;

procedure TTWAOptions.DmeCBClick(Sender: TObject);
begin
ini.WriteBool('Mode','DisableMulti',DmeCb.Checked);
initext.Lines.LoadFromFile(ini.FileName);
end;

procedure TTWAOptions.FormShow(Sender: TObject);

begin
If not fileexists (AnsiReplaceStr(LowerCase(ini.ReadString('Path','WinampFolder','')),'%commander_path%',tcdir)+'winamp.exe') then
 begin
 if GetWinampPath<>'' then
  begin
   case MessageBox (Application.Handle,pchar('Path to Winamp detected: '+ExtractFilePath(GetWinampPath)+#10+'It is correct path?'),'Winamp path autodetection',mb_YesNo+Mb_IconQuestion) of
   ID_YES: Begin
           Ini.WriteString('Path','WinampFolder',ExtractFilePath(GetWinampPath));
           End;
   ID_NO:  Begin
           //ничего не делаем, пусть юзер сам указывает, где у него винамп...
           End;
   end; {case}
  end;
 end;


dmeCB.Checked:=ini.ReadBool('Mode','DisableMulti',false);
darCB.Checked:=ini.ReadBool('Bug','BugWithAttributes',false);
rsiCB.Checked:=ini.ReadBool('Thumbnails','ResizeSmallImages',false);
wopdCB.ItemIndex:=GetSettingsWinampHomePathNum;
atmCB.Checked :=ini.ReadBool('Thumbnails','Auto',false);
if not fileexists (GetSettingsWinampHomePath+'winamp.m3u') then
 begin
 wm3u.Caption:='Winamp.m3u not found';
 wm3u.Font.Color:=clRed
 end else
 begin
 wm3u.Font.Color:=clGreen;
 wm3u.Caption :='Winamp.m3u founded';
 wm3u.hint:=GetSettingsWinampHomePath+'winamp.m3u';
 end;


initext.Lines.LoadFromFile(ini.FileName);

end;

procedure TTWAOptions.darCBClick(Sender: TObject);
begin
if ini.ReadInteger('Bug','BugWithAttributes',-1)=-1 then
 begin
 MessageBox (Application.Handle,'This option disables attributes reading for files in the list.'+
 ' It allows to bypass a bug with incorrect filetypes understanding (when files are displayed as'+
 ' folders). If you do not have such mistake, leave option switched - off.'+#10+#10+
 'Эта настройка отключает чтение атрибутов для файлов в списке.'+
 ' Это позволяет обойти ошибку с неверным определением типов (когда файлы отображаются как папки).'+
 ' Если у вас не возникает такая ошибка, оставьте настройку отключенной.','TWinamp',0);
 end;
ini.WriteBool('Bug','BugWithAttributes',darCB.Checked);
initext.Lines.LoadFromFile(ini.FileName);

end;

procedure TTWAOptions.initextKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
if key=VK_ESCAPE then cb.Click;
end;

procedure TTWAOptions.rsiCBClick(Sender: TObject);
begin
ini.WriteBool('Thumbnails','ResizeSmallImages',RsiCb.Checked);
initext.Lines.LoadFromFile(ini.FileName);
end;

procedure TTWAOptions.wopdCBChange(Sender: TObject);
var
W_FOLDER:String;
begin
case wopdCB.ItemIndex of
 0: begin
    //auto
    ini.WriteString('Path','WinampHomePath','');
    end;
 1: begin
    ini.WriteString('Path','WinampHomePath',ini.ReadString('Path','WinampFolder',''));
    end;
 2: begin
    ini.WriteString('Path','WinampHomePath','%appdata%\winamp\');
    end;
 3: begin
    W_Folder:='';
    W_FOLDER:=includetrailingbackslash(GiveFolder ('Select directory with winamp.m3u',TWAOptions.Handle));
    if DirectoryExists (W_FOLDER) then ini.WriteString('Path','WinampHomePath',w_folder);
    end;   
 end;
if not fileexists (GetSettingsWinampHomePath+'winamp.m3u') then
 begin
 wm3u.Caption:='Winamp.m3u not found';
 wm3u.Font.Color:=clRed;
 wm3u.hint:='';
 end else
 begin
 wm3u.Font.Color:=clGreen;
 wm3u.Caption :='Winamp.m3u founded';
 wm3u.hint:=GetSettingsWinampHomePath+'winamp.m3u';
 end;

initext.Lines.LoadFromFile(ini.FileName);
end;


procedure TTWAOptions.atmCBClick(Sender: TObject);
begin
ini.WriteBool('Thumbnails','Auto',atmCB.Checked);
initext.Lines.LoadFromFile(ini.FileName);
end;

procedure TTWAOptions.FormCreate(Sender: TObject);
var
p:string;
begin
//Больше никаких проверок и т.д. Всё это очень хорошо в теории, но на практике
//тупо раздражает. Пусть будет железобетонная привязка ини-файла к каталогу плагина
p:=IncludeTrailingbackslash(ExtractFilePath(PluginPath))+'twinamp.ini';
if not fileexists (p) then FileClose (FileCreate (p));
initext.Lines.LoadFromFile(p);
ini:=TInifile.Create(p);
end;

end.

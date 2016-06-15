unit Ufrm_Main;

{$mode delphi}
{$H+}

interface

uses
  Classes,
  SysUtils,
  FileUtil,
  Ipfilebroker,
  IpHtml,
  Forms,
  Controls,
  Graphics,
  Dialogs,
  StdCtrls,
  ComCtrls,
  Process,
  LCLType,
  LCLIntF,
  LCLProc,
  Menus,
  ExtCtrls,
  Clipbrd,
  ActnList,
  UTF8Process,

  UStringSplitter,
  UPersistency,
  ULogger;

const
  APP_VER = '0.1.2-alpha';

type

  { Tfrm_Main }

  Tfrm_Main = class(TForm)
    ac_ExcludeCBE: TAction;
    ac_SuperUser: TAction;
    ac_NewSearchWindow: TAction;
    ac_Options: TAction;
    al_Main: TActionList;
    btn_Locate: TButton;
    edt_SearchPattern: TEdit;
    MenuItem3: TMenuItem;
    MenuItem5: TMenuItem;
    MenuItem9: TMenuItem;
    mi_ExcludeCBE: TMenuItem;
    mi_Delete: TMenuItem;
    mi_TestBackdoorSeparator: TMenuItem;
    mi_TestBackdoor: TMenuItem;
    mi_TraySuperUser: TMenuItem;
    mi_NewSearchWindow: TMenuItem;
    MenuItem7: TMenuItem;
    mi_SuperUser: TMenuItem;
    tmr_Popup: TTimer;
    lv_Files: TListView;
    MenuItem4: TMenuItem;
    mi_TrayNewSearchWindow: TMenuItem;
    MenuItem6: TMenuItem;
    mi_TrayOptions: TMenuItem;
    MenuItem8: TMenuItem;
    mi_TrayExit: TMenuItem;
    mi_OpenWithSelectAdd: TMenuItem;
    mi_OpenWith: TMenuItem;
    mi_UpdateDB: TMenuItem;
    mi_About: TMenuItem;
    mi_Help: TMenuItem;
    mi_Tools: TMenuItem;
    mi_Options: TMenuItem;
    mnu_Main: TMainMenu;
    MenuItem1: TMenuItem;
    mi_File: TMenuItem;
    mi_Exit: TMenuItem;
    mi_Properties: TMenuItem;
    mi_CopyFullNameToClipboard: TMenuItem;
    MenuItem2: TMenuItem;
    mi_CopyPathToClipboard: TMenuItem;
    mi_CopyNameOnlyToClipboard: TMenuItem;
    mi_Open: TMenuItem;
    mi_OpenPath: TMenuItem;
    mnu_PopupFiles: TPopupMenu;
    dlg_OpenWith: TOpenDialog;
    pnl_Locate: TPanel;
    mnu_PopupTray: TPopupMenu;
    sb_Main: TStatusBar;
    ti_Main: TTrayIcon;
    procedure ac_ExcludeCBEExecute(Sender: TObject);
    procedure ac_NewSearchWindowExecute(Sender: TObject);
    procedure ac_OptionsExecute(Sender: TObject);
    procedure ac_SuperUserExecute(Sender: TObject);
    procedure btn_LocateClick(Sender: TObject);
    procedure edt_SearchPatternKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormHide(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormShow(Sender: TObject);
    procedure lv_FilesContextPopup(Sender: TObject; MousePos: TPoint; var Handled: Boolean);
    procedure lv_FilesDblClick(Sender: TObject);
    procedure lv_FilesDrawItem(Sender: TCustomListView; AItem: TListItem; ARect: TRect; AState: TOwnerDrawState);
    procedure lv_FilesKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure lv_FilesMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure mi_DeleteClick(Sender: TObject);
    procedure mi_TestBackdoorClick(Sender: TObject);
    procedure mi_TrayOptionsClick(Sender: TObject);
    procedure mi_TrayExitClick(Sender: TObject);
    procedure mi_AboutClick(Sender: TObject);
    procedure mi_OpenWithSelectAddClick(Sender: TObject);
    procedure mi_UpdateDBClick(Sender: TObject);
    procedure mi_ExitClick(Sender: TObject);
    procedure mi_CopyFullNameToClipboardClick(Sender: TObject);
    procedure mi_CopyNameOnlyToClipboardClick(Sender: TObject);
    procedure mi_CopyPathToClipboardClick(Sender: TObject);
    procedure mi_OpenClick(Sender: TObject);
    procedure mi_OpenPathClick(Sender: TObject);
    procedure mi_PropertiesClick(Sender: TObject);
    procedure mnu_PopupFilesClose(Sender: TObject);
    procedure mnu_PopupFilesPopup(Sender: TObject);
    procedure ti_MainClick(Sender: TObject);
    procedure tmr_PopupTimer(Sender: TObject);
    procedure ti_MainDblClick(Sender: TObject);
  private
    { private declarations }
    FInitialW: Integer;
    FInitialH: Integer;
    FCanClose: Boolean;
    FOperation: String;
    FLastX: Integer;
    FLastY: Integer;
    FShowMenu: Boolean;
    FLastCommandParams: String;
    FLastCommandOutput: String;
    FSuppressUpdateDBDialogs: Boolean;

    procedure OpenWithAppClick(Sender: TObject);

    procedure Reset;
    procedure ResetLocate;
    procedure LockUI(Lock: Boolean);
    procedure SetOperation(Operation: String);
    function GetOperation: String;
    procedure SetStatus(Status: String);
    function GetStatus: String;
    procedure WarnUser(Msg: String);
    function GetUpdateDBMenuPath: String;
    function GetUpdateDBShortcut: String;
    function GetUpdateDBDirections: String;
    function GetSuperUserMenuPath: String;
    function GetSuperUserDirections: String;

    procedure ILog(Msg: String);
    procedure WLog(Msg: String);
    procedure ELog(Msg: String; Routine: String);

    function ExecuteCommand(Directory: String; Command: String; Parameters: array of String; SuperUser: Boolean): Boolean; overload;
    function ExecuteCommand(Directory: String; Command: String; Parameters: array of String; SuperUser: Boolean; var Output: String): Boolean; overload;
    function TriggerCommand(Directory: String; Command: String; Parameters: array of String; SuperUser: Boolean): Boolean; overload;
    function TriggerCommand(Directory: String; Command: String; Parameters: array of String; SuperUser: Boolean; TimeoutMS: Integer): Boolean; overload;
    function OpenDocumentEx(FileName: String; SuperUser: Boolean): Boolean; overload;
    function OpenDocumentEx(FileName: String; SuperUser: Boolean; var OSHandlerApp: String): Boolean; overload;

    procedure LocateFiles(SearchPattern: String; JustUpdatedDB: Boolean);
    procedure FilterList(List: TStringList; Keyword: String);
  public
    { public declarations }
  end;

const
  OPEN_WITH_APP_MENU_ITEM_MASK = $10000;

const
  TMO_NONE                = 0;
  TMO_MS_OPEN_DOC         = 1000;

var
  frm_Main: Tfrm_Main;
  VisibleInstances: TList;

implementation

uses
  ufrm_options;

{ misc routines }

function Get_Home_Dir: String;
begin
  Result := ExpandFileName('~/');
end;

function Internal_Execute_Command(Process: TProcess; var OutputString: String; var ExitStatus: Integer): Integer;
const
  READ_BYTES = 65536;
  STEP_SLEEP_MS = 100;
var
  NumBytes: Integer;
  BytesRead: Integer;
begin
  Result := -1;
  try
    try
      Process.Options := [poUsePipes];
      BytesRead := 0;
      Process.Execute;

      while Process.Running do
      begin
        Setlength(OutputString, BytesRead + READ_BYTES);
        NumBytes := Process.Output.Read(OutputString[1 + BytesRead], READ_BYTES);
        if NumBytes > 0 then
          Inc(BytesRead, NumBytes)
        else
          Sleep(STEP_SLEEP_MS);
      end;

      repeat
        Setlength(OutputString, BytesRead + READ_BYTES);
        NumBytes := Process.Output.Read(OutputString[1 + BytesRead], READ_BYTES);
        if NumBytes > 0 then
          Inc(BytesRead, NumBytes);
      until NumBytes <= 0;

      Setlength(OutputString, BytesRead);
      ExitStatus := Process.ExitStatus;
      Result := 0;
    except
      on E: Exception do
      begin
        Result := 1;
        Setlength(OutputString, BytesRead);
      end;
    end;
  finally
    Process.Free;
  end;
end;

function Internal_Trigger_Command(Process: TProcess; var ExitStatus: Integer; TimeoutMS: Integer): Integer;
const
  STEP_SLEEP_MS = 100;
var
  T0: Integer;
begin
  Result := -1;
  try
    try
      Process.Options := [];
      Process.Execute;

      T0 := GetTickCount;
      while Process.Running and (GetTickCount - T0 < TimeoutMS) do
        Sleep(STEP_SLEEP_MS);

      ExitStatus := Process.ExitStatus;
      Result := 0;
    except
      on E: Exception do
      begin
        Result := 1;
      end;
    end;
  finally
    Process.Free;
  end;
end;

function Caption_To_Message(Caption: String): String;
var
  i: Integer;
begin
  Result := '';
  for i := 1 to Length(Caption) do
    if Caption[i] <> '&' then
      Result := Result + Caption[i];
end;

{ Tfrm_Main }

{$R *.lfm}

procedure Tfrm_Main.FormCreate(Sender: TObject);
begin
  // tray icon only for the main form;
  if Self = frm_Main then // Application.MainForm is not yet set;
  begin
    ti_Main.Icon := Application.Icon;
    ti_Main.Hint := Application.Title;
    ti_Main.Visible := True;
  end;

  FInitialW := Width;
  FInitialH := Height;

  ac_SuperUser.Checked := Pers_Gen_Get_Super_User;
  ac_ExcludeCBE.Checked := Pers_Gen_Get_Exclude_CBE;

  Reset;
  System.Randomize;
end;

procedure Tfrm_Main.FormDestroy(Sender: TObject);
begin
  {}
end;

procedure Tfrm_Main.FormHide(Sender: TObject);
begin
  VisibleInstances.Remove(Self);
end;

procedure Tfrm_Main.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  Shift := Shift;

  if Key = VK_ESCAPE then
    Close;
end;

procedure Tfrm_Main.FormShow(Sender: TObject);
begin
  VisibleInstances.Add(Self);

  if edt_SearchPattern.IsVisible then
    edt_SearchPattern.SetFocus;

  // let's just not risk it;
  mi_TestBackdoor.ShortCut := scNone;
  mi_TestBackdoor.Visible := False;
  mi_TestBackdoorSeparator.Visible := False;

{$ifdef DEBUG}
  mi_TestBackdoor.ShortCut := scCtrl + VK_F12;
  mi_TestBackdoor.Visible := True;
  mi_TestBackdoorSeparator.Visible := True;
{$endif}
end;

procedure Tfrm_Main.lv_FilesContextPopup(Sender: TObject; MousePos: TPoint; var Handled: Boolean);
var
  HasSelectedFile: Boolean;
begin
  MousePos := MousePos;
  Handled := Handled;

  HasSelectedFile := (lv_Files.Items.Count > 0) and (lv_Files.ItemIndex <> -1);
  mi_Open.Enabled                           := HasSelectedFile;
  mi_OpenPath.Enabled                       := HasSelectedFile;
  mi_OpenWith.Enabled                       := HasSelectedFile;
  mi_CopyFullNameToClipboard.Enabled        := HasSelectedFile;
  mi_CopyPathToClipboard.Enabled            := HasSelectedFile;
  mi_CopyNameOnlyToClipboard.Enabled        := HasSelectedFile;
  mi_Delete.Enabled                         := HasSelectedFile;
  mi_Properties.Enabled                     := HasSelectedFile;
end;

procedure Tfrm_Main.lv_FilesDblClick(Sender: TObject);
begin
  mi_Open.Click;
end;

procedure Tfrm_Main.lv_FilesDrawItem(Sender: TCustomListView; AItem: TListItem; ARect: TRect; AState: TOwnerDrawState);
const
  COL_BRUSH_CURRENT_SEL_EVEN     = $705030;
  COL_BRUSH_CURRENT_SEL_ODD      = $66482B;
  COL_BRUSH_OTHER_SEL_EVEN       = COL_BRUSH_CURRENT_SEL_EVEN;
  COL_BRUSH_OTHER_SEL_ODD        = COL_BRUSH_CURRENT_SEL_ODD;
  COL_BRUSH_OTHER_UNSEL_EVEN     = $FFFFFF;
  COL_BRUSH_OTHER_UNSEL_ODD      = $F8F8F8;
  COL_FONT_OTHER_SEL             = $FFFFFF;
  COL_FONT_OTHER_UNSEL           = $606060;
var
  LV: TCustomListView;
  C: TCanvas;
  FileName: String;
  Index: Integer;
begin
  LV := Sender;
  Index := AItem.Index;

  // get filename & canvas;
  FileName := LV.Items.Item[Index].Caption;
  C := LV.Canvas;

  // setup brush;
  C.Brush.Style := bsSolid;
  if odSelected in AState then
    if Index mod 2 = 0 then
      C.Brush.Color := COL_BRUSH_OTHER_SEL_EVEN
    else
      C.Brush.Color := COL_BRUSH_OTHER_SEL_ODD
  else
    if Index mod 2 = 0 then
      C.Brush.Color := COL_BRUSH_OTHER_UNSEL_EVEN
    else
      C.Brush.Color := COL_BRUSH_OTHER_UNSEL_ODD;

  // setup font;
  C.Font.Assign(LV.Font);
  if odSelected in AState then
    C.Font.Color := COL_FONT_OTHER_SEL
  else
    C.Font.Color := COL_FONT_OTHER_UNSEL;

  // clear item's area;
  C.FillRect(ARect);

  // render text;
  C.Brush.Style := bsClear;
  C.TextOut(ARect.Left + 2, ARect.Top + (10 - C.TextHeight('h')) div 2, FileName);
end;

procedure Tfrm_Main.lv_FilesKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  Shift := Shift;

  if Key = VK_RETURN then
    mi_Open.Click;

  if Key = VK_DELETE then
    mi_Delete.Click;
end;

procedure Tfrm_Main.lv_FilesMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  P: TPoint;
begin
  Shift := Shift;

  if Button = mbRight then
  begin
    P := lv_Files.ClientToScreen(Point(X, Y));
    FLastX := P.X;
    FLastY := P.Y;
    FShowMenu := True;
  end;
end;

procedure Tfrm_Main.mi_DeleteClick(Sender: TObject);
var
  FileName: String;
  DlgCaption: String;
begin
  if lv_Files.Items.Count < 1 then
    Exit;

  if not Assigned(lv_Files.ItemFocused) then
    Exit;

  FileName := lv_Files.ItemFocused.Caption;
  if FileExists(FileName) then
  begin
    DlgCaption := 'Delete';
    if MessageDlg(DlgCaption, Format('Delete "%s"?' + #13#13 + 'Trash is not used ("rm -rf").', [FileName]), mtConfirmation, [mbYes, mbNo], 0) <> mrYes then
      Exit;

    if ExecuteCommand('', 'rm', [FileName, '-rf'], mi_SuperUser.Checked) then
    begin
      MessageDlg( Format( 'Successfully removed "%s".',
                          [ FileName ] ),
                  mtInformation,
                  [mbOk],
                  0 );

      // update db and refresh current search;
      FSuppressUpdateDBDialogs := True;
      mi_UpdateDB.Click;
      FSuppressUpdateDBDialogs := False;
    end
    else
      MessageDlg( Format( 'Could not remove "%s".' + #13#13 +
                          'Perhaps you don''t have sufficient permissions.' + #13#13 +
                          '%s' + #13#13 +
                          'But be warned, with great power comes great responsability.',
                          [ FileName, GetSuperUserDirections ] ),
                  mtWarning,
                  [mbOk],
                  0 );
  end
  else
    MessageDlg( Format( '"%s" does not exist.' + #13#13 +
                        'You should update the "locate" database.' + #13#13 +
                        '%s',
                        [ FileName, GetUpdateDBDirections ] ),
                mtWarning,
                [mbOk],
                0 );
end;

procedure Tfrm_Main.mi_TestBackdoorClick(Sender: TObject);

  procedure Report_Test_Result(TestResultOk: Boolean);
  const
    STATUS_DESC: array [Boolean] of String = ('failed', 'succeeded');
  begin
    ShowMessageFmt('Operation %s.', [STATUS_DESC[TestResultOk]]);
  end;

begin
  //Report_Test_Result(ExecuteCommand('~/', 'bad_command', [], False)); // ok, should fail; // test bad commands;
  //Report_Test_Result(ExecuteCommand('~/', 'bad_command', ['bad_param'], False)); // ok, should fail; // test bad commands with bad params;
  //Report_Test_Result(TriggerCommand('~/', 'bad_command', [], False)); // ok, should fail; // test bad commands;
  //Report_Test_Result(TriggerCommand('~/', 'bad_command', ['bad_param'], False)); // ok, should fail; // test bad commands with bad params;

  //Report_Test_Result(ExecuteCommand('~/', 'nemo', ['~/blank space zzzzzz'], False)); // ok; // test files with blank spaces in path;

  //Report_Test_Result(ExecuteCommand('/etc/lighttpd/', '/usr/bin/kate', ['/etc/lighttpd/lighttpd.conf'], False)); // ok; // test open file with kate no sudo;
  //Report_Test_Result(ExecuteCommand('/etc/lighttpd/', '/usr/bin/kate', ['/etc/lighttpd/lighttpd.conf'], True)); // NOK; // test open file with kate with sudo;
  //Report_Test_Result(ExecuteCommand('/etc/lighttpd/', '/usr/bin/gedit', ['/etc/lighttpd/lighttpd.conf'], True)); // ok, sync while gedit runs; // test open file with gedit with sudo;

  //Report_Test_Result(ExecuteCommand('/etc/lighttpd/', '/usr/bin/xdg-open', ['/etc/lighttpd/lighttpd.conf'], False)); // ok; // test open file with OS default no sudo;
  //Report_Test_Result(ExecuteCommand('/etc/lighttpd/', '/usr/bin/xdg-open', ['/etc/lighttpd/lighttpd.conf'], True)); // ok; // test open file with OS default with sudo;

  //Report_Test_Result(ExecuteCommand('/etc/lighttpd/', '/usr/bin/xdg-open', ['/etc/lighttpd/'], False)); // ok; // test open dir with OS default no sudo;
  //Report_Test_Result(ExecuteCommand('/etc/lighttpd/', '/usr/bin/xdg-open', ['/etc/lighttpd/'], True)); // ok, but hangs; // test open dir with OS default with sudo;

  //Report_Test_Result(ExecuteCommand('/etc/lighttpd/', 'nemo', ['/etc/lighttpd/'], False)); // ok; // test open file with nemo default no sudo;
  //Report_Test_Result(ExecuteCommand('/etc/lighttpd/', 'nemo', ['/etc/lighttpd/'], True)); // ok, but doesn't return; // test open dir with nemo with sudo;
  //Report_Test_Result(ExecuteCommand('/etc/lighttpd/', 'nautilus', ['/etc/lighttpd/'], False)); // ok, doesn't return; // test dir file with nautilus default no sudo;
  //Report_Test_Result(ExecuteCommand('/etc/lighttpd/', 'nautilus', ['/etc/lighttpd/'], True)); // ok, doesn't return; // test open dir with nautilus with sudo;

  //Report_Test_Result(TriggerCommand('/etc/lighttpd/', 'nemo', ['/etc/lighttpd/'], False, TMO_MS_OPEN_DOC)); // ok; // test open file with nemo default no sudo;
  //Report_Test_Result(TriggerCommand('/etc/lighttpd/', 'nemo', ['/etc/lighttpd/'], True, TMO_MS_OPEN_DOC)); // ok, but WarnUsers failure; // test open dir with nemo with sudo;
  //Report_Test_Result(TriggerCommand('/etc/lighttpd/', 'nautilus', ['/etc/lighttpd/'], False, TMO_MS_OPEN_DOC)); // ok, but WarnUsers failure; // test dir file with nautilus default no sudo;
  //Report_Test_Result(TriggerCommand('/etc/lighttpd/', 'nautilus', ['/etc/lighttpd/'], True, TMO_MS_OPEN_DOC)); // ok, but WarnUsers failure; // test open dir with nautilus with sudo;

  {
    Conclusions:
    - kate crashes if ran with sudo;
    - nemo runs, but freezes locator if ran with sudo - internal process hangs?;
    - nautilus runs, but freezes locator regardless if ran with sudo or not - internal process hangs?; to check if same behavior if using separate thread;
  }
end;

procedure Tfrm_Main.mi_TrayOptionsClick(Sender: TObject);
begin
  mi_Options.Click;
end;

procedure Tfrm_Main.mi_TrayExitClick(Sender: TObject);
begin
  mi_Exit.Click;
end;

procedure Tfrm_Main.mi_AboutClick(Sender: TObject);
begin
  MessageDlg( Application.Title + #13#13 +
              '    Purpose: Unix "locate" command front-end.' + #13 +
              '    Author: Alex Tuduran' + #13 +
              '    License: Completely free' + #13 +
              '    Version: ' + APP_VER,
              mtInformation,
              [mbOk],
              0 );
end;

procedure Tfrm_Main.mi_OpenWithSelectAddClick(Sender: TObject);
var
  NumApps: Integer;
  FileName: String;
  App: String;

  function Open_With_App_Is_Registered(FileName: String): Boolean;
  var
    NumApps: Integer;
    i: Integer;
  begin
    Result := False;
    NumApps := Pers_OpenWith_Get_Num_Apps;
    for i := 0 to NumApps - 1 do
      if FileName = Pers_OpenWith_Get_App(i) then
      begin
        Result := True;
        Break;
      end;
  end;

begin
  if lv_Files.Items.Count < 1 then
    Exit;

  if not Assigned(lv_Files.ItemFocused) then
    Exit;

  dlg_OpenWith.FileName := '';
  dlg_OpenWith.InitialDir := ExtractFilePath(dlg_OpenWith.FileName);
  if dlg_OpenWith.Execute then
  begin
    App := dlg_OpenWith.FileName;

    // register app;
    if not Open_With_App_Is_Registered(App) then
    begin
      NumApps := Pers_OpenWith_Get_Num_Apps;
      Pers_OpenWith_Set_Num_Apps(NumApps + 1);
      Pers_OpenWith_Set_App(NumApps, App);
    end;

    // run app;
    FileName := lv_Files.ItemFocused.Caption;
    if not ExecuteCommand(Get_Home_Dir, App, [FileName], ac_SuperUser.Checked) then
      WarnUser(Format('Could not open "%s" with "%s": External failure.', [FileName, App]));
  end;
end;

procedure Tfrm_Main.mi_UpdateDBClick(Sender: TObject);
var
  CmdStatus: Boolean;
  DlgCaption: String;
begin
  DlgCaption := 'Update locate database';

  if not FSuppressUpdateDBDialogs then
    if MessageDlg(DlgCaption, 'This is a potentially long operation lasting seconds to minutes.' + #13#13 + 'Continue?', mtConfirmation, [mbYes, mbNo], 0) <> mrYes then
    begin
      MessageDlg(DlgCaption, 'Database was not updated.' + #13#13 + 'Operation was canceled by user.', mtWarning, [mbOk], 0);
      Exit;
    end;

  CmdStatus := False;
  try
    SetOperation('Updating database...');
    SetStatus('Busy');
    LockUI(True);
    Application.ProcessMessages;
    CmdStatus := ExecuteCommand('', 'updatedb', [], True); // updatedb requires sudo;
    Application.ProcessMessages;

    if CmdStatus and (Length(edt_SearchPattern.Text) > 0) then
    begin
      SetOperation('Updating current search...');
      SetStatus('Busy');
      ResetLocate;
      LocateFiles(edt_SearchPattern.Text, True);
    end;

    if not FSuppressUpdateDBDialogs then
      if CmdStatus then
        MessageDlg(DlgCaption, 'Database updated successfully.', mtInformation, [mbOk], 0)
      else
        MessageDlg(DlgCaption, 'Database could not be updated.' + #13#13 + 'Please open a terminal and manually run command "sudo updatedb".', mtWarning, [mbOk], 0);
  finally
    LockUI(False);
    SetStatus('Idle');
    SetOperation('');
  end;
end;

procedure Tfrm_Main.mi_ExitClick(Sender: TObject);
begin
  FCanClose := True;
  Close;
end;

procedure Tfrm_Main.mi_CopyFullNameToClipboardClick(Sender: TObject);
begin
  if lv_Files.Items.Count < 1 then
    Exit;

  if not Assigned(lv_Files.ItemFocused) then
    Exit;

  Clipboard.AsText := lv_Files.ItemFocused.Caption;
end;

procedure Tfrm_Main.mi_CopyNameOnlyToClipboardClick(Sender: TObject);
begin
  if lv_Files.Items.Count < 1 then
    Exit;

  if not Assigned(lv_Files.ItemFocused) then
    Exit;

  Clipboard.AsText := ExtractFileName(lv_Files.ItemFocused.Caption);
end;

procedure Tfrm_Main.mi_CopyPathToClipboardClick(Sender: TObject);
begin
  if lv_Files.Items.Count < 1 then
    Exit;

  if not Assigned(lv_Files.ItemFocused) then
    Exit;

  Clipboard.AsText := ExtractFilePath(lv_Files.ItemFocused.Caption);
end;

procedure Tfrm_Main.mi_OpenClick(Sender: TObject);
var
  App: String;
  FileName: String;
begin
  if lv_Files.Items.Count < 1 then
    Exit;

  if not Assigned(lv_Files.ItemFocused) then
    Exit;

  App := '';
  FileName := lv_Files.ItemFocused.Caption;
  if not OpenDocumentEx(FileName, ac_SuperUser.Checked, App) then // with os default handler;
    WarnUser(Format('Could not open "%s" (with OS default handler "%s"): External failure.', [FileName, App]));
end;

procedure Tfrm_Main.mi_OpenPathClick(Sender: TObject);
var
  App: String;
  Path: String;
begin
  if lv_Files.Items.Count < 1 then
    Exit;

  if not Assigned(lv_Files.ItemFocused) then
    Exit;

  App := Pers_Gen_Get_Open_Path_App;
  Path := ExtractFilePath(lv_Files.ItemFocused.Caption);
  if (Length(App) < 1) or
     (App = OPEN_PATH_OPT_OS_DEFAULT) then
  begin
    if not OpenDocumentEx(Path, ac_SuperUser.Checked) then // with os default handler;
      WarnUser(Format('Could not open "%s" (with OS default handler "%s"): External failure.', [Path, App]));
  end
  else
  begin
    if (LowerCase(App) = 'nautilus') or
       (LowerCase(App) = 'nemo') then
      App := LowerCase(App);

    if not TriggerCommand(Get_Home_Dir, App, [Path], ac_SuperUser.Checked, TMO_MS_OPEN_DOC) then
      WarnUser(Format('Could not open "%s" with "%s": External failure.', [Path, App]));
  end;
end;

procedure Tfrm_Main.mi_PropertiesClick(Sender: TObject);
const
  FILE_PROPERTIES_MSG: array [0..17] of String =
  (
    'A great file.',
    'Best file in the world.',
    'An amazing file.',
    'The super-file.',
    'A file like no other.',
    'Not a file you want to open.',
    'You don''t screw up with this file.',
    'A file to remember.',
    'The mother of all files.',
    'Can''t un-see one you''ve seen this file.',
    'Monster-file.',
    'A lousy-ass file.',
    'Not worth showing properties for this file.',
    'This file will keep you awake all night.',
    'The file that will change it all.',
    'You won''t believe how awesome this file is.',
    'This file is for babies',
    'Properties: Umm, agh, lots of properties..'
  );
begin
  MessageDlg(FILE_PROPERTIES_MSG[Random(Length(FILE_PROPERTIES_MSG))], mtInformation, [mbOK], 0);
end;

procedure Tfrm_Main.mnu_PopupFilesClose(Sender: TObject);
var
  i: Integer;
begin
  i := 0;
  while i < mi_OpenWith.Count do
    if mi_OpenWith.Items[i].Tag and OPEN_WITH_APP_MENU_ITEM_MASK = OPEN_WITH_APP_MENU_ITEM_MASK then
    begin
      mi_OpenWith.Items[i].Clear;
      mi_OpenWith.Items[i].Free;
    end
    else
      Inc(i);
end;

procedure Tfrm_Main.mnu_PopupFilesPopup(Sender: TObject);
var
  NumApps: Integer;
  Item: TMenuItem;
  App: String;
  i: Integer;
begin
  NumApps := Pers_OpenWith_Get_Num_Apps;

  if NumApps < 1 then
    Exit;

  for i := 0 to NumApps - 1 do
  begin
    App := Pers_OpenWith_Get_App(i);
    if FileExists(App) then
    begin
      Item := TMenuItem.Create(nil);
      Item.Caption := App;
      Item.Tag     := OPEN_WITH_APP_MENU_ITEM_MASK or i;
      Item.OnClick := OpenWithAppClick;
      mi_OpenWith.Add(Item);
    end;
  end;
end;

procedure Tfrm_Main.ti_MainClick(Sender: TObject);
begin
  mi_TrayNewSearchWindow.Click;
end;

procedure Tfrm_Main.tmr_PopupTimer(Sender: TObject);
begin
  if FShowMenu then
  begin
    FShowMenu := False;
    mnu_PopupFiles.PopUp(FLastX, FLastY);
  end;
end;

procedure Tfrm_Main.ti_MainDblClick(Sender: TObject);
begin
  mi_TrayNewSearchWindow.Click;
end;

procedure Tfrm_Main.OpenWithAppClick(Sender: TObject);
var
  Item: TMenuItem;
  AppIndex: Integer;
  App: String;
  FileName: String;
begin
  if lv_Files.Items.Count < 1 then
    Exit;

  if not Assigned(lv_Files.ItemFocused) then
    Exit;

  if not (Sender is TMenuItem) then
    Exit;

  Item := Sender as TMenuItem;
  if not (Item.Tag and OPEN_WITH_APP_MENU_ITEM_MASK = OPEN_WITH_APP_MENU_ITEM_MASK) then
    Exit;

  AppIndex := Item.Tag and not OPEN_WITH_APP_MENU_ITEM_MASK;
  if (AppIndex < 0) or (AppIndex > Pers_OpenWith_Get_Num_Apps - 1) then
    Exit;

  App := Pers_OpenWith_Get_App(AppIndex);
  if not FileExists(App) then
    Exit;

  FileName := lv_Files.ItemFocused.Caption;
  if not ExecuteCommand(Get_Home_Dir, App, [FileName], ac_SuperUser.Checked) then
    WarnUser(Format('Could not open "%s" with "%s": External failure.', [FileName, App]));
end;

procedure Tfrm_Main.Reset;
begin
  Width := FInitialW;
  Height := FInitialH;
  FCanClose := False;
  FLastX := 0;
  FLastY := 0;
  FShowMenu := False;

  ResetLocate;

  edt_SearchPattern.Text := '';
  lv_Files.Clear;
  lv_Files.ItemIndex := -1;
  sb_Main.Panels[0].Text := '';
  sb_Main.Panels[1].Text := '';

  LockUI(False);
  SetStatus('Idle');
  SetOperation('');
end;

procedure Tfrm_Main.ResetLocate;
begin
  FLastCommandParams := '';
  FLastCommandOutput := '';
end;

procedure Tfrm_Main.LockUI(Lock: Boolean);
begin
  sb_Main.Enabled := not Lock;
  edt_SearchPattern.Enabled := not Lock;
  btn_Locate.Enabled := not Lock;
  lv_Files.Enabled :=  not Lock;
  Application.ProcessMessages;
end;

procedure Tfrm_Main.SetOperation(Operation: String);
begin
  FOperation := Operation;

  Caption := Application.Title;

  if mi_SuperUser.Checked then
    Caption := Format('%s (Super-user mode)', [Caption]);

  if Length(Operation) > 0 then
    Caption := Format('%s - [%s] ', [Caption, Operation]);

  Application.ProcessMessages;
end;

function Tfrm_Main.GetOperation: String;
begin
  Result := FOperation;
end;

procedure Tfrm_Main.SetStatus(Status: String);
begin
  sb_Main.Panels[0].Text := Status;
  Application.ProcessMessages;
end;

function Tfrm_Main.GetStatus: String;
begin
  Result := sb_Main.Panels[0].Text;
end;

procedure Tfrm_Main.WarnUser(Msg: String);
begin
  WLog(Msg);
  if Pers_Gen_Get_Show_Op_Fail_Warns then
    MessageDlg(Msg, mtWarning, [mbOk], 0);
end;

function Tfrm_Main.GetUpdateDBMenuPath: String;
begin
  Result := Format( 'main menu -> %s -> %s',
                    [ Caption_To_Message(mi_Tools.Caption),
                      Caption_To_Message(mi_UpdateDB.Caption) ] );
end;

function Tfrm_Main.GetUpdateDBShortcut: String;
begin
  Result := ShortCutToText(mi_UpdateDB.ShortCut);
end;

function Tfrm_Main.GetUpdateDBDirections: String;
begin
  Result := Format('You can update the "locate" database from %s or by pressing %s.', [GetUpdateDBMenuPath, GetUpdateDBShortcut]);
end;

function Tfrm_Main.GetSuperUserMenuPath: String;
begin
  Result := Format( 'main menu -> %s -> %s',
                    [ Caption_To_Message(mi_Tools.Caption),
                      Caption_To_Message(mi_SuperUser.Caption) ] );
end;

function Tfrm_Main.GetSuperUserDirections: String;
begin
  Result := Format('Try impersonating super-user by checking %s.', [GetSuperUserMenuPath]);
end;

procedure Tfrm_Main.ILog(Msg: String);
begin
  ULogger.ILog(Msg);
end;

procedure Tfrm_Main.WLog(Msg: String);
begin
  ULogger.WLog(Msg);
end;

procedure Tfrm_Main.ELog(Msg: String; Routine: String);
begin
  ULogger.ELog(Msg, Routine);
end;

function Tfrm_Main.ExecuteCommand(Directory: String; Command: String; Parameters: array of String; SuperUser: Boolean): Boolean;
var
  CmdOutput: String;
begin
  CmdOutput := '';
  Result := ExecuteCommand(Directory, Command, Parameters, SuperUser, CmdOutput);
end;

function Tfrm_Main.ExecuteCommand(Directory: String; Command: String; Parameters: array of String; SuperUser: Boolean; var Output: String): Boolean;
var
  Process: TProcess;
  i: Integer;
  ExitStatus: Integer;
  Cmd: String;
  T0: Integer;
  T1: Integer;
begin
  Process := TProcess.Create(nil);
  if SuperUser then
  begin
    Process.Executable := 'sudo';
    Process.Parameters.Add(Command);
  end
  else
    Process.Executable := Command;

  for i := 0 to Length(Parameters) - 1 do
    Process.Parameters.Add(Parameters[i]);

  Process.CurrentDirectory := Directory;

  Cmd := Process.Executable;
  for i := 0 to Process.Parameters.Count - 1 do
    Cmd := Cmd + ' ' + Process.Parameters[i];
  ILog(Format('Will execute command "%s" in dir "%s"...', [Cmd, Directory]));

  ExitStatus := 0;
  Output := '';
  T0 := GetTickCount;
  Result := (Internal_Execute_Command(Process, Output, ExitStatus) = 0);
  T1 := GetTickCount;
  ILog(Format('Execution of command "%s" in dir "%s" returned with exit status %d after %d ms', [Cmd, Directory, ExitStatus, T1 - T0]));

  if ExitStatus <> 0 then
    Result := False;
end;

function Tfrm_Main.TriggerCommand(Directory: String; Command: String; Parameters: array of String; SuperUser: Boolean): Boolean;
begin
  Result := TriggerCommand(Directory, Command, Parameters, SuperUser, TMO_NONE);
end;

function Tfrm_Main.TriggerCommand(Directory: String; Command: String; Parameters: array of String; SuperUser: Boolean; TimeoutMS: Integer): Boolean;
var
  Process: TProcess;
  i: Integer;
  ExitStatus: Integer;
  Cmd: String;
  T0: Integer;
  T1: Integer;
begin
  Process := TProcess.Create(nil);
  if SuperUser then
  begin
    Process.Executable := 'sudo';
    Process.Parameters.Add(Command);
  end
  else
    Process.Executable := Command;

  for i := 0 to Length(Parameters) - 1 do
    Process.Parameters.Add(Parameters[i]);

  Process.CurrentDirectory := Directory;

  Cmd := Process.Executable;
  for i := 0 to Process.Parameters.Count - 1 do
    Cmd := Cmd + ' ' + Process.Parameters[i];
  ILog(Format('Will trigger command "%s" in dir "%s" with timeout of %d ms...', [Cmd, Directory, TimeoutMS]));

  ExitStatus := 0;
  T0 := GetTickCount;
  Result := (Internal_Trigger_Command(Process, ExitStatus, TimeoutMS) = 0);
  T1 := GetTickCount;
  ILog(Format('Triggering of command "%s" in dir "%s" with timeout of %d returned with exit status %d after %d ms', [Cmd, Directory, TimeoutMS, ExitStatus, T1 - T0]));

  if ExitStatus <> 0 then
    Result := False;
end;

function Tfrm_Main.OpenDocumentEx(FileName: String; SuperUser: Boolean): Boolean;
var
  OSHandlerApp: String;
begin
  OSHandlerApp := '';
  Result := OpenDocumentEx(FileName, SuperUser, OSHandlerApp);
end;

function Tfrm_Main.OpenDocumentEx(FileName: String; SuperUser: Boolean; var OSHandlerApp: String): Boolean;
begin
  {
    Alex Tuduran:

    - based on Lazarus implementation of OpenDocument();
    - adapted to allow superuser parameter;
  }

  //ShowMessage('FileName=[' + FileName + ']');

  Result := False;
  if not FileExistsUTF8(FileName) then
    Exit;

  OSHandlerApp := FindFilenameOfCmd('xdg-open'); // Portland OSDL/FreeDesktop standard on Linux;
  if OSHandlerApp = '' then
    OSHandlerApp := FindFilenameOfCmd('kfmclient'); // KDE command;
  if OSHandlerApp = '' then
    OSHandlerApp := FindFilenameOfCmd('gnome-open'); // GNOME command;
  if OSHandlerApp = '' then
    Exit;

  Result := TriggerCommand(Get_Home_Dir, OSHandlerApp, [FileName], SuperUser, TMO_MS_OPEN_DOC);
end;

procedure Tfrm_Main.LocateFiles(SearchPattern: String; JustUpdatedDB: Boolean);
const
  IDX_TOKEN_COMMAND_PARAM = 0;
  LOCATE_CMD = 'locate';
var
  CmdOutput: String;
  Files: TStringList;
  i: Integer;
  Tokens: TStringList;
  CommandParams: String;
  DlgMsg: String;
begin
  SearchPattern := Trim(SearchPattern);
  if Length(SearchPattern) < 1 then
    Exit;

  Tokens := Splitter_Split_Strings(SearchPattern, ' ');
  Tokens.BeginUpdate;
  i := 0;
  while i < Tokens.Count do
    if Length(Trim(Tokens[i])) < 1 then
      Tokens.Delete(i)
    else
      Inc(i);
  Tokens.EndUpdate;
  CommandParams := Tokens[IDX_TOKEN_COMMAND_PARAM];

  if ac_ExcludeCBE.Checked then
    Tokens.Add('!cbe');

  Files := TStringList.Create;

  // get the file list from the output of the executed locate command if command parameter is a different one;
  if FLastCommandParams <> CommandParams then
  begin
    CmdOutput := '';
    if not ExecuteCommand('/', LOCATE_CMD, [CommandParams], False, CmdOutput) then // specifially use '/' to locate in the root context; // locate doesn't require sudo
    begin
      CmdOutput := '';
      DlgMsg := Format('Nothing was found for "%s".', [CommandParams]);
      if not JustUpdatedDB then
        DlgMsg := DlgMsg + #13#13 + Format( 'You should update the "locate" database.' + #13#13 +
                                            '%s',
                                            [GetUpdateDBDirections] );
      MessageDlg(DlgMsg, mtInformation, [mbOk], 0);
    end;
    Files.Text := CmdOutput;
    CmdOutput := Files.Text; // because the string list might change the text property;

    FLastCommandParams := CommandParams;
    FLastCommandOutput := CmdOutput;
  end

  // get the file list from the last output of locate command if command parameter is the last one;
  else
    Files.Text := FLastCommandOutput;

  // apply filtering according to the user input;
  for i := 1 to Tokens.Count - 1 do
    FilterList(Files, Tokens[i]);

  Tokens.Free;

  // transfer entries to the list view;
  lv_Files.Items.BeginUpdate;
  lv_Files.Clear;
  for i := 0 to Files.Count - 1 do
    if FileExists(Files[i]) then
      lv_Files.AddItem(Files[i], nil);
  lv_Files.Items.EndUpdate;
  Application.ProcessMessages;

  Files.Free;

  // select first item;
  if lv_Files.Items.Count > 0 then
    lv_Files.ItemIndex := 0;

  // update the entry count in the status bar;
  sb_Main.Panels[1].Text := Format('%d files', [lv_Files.Items.Count]);
end;

procedure Tfrm_Main.FilterList(List: TStringList; Keyword: String);
var
  i: Integer;
  KeywordLC: String;
  HasKeyword: Boolean;
  IsInvKeyword: Boolean;
begin
  KeywordLC := LowerCase(Keyword);
  IsInvKeyword := KeywordLC[1] = '!';
  If IsInvKeyword then
    Delete(KeywordLC, 1, 1);

  if Length(KeyWord) < 1 then
    Exit;

  List.BeginUpdate;
  i := 0;
  while i < List.Count do
  begin
    HasKeyword := Pos(KeywordLC, LowerCase(List[i])) <> 0;
    if (not HasKeyword and not IsInvKeyword) or // remove if does not contain the keyword when keyword is not inverted;
       (HasKeyword and IsInvKeyword) then // remove if contains the keyword when keyword is inverted;
      List.Delete(i)
    else
      Inc(i);
  end;
  List.EndUpdate;
end;

procedure Tfrm_Main.btn_LocateClick(Sender: TObject);
begin
  try
    SetOperation('Fetching...');
    SetStatus('Busy');
    LockUI(True);
    LocateFiles(edt_SearchPattern.Text, False);
  finally
    LockUI(False);
    SetStatus('Idle');
    SetOperation('');
  end;
end;

procedure Tfrm_Main.ac_OptionsExecute(Sender: TObject);
var
  Form: Tfrm_Options;
  i: Integer;
begin
  Form := Tfrm_Options.Create(nil);

  Form.pc_Main.PageIndex := Pers_Gen_Get_Cfg_Page_Index;
  Form.SetOpenWith(Pers_Gen_Get_Open_Path_App);
  Form.cb_ShowOpFailWarns.Checked := Pers_Gen_Get_Show_Op_Fail_Warns;

  for i := 0 to Pers_OpenWith_Get_Num_Apps - 1 do
    if FileExists(Pers_OpenWith_Get_App(i)) then
      Form.lb_OpenWithApps.Items.Add(Pers_OpenWith_Get_App(i));

  if Form.ShowModal = mrOk then
  begin
    Pers_Gen_Set_Cfg_Page_Index(Form.pc_Main.PageIndex);
    Pers_Gen_Set_Open_Path_App(Form.GetOpenWith);
    Pers_Gen_Set_Show_Op_Fail_Warns(Form.cb_ShowOpFailWarns.Checked);

    Pers_OpenWith_Set_Num_Apps(Form.lb_OpenWithApps.Count);
    for i := 0 to Form.lb_OpenWithApps.Count -1 do
      Pers_OpenWith_Set_App(i, Form.lb_OpenWithApps.Items[i]);
  end;

  Form.Free;
end;

procedure Tfrm_Main.ac_SuperUserExecute(Sender: TObject);
const
  SUPER_USER_DIPLAY_PREFIX = '(SUDO) ';
begin
  ac_SuperUser.Checked := not ac_SuperUser.Checked;
  Pers_Gen_Set_Super_User(ac_SuperUser.Checked);

  mi_Open.Caption                        := '&Open';
  mi_OpenPath.Caption                    := 'Open &Path';
  mi_OpenWith.Caption                    := 'Open &With...';
  mi_Delete.Caption                      := '&Delete';

  if ac_SuperUser.Checked then
  begin
    mi_Open.Caption                        := SUPER_USER_DIPLAY_PREFIX + mi_Open.Caption;
    mi_OpenPath.Caption                    := SUPER_USER_DIPLAY_PREFIX + mi_OpenPath.Caption;
    mi_OpenWith.Caption                    := SUPER_USER_DIPLAY_PREFIX + mi_OpenWith.Caption;
    mi_Delete.Caption                      := SUPER_USER_DIPLAY_PREFIX + mi_Delete.Caption;
  end;

  if ac_SuperUser.Checked then
    lv_Files.Font.Color := clRed
  else
    lv_Files.Font.Color := clDefault;

  SetOperation(GetOperation);
end;

procedure Tfrm_Main.ac_NewSearchWindowExecute(Sender: TObject);
var
  Form: Tfrm_Main;
  Pos: TPoint;

  function Find_New_Form_Position: TPoint;
  const
    FORM_CASCADE_STEP = 32;
    FORM_CASCADE_MARGIN = 80;
  var
    LastForm: Tfrm_Main;
  begin
    if VisibleInstances.Count = 0 then
    begin
      Result.X := (Screen.Width  - Width ) div 2;
      Result.Y := (Screen.Height - Height) div 2;
    end
    else
    begin
      LastForm := VisibleInstances[VisibleInstances.Count - 1];

      Result.X := LastForm.Left + FORM_CASCADE_STEP;
      Result.Y := LastForm.Top  + FORM_CASCADE_STEP;

      if Result.X + LastForm.Width >= Screen.Width - FORM_CASCADE_MARGIN then
       Result.X := Result.X mod LastForm.Width;

      if Result.Y + LastForm.Height >= Screen.Height - FORM_CASCADE_MARGIN then
       Result.Y := Result.Y mod LastForm.Height;
    end;
  end;

begin
  Pos := Find_New_Form_Position;
  if not Visible then
  begin
    // reset and show first main form if hidden;
    Reset;
    Show;
    Left := Pos.X;
    Top  := Pos.Y;
  end
  else
  begin
    // create a new main form and show it if first main form is visible;
    Application.CreateForm(Tfrm_Main, Form);
    Form.Show;
    Form.Left := Pos.X;
    Form.Top  := Pos.Y;
  end;
end;

procedure Tfrm_Main.ac_ExcludeCBEExecute(Sender: TObject);
begin
  ac_ExcludeCBE.Checked := not ac_ExcludeCBE.Checked;
  Pers_Gen_Set_Exclude_CBE(ac_ExcludeCBE.Checked);
end;

procedure Tfrm_Main.edt_SearchPatternKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  Shift := Shift;

  if Key = VK_RETURN then
    btn_Locate.Click;
end;

procedure Tfrm_Main.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
{$ifdef DEBUG}
  CloseAction := CloseAction;
  Application.Terminate;
{$else}
  if Self = frm_Main then
  begin
    if not FCanClose then
    begin
      CloseAction := caNone;
      Hide;
    end;
  end
  else
    CloseAction := caFree;
{$endif}
end;

initialization
begin
  VisibleInstances := TList.Create;
end;

finalization
begin
  FreeAndNil(VisibleInstances);
end;

end.


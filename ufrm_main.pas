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
  Menus,
  ExtCtrls,
  Clipbrd,

  UStringSplitter,
  UPersistency;

const
  APP_VER = '0.4-alpha';

type

  { Tfrm_Main }

  Tfrm_Main = class(TForm)
    btn_Locate: TButton;
    edt_SearchPattern: TEdit;
    MenuItem3: TMenuItem;
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
    procedure btn_LocateClick(Sender: TObject);
    procedure edt_SearchPatternKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormHide(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure lv_FilesContextPopup(Sender: TObject; MousePos: TPoint; var Handled: Boolean);
    procedure lv_FilesDblClick(Sender: TObject);
    procedure lv_FilesDrawItem(Sender: TCustomListView; AItem: TListItem; ARect: TRect; AState: TOwnerDrawState);
    procedure lv_FilesKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure lv_FilesMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure mi_TrayNewSearchWindowClick(Sender: TObject);
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
    procedure mi_OptionsClick(Sender: TObject);
    procedure mi_PropertiesClick(Sender: TObject);
    procedure mnu_PopupFilesClose(Sender: TObject);
    procedure mnu_PopupFilesPopup(Sender: TObject);
    procedure tmr_PopupTimer(Sender: TObject);
    procedure ti_MainDblClick(Sender: TObject);
  private
    { private declarations }
    FInitialW: Integer;
    FInitialH: Integer;
    FCanClose: Boolean;
    FLastX: Integer;
    FLastY: Integer;
    FShowMenu: Boolean;
    FLastCommandParam: String;
    FLastCommandOutput: String;

    procedure OpenWithAppClick(Sender: TObject);

    procedure Reset;
    procedure ResetLocate;
    procedure LockUI(Lock: Boolean);
    procedure SetOperation(Operation: String);
    procedure SetStatus(Status: String);

    procedure LocateFiles(SearchPattern: String);
    procedure FilterList(List: TStringList; Keyword: String);
  public
    { public declarations }
  end;

const
  OPEN_WITH_APP_MENU_ITEM_MASK = $10000;

var
  frm_Main: Tfrm_Main;
  VisibleInstances: TList;

implementation

uses
  ufrm_options;

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

procedure Tfrm_Main.FormShow(Sender: TObject);
begin
  VisibleInstances.Add(Self);
  if edt_SearchPattern.IsVisible then
    edt_SearchPattern.SetFocus;
end;

procedure Tfrm_Main.lv_FilesContextPopup(Sender: TObject; MousePos: TPoint; var Handled: Boolean);
var
  HasSelectedFile: Boolean;
begin
  HasSelectedFile := (lv_Files.Items.Count > 0) and (lv_Files.ItemIndex <> -1);
  mi_Open.Enabled                           := HasSelectedFile;
  mi_OpenPath.Enabled                       := HasSelectedFile;
  mi_OpenWith.Enabled                       := HasSelectedFile;
  mi_CopyFullNameToClipboard.Enabled        := HasSelectedFile;
  mi_CopyPathToClipboard.Enabled            := HasSelectedFile;
  mi_CopyNameOnlyToClipboard.Enabled        := HasSelectedFile;
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
  if Key = VK_RETURN then
    mi_Open.Click;
end;

procedure Tfrm_Main.lv_FilesMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  P: TPoint;
begin
  if Button = mbRight then
  begin
    P := lv_Files.ClientToScreen(Point(X, Y));
    FLastX := P.X;
    FLastY := P.Y;
    FShowMenu := True;
  end;
end;

procedure Tfrm_Main.mi_TrayNewSearchWindowClick(Sender: TObject);
var
  Form: Tfrm_Main;
  LastForm: Tfrm_Main;
  X, Y: Integer;
  i: Integer;
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
    //VisibleInstances.Add(Form);
  end;
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
              '    Purpose: Unix locate command front-end.' + #13 +
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
  S: AnsiString;

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
    if not Open_With_App_Is_Registered(dlg_OpenWith.FileName) then
    begin
      NumApps := Pers_OpenWith_Get_Num_Apps;
      Pers_OpenWith_Set_Num_Apps(NumApps + 1);
      Pers_OpenWith_Set_App(NumApps, dlg_OpenWith.FileName);
    end;

    FileName := lv_Files.ItemFocused.Caption;
    S := '';
    RunCommandInDir(ExtractFilePath(FileName), dlg_OpenWith.FileName + ' ' + FileName, S);
  end;
end;

procedure Tfrm_Main.mi_UpdateDBClick(Sender: TObject);
var
  CmdStatus: Boolean;
  S: AnsiString;
begin
  if MessageDlg('This is a potentially long operation lasting seconds to minutes.' + #13#13 + 'Continue?', mtConfirmation, [mbYes, mbNo], 0) <> mrYes then
  begin
    MessageDlg('Database was not updated.' + #13#13 + 'Operation was canceled by user.', mtWarning, [mbOk], 0);
    Exit;
  end;

  try
    SetOperation('Updating database...');
    SetStatus('Busy');
    LockUI(True);
    Application.ProcessMessages;
    CmdStatus := RunCommand('sudo updatedb', S);
    Application.ProcessMessages;
    if CmdStatus then
      MessageDlg('Database updated successfully.', mtInformation, [mbOk], 0)
    else
      MessageDlg('Database could not be updated.' + #13#13 + 'Please open a terminal and manually run command "sudo updatedb".', mtWarning, [mbOk], 0);
  finally
    // locate output might be different after an update-db;
    ResetLocate;

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
begin
  if lv_Files.Items.Count < 1 then
    Exit;

  if not Assigned(lv_Files.ItemFocused) then
    Exit;

  OpenDocument(lv_Files.ItemFocused.Caption);
end;

procedure Tfrm_Main.mi_OpenPathClick(Sender: TObject);
var
  S: AnsiString;
  OpenPathApp: String;
begin
  if lv_Files.Items.Count < 1 then
    Exit;

  if not Assigned(lv_Files.ItemFocused) then
    Exit;

  S := '';
  OpenPathApp := Pers_Gen_Get_Open_Path_App;
  if (Length(OpenPathApp) < 1) or
     (OpenPathApp = OPEN_PATH_OPT_OS_DEFAULT)then
    OpenDocument(ExtractFilePath(lv_Files.ItemFocused.Caption)) // os default;
  else
  begin
    if (LowerCase(OpenPathApp) = 'nautilus') or
       (LowerCase(OpenPathApp) = 'nemo') then
      OpenPathApp := LowerCase(OpenPathApp);
    RunCommand(OpenPathApp + ' ' + ExtractFilePath(lv_Files.ItemFocused.Caption), S);
  end;
end;

procedure Tfrm_Main.mi_OptionsClick(Sender: TObject);
var
  Form: Tfrm_Options;
  i: Integer;
begin
  Form := Tfrm_Options.Create(nil);

  Form.pc_Main.PageIndex := Pers_Gen_Get_Cfg_Page_Index;
  Form.SetOpenWith(Pers_Gen_Get_Open_Path_App);
  for i := 0 to Pers_OpenWith_Get_Num_Apps - 1 do
    if FileExists(Pers_OpenWith_Get_App(i)) then
      Form.lb_OpenWithApps.Items.Add(Pers_OpenWith_Get_App(i));

  if Form.ShowModal = mrOk then
  begin
    Pers_Gen_Set_Cfg_Page_Index(Form.pc_Main.PageIndex);
    Pers_Gen_Set_Open_Path_App(Form.GetOpenWith);
    Pers_OpenWith_Set_Num_Apps(Form.lb_OpenWithApps.Count);
    for i := 0 to Form.lb_OpenWithApps.Count -1 do
      Pers_OpenWith_Set_App(i, Form.lb_OpenWithApps.Items[i]);
  end;

  Form.Free;
end;

procedure Tfrm_Main.mi_PropertiesClick(Sender: TObject);
const
  FILE_PROPERTIES_MSG: array [0..14] of String =
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
    'The file that will change it all.'
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
  S: AnsiString;
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
  S := '';
  RunCommandInDir(ExtractFilePath(FileName), App + ' ' + FileName, S);
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
  FLastCommandParam := '';
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
  if Length(Operation) < 1 then
    Caption := Format('%s', [Application.Title])
  else
    Caption := Format('%s - [%s] ', [Application.Title, Operation]);
  Application.ProcessMessages;
end;

procedure Tfrm_Main.SetStatus(Status: String);
begin
  sb_Main.Panels[0].Text := Status;
  Application.ProcessMessages;
end;

procedure Tfrm_Main.LocateFiles(SearchPattern: String);
const
  IDX_TOKEN_COMMAND_PARAM = 0;
var
  Cmd: String;
  CmdOutput: AnsiString;
  Files: TStringList;
  i: Integer;
  Tokens: TStringList;
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

  Files := TStringList.Create;

  // get the file list from the output of the executed locate command if command parameter is a different one;
  if FLastCommandParam <> Tokens[IDX_TOKEN_COMMAND_PARAM] then
  begin
    Cmd := 'locate ' + Tokens[IDX_TOKEN_COMMAND_PARAM];
    CmdOutput := '';
    if not RunCommandInDir('/', Cmd, CmdOutput) then
      CmdOutput := '';
    Files.Text := CmdOutput;

    FLastCommandParam := Tokens[IDX_TOKEN_COMMAND_PARAM];
    FLastCommandOutput := CmdOutput;
  end

  // get the file list from the last output of locate command if command parameter is the last one;
  else
    Files.Text := FLastCommandOutput;

  for i := 1 to Tokens.Count - 1 do
    FilterList(Files, Tokens[i]);

  Tokens.Free;

  lv_Files.Items.BeginUpdate;
  lv_Files.Clear;
  for i := 0 to Files.Count - 1 do
    lv_Files.AddItem(Files[i], nil);
  lv_Files.Items.EndUpdate;
  Application.ProcessMessages;

  Files.Free;

  if lv_Files.Items.Count > 0 then
    lv_Files.ItemIndex := 0;
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
    LocateFiles(edt_SearchPattern.Text);
    sb_Main.Panels[1].Text := Format('%d files', [lv_Files.Items.Count]);
  finally
    LockUI(False);
    SetStatus('Idle');
    SetOperation('');
  end;
end;

procedure Tfrm_Main.edt_SearchPatternKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = VK_RETURN then
    btn_Locate.Click;
end;

procedure Tfrm_Main.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
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


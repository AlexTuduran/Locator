unit ufrm_options;

{$mode objfpc}{$H+}

interface

uses
  Classes,
  SysUtils,
  FileUtil,
  Forms,
  Controls,
  Graphics,
  Dialogs,
  ComCtrls,
  StdCtrls,
  LCLType;

type

  { Tfrm_Options }

  Tfrm_Options = class(TForm)
    btn_Ok: TButton;
    btn_Cancel: TButton;
    btn_Delete: TButton;
    cb_OpenPathWith: TComboBox;
    cb_ShowOpFailWarns: TCheckBox;
    edt_OpenPathWith: TEdit;
    lbl_OpenPathWith: TLabel;
    lb_OpenWithApps: TListBox;
    pc_Main: TPageControl;
    ts_General: TTabSheet;
    ts_OpenWith: TTabSheet;
    procedure btn_DeleteClick(Sender: TObject);
    procedure cb_OpenPathWithChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  private
    { private declarations }
  public
    { public declarations }
    function GetOpenWith: String;
    procedure SetOpenWith(Value: String);
  end;

const
  OPEN_PATH_OPT_OS_DEFAULT   = 'OS default';
  OPEN_PATH_OPT_OTHER        = 'Other...';

implementation

{$R *.lfm}

{ Tfrm_Options }

function Get_Root_Path: String;
begin
  Result := '.';
end;

procedure Tfrm_Options.FormCreate(Sender: TObject);
begin
  Caption := 'Options';

  edt_OpenPathWith.Text := '';
  cb_OpenPathWithChange(cb_OpenPathWith);
end;

procedure Tfrm_Options.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  Shift := Shift;

  if Key = VK_ESCAPE then
    Close;
end;

function Tfrm_Options.GetOpenWith: String;
begin
  if cb_OpenPathWith.ItemIndex = cb_OpenPathWith.Items.IndexOf(OPEN_PATH_OPT_OTHER) then
    Result := edt_OpenPathWith.Text
  else
    Result := cb_OpenPathWith.Text;
end;

procedure Tfrm_Options.SetOpenWith(Value: String);
begin
  if Length(Value) < 1 then
    cb_OpenPathWith.ItemIndex := cb_OpenPathWith.Items.IndexOf(OPEN_PATH_OPT_OS_DEFAULT)
  else
  begin
    cb_OpenPathWith.ItemIndex := cb_OpenPathWith.Items.IndexOf(Value);
    if cb_OpenPathWith.ItemIndex = -1 then
    begin
      cb_OpenPathWith.ItemIndex := cb_OpenPathWith.Items.IndexOf(OPEN_PATH_OPT_OTHER);
      cb_OpenPathWithChange(cb_OpenPathWith);
      edt_OpenPathWith.Text := Value;
    end;
  end;
end;

procedure Tfrm_Options.cb_OpenPathWithChange(Sender: TObject);
begin
  edt_OpenPathWith.Visible := (cb_OpenPathWith.ItemIndex = cb_OpenPathWith.Items.IndexOf(OPEN_PATH_OPT_OTHER));
end;

procedure Tfrm_Options.btn_DeleteClick(Sender: TObject);
var
  i: Integer;
begin
  lb_OpenWithApps.Items.BeginUpdate;
  i := 0;
  while i < lb_OpenWithApps.Count do
    if lb_OpenWithApps.Selected[i] then
      lb_OpenWithApps.Items.Delete(i)
    else
      Inc(i);
  lb_OpenWithApps.Items.EndUpdate;
end;

end.


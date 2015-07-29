unit UPersistency;

(******************************************************************************
 * Description: System persistency services                                   *   
 * Author: Alexandru Tuduran                                                  *
 * Contact: mp_nova_2004@yahoo.com                                            *
( *****************************************************************************)

interface

{$warn UNIT_PLATFORM OFF}
{$warn SYMBOL_PLATFORM OFF}

uses
  Forms,
  SysUtils,
  IniFiles;

  function Pers_Gen_Get_Cfg_Page_Index: Integer;
  procedure Pers_Gen_Set_Cfg_Page_Index(Value: Integer);
  function Pers_Gen_Get_WndX: Integer;
  procedure Pers_Gen_Set_WndX(Value: Integer);
  function Pers_Gen_Get_WndY: Integer;
  procedure Pers_Gen_Set_WndY(Value: Integer);
  function Pers_Gen_Get_WndW: Integer;
  procedure Pers_Gen_Set_WndW(Value: Integer);
  function Pers_Gen_Get_WndH: Integer;
  procedure Pers_Gen_Set_WndH(Value: Integer);
  function Pers_Gen_Get_Open_Path_App: String;
  procedure Pers_Gen_Set_Open_Path_App(Value: String);
  function Pers_Gen_Get_Show_Op_Fail_Warns: Boolean;
  procedure Pers_Gen_Set_Show_Op_Fail_Warns(Value: Boolean);

  function Pers_OpenWith_Get_Num_Apps: Integer;
  procedure Pers_OpenWith_Set_Num_Apps(Value: Integer);
  function Pers_OpenWith_Get_App(Index: Integer): String;
  procedure Pers_OpenWith_Set_App(Index: Integer; Value: String);

implementation

const
  INI_GEN_SECTION     = 'General';
  INI_OW_SECTION      = 'OpenWith';

{ Generic routines }

function Get_App_Path: String;
begin
  Result := ExtractFilePath(Application.ExeName);
end;

function Get_Cfg_File: TIniFile;
begin
  Result := TIniFile.Create(Get_App_Path + 'settings.cfg');
end;

procedure Write_Integer(Section: String; Ident: String; Value: Integer);
begin
  with Get_Cfg_File do
  begin
    WriteInteger(Section, Ident, Value);
    Free;
  end;
end;

function Read_Integer(Section: String; Ident: String; Default: Integer): Integer;
begin
  with Get_Cfg_File do
  begin
    Result := ReadInteger(Section, Ident, Default);
    Free;
  end;
end;

procedure Write_Boolean(Section: String; Ident: String; Value: Boolean);
begin
  with Get_Cfg_File do
  begin
    WriteBool(Section, Ident, Value);
    Free;
  end;
end;

function Read_Boolean(Section: String; Ident: String; Default: Boolean): Boolean;
begin
  with Get_Cfg_File do
  begin
    Result := ReadBool(Section, Ident, Default);
    Free;
  end;
end;

procedure Write_String(Section: String; Ident: String; Value: String);
begin
  with Get_Cfg_File do
  begin
    WriteString(Section, Ident, Value);
    Free;
  end;
end;

function Read_String(Section: String; Ident: String; Default: String): String;
begin
  with Get_Cfg_File do
  begin
    Result := ReadString(Section, Ident, Default);
    Free;
  end;
end;

{ Specialized routines - general }

function Pers_Gen_Get_Cfg_Page_Index: Integer;
begin
  Result := Read_Integer(INI_GEN_SECTION, 'Cfg_Page_Index', 0);
end;

procedure Pers_Gen_Set_Cfg_Page_Index(Value: Integer);
begin
  Write_Integer(INI_GEN_SECTION, 'Cfg_Page_Index', Value);
end;

function Pers_Gen_Get_WndX: Integer;
begin
  Result := Read_Integer(INI_GEN_SECTION, 'Wnd_X', -1);
end;

procedure Pers_Gen_Set_WndX(Value: Integer);
begin
  Write_Integer(INI_GEN_SECTION, 'Wnd_X', Value);
end;

function Pers_Gen_Get_WndY: Integer;
begin
  Result := Read_Integer(INI_GEN_SECTION, 'Wnd_Y', -1);
end;

procedure Pers_Gen_Set_WndY(Value: Integer);
begin
  Write_Integer(INI_GEN_SECTION, 'Wnd_Y', Value);
end;

function Pers_Gen_Get_WndW: Integer;
begin
  Result := Read_Integer(INI_GEN_SECTION, 'Wnd_W', -1);
end;

procedure Pers_Gen_Set_WndW(Value: Integer);
begin
  Write_Integer(INI_GEN_SECTION, 'Wnd_W', Value);
end;

function Pers_Gen_Get_WndH: Integer;
begin
  Result := Read_Integer(INI_GEN_SECTION, 'Wnd_H', -1);
end;

procedure Pers_Gen_Set_WndH(Value: Integer);
begin
  Write_Integer(INI_GEN_SECTION, 'Wnd_H', Value);
end;

function Pers_Gen_Get_Show_Op_Fail_Warns: Boolean;
begin
  Result := Read_Boolean(INI_GEN_SECTION, 'Show_Op_Fail_Warns', True);
end;

procedure Pers_Gen_Set_Show_Op_Fail_Warns(Value: Boolean);
begin
  Write_Boolean(INI_GEN_SECTION, 'Show_Op_Fail_Warns', Value);
end;

{ Specialized routines - open with }

function Pers_Gen_Get_Open_Path_App: String;
begin
  Result := Read_String(INI_GEN_SECTION, 'Open_Path_App', '');
end;

procedure Pers_Gen_Set_Open_Path_App(Value: String);
begin
  Write_String(INI_GEN_SECTION, 'Open_Path_App', Value);
end;

function Pers_OpenWith_Get_Num_Apps: Integer;
begin
  Result := Read_Integer(INI_OW_SECTION, 'Num_Open_With_Apps', 0);
end;

procedure Pers_OpenWith_Set_Num_Apps(Value: Integer);
begin
  Write_Integer(INI_OW_SECTION, 'Num_Open_With_Apps', Value);
end;

function Pers_OpenWith_Get_App(Index: Integer): String;
begin
  Result := Read_String(INI_OW_SECTION, Format('Open_With_App_%d', [Index]), '');
end;

procedure Pers_OpenWith_Set_App(Index: Integer; Value: String);
begin
  Write_String(INI_OW_SECTION, Format('Open_With_App_%d', [Index]), Value);
end;

end.

unit ULogger;

(******************************************************************************
 * Description: Logging service                                               *
 * Author: Alexandru Tuduran                                                  *
 * Contact: mp_nova_2004@yahoo.com                                            *
 ******************************************************************************)

interface

{$DEFINE USE_DEBUGGING} //enable or disable this;
{$IFDEF USE_DEBUGGING}
uses
  SysUtils, Forms;
{$ENDIF}

  procedure Log(Msg: String);
  procedure ILog(Msg: String);
  procedure WLog(Msg: String);
  procedure ELog(Msg: String; Routine: String);

implementation

const
  MAX_LOG_COUNTER = 2000000000; // make it an obvious value;

{$IFDEF USE_DEBUGGING}
var
  LogCounter: Integer;
{$ENDIF}

{ Interface routines }

procedure Log(Msg: String);
{$IFDEF USE_DEBUGGING}
var
  F: Text;
  FN: String;
  T: TSystemTime;
  TStr: String;
  i: Integer;
{$ENDIF}
begin
  {$IFDEF USE_DEBUGGING}
  FN := ExtractFilePath(Application.ExeName) + 'app.log';
  AssignFile(F, FN);
  if FileExists(FN) then
    Append(F)
  else
    ReWrite(F);

  if Length(Msg) > 0 then
  begin
    T.Year         := 0;
    T.Month        := 0;
    T.Day          := 0;
    T.Hour         := 0;
    T.Minute       := 0;
    T.Second       := 0;
    T.Millisecond  := 0;
    GetLocalTime(T);
    TStr := Format('%2d.%2d.%2d|%2d:%2d:%2d.%3d', [T.Year, T.Month, T.Day, T.Hour, T.Minute, T.Second, T.Millisecond]);
    for i := 1 to Length(TStr) do
      if TStr[i] = ' ' then
        TStr[i] := '0';
    WriteLn(F, Format('%s|%10d|%s', [TStr, LogCounter, Msg]));
    LogCounter := (LogCounter + 1) mod MAX_LOG_COUNTER;
  end
  else
    WriteLn(F);

  Flush(F);
  Close(F);
  {$ENDIF}
end;

procedure ILog(Msg: String);
begin
  {$IFDEF USE_DEBUGGING}
  Log(Format('INF|%s', [Msg]));
  {$ENDIF}
end;

procedure WLog(Msg: String);
begin
  {$IFDEF USE_DEBUGGING}
  Log(Format('WRN|%s', [Msg]));
  {$ENDIF}
end;

procedure ELog(Msg: String; Routine: String);
begin
  {$IFDEF USE_DEBUGGING}
  Log(Format('ERR|%s()|%s', [Routine, Msg]));
  {$ENDIF}
end;

end.

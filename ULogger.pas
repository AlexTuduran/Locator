unit ULogger;

(******************************************************************************
 * Description: Logging routines                                               *
 * Author: Alexandru Tuduran                                                  *
 * Contact: alex.tuduran@gmail.com                                            *
 ******************************************************************************)

interface

{$define NUSE_LOGGING} //enable or disable this;

{$ifdef USE_LOGGING}
uses
  SysUtils,
  Forms;
{$endif}

procedure Log(Msg: String);
procedure ILog(Msg: String);
procedure WLog(Msg: String);
procedure ELog(Msg: String; Routine: String);

implementation

const
  MAX_LOG_COUNTER = 2000000000; // make it an obvious value;

{$ifdef USE_LOGGING}
var
  LogCounter: Integer;
{$endif}

{ Interface routines }

procedure Log(Msg: String);
{$ifdef USE_LOGGING}
var
  F: Text;
  FN: String;
  T: TSystemTime;
  TStr: String;
  i: Integer;
{$endif}
begin
{$ifdef USE_LOGGING}
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
{$else}
  Msg := Msg;
{$endif}
end;

procedure ILog(Msg: String);
begin
{$ifdef USE_LOGGING}
  Log(Format('INF|%s', [Msg]));
{$else}
  Msg := Msg;
{$endif}
end;

procedure WLog(Msg: String);
begin
{$ifdef USE_LOGGING}
  Log(Format('WRN|%s', [Msg]));
{$else}
  Msg := Msg;
{$endif}
end;

procedure ELog(Msg: String; Routine: String);
begin
{$ifdef USE_LOGGING}
  Log(Format('ERR|%s()|%s', [Routine, Msg]));
{$else}
  Msg := Msg;
{$endif}
end;

end.

program locator;

{$mode objfpc}
{$H+}

uses
{$IFDEF UNIX}
{$IFDEF UseCThreads}
  cthreads,
{$ENDIF}
{$ENDIF}
  Interfaces,
  Forms,
  ufrm_Main,
  ufrm_options,
  ufrm_progress;

{$R *.res}

begin
  Application.Title := 'Locator';
  RequireDerivedFormResource := True;
  Application.Initialize;
  Application.CreateForm(Tfrm_Main, frm_Main);
  Application.Run;
end.


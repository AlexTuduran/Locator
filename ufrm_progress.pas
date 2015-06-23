unit ufrm_progress;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls;

type

  { Tfrm_Progress }

  Tfrm_Progress = class(TForm)
    pnl_Main: TPanel;
    tmr_Animate: TTimer;
    procedure tmr_AnimateTimer(Sender: TObject);
  private
    { private declarations }
    FAnimationIndex: Integer;
  public
    { public declarations }
  end;

implementation

{$R *.lfm}

{ Tfrm_Progress }

procedure Tfrm_Progress.tmr_AnimateTimer(Sender: TObject);
const
  DOTS: array [0..2] of String = ('.', '..', '...');
begin
  FAnimationIndex := (FAnimationIndex + 1) mod Length(DOTS);
  pnl_Main.Caption := 'Busy' + DOTS[FAnimationIndex];
  Application.ProcessMessages;
end;

end.


unit UStringSplitter;

(******************************************************************************
 * Description: Token-based string splitter                                   *
 * Author: Alexandru Tuduran                                                  *
 * Contact: mp_nova_2004@yahoo.com                                            *
( *****************************************************************************)

interface

{$WARN UNIT_PLATFORM OFF}
{$WARN SYMBOL_PLATFORM OFF}

uses
  Classes,
  SysUtils,
  Dialogs;

  function Splitter_Split_Strings(Source: String; Separator: Char): TStringList;
  function Splitter_Get_Next_Token(S: String; var Index: Integer; Separator: Char): String;

implementation

{ Interface routines }

function Splitter_Split_Strings(Source: String; Separator: Char): TStringList;
var
  SL: TStringList;
  Index: Integer;
begin
  //create splits;
  SL := TStringList.Create;

  //find splits using tokenizer;
  Index := 1;
  repeat
    SL.Add(Splitter_Get_Next_Token(Source, Index, Separator));
  until Index > Length(Source);

  //return
  Result := SL;
end;

function Splitter_Get_Next_Token(S: String; var Index: Integer; Separator: Char): String;
var
  Token: String;
begin
  Token := '';
  while Index <= Length(S) do
  begin
    if S[Index] = Separator then
      Break;
    Token := Token + S[Index];
    Inc(Index);
  end;
  Inc(Index);
  Result := Token;
end;

end.

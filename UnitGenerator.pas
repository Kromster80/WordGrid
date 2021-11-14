unit UnitGenerator;
interface
uses
  System.Classes, System.SysUtils,
  Math;

type
  TFillMode = (fmTight, fmSpread);

  TGridLetter = record
    Letter: Char;
    Usage: Byte;
    function IsEmpty: Boolean; inline;
  end;

  TGridGenerator = class(TThread)
  private
    fGridSizeX: Integer;
    fGridSizeY: Integer;
    fMode: TFillMode;
    fWordList: array of TStringList;
    fGrid: array of array of TGridLetter;
    fBestLayoutScore: Integer;
    fIterationsDone: Integer;
    fIterationsTotal: Integer;
    fOnBetter: TProc;
    procedure GridClear;
    function DoLayout: Boolean;
    function DoLayoutSet(aWordList: TStringList): Boolean;
    function FindPlace(const aWord1, aWord2: string; aFromX, aY: Byte; out aX: Byte): Boolean;
    procedure FindStart(out aX, aY: Byte);
    function GetScore(const aWord1, aWord2: string; aX, aY: Byte): Integer;
    procedure PlaceWord(const aWord1, aWord2: string; aX, aY: Byte);
    function GetLayoutScore: Integer;
    procedure SaveGrid;
  public
    fBestGrid: array of array of TGridLetter;
    constructor Create(aGridSizeX, aGridSizeY: Integer; aMode: TFillMode; aOnBetter: TProc);
    destructor Destroy; override;
    procedure Improve(aCount: Integer);
    property GridSizeX: Integer read fGridSizeX;
    property GridSizeY: Integer read fGridSizeY;
    property IterationsDone: Integer read fIterationsDone;
    property IterationsTotal: Integer read fIterationsTotal;
    property BestLayoutScore: Integer read fBestLayoutScore;
    procedure Execute; override;
  end;

  
implementation


constructor TGridGenerator.Create(aGridSizeX, aGridSizeY: Integer; aMode: TFillMode; aOnBetter: TProc);
begin
  inherited Create;

  fGridSizeX := aGridSizeX;
  fGridSizeY := aGridSizeY;
  fMode := aMode;
  fOnBetter := aOnBetter;
  SetLength(fGrid, fGridSizeY, fGridSizeX);
  SetLength(fBestGrid, fGridSizeY, fGridSizeX);

  fBestLayoutScore := -9999;

  SetLength(fWordList, 7);

  fWordList[0] := TStringList.Create;
  fWordList[0].Add('сейчас ');

  fWordList[1] := TStringList.Create;
  fWordList[1].Add('ноль');
  fWordList[1].Add('один');
  fWordList[1].Add('два');
  fWordList[1].Add('три');
  fWordList[1].Add('четыре');
  fWordList[1].Add('пять');
  fWordList[1].Add('шесть');
  fWordList[1].Add('семь');
  fWordList[1].Add('восемь');
  fWordList[1].Add('девять');
  fWordList[1].Add('десять');
  fWordList[1].Add('один.надцать');
  fWordList[1].Add('две.надцать');

  fWordList[2] := TStringList.Create;
  fWordList[2].Add('час');
  fWordList[2].Add('часа');
  fWordList[2].Add('часов');

  fWordList[3] := TStringList.Create;
  fWordList[3].Add('два.дцать');
  fWordList[3].Add('три.дцать');
  fWordList[3].Add('сорок');
  fWordList[3].Add('пять.десят');

  fWordList[4] := TStringList.Create;
  fWordList[4].Add('ровно');

  fWordList[5] := TStringList.Create;
  fWordList[5].Add('одна');
  fWordList[5].Add('две');
  fWordList[5].Add('три');
  fWordList[5].Add('четыре');
  fWordList[5].Add('пять');
  fWordList[5].Add('шесть');
  fWordList[5].Add('семь');
  fWordList[5].Add('восемь');
  fWordList[5].Add('девять');
  fWordList[5].Add('десять');
  fWordList[5].Add('один.надцать');
  fWordList[5].Add('две.надцать');
  fWordList[5].Add('три.надцать');
  fWordList[5].Add('четыр.надцать');
  fWordList[5].Add('пят.надцать');
  fWordList[5].Add('шест.надцать');
  fWordList[5].Add('сем.надцать');
  fWordList[5].Add('восем.надцать');
  fWordList[5].Add('девят.надцать');

  fWordList[6] := TStringList.Create;
  fWordList[6].Add('минут');
  fWordList[6].Add('минута');
  fWordList[6].Add('минуты');
end;


destructor TGridGenerator.Destroy;
var
  I: Integer;
begin
  for I := 0 to High(fWordList) do
    fWordList[I].Free;

  inherited;
end;


procedure TGridGenerator.Improve(aCount: Integer);
begin
  Inc(fIterationsTotal, aCount);
end;


function TGridGenerator.DoLayout: Boolean;
var
  I: Integer;
  res: Boolean;
begin
  Result := True;

  GridClear;

  for I := 0 to High(fWordList) do
  begin
    res := DoLayoutSet(fWordList[I]);
    if not res then
      Exit(False);
  end;
end;


function TGridGenerator.DoLayoutSet(aWordList: TStringList): Boolean;
var
  I, K: Integer;
  r1, r2: Integer;
  s: string;
  ox: Byte;
  wordHasBreaks: Boolean;
  w, w1, w2: string;
  startX, startY: Byte;
begin
  Result := True;

  // Shuffle words
  for I := 0 to aWordList.Count do
  begin
    r1 := Random(aWordList.Count);
    r2 := Random(aWordList.Count);

    s := aWordList[r1];
    aWordList[r1] := aWordList[r2];
    aWordList[r2] := s;
  end;

  // Mark all words "unused"
  for I := 0 to aWordList.Count - 1 do
    aWordList.Objects[I] := TObject(0);

  FindStart(startX, startY);

  for I := 0 to aWordList.Count - 1 do
  begin
    w := aWordList[I];
    wordHasBreaks := Pos('.', w) > 0;

    // Sometimes we can just ignore the breaks
    if wordHasBreaks and (Random < 0.5) then
    begin
      w := StringReplace(w, '.', '', [rfReplaceAll]);
      wordHasBreaks := False;
    end;

    if not wordHasBreaks then
    begin
      // Word has no breaks, place as usual
      for K := startY to High(fGrid) do
      if FindPlace(w, '', startX * Ord(K = startY), K, ox) then
      begin
        PlaceWord(w, '', ox, K);

        // Mark word "used"
        aWordList.Objects[I] := TObject(1);
        Break;
      end;
    end else
    begin
      // Word has a break
      w1 := Copy(w, 1, Pos('.', w)-1);
      w2 := Copy(w, Pos('.', w)+1, Length(w));

      for K := startY to High(fGrid)-1 do
      if FindPlace(w1, w2, startX * Ord(K = startY), K, ox) then
      begin
        PlaceWord(w1, w2, ox, K);

        // Mark word "used"
        aWordList.Objects[I] := TObject(1);
        Break;
      end;
    end;
  end;

  for I := 0 to aWordList.Count - 1 do
  if aWordList.Objects[I] = TObject(0) then
    Result := False;
end;


function TGridGenerator.FindPlace(const aWord1, aWord2: string; aFromX, aY: Byte; out aX: Byte): Boolean;
var
  I: Integer;
  bestScore, newScore: Integer;
  hx: Integer;
begin
  Result := False;

  bestScore := 0;
  hx := Length(fGrid[0]) - Max(Length(aWord1), Length(aWord2));
  for I := aFromX to hx do
  begin
    newScore := GetScore(aWord1, aWord2, I, aY);

    if newScore > 0 then
      newScore := newScore + Random(2);

    if newScore > bestScore then
    begin
      bestScore := newScore;
      aX := I;
      Result := True;
    end;
  end;
end;


function TGridGenerator.GetLayoutScore: Integer;
  function LineIsEmpty(aY: Byte): Boolean;
  var
    I: Integer;
  begin
    Result := True;
    for I := 0 to High(fGrid[aY]) do
    if not fGrid[aY, I].IsEmpty then
      Exit(False);
  end;
  function EndpointsScore: Integer;
  begin
    Result := Ord(not fGrid[0, 0].IsEmpty) + Ord(not fGrid[High(fGrid), High(fGrid[0])].IsEmpty);
  end;
  function GapScore(aSkipEmptyLines: Boolean): Integer;
  var
    I, K: Integer;
  begin
    Result := 0;
    for I := 0 to High(fGrid) do
    if not aSkipEmptyLines or not LineIsEmpty(I) then
    for K := 0 to High(fGrid[I]) do
    if fGrid[I, K].IsEmpty then
      Inc(Result);
  end;
  function StreaksScore: Integer;
  var
    I, K: Integer;
  begin
    Result := 0;

    for I := 0 to High(fGrid) do
    if not LineIsEmpty(I) then
    for K := 1 to High(fGrid[I]) do
    if fGrid[I, K-1].IsEmpty and fGrid[I, K].IsEmpty then
      Inc(Result, 1);

    for I := 0 to High(fGrid) do
    if not LineIsEmpty(I) then
    for K := 2 to High(fGrid[I]) do
    if fGrid[I, K-2].IsEmpty and fGrid[I, K-1].IsEmpty and fGrid[I, K].IsEmpty then
      Inc(Result, 3);
  end;
begin
  Result := EndpointsScore * 10;

  case fMode of
    fmTight:  Result := Result + GapScore(True);  // More gaps is better
    fmSpread: Result := Result - GapScore(False);  // Fewer gaps is better
  end;
end;


// Score of 0 means word can't be placed
function TGridGenerator.GetScore(const aWord1, aWord2: string; aX, aY: Byte): Integer;
  function CanPlace(const aWord: string; aIdx, aToX, aToY: Byte): Integer;
  begin
    Result := -1;
    if aIdx > Length(aWord) then Exit(0);
    if fGrid[aToY, aToX].Letter = aWord[aIdx] then Exit(3);
    if fGrid[aToY, aToX].IsEmpty then Exit(1);
  end;
var
  I: Integer;
  hx: Integer;
  px: Integer;
  res1, res2: Integer;
begin
  Result := 0;
  hx := Max(Length(aWord1), Length(aWord2));
  for I := 1 to hx do
  begin
    px := aX + I - 1;
    res1 := CanPlace(aWord1, I, px, aY);
    res2 := CanPlace(aWord2, I, px, aY+1);
    if (res1 = -1) or (res2 = -1) then Exit(0);
    Inc(Result, res1 + res2);
  end;
end;


procedure TGridGenerator.GridClear;
var
  I, K: Integer;
begin
  for I := 0 to High(fGrid) do
  for K := 0 to High(fGrid[I]) do
  begin
    fGrid[I, K].Letter := #0;
    fGrid[I, K].Usage := 0;
  end;
end;


procedure TGridGenerator.FindStart(out aX, aY: Byte);
var
  I, K: Integer;
begin
  aX := 0;
  aY := 0;
  for I := High(fGrid) downto 0 do
  for K := High(fGrid[I]) downto 0 do
  if not fGrid[I, K].IsEmpty then
  begin
    aX := K;
    aY := I;
    Exit;
  end;
end;


procedure TGridGenerator.PlaceWord(const aWord1, aWord2: string; aX, aY: Byte);
var
  I: Integer;
begin
  for I := 1 to Length(aWord1) do
  if aWord1[I] <> fGrid[aY, aX + I - 1].Letter then
  begin
    if not fGrid[aY, aX + I - 1].IsEmpty then
      Assert(False, Format('Line %d. Overwriting %s with %s', [aY, fGrid[aY, aX + I - 1].Letter, aWord1[I]]));
    fGrid[aY, aX + I - 1].Letter := aWord1[I];
  end;

  for I := 1 to Length(aWord2) do
  if aWord2[I] <> fGrid[aY+1, aX + I - 1].Letter then
  begin
    if not fGrid[aY+1, aX + I - 1].IsEmpty then
      Assert(False, Format('Line %d. Overwriting %s with %s', [aY, fGrid[aY+1, aX + I - 1].Letter, aWord2[I]]));
    fGrid[aY+1, aX + I - 1].Letter := aWord2[I];
  end;
end;


procedure TGridGenerator.SaveGrid;
var
  I, K: Integer;
begin
  for I := 0 to High(fGrid) do
  for K := 0 to High(fGrid[I]) do
    fBestGrid[I, K] := fGrid[I, K];
end;


procedure TGridGenerator.Execute;
var
  success: Boolean;
  layoutScore: Integer;
begin
  repeat

    while fIterationsDone < fIterationsTotal do
    begin
      success := DoLayout;

          if (fIterationsDone = 0) then
            Synchronize(
              procedure
              begin
                fOnBetter;
              end);
      if success then
      begin
        layoutScore := GetLayoutScore; // More is better

        if layoutScore >= fBestLayoutScore then
        begin
          SaveGrid;
          fBestLayoutScore := layoutScore;

          if Assigned(fOnBetter) then
            Synchronize(
              procedure
              begin
                fOnBetter;
              end);
        end;
      end;

      if Terminated then Break;

      Inc(fIterationsDone);
    end;

    sleep(1);
  until Terminated;
end;


{ TGridLetter }

function TGridLetter.IsEmpty: Boolean;
begin
  Result := Letter = #0;
end;


end.

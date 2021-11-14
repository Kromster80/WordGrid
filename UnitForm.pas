unit UnitForm;
interface
uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  Math, Vcl.Samples.Spin,
  UnitGenerator;

type
  TFormWordGrid = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
    Panel1: TPanel;
    btnGenerateNew: TButton;
    seGridSizeX: TSpinEdit;
    Label3: TLabel;
    btnImprove: TButton;
    Timer1: TTimer;
    Label4: TLabel;
    seGridSizeY: TSpinEdit;
    RadioGroup1: TRadioGroup;
    procedure FormCreate(Sender: TObject);
    procedure btnGenerateNewClick(Sender: TObject);
    procedure btnImprove10Click(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    fGenerator: TGridGenerator;
    procedure DisplayGrid;
  end;


implementation

{$R *.dfm}


procedure TFormWordGrid.FormCreate(Sender: TObject);
begin
  Randomize;

  btnGenerateNewClick(nil);
end;


procedure TFormWordGrid.FormDestroy(Sender: TObject);
begin
  FreeAndNil(fGenerator);
end;


procedure TFormWordGrid.Timer1Timer(Sender: TObject);
begin
  Label4.Caption := Format('%d/%d', [fGenerator.IterationsDone, fGenerator.IterationsTotal]);
end;


procedure TFormWordGrid.btnGenerateNewClick(Sender: TObject);
begin
  FreeAndNil(fGenerator);
  fGenerator := TGridGenerator.Create(
    seGridSizeX.Value, seGridSizeY.Value,
    TFillMode(RadioGroup1.ItemIndex),
    procedure
    begin
      DisplayGrid;
      Application.ProcessMessages;
    end);

  btnImprove10Click(Sender);
end;


procedure TFormWordGrid.btnImprove10Click(Sender: TObject);
begin
  fGenerator.Improve(1000000);
end;


procedure TFormWordGrid.DisplayGrid;
var
  I, K: Integer;
  lbl: TLabel;
begin
  while Panel1.ControlCount > 0 do
    Panel1.Controls[0].Free;

  for I := 0 to fGenerator.GridSizeY - 1 do
  for K := 0 to fGenerator.GridSizeX - 1 do
  begin
    lbl := TLabel.Create(Panel1);
    lbl.Parent := Panel1;

    lbl.Font.Size := 14;
    lbl.Font.Name := 'Consolas';

    lbl.Left := 28 + K * 20;
    lbl.Top := 24 + I * 20;

    if not fGenerator.fBestGrid[I,K].IsEmpty then
      lbl.Caption := AnsiUpperCase(fGenerator.fBestGrid[I,K].Letter)
    else
      lbl.Caption := '-';
  end;

  Label2.Caption := IntToStr(fGenerator.BestLayoutScore);
end;


end.

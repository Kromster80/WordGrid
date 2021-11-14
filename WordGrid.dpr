program WordGrid;
uses
  Vcl.Forms,
  UnitGenerator in 'UnitGenerator.pas',
  UnitForm in 'UnitForm.pas' {FormWordGrid};

{$R *.res}

var
  FormWordGrid: TFormWordGrid;

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFormWordGrid, FormWordGrid);
  Application.Run;
end.

program WordGrid;
uses
  Vcl.Forms,
  UnitGenerator in 'UnitGenerator.pas',
  UnitForm in 'UnitForm.pas' {Form6};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm6, Form6);
  Application.Run;
end.

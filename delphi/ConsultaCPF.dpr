program ConsultaCPF;

uses
  Vcl.Forms,
  uConsultaCPF in 'uConsultaCPF.pas' {frmConsultaCPF},
  CpfBrasilOrg in '..\classe\CpfBrasilOrg.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmConsultaCPF, frmConsultaCPF);
  Application.Run;
end.

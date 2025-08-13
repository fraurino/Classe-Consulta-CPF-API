unit uConsultaCPF;

interface

{$IFDEF FPC}
  {$MODE DELPHI}
{$ENDIF}


uses
  {$IFDEF MSWINDOWS}
    Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
    Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, ShellAPI;
  {$ENDIF}


type
  TfrmConsultaCPF = class(TForm)
    lblNome: TLabel;
    lblNomeMae: TLabel;
    edtCPF: TEdit;
    edtNomeCompleto: TEdit;
    edtNomedaMae: TEdit;
    Label1: TLabel;
    edtsexo: TEdit;
    Label2: TLabel;
    edtnascimento: TEdit;
    Label3: TLabel;
    btnBuscar: TButton;
    btnObterTOKEN: TButton;
    edtToken: TEdit;
    lblstatus: TLabel;
    procedure btnObterTOKENClick(Sender: TObject);
    procedure btnBuscarClick(Sender: TObject);
  private
    { Private declarations }
    procedure AbrirURL(const URL: string);
  public
    { Public declarations }
    procedure consultaCPF(token , CPF: string );
  end;

var
  frmConsultaCPF: TfrmConsultaCPF;

implementation

uses
  CpfBrasilOrg;


{$R *.dfm}

procedure TfrmConsultaCPF.AbrirURL(const URL: string);
begin
  {$IFDEF MSWINDOWS}
    // Windows: abre no navegador padrão
    ShellExecute(0, 'open', PChar(URL), nil, nil, SW_SHOWNORMAL);
  {$ELSE}
    // Linux/macOS: usa comando do sistema
    if ExecuteProcess('/usr/bin/xdg-open', [URL]) <> 0 then
      Writeln('Não foi possível abrir a URL: ' + URL);
  {$ENDIF}
end;

procedure TfrmConsultaCPF.btnBuscarClick(Sender: TObject);
begin
   consultaCPF(edtToken.Text, edtCPF.text);
end;

procedure TfrmConsultaCPF.btnObterTOKENClick(Sender: TObject);
begin
  AbrirURL ('https://aurino.com.br/consultacpf');
end;

procedure TfrmConsultaCPF.consultaCPF(token , CPF: string);
var
  api: TCpfBrasilOrg;
  retorno: TCpfData;
begin
  api := TCpfBrasilOrg.Create( token );
  try
      edtNomeCompleto.Clear;
      edtNomedaMae.Clear;
      edtnascimento.Clear;
      edtsexo.Clear;
     retorno := api.ConsultarCPF(CPF);
     edtNomeCompleto.Text := retorno.Nome;
     edtNomedaMae.Text    := retorno.NomeMae;
     edtsexo.Text	        := retorno.Sexo;
     edtnascimento.Text   := retorno.Nascimento;

      lblStatus.Caption := Format(
      'Mensagem: %s' + sLineBreak +
      'Quota usada: %d | Limite: %d | Restante: %d',
      [retorno.Msg, retorno.QuotaUsed, retorno.QuotaLimit, retorno.QuotaRemaining]
      );

     lblStatus.Repaint;
  finally
    api.Free;
  end;
end;

end.

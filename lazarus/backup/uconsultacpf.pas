unit uConsultaCPF;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, CpfBrasilOrg, LCLIntf,  opensslsockets;

type

  { TfrmConsultaCPF }

  TfrmConsultaCPF = class(TForm)
    btnBuscar: TButton;
    btnObterTOKEN: TButton;
    edtCPF: TEdit;
    edtnascimento: TEdit;
    edtNomeCompleto: TEdit;
    edtNomedaMae: TEdit;
    edtsexo: TEdit;
    edtToken: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    lblNome: TLabel;
    lblNomeMae: TLabel;
    lblstatus: TLabel;
    procedure btnBuscarClick(Sender: TObject);
    procedure btnObterTOKENClick(Sender: TObject);
  private
   procedure AbrirURL(const URL: string);
   procedure consultaCPF(token , CPF: string);
  public

  end;

var
  frmConsultaCPF: TfrmConsultaCPF;

implementation

{$R *.lfm}

{ TfrmConsultaCPF }

procedure TfrmConsultaCPF.btnBuscarClick(Sender: TObject);
begin
  consultaCPF(edtToken.Text, edtCPF.text);
end;

procedure TfrmConsultaCPF.btnObterTOKENClick(Sender: TObject);
begin
   AbrirURL ('https://aurino.com.br/consultacpf');
end;

procedure TfrmConsultaCPF.AbrirURL(const URL: string);
begin
  try
    OpenURL(URL);
  except
    on E: Exception do
      Writeln('Erro ao abrir a URL: ' + E.Message);
  end;
end;

procedure TfrmConsultaCPF.consultaCPF(token, CPF: string);
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
     edtsexo.Text	  := retorno.Sexo;
     edtnascimento.Text   := retorno.Nascimento;
     lblStatus.Caption := Format('Mensagem: %s', [retorno.Msg]);

      lblStatus.Repaint;
  finally
    api.Free;
  end;

end;

end.


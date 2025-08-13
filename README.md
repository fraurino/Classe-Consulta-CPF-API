# Consulta de CPF - Delphi 11 e Lazarus 4.0

Projeto de exemplo para consulta de CPF utilizando a **API CPF Brasil**  
Compatível com **Delphi 11** e **Lazarus 4.0**, permitindo consultas de forma simples e estruturada.

## 🔗 **Plataforma da API e obter TOKEN:** [https://aurino.com.br/consultacpf](https://aurino.com.br/consultacpf)

---

## 📌 Recursos
- Consulta CPF online com retorno estruturado.
- Compatível com Delphi 11 e Lazarus 4.0.
- Suporte a retorno de **cotas utilizadas** e mensagens de erro da API.
- Tratamento de exceções e respostas em formato **JSON**.
- Exemplo de integração com componentes visuais (TEdit, TLabel etc.).

---

## 🚀 Requisitos

### Delphi
- ✅ Disponível: Delphi XE8, 10 Seattle, 10.1 Berlin, 10.2 Tokyo, 10.3 Rio, 10.4 Sydney, 11 Alexandria, 12 Athenas.
- Unit `System.Net.HttpClient` (nativo no Delphi).
- ❌ Não disponível nativamente: Delphi XE7 ou anteriores (nessas, você teria que usar Indy (TIdHTTP) ou componentes de terceiros).
<img width="566" height="370" alt="image" src="https://github.com/user-attachments/assets/256a193f-f0ab-4e7a-9979-a21965fbf3f4" />

### Lazarus
-  Lazarus FPC 2.x+ até Lazarus 4.0;
- Pacote `fphttpclient` (nativo no FPC).
- Unit `fpjson` e `jsonparser` para tratamento do JSON.
<img width="593" height="369" alt="image" src="https://github.com/user-attachments/assets/ea3fe908-c629-4434-a8e0-0f8762f28254" />


---

## 📝 Exemplo de uso da Classe
<pre>procedure TfrmConsultaCPF.consultaCPF(token, CPF: string);
var
  api: TCpfBrasilOrg;
  retorno: TCpfData;
begin
  // informando TOKEN de autenticação
  api := TCpfBrasilOrg.Create( token );
  try
     // limpando TEDIT;
     edtNomeCompleto.Clear;
     edtNomedaMae.Clear;
     edtnascimento.Clear;
     edtsexo.Clear;
     
     //requisitando...
     retorno              := api.ConsultarCPF(CPF);
  
     // passando retorno ao componente visual TEDIT
     edtNomeCompleto.Text := retorno.Nome;
     edtNomedaMae.Text    := retorno.NomeMae;
     edtsexo.Text	      := retorno.Sexo;
     edtnascimento.Text   := retorno.Nascimento;
  
     lblStatus.Caption := Format('Mensagem: %s', [retorno.Msg]);
      lblStatus.Repaint;
  
  finally
    api.Free;
  end;

end;
</pre>
## 📥 Instalação
1. Clone este repositório:
   ```bash
   git clone https://github.com/fraurino/Classe-Consulta-CPF-API.git

## 📊 Retorno da API
## ✅ Resposta de sucesso:
<pre> {
  "success": true,
  "data": {
    "CPF": "00000000000",
    "NOME": "Fulano de Tal",
    "SEXO": "M",
    "NASC": "01/01/1990",
    "NOME_MAE": "Maria Tal"
  },
  "quota": {
    "quota_used": 5,
    "quota_limit": 10,
    "quota_remaining": 5
  }
}
</pre>

## ❌ Resposta de erro (exemplo):
<pre>{
  "error": "Quota Excedida",
  "message": "Sua quota mensal foi excedida. Faça upgrade ou aguarde o reset.",
  "code": "QUOTA_EXCEEDED",
  "action": "Acesse https://dash.cpf-brasil.org para upgrade",
  "quota_used": 10,
  "quota_limit": 10,
  "reset_date": "2025-09-01"
}
</pre>

## 📢 Observações
A API oferece plano gratuito com limite de consultas mensais. Há também plano pago com consultas ilimitadas e API sem rate limiting.

## 📄 Licença
Este projeto é de uso livre para fins educacionais e até comerciais.
Consulte os termos de uso da API em [https://aurino.com.br/consultacpf](https://aurino.com.br/consultacpf)


## ⚠️ Aviso: A API de consulta de CPF utilizada neste projeto não é de minha responsabilidade. Este projeto apenas integra a API para fins de consulta. Qualquer problema relacionado ao serviço, limites de uso ou questões técnicas devem ser tratados diretamente com o provedor da API.

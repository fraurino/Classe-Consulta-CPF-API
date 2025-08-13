unit CpfBrasilOrg;

{$IFDEF FPC}
  {$MODE DELPHI}
{$ENDIF}

interface

uses
  {$IFDEF FPC}
  forms, dialogs,fphttpclient, fpjson, jsonparser, sysutils , classes
  {$ELSE}
  forms, dialogs,  System.SysUtils, System.Classes, System.Net.HttpClient, System.JSON
  {$ENDIF};

type
  ECpfBrasilOrg = class(Exception); // Exceção customizada

  TCpfData = record
    CPF: string;
    Nome: string;
    Sexo: string;
    Nascimento: string;
    NomeMae: string;
    QuotaUsed: Integer;
    QuotaLimit: Integer;
    QuotaRemaining: Integer;
    Msg  : string;
    Action : string;
    ResetDate  : string;
  end;

  TCpfBrasilOrg = class
  private
    const FUrl: string = 'https://api.cpf-brasil.org/cpf/';
    var FToken: string;
  public
    constructor Create(const AToken: string);
    function ConsultarCPF(const ACpf: string): TCpfData;
  end;

implementation

{ TCpfBrasilOrg }

constructor TCpfBrasilOrg.Create(const AToken: string);
begin
  FToken := AToken;
end;

function TCpfBrasilOrg.ConsultarCPF(const ACpf: string): TCpfData;

{$IFDEF FPC}
 var
  HTTP: TFPHTTPClient;
  RespStream: TStringStream;
  RespStr: string;
  JsonData, JsonObj, JsonQuota, JsonError: TJSONData;
  HttpError: Boolean;
begin
  Result := Default(TCpfData);
  HTTP := TFPHTTPClient.Create(nil);
  RespStream := TStringStream.Create('');
  HttpError := False;

  try
    HTTP.AddHeader('X-API-Key', FToken);

    try
      HTTP.Get(FUrl + ACpf, RespStream);
    except
      on E: EHTTPClient do
      begin
        // Captura erros HTTP (401, 403, 500, etc.)
        HttpError := True;
        RespStr := RespStream.DataString;

        // Se não há conteúdo na resposta, usa a mensagem do erro HTTP
        if RespStr = '' then
          RespStr := E.Message;
      end;
      on E: Exception do
        raise ECpfBrasilOrg.Create('Erro na requisição: ' + E.Message);
    end;

    // Se não houve erro HTTP, pega a resposta normal
    if not HttpError then
      RespStr := RespStream.DataString;

    if RespStr = '' then
      raise ECpfBrasilOrg.Create('Nenhuma resposta do servidor');

    // Verifica se a resposta é JSON válido
    JsonData := nil;
    try
      JsonData := GetJSON(RespStr);
    except
      on E: Exception do
      begin
        // Se não conseguiu fazer parse do JSON, trata como erro de texto simples
        if HttpError then
        begin
          // Para erros HTTP comuns, define mensagens mais claras
          if Pos('401', RespStr) > 0 then
            begin
              Result.QuotaUsed      := 0;
              Result.QuotaLimit     := 0;
              Result.QuotaRemaining := 0;
              Result.Msg            := 'Sua quota mensal foi excedida. Faca upgrade ou aguarde o reset' ;
              result.Action         := 'Acesse https://dash.cpf-brasil.org para upgrade';
            end
          else if Pos('Unauthorized', RespStr) > 0 then
            Result.Msg := 'Acesso não autorizado. Verifique seu token de API'
          else if Pos('403', RespStr) > 0 then
            Result.Msg := 'Acesso negado'
          else if Pos('429', RespStr) > 0 then
            Result.Msg := 'Muitas requisições. Tente novamente mais tarde'
          else
            Result.Msg := 'Erro: ' + RespStr;

          Result.Action := 'Verifique seu token de API';
          Exit; // sai retornando o erro
        end
        else
          raise ECpfBrasilOrg.Create('Resposta inválida do servidor: ' + E.Message);
      end;
    end;

    if Assigned(JsonData) then
    try
      // Verifica se existe erro na resposta JSON
      JsonError := JsonData.FindPath('error');
      if Assigned(JsonError) then
      begin
        Result.Msg := JsonData.FindPath('message').AsString;

        JsonObj := JsonData.FindPath('action');
        if Assigned(JsonObj) then
          Result.Action := JsonObj.AsString;

        JsonObj := JsonData.FindPath('reset_date');
        if Assigned(JsonObj) then
          Result.ResetDate := JsonObj.AsString;

        JsonObj := JsonData.FindPath('quota_used');
        if Assigned(JsonObj) then
          Result.QuotaUsed := JsonObj.AsInteger;

        JsonObj := JsonData.FindPath('quota_limit');
        if Assigned(JsonObj) then
          Result.QuotaLimit := JsonObj.AsInteger;

        JsonObj := JsonData.FindPath('quota_remaining');
        if Assigned(JsonObj) then
          Result.QuotaRemaining := JsonObj.AsInteger;

        Exit; // sai da função retornando os dados do erro
      end;

      // Verifica sucesso (só para respostas sem erro)
      JsonObj := JsonData.FindPath('success');
      if Assigned(JsonObj) and not JsonObj.AsBoolean then
        raise ECpfBrasilOrg.Create('CPF não encontrado ou inválido');

      // Dados do CPF
      JsonObj := JsonData.FindPath('data');
      if Assigned(JsonObj) then
      begin
        Result.CPF := JsonObj.FindPath('CPF').AsString;
        Result.Nome := JsonObj.FindPath('NOME').AsString;
        Result.Sexo := JsonObj.FindPath('SEXO').AsString;
        Result.Nascimento := JsonObj.FindPath('NASC').AsString;
        Result.NomeMae := JsonObj.FindPath('NOME_MAE').AsString;
      end;

      // Dados da quota
      JsonQuota := JsonData.FindPath('quota');
      if Assigned(JsonQuota) then
      begin
        Result.QuotaUsed := JsonQuota.FindPath('quota_used').AsInteger;
        Result.QuotaLimit := JsonQuota.FindPath('quota_limit').AsInteger;
        Result.QuotaRemaining := JsonQuota.FindPath('quota_remaining').AsInteger;
      end;

    finally
      JsonData.Free;
    end;

  finally
    HTTP.Free;
    RespStream.Free;
  end;

{$ELSE}
var
  HTTP: THttpClient;
  Resp: IHTTPResponse;
  JsonObj, JsonData, JsonQuota: TJSONObject;
  JsonValue: TJSONValue;
  JsonSuccess, JsonError: TJSONValue;

begin
  Result := Default(TCpfData);
  HTTP := THttpClient.Create;
  try
    HTTP.CustomHeaders['X-API-Key'] := FToken;
    try
      Resp := HTTP.Get(FUrl + ACpf);
    except
      on E: Exception do
        raise ECpfBrasilOrg.Create('Erro de conexão: ' + E.Message);
    end;

    // Lê JSON com segurança
    JsonValue := TJSONObject.ParseJSONValue(Resp.ContentAsString);
    if not Assigned(JsonValue) then
      raise ECpfBrasilOrg.Create('Resposta inválida do servidor');

    try
      if not (JsonValue is TJSONObject) then
        raise ECpfBrasilOrg.Create('JSON retornado não é um objeto');

      JsonObj := TJSONObject(JsonValue);

      // Verifica se existe erro na resposta (quota excedida, token inválido, etc)
      JsonError := JsonObj.GetValue('error');
      if Assigned(JsonError) then
      begin
        // Inicializa quotas com 0 caso não existam
        Result.QuotaUsed := 0;
        Result.QuotaLimit := 0;
        Result.QuotaRemaining := 0;

        if JsonObj.TryGetValue<Integer>('quota_used', Result.QuotaUsed) = False then
          Result.QuotaUsed := 0;

        if JsonObj.TryGetValue<Integer>('quota_limit', Result.QuotaLimit) = False then
          Result.QuotaLimit := 0;

        if JsonObj.TryGetValue<Integer>('quota_remaining', Result.QuotaRemaining) = False then
          Result.QuotaRemaining := 0;

        if Assigned(JsonObj.GetValue('message')) then
          Result.Msg := JsonObj.GetValue('message').Value;

        if Assigned(JsonObj.GetValue('action')) then
          Result.Action := JsonObj.GetValue('action').Value;

        if Assigned(JsonObj.GetValue('reset_date')) then
          Result.ResetDate := JsonObj.GetValue('reset_date').Value;
         exit;
      end;

      // Verifica sucesso
      JsonSuccess := JsonObj.GetValue('success');
      if (JsonSuccess = nil) or (not JsonSuccess.AsType<Boolean>) then
        raise ECpfBrasilOrg.Create('CPF não encontrado ou inválido');

      // Dados do CPF
      JsonData := JsonObj.GetValue('data') as TJSONObject;
      if Assigned(JsonData) then
      begin
        Result.CPF        := JsonData.GetValue('CPF').Value;
        Result.Nome       := JsonData.GetValue('NOME').Value;
        Result.Sexo       := JsonData.GetValue('SEXO').Value;
        Result.Nascimento := JsonData.GetValue('NASC').Value;
        Result.NomeMae    := JsonData.GetValue('NOME_MAE').Value;
      end
      else
        raise ECpfBrasilOrg.Create('Nenhum dado retornado para o CPF informado');

      // Dados da quota
      JsonQuota := JsonObj.GetValue('quota') as TJSONObject;
      if Assigned(JsonQuota) then
      begin
        Result.QuotaUsed      := JsonQuota.GetValue<Integer>('quota_used');
        Result.QuotaLimit     := JsonQuota.GetValue<Integer>('quota_limit');
        Result.QuotaRemaining := JsonQuota.GetValue<Integer>('quota_remaining');
      end;

    finally
      // Não libera JsonValue aqui pois ele agora é o mesmo que JsonObj
      JsonObj := nil;
    end;

  finally
    HTTP.Free;
  end;
{$ENDIF}

end;

end.


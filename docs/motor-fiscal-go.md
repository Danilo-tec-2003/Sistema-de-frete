# Motor Fiscal Go

Este documento explica o projeto Go `Motor_fiscal` de forma completa, com foco em arquitetura, papel no sistema de fretes, endpoints, motor de regras, calculo tributario e integracao com o Java.

Projeto local:

```text
/home/danilo/Documentos/Projetos/Motor_fiscal
```

## Papel Do Motor Fiscal

O Motor Fiscal e um microservico Go responsavel por centralizar calculos e decisoes fiscais relacionadas ao frete.

Ele foi separado do sistema Java para que regras fiscais nao fiquem espalhadas em JSPs, Servlets, BOs ou DAOs.

Divisao de responsabilidade:

```text
Sistema de Fretes Java:
  operacao logistica, cadastros, fretes, ocorrencias, relatorios e telas.

Motor Fiscal Go:
  regra fiscal, CFOP, calculo de impostos, memoria de calculo e auditoria.
```

## O Que A API Faz

- recebe dados basicos de um frete;
- valida o payload;
- seleciona regra fiscal vigente;
- calcula ICMS, IBS e CBS;
- calcula total de tributos;
- calcula total com tributos;
- retorna CFOP;
- retorna dados da regra aplicada;
- salva auditoria da simulacao oficial;
- salva memoria de calculo por imposto;
- padroniza erros em JSON;
- protege endpoints com API Key;
- propaga `X-Correlation-ID` para rastreabilidade.

## O Que A API Nao Faz

- nao cadastra fretes no sistema Java;
- nao altera status operacional;
- nao grava clientes, motoristas ou veiculos do sistema Java;
- nao emite CT-e real;
- nao substitui o PostgreSQL do sistema principal;
- nao e fonte fiscal oficial por si so: depende de regras cadastradas e revisadas.

## Stack Tecnica

| Item | Tecnologia |
|---|---|
| Linguagem | Go |
| HTTP | `net/http` |
| Banco | PostgreSQL |
| Driver/pool | `pgxpool` |
| Decimal monetario | `shopspring/decimal` |
| Contrato | OpenAPI em `docs/openapi.yaml` |
| Autenticacao | Header `X-API-Key` |
| Rastreio | Header `X-Correlation-ID` |
| Deploy local | Docker/Docker Compose |

## Estrutura Do Projeto Go

```text
cmd/api
internal/config
internal/handler
internal/middleware
internal/service
internal/repository
internal/dto
internal/model
internal/errors
internal/validator
docs
migrations
```

Responsabilidades:

| Pasta | Papel |
|---|---|
| `cmd/api` | Ponto de entrada da aplicacao |
| `internal/config` | Variaveis de ambiente |
| `internal/handler` | Rotas e handlers HTTP |
| `internal/middleware` | API Key e correlation ID |
| `internal/service` | Regras de negocio e calculos |
| `internal/repository` | Acesso ao PostgreSQL |
| `internal/dto` | Requests e responses JSON |
| `internal/model` | Modelos internos do dominio fiscal |
| `internal/errors` | Erros padronizados |
| `internal/validator` | Validacao de payload |
| `migrations` | Estrutura e seeds do banco fiscal |
| `docs` | Contrato e documentacao da API |

## Inicializacao Da API

Arquivo:

```text
cmd/api/main.go
```

Fluxo:

```text
1. Carrega configuracao com config.Load()
2. Cria pool PostgreSQL com pgxpool.New()
3. Executa Ping para validar conexao
4. Cria repositories
5. Cria services
6. Cria handlers
7. Monta router
8. Sobe http.ListenAndServe()
```

Dependencias montadas:

```text
FiscalRuleRepository
FiscalSimulationRepository
FiscalRuleService
TaxService
CTeService
TaxHandler
CTeHandler
Router
```

## Configuracao

Arquivo:

```text
internal/config/config.go
```

Variaveis:

| Variavel | Default | Uso |
|---|---|---|
| `APP_PORT` | `8080` | Porta HTTP |
| `INTERNAL_API_KEY` | `dev-token` | Token usado pelo Java |
| `DATABASE_URL` | `postgres://motor_fiscal:motor_fiscal@localhost:5433/motor_fiscal?sslmode=disable` | Banco do Motor Fiscal |

Importante:

```text
O valor de INTERNAL_API_KEY precisa bater com motor.fiscal.api.key no sistema Java.
```

## Rotas

Arquivo:

```text
internal/handler/routes.go
```

Rotas:

| Metodo | Rota | Protegida? | Papel |
|---|---|---|---|
| GET | `/health` | Nao | Verificar se a API esta online |
| POST | `/api/v1/tax/preview` | Sim | Calcular previa sem salvar auditoria oficial |
| POST | `/api/v1/tax/simulate` | Sim | Calcular frete salvo e persistir simulacao |
| POST | `/api/v1/tax/compare` | Sim | Comparar cenario atual e reforma |
| POST | `/api/v1/tax/batch` | Sim | Processar varios fretes |
| POST | `/api/v1/cte/validate` | Sim | Validar dados minimos de CT-e |

O sistema Java usa principalmente:

```text
POST /api/v1/tax/preview
POST /api/v1/tax/simulate
```

## Middlewares

### API Key

Arquivo:

```text
internal/middleware/api_key.go
```

Header:

```text
X-API-Key: <token>
```

Se o token estiver ausente ou errado:

```text
HTTP 401
code = UNAUTHORIZED
```

### Correlation ID

Arquivo:

```text
internal/middleware/correlation_id.go
```

Header:

```text
X-Correlation-ID: frete-10
```

Regras:

- se o Java envia, o Go reaproveita;
- se nao envia, o Go gera um `req-<timestamp>`;
- o mesmo ID volta na resposta;
- esse ID ajuda a rastrear a mesma operacao nos logs.

## Contrato De Calculo Fiscal

### Request Do `simulate`

```json
{
  "freight_id": 1001,
  "operation_date": "2026-03-10",
  "origin_uf": "PE",
  "destination_uf": "SP",
  "freight_value": "3500.00",
  "customer_type": "PJ",
  "operation_type": "INTERESTADUAL"
}
```

Campos:

| Campo | Tipo | Observacao |
|---|---|---|
| `freight_id` | integer | ID do frete no sistema Java |
| `operation_date` | string | Data `YYYY-MM-DD` usada para vigencia da regra |
| `origin_uf` | string | UF origem |
| `destination_uf` | string | UF destino |
| `freight_value` | string | Valor monetario como string |
| `customer_type` | string | `PF` ou `PJ` |
| `operation_type` | string | `INTERNA` ou `INTERESTADUAL` |

Por que valor monetario e string?

```text
Para evitar perda de precisao em JSON/float.
No service, o valor vira decimal.Decimal.
```

### Request Do `preview`

O `preview` usa os mesmos campos, mas sem `freight_id`.

Ele e usado antes do frete existir no banco Java.

### Response

```json
{
  "freight_id": 1001,
  "base_value": "3500.00",
  "icms": {
    "rate": "12.00",
    "amount": "420.00"
  },
  "ibs": {
    "rate": "3.60",
    "amount": "126.00"
  },
  "cbs": {
    "rate": "0.90",
    "amount": "31.50"
  },
  "total_tax": "577.50",
  "total_with_tax": "4077.50",
  "cfop": "6351",
  "rule_id": 1,
  "rule_code": "RULE_PE_SP_INTERESTADUAL_PJ_2026_01_2026_01_01",
  "rule_version": "2026.01",
  "rule_status": "PENDING_REVIEW",
  "calculation_basis": "FREIGHT_VALUE",
  "from_cache": false
}
```

Tambem pode retornar `calculation_details`, que guarda memoria detalhada do calculo.

## Handler HTTP

Arquivo:

```text
internal/handler/tax_handler.go
```

Responsabilidades:

- aceitar somente POST;
- decodificar JSON;
- validar payload;
- chamar `TaxService`;
- converter erros de dominio em erros HTTP;
- responder JSON.

Fluxo do `simulate`:

```text
TaxHandler.Simulate()
  -> valida metodo POST
  -> decodeJSON()
  -> ValidateTaxSimulationRequest()
  -> taxService.Simulate()
  -> WriteJSON(200)
```

Fluxo do `preview`:

```text
TaxHandler.Preview()
  -> valida metodo POST
  -> decodeJSON()
  -> ValidateTaxPreviewRequest()
  -> taxService.Preview()
  -> WriteJSON(200)
```

## Validacao Do Payload

Arquivo:

```text
internal/validator/tax_validator.go
```

Validacoes:

- `freight_id > 0` no `simulate`;
- `operation_date` obrigatoria e no formato `YYYY-MM-DD`;
- `origin_uf` e `destination_uf` obrigatorias e validas;
- `freight_value` obrigatorio, numerico e maior que zero;
- `customer_type` deve ser `PF` ou `PJ`;
- `operation_type` deve ser `INTERNA` ou `INTERESTADUAL`;
- se UFs iguais, operacao deve ser `INTERNA`;
- se UFs diferentes, operacao deve ser `INTERESTADUAL`.

Erro de validacao:

```json
{
  "code": "VALIDATION_ERROR",
  "message": "Payload invalido.",
  "correlation_id": "frete-10",
  "details": [
    {
      "field": "freight_value",
      "message": "Deve ser maior que zero."
    }
  ]
}
```

## TaxService

Arquivo:

```text
internal/service/tax_service.go
```

Responsabilidades:

- converter `freight_value` para decimal;
- chamar o servico de regras fiscais;
- calcular impostos;
- montar response;
- salvar auditoria quando for `simulate`;
- nao salvar auditoria quando for `preview`.

Diferenca importante:

```text
Preview:
  calcula e retorna, mas nao salva fiscal_simulations.

Simulate:
  calcula, retorna e salva fiscal_simulations + fiscal_simulation_tax_details.
```

## Calculo Dos Impostos

Arquivo:

```text
internal/service/tax_calculator.go
```

Formula:

```text
effective_base_value = base_value - base_reduction
amount = effective_base_value * rate / 100
```

Depois:

```text
total_tax = ICMS + IBS + CBS
total_with_tax = freight_value + total_tax
```

O calculo usa `decimal.Decimal`, nao `float`.

Isso evita problemas como:

```text
0.1 + 0.2 = 0.30000000000000004
```

O motor exige que a regra tenha:

- ICMS
- IBS
- CBS

Se faltar algum:

```text
ErrFiscalRuleIncomplete
```

## Motor De Regras

Arquivo:

```text
internal/service/fiscal_rule_service.go
```

Objetivo:

```text
Escolher a regra fiscal correta para o payload recebido.
```

Fluxo:

```text
1. Busca regras candidatas no banco
2. Filtra por active = true
3. Considera status APPROVED ou PENDING_REVIEW
4. Considera vigencia da operation_date
5. Carrega condicoes e impostos
6. Avalia todas as condicoes
7. Ordena por prioridade
8. Resolve desempate por valid_from mais recente
9. Detecta conflito se duas regras empatam
10. Retorna FiscalRule
```

Operadores suportados:

| Operador | Significado |
|---|---|
| `EQUALS` | Campo precisa ser igual |
| `NOT_EQUALS` | Campo precisa ser diferente |
| `IN` | Campo precisa estar em lista |
| `BETWEEN` | Data precisa estar em intervalo |

Campos avaliados:

- `operation_date`
- `origin_uf`
- `destination_uf`
- `operation_type`
- `customer_type`

Status de regra:

| Status | Uso |
|---|---|
| `DRAFT` | Rascunho |
| `PENDING_REVIEW` | Pendente de revisao |
| `APPROVED` | Aprovada |
| `INACTIVE` | Inativa |

## Repositorios

### FiscalRuleRepository

Arquivo:

```text
internal/repository/fiscal_rule_repository.go
```

Busca:

- regras candidatas;
- condicoes da regra;
- impostos da regra.

Consulta principal considera:

```text
active = TRUE
status IN ('APPROVED', 'PENDING_REVIEW')
operation_date BETWEEN valid_from AND valid_to
```

### FiscalSimulationRepository

Arquivo:

```text
internal/repository/fiscal_simulation_repository.go
```

Salva:

- resumo em `fiscal_simulations`;
- detalhes em `fiscal_simulation_tax_details`.

Isso cria memoria de calculo auditavel.

## Banco Do Motor Fiscal

Principais tabelas:

| Tabela | Papel |
|---|---|
| `fiscal_rules` | Regra, CFOP, vigencia, prioridade e status |
| `fiscal_rule_conditions` | Condicoes para aplicar a regra |
| `fiscal_rule_taxes` | Impostos e aliquotas |
| `fiscal_rule_sources` | Fontes legais/referencias |
| `fiscal_rule_accounting_reviews` | Revisao contabil |
| `fiscal_simulations` | Historico de simulacoes |
| `fiscal_simulation_tax_details` | Memoria de calculo por imposto |

Migrations importantes:

| Arquivo | Papel |
|---|---|
| `001_create_fiscal_tables.sql` | Cria tabelas iniciais |
| `002_model_fiscal_rule_engine.sql` | Evolui para motor de regras por condicoes |
| `003_add_fiscal_rule_source_and_review_tracking.sql` | Fonte e revisao contabil |
| `004_persist_fiscal_calculation_audit.sql` | Detalhes de auditoria |
| `005_seed_demonstrative_fallback_rules.sql` | Regras fallback demonstrativas |

## Regras Fallback

As regras fallback existem para o MVP funcionar mesmo sem regra especifica para cada UF.

Caracteristicas:

- prioridade `900`;
- status `PENDING_REVIEW`;
- fonte `INTERNAL_NOTE`;
- revisao contabil pendente;
- nao sao regras fiscais oficiais.

Como o motor ordena prioridade crescente, regras especificas com prioridade menor vencem o fallback.

Exemplo:

```text
Regra PE -> SP especifica: prioridade 100
Fallback interestadual PJ: prioridade 900

Resultado: aplica PE -> SP.
```

## Validacao De CT-e

Endpoint:

```text
POST /api/v1/cte/validate
```

Arquivo:

```text
internal/service/cte_service.go
```

Hoje ele faz uma validacao basica:

- remetente com nome;
- remetente com documento;
- destinatario com nome;
- destinatario com documento;
- tenta determinar CFOP pela regra fiscal.

Nao emite CT-e real.

## Integracao Com O Sistema Java

No Java, os arquivos principais sao:

| Arquivo | Papel |
|---|---|
| `MotorFiscalConfig.java` | Le URL, API key e timeout |
| `MotorFiscalClient.java` | Cliente HTTP |
| `TaxSimulationRequest.java` | Payload com `freight_id` |
| `TaxPreviewRequest.java` | Payload sem `freight_id` |
| `TaxSimulationResponse.java` | Response consumida pelo Java |
| `FreteBO.java` | Chama preview/simulate |
| `FreteDAO.java` | Atualiza campos fiscais do frete |

Configuracao no Java:

```text
motor.fiscal.base.url
motor.fiscal.api.key
motor.fiscal.timeout.ms
```

Ou por variaveis:

```text
MOTOR_FISCAL_BASE_URL
MOTOR_FISCAL_API_KEY
MOTOR_FISCAL_TIMEOUT_MS
```

Headers enviados:

```text
Content-Type: application/json; charset=UTF-8
Accept: application/json
X-API-Key: <token>
X-Correlation-ID: frete-<id>
```

## Fluxo De Preview

```text
Usuario preenche FormFrete.jsp
  -> JS chama /fretes com acao=previewFiscal
  -> FreteControlador monta Frete temporario
  -> FreteBO.previsualizarFiscal()
  -> Java monta TaxPreviewRequest
  -> POST /api/v1/tax/preview
  -> Go valida payload
  -> Go escolhe regra
  -> Go calcula impostos
  -> Go retorna JSON
  -> Java devolve JSON para tela
```

Caracteristica:

```text
Nao salva frete e nao salva simulacao oficial.
```

## Fluxo De Simulate Oficial

```text
FreteBO.emitir()
  -> insere frete no banco Java
  -> commit da transacao
  -> calcularFiscalAposEmissao()
  -> TaxSimulationRequest.fromFrete()
  -> POST /api/v1/tax/simulate
  -> Go valida payload
  -> Go escolhe regra
  -> Go calcula impostos
  -> Go salva fiscal_simulations
  -> Go salva fiscal_simulation_tax_details
  -> Java recebe response
  -> FreteDAO.atualizarResumoFiscal()
```

Se o Motor Fiscal falhar:

```text
Frete continua emitido.
Java marca status_fiscal = ERRO.
Erro fica registrado no motivo fiscal/log.
```

## Campos Atualizados No Frete Java

O response do Go alimenta:

- aliquota ICMS;
- valor ICMS;
- aliquota IBS;
- valor IBS;
- aliquota CBS;
- valor CBS;
- valor total;
- CFOP;
- motivo CFOP;
- status fiscal;
- regra aplicada;
- total de tributos;
- valor total estimado.

Status final de sucesso:

```text
status_fiscal = CALCULADO
```

## Erros Padronizados

| Codigo | HTTP | Significado |
|---|---:|---|
| `UNAUTHORIZED` | 401 | Token ausente ou invalido |
| `BAD_REQUEST` | 400 | JSON invalido |
| `VALIDATION_ERROR` | 422 | Payload invalido |
| `FISCAL_RULE_NOT_FOUND` | 404 | Nenhuma regra vigente |
| `FISCAL_RULE_CONFLICT` | 409 | Mais de uma regra compativel |
| `FISCAL_RULE_INCOMPLETE` | 500 | Regra sem impostos obrigatorios |
| `UNSUPPORTED_CALCULATION_BASIS` | 500 | Base de calculo nao suportada |
| `INTERNAL_ERROR` | 500 | Erro inesperado |

## Como Explicar Em Uma Apresentacao

Explicacao curta:

```text
O Motor Fiscal e um microservico Go chamado pelo sistema Java sempre que o frete precisa de calculo tributario. Ele recebe um payload simples com UF origem, UF destino, valor do frete, tipo de cliente e tipo de operacao. A partir disso, busca uma regra fiscal vigente no banco, calcula ICMS, IBS e CBS usando decimal, retorna CFOP e totais, e salva a memoria de calculo para auditoria.
```

Explicacao por camadas:

```text
Handler:
  HTTP, JSON, status code e erros.

Validator:
  consistencia do payload.

Service:
  regra de negocio e orquestracao.

Rule Service:
  escolha da regra fiscal.

Calculator:
  calculo matematico dos tributos.

Repository:
  leitura de regras e gravacao de auditoria.
```

## Pontos Fortes

- microservico separado por responsabilidade;
- contrato REST claro;
- autenticacao por API Key;
- rastreabilidade por Correlation ID;
- calculo monetario com decimal;
- motor de regras baseado em banco;
- regras versionadas e com vigencia;
- auditoria de simulacao;
- memoria de calculo por imposto;
- pronto para evoluir sem mexer diretamente nas telas Java.

## Pontos De Atencao

- as regras fallback sao demonstrativas;
- `PENDING_REVIEW` deve ser tratado como alerta em producao;
- cache real ainda nao esta implementado, apesar do campo `from_cache`;
- o Java ignora `calculation_details` no DTO atual, mas o Go salva os detalhes no banco;
- se `INTERNAL_API_KEY` e `motor.fiscal.api.key` divergirem, o Java recebera 401;
- se nao houver regra vigente, o Java marcara erro fiscal no frete.

## Roteiro De Estudo No Codigo

1. Abra `cmd/api/main.go`.
2. Veja `internal/handler/routes.go`.
3. Leia `internal/handler/tax_handler.go`.
4. Leia `internal/validator/tax_validator.go`.
5. Leia `internal/service/tax_service.go`.
6. Leia `internal/service/fiscal_rule_service.go`.
7. Leia `internal/service/tax_calculator.go`.
8. Leia os repositories.
9. Leia as migrations.
10. Volte ao Java e leia `FreteBO.calcularFiscal()`.

## Perguntas Que Voce Deve Saber Responder

- Por que existe um microservico fiscal separado?
- Qual a diferenca entre preview e simulate?
- Como a API escolhe uma regra fiscal?
- O que significa prioridade da regra?
- Por que usar decimal em vez de float?
- Onde a auditoria fica salva?
- Como o Java autentica no Go?
- O que e correlation ID?
- O que acontece se nao houver regra?
- O que acontece se a API estiver fora do ar?


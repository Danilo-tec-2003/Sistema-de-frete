# Guia de Estudo: Relatorios e Motor Fiscal

Este documento resume os dois pontos mais importantes para explicar tecnicamente o sistema:

1. Como os relatorios do sistema de fretes sao montados e gerados.
2. Qual e o papel da API Go `Motor_fiscal` e como ela se integra ao Java/JSP.

Os caminhos citados consideram dois projetos locais:

- Sistema principal: `/home/danilo/Documentos/Projetos/sistema-fretes`
- Motor Fiscal Go: `/home/danilo/Documentos/Projetos/Motor_fiscal`

## Visao Geral Da Arquitetura

O sistema principal e uma aplicacao Java Web com JSP, Servlets, DAOs JDBC e PostgreSQL. Ele concentra a operacao de fretes: cadastro de clientes, motoristas, veiculos, emissao de fretes, ocorrencias, status e relatorios.

O Motor Fiscal e um microservico Go separado. Ele recebe dados fiscais basicos de um frete, seleciona uma regra fiscal vigente no proprio banco dele, calcula ICMS, IBS, CBS, CFOP e totais, salva auditoria da simulacao e devolve JSON para o sistema Java.

Fluxo macro:

```text
Usuario
  -> JSP/Servlet Java
  -> BO Java
  -> DAO Java/PostgreSQL do sistema de fretes
  -> relatorios PDF ou chamada HTTP ao Motor Fiscal Go
```

## Parte 1: Relatorios

### Objetivo Dos Relatorios

A area de relatorios gera documentos PDF operacionais e gerenciais a partir dos dados cadastrados no sistema. Ela usa JasperReports para transformar listas de objetos Java em PDFs.

Os relatorios atuais cobrem:

- fretes em aberto;
- romaneio de carga;
- documento individual de frete;
- fretes por cliente;
- ocorrencias por periodo;
- desempenho de motoristas.

### Arquivos Principais

| Arquivo | Responsabilidade |
|---|---|
| `src/main/webapp/jsp/relatorios/relatorios.jsp` | Tela catalogo com formularios e filtros |
| `src/main/java/br/com/gw/relatorio/RelatorioControlador.java` | Servlet `/relatorios`, recebe filtros e devolve PDF |
| `src/main/java/br/com/gw/relatorio/RelatorioBO.java` | Valida filtros, calcula totais e chama Jasper |
| `src/main/java/br/com/gw/relatorio/RelatorioDAO.java` | Consultas SQL especificas dos relatorios |
| `src/main/java/br/com/gw/relatorio/*Relatorio.java` | DTOs usados como linhas dos relatorios |
| `src/main/resources/report/*.jrxml` | Templates JasperReports |
| `build.gradle` | Dependencia `net.sf.jasperreports:jasperreports:6.20.6` |

### Fluxo Completo De Geracao

```text
1. Usuario acessa /relatorios
2. RelatorioControlador carrega catalogos de filtros
3. relatorios.jsp exibe os cards e formularios
4. Usuario escolhe um relatorio e envia acao via GET
5. RelatorioControlador identifica a acao
6. RelatorioBO valida parametros e chama RelatorioDAO
7. RelatorioDAO consulta o banco e monta DTOs
8. RelatorioBO monta parametros do Jasper
9. RelatorioBO compila o .jrxml em runtime
10. JasperFillManager preenche o relatorio
11. JasperExportManager exporta PDF
12. Servlet responde application/pdf inline
```

O controller usa `Content-Disposition: inline`, entao o PDF abre no navegador em vez de baixar automaticamente.

### Entrada Pela Tela

A JSP `relatorios.jsp` trabalha como um catalogo. Cada card tem um formulario com:

- `action="${contextPath}/relatorios"`
- `method="get"`
- `target="_blank"`
- um campo hidden `acao`

Exemplo conceitual:

```text
acao=fretesAbertos
acao=romaneioCarga
acao=documentoFrete
acao=fretesCliente
acao=ocorrenciasPeriodo
acao=desempenhoMotoristas
```

O `RelatorioControlador` le `acao` e direciona para o metodo correto.

### Catalogo De Relatorios

| Relatorio | Acao HTTP | Template JRXML | Fonte de dados | Objetivo |
|---|---|---|---|---|
| Fretes em aberto | `fretesAbertos` | `fretes_abertos.jrxml` | `listarFretesEmAberto()` | Acompanhar fretes nos status Emitido, Saida Confirmada e Em Transito |
| Romaneio de carga | `romaneioCarga` | `romaneio_carga.jrxml` | `listarRomaneio()` e `buscarCabecalhoRomaneio()` | Conferencia por motorista e data de operacao |
| Documento de frete | `documentoFrete` | `documento_frete.jrxml` | `buscarDocumentoFrete()` | Impressao individual completa do frete |
| Fretes por cliente | `fretesCliente` | `fretes_cliente.jrxml` | `listarFretesPorCliente()` | Extrato por cliente no periodo |
| Ocorrencias por periodo | `ocorrenciasPeriodo` | `ocorrencias_periodo.jrxml` | `listarOcorrenciasPorPeriodo()` | Auditoria de eventos e excecoes dos fretes |
| Desempenho de motoristas | `desempenhoMotoristas` | `desempenho_motoristas.jrxml` | `listarDesempenhoMotoristas()` | Indicadores de entregas, atrasos, peso, volumes e valor |

### Papel Do Controller

`RelatorioControlador` e fino. Ele nao monta SQL e nao conhece Jasper profundamente. As principais responsabilidades dele sao:

- receber `GET /relatorios`;
- decidir se deve abrir o catalogo ou gerar PDF;
- converter parametros de string para `int` e `LocalDate`;
- recuperar o usuario logado da sessao;
- chamar o `RelatorioBO`;
- escrever o PDF no `HttpServletResponse`;
- tratar `NegocioException` e voltar para a tela com mensagem.

Exemplo de metodo importante:

```java
private void enviarPdf(HttpServletResponse resp, byte[] pdf, String nomeArquivo)
        throws IOException {
    resp.reset();
    resp.setContentType("application/pdf");
    resp.setHeader("Content-Disposition", "inline; filename=\"" + nomeArquivo + "\"");
    resp.setContentLength(pdf.length);
    resp.getOutputStream().write(pdf);
    resp.getOutputStream().flush();
}
```

### Papel Do BO

`RelatorioBO` concentra a regra de negocio dos relatorios:

- valida filtros obrigatorios;
- impede periodo invertido;
- busca dados no DAO;
- calcula totais para rodape/cabecalho;
- monta parametros comuns;
- carrega e compila o `.jrxml`;
- exporta o PDF.

Parametros comuns:

```text
DATA_GERACAO
USUARIO
```

Parametros especificos por relatorio:

```text
TITULO
SUBTITULO
PERIODO
TOTAL_REGISTROS
TOTAL_FRETES
TOTAL_PESO
TOTAL_VOLUMES
TOTAL_VALOR
TOTAL_OCORRENCIAS
TOTAL_ENTREGAS
TOTAL_NO_PRAZO
```

O ponto central e o metodo `gerarPdf`:

```text
report/<arquivo>.jrxml
  -> JasperCompileManager.compileReport()
  -> JRBeanCollectionDataSource
  -> JasperFillManager.fillReport()
  -> JasperExportManager.exportReportToPdf()
```

### Papel Do DAO

`RelatorioDAO` e exclusivo para consultas dos relatorios. Ele nao devolve entidades completas do sistema, mas objetos prontos para o Jasper.

Exemplos:

- `FreteAbertoRelatorio`
- `RomaneioCargaRelatorio`
- `DocumentoFreteRelatorio`
- `FreteClienteRelatorio`
- `OcorrenciaPeriodoRelatorio`
- `DesempenhoMotoristaRelatorio`

Essa separacao facilita explicar o desenho:

```text
Entidades de dominio: Cliente, Frete, Motorista, Veiculo
DTOs de relatorio: objetos moldados para impressao
```

### Como O Jasper Le Os Dados

O Jasper recebe uma colecao de beans Java. Os campos do JRXML acessam propriedades pelos getters.

Exemplo conceitual:

```text
DTO: getNumero()
JRXML: $F{numero}

DTO: getValorTotal()
JRXML: $F{valorTotal}

Parametro Java: params.put("TITULO", "Fretes em aberto")
JRXML: $P{TITULO}
```

Por isso os nomes nos DTOs precisam bater com os campos configurados no `.jrxml`.

### Como Adicionar Um Novo Relatorio

Passo a passo recomendado:

1. Criar um DTO em `br.com.gw.relatorio`, por exemplo `FreteFiscalRelatorio`.
2. Criar um metodo no `RelatorioDAO` que retorna `List<FreteFiscalRelatorio>`.
3. Criar um metodo no `RelatorioBO` para validar filtros, buscar dados e montar parametros.
4. Criar o template `src/main/resources/report/novo_relatorio.jrxml`.
5. Adicionar uma `acao` no `RelatorioControlador`.
6. Adicionar um card/formulario em `relatorios.jsp`.
7. Testar com dados existentes e verificar se o PDF abre.

### Pontos De Atencao Dos Relatorios

- Os `.jrxml` sao compilados em runtime. Isso facilita desenvolvimento, mas em producao pode ser melhor precompilar para `.jasper`.
- O sistema usa `JRBeanCollectionDataSource`, entao cada relatorio trabalha bem com listas de DTOs.
- Erros de nome de campo no JRXML costumam aparecer em tempo de geracao, nao em compilacao Java.
- Os filtros de periodo aceitam `YYYY-MM-DD`, vindo dos inputs HTML `type=date`.
- O catalogo limita selects grandes: 500 clientes, 500 motoristas e 200 fretes.

## Parte 2: Motor Fiscal Go

### Objetivo Do Motor Fiscal

O Motor Fiscal e uma API REST em Go criada para centralizar regras fiscais e calculos tributarios relacionados ao frete.

Ele existe para evitar que o sistema Java tenha regras fiscais espalhadas em servlets, JSPs ou DAOs. A ideia tecnica e separar responsabilidades:

```text
Sistema Java:
  Operacao de fretes, telas, cadastros, status, ocorrencias e persistencia do frete.

Motor Fiscal Go:
  Regras fiscais, calculo tributario, CFOP, memoria de calculo e auditoria.
```

### O Que O Motor Fiscal Faz

- recebe dados basicos de um frete;
- valida o payload;
- seleciona regra fiscal vigente;
- calcula ICMS, IBS e CBS;
- calcula total de tributos;
- calcula total com tributos;
- determina CFOP pela regra aplicada;
- retorna metadados da regra;
- salva simulacoes oficiais no banco do Motor Fiscal;
- salva detalhes de memoria de calculo por imposto;
- padroniza erros em JSON;
- usa `X-API-Key` para autenticacao interna;
- usa `X-Correlation-ID` para rastreabilidade.

### O Que O Motor Fiscal Nao Faz

- nao cadastra fretes no sistema principal;
- nao altera status operacional do frete;
- nao substitui o banco do sistema Java;
- nao emite CT-e real;
- nao guarda clientes, motoristas ou veiculos do sistema principal;
- no codigo atual, nao implementa cache real, embora o campo `from_cache` exista no contrato.

### Arquivos Principais No Projeto Go

| Arquivo | Responsabilidade |
|---|---|
| `cmd/api/main.go` | Sobe a API, conecta no PostgreSQL e injeta dependencias |
| `internal/config/config.go` | Le `APP_PORT`, `INTERNAL_API_KEY` e `DATABASE_URL` |
| `internal/handler/routes.go` | Define rotas HTTP |
| `internal/handler/tax_handler.go` | Handlers de calculo fiscal |
| `internal/service/tax_service.go` | Orquestra regra fiscal, calculo e persistencia |
| `internal/service/tax_calculator.go` | Calcula impostos com decimal |
| `internal/service/fiscal_rule_service.go` | Seleciona regra fiscal aplicavel |
| `internal/repository/fiscal_rule_repository.go` | Busca regras, condicoes e impostos |
| `internal/repository/fiscal_simulation_repository.go` | Salva simulacoes e detalhes de calculo |
| `internal/validator/tax_validator.go` | Valida payloads de tax |
| `internal/middleware/api_key.go` | Protege endpoints por `X-API-Key` |
| `internal/middleware/correlation_id.go` | Gera ou propaga `X-Correlation-ID` |
| `migrations/*.sql` | Estrutura do banco fiscal e seeds demonstrativos |

### Subida Da API

O `main.go` faz:

```text
1. config.Load()
2. cria pgxpool com DATABASE_URL
3. testa conexao com Ping
4. instancia repositories
5. instancia services
6. instancia handlers
7. monta router
8. sobe http.ListenAndServe
```

Dependencias importantes:

- `net/http` para servidor HTTP;
- `pgxpool` para PostgreSQL;
- `shopspring/decimal` para calculo monetario sem perda de precisao.

### Rotas Do Motor Fiscal

| Metodo | Rota | Consumida pelo Java hoje? | Responsabilidade |
|---|---|---|---|
| GET | `/health` | Nao diretamente | Verifica se a API esta online |
| POST | `/api/v1/tax/preview` | Sim | Previa fiscal antes de salvar o frete |
| POST | `/api/v1/tax/simulate` | Sim | Calculo oficial de um frete salvo |
| POST | `/api/v1/tax/compare` | Nao | Compara carga atual com cenario de reforma |
| POST | `/api/v1/tax/batch` | Nao | Calcula varios fretes em lote |
| POST | `/api/v1/cte/validate` | Nao | Valida dados minimos para CT-e |

Os endpoints `/api/v1/*` exigem `X-API-Key`. O `/health` nao exige.

### Contrato Do Request Fiscal

O Java envia para `simulate`:

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

| Campo | Origem no sistema Java | Observacao |
|---|---|---|
| `freight_id` | `Frete.id` | Obrigatorio no `simulate`, ausente no `preview` |
| `operation_date` | data de emissao ou data atual | Formato `YYYY-MM-DD` |
| `origin_uf` | `Frete.ufOrigem` | UF de origem |
| `destination_uf` | `Frete.ufDestino` | UF de destino |
| `freight_value` | `Frete.valorFrete` | String monetaria para preservar precisao |
| `customer_type` | Documento do destinatario | `PF` para CPF, `PJ` para CNPJ |
| `operation_type` | Comparacao entre UFs | `INTERNA` ou `INTERESTADUAL` |

No sistema Java existem tres tipos operacionais: `MUNICIPAL`, `ESTADUAL` e `INTERESTADUAL`. Para a API Go, `MUNICIPAL` e `ESTADUAL` sao enviados como `INTERNA`, porque ambos ocorrem dentro da mesma UF.

### Contrato Da Response Fiscal

Resposta principal:

```json
{
  "freight_id": 1001,
  "base_value": "3500.00",
  "icms": { "rate": "12.00", "amount": "420.00" },
  "ibs": { "rate": "3.60", "amount": "126.00" },
  "cbs": { "rate": "0.90", "amount": "31.50" },
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

O Go tambem retorna `calculation_details`, com memoria de calculo por imposto. O Java atual nao modela esse campo na classe `TaxSimulationResponse`, entao ele e ignorado pelo Gson no sistema de fretes. Mesmo assim, o Motor Fiscal salva esses detalhes no banco dele.

### Como O Calculo E Feito No Go

O calculo usa a biblioteca `shopspring/decimal`.

Formula basica por imposto:

```text
effective_base_value = base_value - reducao_de_base
amount = effective_base_value * rate / 100
```

Depois:

```text
total_tax = ICMS + IBS + CBS
total_with_tax = freight_value + total_tax
```

O motor exige que a regra tenha os tres impostos:

- `ICMS`
- `IBS`
- `CBS`

Se faltar algum, retorna erro tecnico `FISCAL_RULE_INCOMPLETE`.

### Motor De Regras Fiscais

O Motor Fiscal nao escolhe aliquotas fixas no codigo. Ele busca regras no banco.

Tabelas principais:

| Tabela | Papel |
|---|---|
| `fiscal_rules` | Cabecalho da regra, vigencia, prioridade, status, CFOP |
| `fiscal_rule_conditions` | Condicoes que a requisicao precisa cumprir |
| `fiscal_rule_taxes` | Impostos, aliquotas e reducao de base |
| `fiscal_rule_sources` | Fonte legal ou referencia da regra |
| `fiscal_rule_accounting_reviews` | Revisao contabil da regra |
| `fiscal_simulations` | Historico resumido das simulacoes oficiais |
| `fiscal_simulation_tax_details` | Detalhes de memoria de calculo |

Algoritmo de selecao:

```text
1. Buscar regras ativas em fiscal_rules
2. Considerar status APPROVED ou PENDING_REVIEW
3. Filtrar por vigencia da operation_date
4. Carregar condicoes e impostos da regra
5. Avaliar condicoes contra o payload
6. Ordenar por prioridade menor primeiro
7. Em empate, escolher valid_from mais recente
8. Se duas regras empatam em prioridade e valid_from, retornar conflito
9. Converter regra engine em FiscalRule
10. Calcular tributos
```

Operadores aceitos nas condicoes:

- `EQUALS`
- `NOT_EQUALS`
- `IN`
- `BETWEEN`

Campos avaliaveis:

- `operation_date`
- `origin_uf`
- `destination_uf`
- `operation_type`
- `customer_type`

### Regras Fallback Demonstrativas

Existe uma migration `005_seed_demonstrative_fallback_rules.sql` com regras fallback para o MVP.

Elas servem para permitir demonstracao nacional mesmo quando nao existe uma regra especifica por UF.

Caracteristicas:

- prioridade `900`;
- status `PENDING_REVIEW`;
- fonte marcada como `INTERNAL_NOTE`;
- revisao contabil pendente;
- nao devem ser tratadas como regra fiscal oficial de producao.

Como explicar:

```text
Regras especificas devem ter prioridade menor, como 100.
Fallback usa prioridade alta numericamente, como 900.
Como o motor ordena prioridade crescente, regras especificas vencem fallback.
```

### Erros Padronizados

Formato de erro:

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

Erros relevantes:

| Codigo | HTTP | Significado |
|---|---:|---|
| `UNAUTHORIZED` | 401 | API Key ausente ou invalida |
| `BAD_REQUEST` | 400 | JSON malformado |
| `VALIDATION_ERROR` | 422 | Payload invalido |
| `FISCAL_RULE_NOT_FOUND` | 404 | Nenhuma regra fiscal vigente |
| `FISCAL_RULE_CONFLICT` | 409 | Mais de uma regra compativel empatada |
| `FISCAL_RULE_INCOMPLETE` | 500 | Regra sem ICMS, IBS ou CBS |
| `UNSUPPORTED_CALCULATION_BASIS` | 500 | Base de calculo nao suportada |

### Integracao No Sistema Java

Arquivos Java principais:

| Arquivo | Papel |
|---|---|
| `br/com/gw/motorfiscal/MotorFiscalConfig.java` | Le URL, API key e timeout |
| `br/com/gw/motorfiscal/MotorFiscalClient.java` | Cliente HTTP com `HttpURLConnection` |
| `br/com/gw/motorfiscal/TaxSimulationRequest.java` | Payload oficial com `freight_id` |
| `br/com/gw/motorfiscal/TaxPreviewRequest.java` | Payload de previa sem `freight_id` |
| `br/com/gw/motorfiscal/TaxSimulationResponse.java` | Resposta fiscal consumida pelo Java |
| `br/com/gw/frete/FreteBO.java` | Chama Motor Fiscal e persiste resultado |
| `br/com/gw/frete/FreteDAO.java` | Atualiza campos fiscais no banco de fretes |
| `br/com/gw/frete/FreteControlador.java` | Endpoints de preview e recalculo fiscal |
| `jsp/Frete/FormFrete.jsp` | Botao/JS para previa fiscal |
| `jsp/Frete/FreteDetalhe.jsp` | Exibe resumo fiscal e acao de recalculo |

Configuracao no Java:

```text
motor.fiscal.base.url
motor.fiscal.api.key
motor.fiscal.timeout.ms
```

Ou por ambiente:

```text
MOTOR_FISCAL_BASE_URL
MOTOR_FISCAL_API_KEY
MOTOR_FISCAL_TIMEOUT_MS
```

O Java envia headers:

```text
Content-Type: application/json; charset=UTF-8
Accept: application/json
X-API-Key: <token>
X-Correlation-ID: frete-<id> ou frete-preview-<timestamp>
```

### Fluxo De Preview Fiscal

Preview acontece antes de salvar o frete.

```text
FormFrete.jsp
  -> POST /fretes acao=previewFiscal
  -> FreteControlador.montarFrete()
  -> FreteBO.previsualizarFiscal()
  -> valida campos minimos
  -> infere tipo_operacao e tipo_destinatario
  -> MotorFiscalClient.preview()
  -> Go POST /api/v1/tax/preview
  -> Go calcula e responde JSON
  -> Java devolve JSON para a tela
  -> JSP preenche campos readonly de previa
```

Importante: preview nao grava frete no banco do sistema Java.

### Fluxo De Calculo Oficial Na Emissao

Quando o frete e emitido:

```text
FreteBO.emitir()
  -> valida campos, datas, valores, motorista, veiculo e peso
  -> prepara campos fiscais como PENDENTE
  -> abre transacao JDBC
  -> gera numero FRT-AAAA-NNNNN
  -> insere frete
  -> commit
  -> calcularFiscalAposEmissao()
  -> MotorFiscalClient.simulate()
  -> Go POST /api/v1/tax/simulate
  -> Go seleciona regra, calcula e salva auditoria
  -> Java atualiza resumo fiscal do frete
```

Se o Motor Fiscal falhar depois que o frete foi salvo, o frete continua emitido. O Java registra `status_fiscal=ERRO` e mantem o fluxo operacional vivo.

### Campos Fiscais Persistidos No Sistema De Fretes

Na tabela `frete` do sistema Java:

```text
tipo_operacao
tipo_destinatario
cfop
motivo_cfop
status_fiscal
regra_fiscal_aplicada
aliquota_icms
valor_icms
aliquota_ibs
valor_ibs
aliquota_cbs
valor_cbs
total_tributos
valor_total_estimado
valor_total
```

Status fiscal:

| Status | Significado |
|---|---|
| `PENDENTE` | Frete criado, aguardando calculo |
| `CALCULADO` | Motor Fiscal calculou com sucesso |
| `ERRO` | Integracao fiscal falhou |
| `VALIDADO_CTE` | Reservado para validacao futura de CT-e |

### Persistencia No Banco Do Motor Fiscal

Quando usa `simulate`, o Go salva:

- uma linha em `fiscal_simulations`;
- uma linha por imposto em `fiscal_simulation_tax_details`.

Isso permite auditoria:

```text
Qual regra foi aplicada?
Qual aliquota foi usada?
Qual base efetiva foi considerada?
Qual formula gerou o valor?
Quando a simulacao foi feita?
```

O endpoint `preview` calcula, mas nao salva simulacao oficial.

### Como Explicar Tecnicamente Em Uma Apresentacao

Uma explicacao curta e boa:

```text
O sistema Java cuida da operacao logistica. Quando precisa calcular tributos,
ele envia um payload enxuto para um microservico Go chamado Motor Fiscal.
Esse servico valida a requisicao, seleciona uma regra fiscal vigente no banco,
calcula ICMS, IBS e CBS com decimal, retorna CFOP e totais, e salva a memoria
de calculo para auditoria. O Java persiste apenas o resumo fiscal no frete.
```

Explicacao por camadas:

```text
JSP: captura dados e exibe previa.
Servlet: recebe a acao do usuario.
BO: valida negocio e chama integracao.
Client HTTP: serializa JSON e envia para Go.
API Go: valida, escolhe regra, calcula e responde.
Repository Go: salva auditoria fiscal.
DAO Java: atualiza resumo fiscal do frete.
```

### Pontos Fortes Da Arquitetura

- separa regra fiscal da operacao de frete;
- evita calculo tributario espalhado no Java/JSP;
- usa contrato HTTP claro;
- usa API Key interna;
- usa correlation ID para rastreabilidade;
- usa decimal para valores monetarios;
- salva memoria de calculo no Motor Fiscal;
- permite evoluir regras fiscais sem mexer diretamente nas telas.

### Pontos De Atencao

- As regras fallback sao demonstrativas, nao oficiais.
- O Java atual consome somente `preview` e `simulate`.
- O campo `calculation_details` retornado pelo Go nao e persistido no banco Java, apenas no banco do Motor Fiscal.
- O `from_cache` existe no contrato, mas o codigo atual retorna `false` e nao implementa cache real.
- Se a API Go estiver fora do ar ou a API key estiver errada, o frete ainda pode ser emitido, mas fica com `status_fiscal=ERRO`.
- O arquivo `db.properties` do sistema Java precisa ter a configuracao correta do Motor Fiscal ou as variaveis de ambiente equivalentes.

### Checklist Para Estudar No Codigo

Relatorios:

1. Comece por `relatorios.jsp` para ver as acoes disponiveis.
2. Va para `RelatorioControlador` e acompanhe o switch da `acao`.
3. Leia o metodo correspondente no `RelatorioBO`.
4. Leia a query equivalente no `RelatorioDAO`.
5. Abra o `.jrxml` usado e compare campos com o DTO.

Motor Fiscal:

1. No Java, comece por `FreteBO.calcularFiscal`.
2. Veja como `TaxSimulationRequest.fromFrete()` monta o payload.
3. Leia `MotorFiscalClient.post()`.
4. No Go, siga `routes.go -> tax_handler.go -> tax_service.go`.
5. Leia `FiscalRuleService.FindRule()`.
6. Leia `CalculateTaxes()`.
7. Veja `FiscalSimulationRepository.Save()`.
8. Volte para `FreteDAO.atualizarResumoFiscal()` no Java.

### Perguntas Que Voce Deve Saber Responder

Relatorios:

- Por que existe `RelatorioBO` separado de `RelatorioDAO`?
- Por que os relatorios usam DTOs em vez das entidades completas?
- Como o Jasper encontra os campos dos objetos?
- O que acontece se um filtro obrigatorio nao for informado?
- Como um PDF e enviado para o navegador?

Motor Fiscal:

- Por que o calculo fiscal ficou em um microservico Go?
- Qual diferenca entre `preview` e `simulate`?
- Como o Java autentica na API Go?
- O que e `X-Correlation-ID`?
- Como a regra fiscal e escolhida?
- Onde a auditoria do calculo fica salva?
- O que acontece se nao houver regra fiscal?
- O que acontece se a API falhar apos a emissao do frete?


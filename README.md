# Sistema De Fretes - FiscalMove FMS

Sistema web Java para gestao operacional de fretes, clientes, motoristas,
veiculos, ocorrencias, relatorios e integracao fiscal com uma API Go chamada
Motor Fiscal.

O projeto representa um fluxo completo de uma transportadora: cadastro das
entidades principais, emissao do frete, acompanhamento do status operacional,
registro de ocorrencias, geracao de documentos em PDF e calculo fiscal
integrado.

## Contexto Do Projeto

Este sistema faz parte de uma proposta tecnica formada por tres projetos:

| Projeto | Papel |
|---|---|
| `analise-prs` | Diagnostico em Python feito sobre PRs internos para identificar dores recorrentes |
| `sistema-fretes` | Sistema Java principal, responsavel pela operacao de fretes |
| `Motor_fiscal` | API Go dedicada a regras fiscais, simulacoes, calculos e auditoria |

A ideia do Motor Fiscal nasceu antes da implementacao da API. Primeiro foi
feito um levantamento com Python em PRs internos da empresa para entender
padroes de manutencao, recorrencia de problemas e pontos de maior custo
tecnico.

Na analise local foram processados:

| Indicador | Resultado |
|---|---:|
| PRs coletados | 13.397 |
| Repositorios analisados | 2 |
| Autores identificados | 55 |
| Periodo analisado | 2019-02-01 a 2026-04-15 |
| Registros com qualidade para analise aprofundada | 274 |

As categorias tecnicas mais relevantes encontradas foram banco, relatorios,
performance e regra de negocio. Esse diagnostico ajudou a justificar a
separacao da inteligencia fiscal em um servico proprio.

## Problema Resolvido

Em um sistema de fretes, regras fiscais, valores tributarios e validacoes de
negocio podem ficar espalhados entre telas, servlets, classes de negocio e
banco de dados. Isso aumenta o custo de manutencao e dificulta explicar por que
um determinado imposto foi calculado.

Este projeto resolve esse problema dividindo responsabilidades:

- o Java cuida da operacao do frete;
- o PostgreSQL do sistema guarda os dados operacionais;
- os relatorios consolidam informacoes em PDFs;
- o Motor Fiscal calcula impostos e registra memoria fiscal;
- o projeto `analise-prs` documenta a origem da decisao arquitetural.

## Stack Tecnica

| Area | Tecnologia |
|---|---|
| Linguagem principal | Java 8 |
| Web | Servlets, JSP, JSTL |
| Build | Gradle |
| Servidor local | Gretty com Tomcat 9 |
| Banco | PostgreSQL |
| Pool/conexao | Apache Commons DBCP2 |
| Relatorios | JasperReports |
| JSON | Gson |
| Integracao fiscal | HTTP para API Go |

## Como Rodar

Compile o projeto:

```bash
./gradlew clean war
```

Rode localmente com Gretty:

```bash
./gradlew appRun
```

Acesse:

```text
http://localhost:8080/SISTEMA-FRETES
```

Configuracoes principais:

```text
src/main/resources/db.properties
```

Exemplo local:

```properties
db.url=jdbc:postgresql://localhost:5432/DB_TMS
db.user=postgres
db.password=postgres
db.driver=org.postgresql.Driver

motor.fiscal.base.url=http://localhost:8080
motor.fiscal.api.key=dev-token
motor.fiscal.timeout.ms=5000
```

## Banco De Dados

Os scripts SQL ficam em:

```text
db/
```

Ordem recomendada:

```text
01_schema.sql
02_indexes.sql
03_seed_data.sql
04_migration_regras_operacionais_fiscais.sql
05_migration_cliente_logo.sql
```

Principais tabelas:

| Tabela | Papel |
|---|---|
| `usuario` | Login, senha e perfil de acesso |
| `cliente` | Remetentes e destinatarios |
| `motorista` | Motoristas, CPF, CNH, categoria e status |
| `veiculo` | Frota, tipo, capacidade e status |
| `frete` | Operacao principal do sistema |
| `ocorrencia_frete` | Historico operacional do frete |

O banco do `sistema-fretes` nao guarda as regras fiscais completas. Ele guarda
apenas o resumo retornado pelo Motor Fiscal, como CFOP, aliquotas, valores,
total de tributos, status fiscal e regra aplicada.

## Modulos Do Sistema

### Autenticacao

O sistema possui login, cadastro de usuario e filtro de autenticacao.

Classes principais:

```text
br.com.gw.nucleo.login.LoginControlador
br.com.gw.nucleo.login.LoginBO
br.com.gw.nucleo.login.LoginDAO
br.com.gw.nucleo.AuthFilter
```

### Clientes

Gerencia clientes remetentes e destinatarios, com validacao de CPF/CNPJ,
enderecos, contatos, status e dados visuais como logo.

Classes principais:

```text
br.com.gw.cliente.ClienteControlador
br.com.gw.cliente.ClienteBO
br.com.gw.cliente.ClienteDAO
```

### Motoristas

Gerencia motoristas, CPF, CNH, categoria, vinculo, status e regras de
compatibilidade operacional.

Classes principais:

```text
br.com.gw.motorista.MotoristaControlador
br.com.gw.motorista.MotoristaBO
br.com.gw.motorista.MotoristaDAO
```

### Veiculos

Gerencia veiculos, placa, tipo, capacidade, status e disponibilidade para
fretes.

Classes principais:

```text
br.com.gw.veiculos.VeiculoControlador
br.com.gw.veiculos.VeiculoBO
br.com.gw.veiculos.VeiculoDAO
```

### Fretes

Modulo central do sistema. Emite fretes, controla status, valida motorista,
veiculo, peso, datas, valores, origem, destino e ocorrencias.

Classes principais:

```text
br.com.gw.frete.FreteControlador
br.com.gw.frete.FreteBO
br.com.gw.frete.FreteDAO
```

Maquina de estados operacional:

```text
EMITIDO -> SAIDA_CONFIRMADA -> EM_TRANSITO -> ENTREGUE
                                  |
                                  -> NAO_ENTREGUE

Qualquer estado aberto -> CANCELADO
```

Durante a emissao, o sistema:

1. valida campos obrigatorios;
2. valida datas, valores e peso;
3. valida motorista ativo e CNH;
4. valida veiculo disponivel;
5. valida compatibilidade motorista/veiculo;
6. gera numero do frete;
7. grava o frete em transacao;
8. chama o Motor Fiscal para calcular o resumo tributario.

## Integracao Com O Motor Fiscal

A integracao fica no pacote:

```text
br.com.gw.motorfiscal
```

Classes principais:

| Classe | Papel |
|---|---|
| `MotorFiscalConfig` | Le configuracoes de `db.properties` ou variaveis de ambiente |
| `MotorFiscalClient` | Cliente HTTP usado pelo Java para chamar a API Go |
| `TaxSimulationRequest` | Monta payload de simulacao a partir do frete |
| `TaxPreviewRequest` | Monta payload de preview antes de salvar |
| `TaxSimulationResponse` | Representa o retorno fiscal da API |
| `MotorFiscalException` | Padroniza erros retornados pela API |

Fluxo principal:

```text
Tela de frete
  -> FreteControlador
  -> FreteBO
  -> MotorFiscalClient
  -> POST /api/v1/tax/simulate
  -> Motor Fiscal Go
  -> resposta JSON
  -> FreteDAO.atualizarResumoFiscal
  -> tabela frete
```

Endpoints usados:

| Endpoint | Uso no sistema Java |
|---|---|
| `POST /api/v1/tax/preview` | Previa fiscal antes de gravar |
| `POST /api/v1/tax/simulate` | Calculo fiscal definitivo do frete |

Seguranca da integracao:

- o navegador nao chama o Motor Fiscal diretamente;
- o token fica no backend Java;
- o Java envia `X-API-Key`;
- o Java envia `X-Correlation-ID` para rastreabilidade;
- erros fiscais nao expoem stack trace para o usuario.

## Relatorios

Os relatorios sao um dos pontos principais do sistema. Eles sao gerados com
JasperReports a partir de templates JRXML versionados no projeto.

Templates:

```text
src/main/resources/report/fretes_abertos.jrxml
src/main/resources/report/romaneio_carga.jrxml
src/main/resources/report/documento_frete.jrxml
src/main/resources/report/fretes_cliente.jrxml
src/main/resources/report/ocorrencias_periodo.jrxml
src/main/resources/report/desempenho_motoristas.jrxml
```

Classes principais:

```text
br.com.gw.relatorio.RelatorioControlador
br.com.gw.relatorio.RelatorioBO
br.com.gw.relatorio.RelatorioDAO
```

Fluxo de geracao:

```text
Usuario acessa /relatorios
  -> RelatorioControlador recebe filtros
  -> RelatorioBO valida entrada
  -> RelatorioDAO consulta o PostgreSQL
  -> BO monta parametros do relatorio
  -> Jasper compila o JRXML em runtime
  -> Jasper preenche com JRBeanCollectionDataSource
  -> JasperExportManager exporta PDF
  -> Servlet retorna application/pdf inline
```

Relatorios disponiveis:

| Relatorio | Finalidade |
|---|---|
| Fretes em aberto | Lista fretes ainda nao finalizados |
| Romaneio de carga | Consolida cargas por motorista e data |
| Documento de frete | Gera documento individual do frete |
| Fretes por cliente | Lista fretes de um cliente em um periodo |
| Ocorrencias por periodo | Audita ocorrencias registradas |
| Desempenho de motoristas | Mede entregas, prazo e valor transportado |

Detalhes tecnicos importantes:

- os filtros sao validados no BO;
- as consultas SQL ficam no DAO;
- os templates JRXML ficam em `src/main/resources/report`;
- os dados sao passados ao Jasper como objetos Java simples;
- o retorno HTTP usa `Content-Type: application/pdf`;
- o PDF abre inline no navegador;
- os templates sao compilados em runtime para facilitar manutencao durante o
  desenvolvimento.

## Papel Da Analise De PRs

O projeto `analise-prs` foi usado como uma etapa anterior de pesquisa tecnica.
Ele coletou PRs via API do GitHub, tratou os dados com Python e gerou insumos
para entender dores recorrentes.

Fluxo do projeto de analise:

```text
GitHub API
  -> extrair_prs.py
  -> prs_analise_final.csv
  -> limpar_dados.py
  -> analise_completa.csv / analise_ia.csv
  -> gerar_dashboard.py
  -> analise_prs_dashboard.xlsx
```

Essa analise fortalece a apresentacao porque mostra que a decisao pelo Motor
Fiscal foi baseada em evidencia: havia sinais de recorrencia em regra de
negocio, banco, relatorios e manutencao.

Na apresentacao, o ponto principal e:

```text
Primeiro foi feito um diagnostico tecnico nos PRs.
Depois foram identificadas dores recorrentes.
Por fim, foi proposta a separacao da inteligencia fiscal em uma API Go.
```

## Arquitetura Geral

```text
analise-prs
  -> identifica dores tecnicas recorrentes
  -> sustenta a decisao arquitetural

sistema-fretes
  -> opera clientes, motoristas, veiculos e fretes
  -> gera relatorios em PDF
  -> chama Motor Fiscal quando precisa de calculo tributario

Motor_fiscal
  -> escolhe regra fiscal
  -> calcula ICMS, IBS e CBS
  -> registra memoria de calculo
  -> retorna resumo fiscal para o sistema Java
```

## Estrutura Do Projeto

```text
sistema-fretes/
|-- build.gradle
|-- db/
|-- src/main/java/br/com/gw/
|   |-- cliente/
|   |-- frete/
|   |-- motorista/
|   |-- motorfiscal/
|   |-- nucleo/
|   |-- relatorio/
|   `-- veiculos/
|-- src/main/resources/
|   |-- db.properties
|   `-- report/
`-- src/main/webapp/
    |-- css/
    |-- js/
    |-- jsp/
    `-- WEB-INF/
```

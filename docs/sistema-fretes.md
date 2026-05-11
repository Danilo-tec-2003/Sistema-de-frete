# Sistema De Fretes

Este documento explica o projeto `sistema-fretes` como um todo. A ideia e servir como material de estudo e apoio para uma explicacao tecnica do sistema.

## Objetivo Do Sistema

O Sistema de Fretes e uma aplicacao Java Web para gerenciar uma operacao de transporte. Ele cobre:

- autenticacao de usuarios;
- dashboard operacional;
- cadastro de clientes;
- cadastro de motoristas;
- cadastro de veiculos;
- emissao e acompanhamento de fretes;
- historico de ocorrencias;
- integracao fiscal;
- geracao de relatorios PDF.

## Stack Tecnica

| Camada | Tecnologia |
|---|---|
| Linguagem principal | Java 8 |
| Web | Servlets e JSP |
| Build | Gradle |
| Empacotamento | WAR |
| Servidor local | Gretty com Tomcat 9 |
| Banco | PostgreSQL |
| Pool de conexoes | Apache Commons DBCP2 |
| View | JSP, JSTL, CSS e JavaScript |
| Relatorios | JasperReports |
| JSON | Gson |
| Integracao fiscal | API Go `Motor_fiscal` |

Dependencias principais em `build.gradle`:

```gradle
compileOnly 'javax.servlet:javax.servlet-api:4.0.1'
implementation 'org.postgresql:postgresql:42.7.2'
implementation 'net.sf.jasperreports:jasperreports:6.20.6'
implementation 'org.apache.commons:commons-dbcp2:2.9.0'
implementation 'javax.servlet:jstl:1.2'
implementation 'com.google.code.gson:gson:2.10.1'
```

## Estrutura Principal

```text
src/main/java/br/com/gw
  Enums
  cliente
  frete
  motorista
  motorfiscal
  nucleo
  relatorio
  veiculos

src/main/webapp
  css
  js
  img
  jsp
  WEB-INF

src/main/resources
  report
  db.properties

db
  scripts SQL do banco do sistema
```

## Arquitetura Em Camadas

O projeto usa uma divisao simples e clara:

```text
JSP
  -> Controller Servlet
  -> BO
  -> DAO
  -> PostgreSQL
```

Responsabilidades:

| Camada | Responsabilidade |
|---|---|
| JSP | Interface visual, formularios e exibicao |
| Controller | Receber HTTP, ler parametros, redirecionar/forward |
| BO | Regra de negocio e validacoes |
| DAO | SQL e acesso ao banco |
| Model/Entity | Objetos de dominio |
| Enum | Codigos controlados do banco |

Essa separacao aparece nos modulos principais:

```text
ClienteControlador -> ClienteBO -> ClienteDAO
MotoristaControlador -> MotoristaBO -> MotoristaDAO
VeiculoControlador -> VeiculoBO -> VeiculoDAO
FreteControlador -> FreteBO -> FreteDAO
RelatorioControlador -> RelatorioBO -> RelatorioDAO
```

## Configuracao E Inicializacao

### Build E Contexto

O projeto e empacotado como WAR.

No `build.gradle`, o Gretty define:

```text
servletContainer = tomcat9
contextPath = /SISTEMA-FRETES
httpPort = 8080
```

URL local esperada:

```text
http://localhost:8080/SISTEMA-FRETES
```

### Conexao Com Banco

A conexao e inicializada por:

```text
br.com.gw.nucleo.AppContextListener
```

Esse listener roda quando a aplicacao sobe.

Fluxo:

```text
1. Tomcat sobe a aplicacao
2. AppContextListener.contextInitialized()
3. Le db.properties no classpath
4. Cria BasicDataSource
5. Configura driver, URL, usuario, senha e pool
6. Injeta DataSource em ConexaoUtil
```

O arquivo esperado e:

```text
src/main/resources/db.properties
```

Ele fica ignorado pelo Git porque contem configuracao local.

### Utilitario De Conexao

`ConexaoUtil` centraliza a obtencao de conexoes.

Conceito:

```text
DAO nao cria pool.
DAO pede conexao ao ConexaoUtil.
ConexaoUtil usa o DataSource configurado no startup.
```

## Autenticacao

Arquivos:

| Arquivo | Papel |
|---|---|
| `LoginControlador.java` | Login e logout |
| `LoginBO.java` | Validacao de login |
| `LoginDAO.java` | Consulta usuario e senha |
| `AuthFilter.java` | Protege rotas autenticadas |
| `Usuario.java` | Usuario em sessao |

Fluxo de login:

```text
GET /login
  -> exibe login.jsp

POST /login
  -> LoginBO.autenticar()
  -> LoginDAO.buscarPorLoginSenha()
  -> senha comparada em SHA-256
  -> cria session usuarioLogado
  -> redirect /home
```

Rotas publicas:

- `/login`
- `/cadastroUsuario`
- `/css/*`
- `/js/*`
- `/img/*`
- `.ico`

Todo o restante passa pelo `AuthFilter`.

## Dashboard

Arquivo principal:

```text
HomeControlador.java
```

A home mostra indicadores operacionais:

- total de fretes;
- fretes em andamento;
- aguardando coleta;
- fretes atrasados;
- entregas hoje;
- total de clientes ativos;
- total de motoristas ativos;
- veiculos disponiveis.

Esses dados sao buscados diretamente pelos DAOs.

## Modulo Cliente

Arquivos:

```text
Cliente.java
ClienteControlador.java
ClienteBO.java
ClienteDAO.java
```

Responsabilidades:

- cadastrar clientes;
- editar dados cadastrais;
- validar CPF/CNPJ;
- validar endereco e contato;
- armazenar logo do cliente;
- listar e paginar clientes;
- impedir exclusao quando ha fretes vinculados.

Tabela principal:

```text
cliente
```

Pontos tecnicos:

- o campo `cnpj` guarda CPF ou CNPJ apenas com digitos;
- `tipo` ficou por compatibilidade, mas o papel real no frete e definido por `id_remetente` e `id_destinatario`;
- logos ficam em `logo_dados BYTEA`;
- cliente pode ser ativo ou inativo.

## Modulo Motorista

Arquivos:

```text
Motorista.java
MotoristaControlador.java
MotoristaBO.java
MotoristaDAO.java
```

Responsabilidades:

- cadastrar motorista;
- validar CPF;
- validar CNH;
- controlar categoria;
- controlar vinculo;
- controlar status;
- impedir alteracoes/exclusoes perigosas quando ha fretes vinculados.

Tabela principal:

```text
motorista
```

Enums relacionados:

- `CategoriaCNH`
- `TipoVinculo`
- `StatusMotorista`

Pontos tecnicos:

- CNH deve ter 11 digitos;
- motorista ativo precisa ter CNH vigente;
- motorista com frete ativo nao deve ser inativado/suspenso.

## Modulo Veiculo

Arquivos:

```text
Veiculo.java
VeiculoControlador.java
VeiculoBO.java
VeiculoDAO.java
```

Responsabilidades:

- cadastrar veiculos;
- validar placa;
- controlar RNTRC;
- controlar tipo do veiculo;
- controlar capacidade;
- controlar status;
- impedir exclusao quando ha historico de fretes.

Tabela principal:

```text
veiculo
```

Enums relacionados:

- `TipoVeiculo`
- `StatusVeiculo`

Tipos de veiculo:

```text
M = Moto
U = Carro Utilitario
V = Van
L = VUC
Q = Caminhao 3/4
O = Caminhao Toco
K = Caminhao Truck
C = Carreta
B = Bitrem/Rodotrem
```

Status:

```text
D = Disponivel
V = Em Viagem
M = Em Manutencao
```

Ponto importante:

```text
O sistema valida se a capacidade informada esta dentro da faixa esperada para o tipo de veiculo.
```

## Modulo Frete

Arquivos:

```text
Frete.java
FreteControlador.java
FreteBO.java
FreteDAO.java
OcorrenciaFrete.java
```

Esse e o modulo central do sistema.

Responsabilidades:

- emitir frete;
- listar e filtrar fretes;
- detalhar frete;
- controlar fluxo operacional;
- registrar ocorrencias;
- calcular dados fiscais;
- controlar motorista e veiculo vinculados.

Tabelas principais:

```text
frete
ocorrencia_frete
```

## Ciclo De Vida Do Frete

Status de frete:

| Codigo | Enum | Significado |
|---|---|---|
| `E` | `EMITIDO` | Frete criado, aguardando saida |
| `S` | `SAIDA_CONFIRMADA` | Veiculo saiu do patio |
| `T` | `EM_TRANSITO` | Frete em rota |
| `R` | `ENTREGUE` | Entrega concluida |
| `N` | `NAO_ENTREGUE` | Tentativa frustrada |
| `C` | `CANCELADO` | Frete cancelado |

Transicoes principais:

```text
EMITIDO
  -> SAIDA_CONFIRMADA
  -> CANCELADO

SAIDA_CONFIRMADA
  -> EM_TRANSITO
  -> CANCELADO

EM_TRANSITO
  -> ENTREGUE
  -> NAO_ENTREGUE
  -> CANCELADO

ENTREGUE, NAO_ENTREGUE e CANCELADO
  -> finais
```

## Emissao De Frete

O metodo central e:

```text
FreteBO.emitir()
```

Ele valida:

- campos obrigatorios;
- datas;
- valores;
- motorista ativo;
- CNH vigente;
- veiculo disponivel;
- motorista sem frete ativo;
- veiculo sem frete ativo;
- compatibilidade entre CNH e tipo de veiculo;
- peso da carga contra capacidade do veiculo.

Fluxo tecnico:

```text
1. Controller monta Frete a partir do request
2. FreteBO valida regras de negocio
3. FreteBO prepara dados fiscais iniciais
4. Abre transacao JDBC
5. Gera numero com seq_numero_frete
6. Insere frete
7. Commit
8. Chama Motor Fiscal para calculo oficial
9. Atualiza resumo fiscal ou marca erro fiscal
```

Numero do frete:

```text
FRT-AAAA-NNNNN
```

Exemplo:

```text
FRT-2026-00001
```

## Ocorrencias Do Frete

Tabela:

```text
ocorrencia_frete
```

Tipos:

| Codigo | Tipo |
|---|---|
| `P` | Saida do Patio |
| `R` | Em Rota |
| `T` | Tentativa de Entrega |
| `E` | Entrega Realizada |
| `A` | Avaria |
| `X` | Extravio |
| `O` | Outros |

Regras:

- entrega realizada exige recebedor;
- avaria, extravio e outros exigem descricao;
- ocorrencias compoem o historico operacional do frete.

## Integracao Fiscal

O sistema Java nao calcula regras fiscais diretamente. Ele chama a API Go `Motor_fiscal`.

Arquivos Java:

```text
motorfiscal/MotorFiscalClient.java
motorfiscal/MotorFiscalConfig.java
motorfiscal/TaxSimulationRequest.java
motorfiscal/TaxPreviewRequest.java
motorfiscal/TaxSimulationResponse.java
```

Fluxos:

```text
Preview:
FormFrete.jsp -> FreteControlador.previewFiscal -> FreteBO.previsualizarFiscal -> Motor Fiscal

Calculo oficial:
FreteBO.emitir -> calcularFiscalAposEmissao -> Motor Fiscal -> FreteDAO.atualizarResumoFiscal
```

Campos fiscais salvos no frete:

- `tipo_operacao`
- `tipo_destinatario`
- `cfop`
- `motivo_cfop`
- `status_fiscal`
- `regra_fiscal_aplicada`
- `aliquota_icms`
- `valor_icms`
- `aliquota_ibs`
- `valor_ibs`
- `aliquota_cbs`
- `valor_cbs`
- `total_tributos`
- `valor_total_estimado`

Status fiscal:

```text
PENDENTE
CALCULADO
ERRO
VALIDADO_CTE
```

## Relatorios

A geracao de relatorios e uma area importante do sistema e esta detalhada em:

```text
docs/relatorios.md
```

Resumo tecnico:

```text
relatorios.jsp
  -> RelatorioControlador
  -> RelatorioBO
  -> RelatorioDAO
  -> DTOs de relatorio
  -> JasperReports
  -> PDF
```

Relatorios atuais:

- Fretes em aberto
- Romaneio de carga
- Documento de frete
- Fretes por cliente
- Ocorrencias por periodo
- Desempenho de motoristas

## Banco De Dados

Scripts em `db/`:

| Arquivo | Papel |
|---|---|
| `01_schema.sql` | Cria tabelas, sequences, constraints |
| `02_indexes.sql` | Cria indices |
| `03_seed_data.sql` | Dados iniciais para demonstracao |
| `04_migration_regras_operacionais_fiscais.sql` | Campos fiscais e regras operacionais |
| `05_migration_cliente_logo.sql` | Campos de logo no cliente |

Tabelas principais:

- `usuario`
- `cliente`
- `motorista`
- `veiculo`
- `frete`
- `ocorrencia_frete`

Sequences:

- `seq_usuario`
- `seq_cliente`
- `seq_motorista`
- `seq_veiculo`
- `seq_frete`
- `seq_numero_frete`
- `seq_ocorrencia`

## Navegacao Principal

Rotas principais:

| Rota | Tela |
|---|---|
| `/login` | Login |
| `/home` | Dashboard |
| `/clientes` | Clientes |
| `/motoristas` | Motoristas |
| `/veiculos` | Veiculos |
| `/fretes` | Fretes |
| `/relatorios` | Relatorios |
| `/logout` | Encerrar sessao |

## Padrao De Tratamento De Erro

O sistema usa excecoes de negocio:

| Classe | Uso |
|---|---|
| `NegocioException` | Erro geral de regra de negocio |
| `CadastroException` | Erros de validacao/cadastro |
| `FreteException` | Regras especificas do fluxo de frete |

Controllers capturam essas excecoes e exibem mensagens amigaveis nas JSPs.

## Como Rodar Localmente

Build/compilacao:

```bash
./gradlew compileJava
```

Subir aplicacao:

```bash
./gradlew appRun
```

URL:

```text
http://localhost:8080/SISTEMA-FRETES
```

Observacoes:

- o banco PostgreSQL precisa estar criado;
- `src/main/resources/db.properties` precisa existir;
- se usar Motor Fiscal, a API Go precisa estar online ou o frete pode ficar com `status_fiscal=ERRO`.

## Explicacao Tecnica Curta

```text
O sistema-fretes e uma aplicacao Java Web em camadas. As JSPs cuidam da interface, os Servlets recebem as requisicoes, os BOs concentram validacoes e regras de negocio, e os DAOs isolam o acesso SQL ao PostgreSQL. O modulo central e Frete, que controla emissao, status, ocorrencias, motorista, veiculo e dados fiscais. Para relatorios, o sistema usa JasperReports. Para calculo fiscal, ele integra com um microservico Go chamado Motor Fiscal.
```

## Pontos Fortes Para Defender

- arquitetura simples e facil de explicar;
- separacao entre tela, controller, regra e banco;
- validacoes de negocio concentradas nos BOs;
- frete com ciclo de vida controlado por enum;
- transacao na emissao do frete;
- numero de frete gerado por sequence;
- relatorios em PDF com JasperReports;
- integracao fiscal separada em microservico;
- uso de pool de conexoes;
- scripts SQL versionados em `db/`.

## Pontos De Atencao Tecnica

- o sistema usa Servlets/JSP, sem framework MVC moderno;
- os `.jrxml` sao compilados em runtime;
- o arquivo `db.properties` e local e nao deve ser versionado com credenciais reais;
- as regras fiscais oficiais ficam fora do Java, no Motor Fiscal;
- falha no Motor Fiscal nao deve derrubar a operacao logistica, mas precisa ser acompanhada pelo `status_fiscal`.


# Relatorios Do Sistema De Fretes

Este documento explica somente a parte de relatorios do sistema de fretes: como a tela funciona, como o backend monta os dados, como o JasperReports gera os PDFs e como voce pode explicar esse fluxo de forma tecnica.

## Objetivo

A area de relatorios transforma dados operacionais do sistema em documentos PDF. Ela serve para acompanhamento diario, conferencia de carga, auditoria de ocorrencias, extratos por cliente e indicadores de desempenho.

Hoje existem seis modelos:

- Fretes em aberto
- Romaneio de carga
- Documento de frete
- Fretes por cliente
- Ocorrencias por periodo
- Desempenho de motoristas

## Arquitetura Da Geracao

O fluxo segue a arquitetura tradicional do projeto:

```text
JSP
  -> Servlet Controller
  -> BO
  -> DAO
  -> DTOs de relatorio
  -> JasperReports
  -> PDF
```

Em termos praticos:

```text
relatorios.jsp
  -> RelatorioControlador
  -> RelatorioBO
  -> RelatorioDAO
  -> classes *Relatorio.java
  -> arquivos .jrxml
  -> resposta application/pdf
```

## Arquivos Principais

| Arquivo | Papel |
|---|---|
| `src/main/webapp/jsp/relatorios/relatorios.jsp` | Tela com o catalogo de relatorios e filtros |
| `src/main/java/br/com/gw/relatorio/RelatorioControlador.java` | Servlet mapeado em `/relatorios` |
| `src/main/java/br/com/gw/relatorio/RelatorioBO.java` | Valida filtros, calcula totais e gera PDF |
| `src/main/java/br/com/gw/relatorio/RelatorioDAO.java` | Executa SQLs especificos dos relatorios |
| `src/main/java/br/com/gw/relatorio/*Relatorio.java` | DTOs usados como linhas dos relatorios |
| `src/main/resources/report/*.jrxml` | Templates JasperReports |
| `build.gradle` | Declara a dependencia `jasperreports` |

Dependencia principal:

```gradle
implementation 'net.sf.jasperreports:jasperreports:6.20.6'
```

## Entrada Pela Tela

A tela `relatorios.jsp` e um catalogo. Cada card representa um relatorio e possui um formulario HTML.

Caracteristicas dos formularios:

- usam `method="get"`;
- enviam para `/relatorios`;
- usam `target="_blank"` para abrir o PDF em nova aba;
- enviam um parametro hidden chamado `acao`;
- usam selects e datas preenchidos pelo controller.

Exemplo conceitual:

```html
<form method="get" action="${pageContext.request.contextPath}/relatorios" target="_blank">
    <input type="hidden" name="acao" value="fretesAbertos">
    <button type="submit">Visualizar relatorio</button>
</form>
```

O parametro `acao` define qual PDF sera gerado.

## Catalogo Dos Relatorios

| Relatorio | `acao` | Template | Filtros | Objetivo |
|---|---|---|---|---|
| Fretes em aberto | `fretesAbertos` | `fretes_abertos.jrxml` | Nenhum | Lista fretes Emitidos, com Saida Confirmada ou Em Transito |
| Romaneio de carga | `romaneioCarga` | `romaneio_carga.jrxml` | Motorista e data | Documento de conferencia por motorista/dia |
| Documento de frete | `documentoFrete` | `documento_frete.jrxml` | Frete | Impressao individual completa |
| Fretes por cliente | `fretesCliente` | `fretes_cliente.jrxml` | Cliente e periodo | Extrato de fretes de um cliente |
| Ocorrencias por periodo | `ocorrenciasPeriodo` | `ocorrencias_periodo.jrxml` | Periodo | Auditoria de ocorrencias registradas |
| Desempenho de motoristas | `desempenhoMotoristas` | `desempenho_motoristas.jrxml` | Periodo | Indicadores de entregas por motorista |

## Controller: `RelatorioControlador`

O controller e o ponto de entrada HTTP.

Responsabilidades:

- receber `GET /relatorios`;
- abrir o catalogo quando nao ha `acao`;
- interpretar `acao`;
- converter filtros para `int` e `LocalDate`;
- recuperar o usuario logado;
- chamar o `RelatorioBO`;
- devolver o PDF no response;
- tratar erros e voltar para a tela.

Fluxo simplificado:

```text
doGet()
  -> le parametro acao
  -> se acao == null: catalogo()
  -> senao: switch(acao)
  -> chama metodo gerar...
  -> recebe byte[] pdf do BO
  -> enviarPdf()
```

O metodo `enviarPdf` define:

```text
Content-Type: application/pdf
Content-Disposition: inline; filename="nome.pdf"
```

Isso faz o navegador abrir o PDF na propria aba.

## BO: `RelatorioBO`

O BO e a camada que conhece a regra de geracao dos documentos.

Responsabilidades:

- validar se filtros obrigatorios foram informados;
- validar se `dataInicio <= dataFim`;
- consultar dados via DAO;
- calcular totais de cabecalho/rodape;
- montar parametros para o Jasper;
- carregar o template `.jrxml`;
- compilar o relatorio em runtime;
- preencher o relatorio com `JRBeanCollectionDataSource`;
- exportar para PDF.

Parametros comuns enviados ao Jasper:

| Parametro | Uso |
|---|---|
| `DATA_GERACAO` | Data/hora em que o PDF foi gerado |
| `USUARIO` | Usuario logado ou `sistema` |

Parametros especificos:

| Parametro | Uso |
|---|---|
| `TITULO` | Titulo do relatorio |
| `SUBTITULO` | Texto auxiliar |
| `PERIODO` | Periodo formatado |
| `TOTAL_REGISTROS` | Total de linhas |
| `TOTAL_FRETES` | Total de fretes |
| `TOTAL_PESO` | Soma de peso |
| `TOTAL_VOLUMES` | Soma de volumes |
| `TOTAL_VALOR` | Soma financeira |
| `TOTAL_OCORRENCIAS` | Total de ocorrencias |
| `TOTAL_ENTREGAS` | Total de entregas |
| `TOTAL_NO_PRAZO` | Entregas feitas no prazo |

## DAO: `RelatorioDAO`

O DAO de relatorios e separado dos DAOs operacionais. Isso e importante porque relatorio normalmente exige consultas com joins, agregacoes e campos ja formatados para apresentacao.

Responsabilidades:

- consultar o PostgreSQL;
- fazer joins entre `frete`, `cliente`, `motorista`, `veiculo` e `ocorrencia_frete`;
- converter codigos de enum para descricoes;
- formatar datas e documentos;
- montar DTOs especificos para cada relatorio.

Exemplo de consulta conceitual:

```text
frete
  JOIN cliente remetente
  JOIN cliente destinatario
  JOIN motorista
  JOIN veiculo
```

## DTOs De Relatorio

Os DTOs ficam em `br.com.gw.relatorio`.

Eles nao sao entidades de dominio completas. Eles existem para representar exatamente o que o PDF precisa imprimir.

Exemplos:

| Classe | Representa |
|---|---|
| `FreteAbertoRelatorio` | Linha do relatorio de fretes em aberto |
| `RomaneioCargaRelatorio` | Linha de carga no romaneio |
| `RomaneioCabecalho` | Dados do cabecalho do romaneio |
| `DocumentoFreteRelatorio` | Documento completo de um frete |
| `FreteClienteRelatorio` | Linha do extrato por cliente |
| `OcorrenciaPeriodoRelatorio` | Linha de ocorrencia |
| `DesempenhoMotoristaRelatorio` | Indicador consolidado por motorista |
| `RelatorioFreteOpcao` | Opcao de select para escolher frete |

## Como O JasperReports Funciona Aqui

O JasperReports usa dois tipos de informacao:

1. Parametros: valores avulsos, como titulo, usuario e periodo.
2. Fields: campos de cada linha da lista de dados.

No Java:

```text
params.put("TITULO", "Fretes em aberto")
params.put("USUARIO", usuario)
```

No JRXML:

```text
$P{TITULO}
$P{USUARIO}
```

No Java, cada DTO tem getters:

```text
getNumero()
getValorTotal()
getStatusDescricao()
```

No JRXML:

```text
$F{numero}
$F{valorTotal}
$F{statusDescricao}
```

Se o nome do field no JRXML nao bater com o getter do DTO, o erro aparece na geracao do PDF.

## Metodo Central De Geracao

O metodo principal no `RelatorioBO` e `gerarPdf`.

Fluxo dele:

```text
1. Monta caminho: report/<arquivo>.jrxml
2. Carrega template pelo classloader
3. Compila JRXML com JasperCompileManager
4. Cria JRBeanCollectionDataSource com os DTOs
5. Preenche com JasperFillManager
6. Exporta com JasperExportManager
7. Retorna byte[] do PDF
```

Conceito importante:

```text
src/main/resources/report
  -> empacotado no classpath
  -> acessado como report/nome.jrxml
```

## Detalhamento Dos Relatorios

### Fretes Em Aberto

Acao: `fretesAbertos`

Objetivo:

- acompanhar fretes ainda ativos;
- destacar previsao de entrega;
- mostrar dias em atraso.

Status considerados:

```text
E = Emitido
S = Saida Confirmada
T = Em Transito
```

Consulta principal:

```text
RelatorioDAO.listarFretesEmAberto()
```

Ordenacao:

```text
dias_atraso DESC
data_prev_entrega ASC
numero ASC
```

Como explicar:

```text
Esse relatorio e operacional. Ele ajuda a equipe a saber quais fretes ainda precisam de acompanhamento e quais estao atrasados.
```

### Romaneio De Carga

Acao: `romaneioCarga`

Filtros:

- motorista;
- data de operacao.

Objetivo:

- apoiar conferencia de carga;
- consolidar fretes de um motorista em uma data;
- mostrar totais de peso, volumes e valor.

Dados principais:

- cabecalho do motorista;
- CNH;
- placas envolvidas;
- lista de fretes;
- totais.

Consulta principal:

```text
RelatorioDAO.buscarCabecalhoRomaneio()
RelatorioDAO.listarRomaneio()
```

Regra de data:

```text
COALESCE(data_saida::date, data_emissao) = data informada
```

Como explicar:

```text
O romaneio agrupa cargas por motorista e dia, servindo como documento de conferencia antes ou durante a saida da operacao.
```

### Documento De Frete

Acao: `documentoFrete`

Filtro:

- ID do frete.

Objetivo:

- gerar uma impressao individual com todos os dados relevantes.

Inclui:

- numero e status;
- remetente e destinatario;
- motorista e CNH;
- veiculo e capacidade;
- origem e destino;
- carga;
- valores;
- impostos;
- observacoes.

Consulta principal:

```text
RelatorioDAO.buscarDocumentoFrete()
```

Como explicar:

```text
E o documento operacional individual do frete, montado com joins entre frete, clientes, motorista e veiculo.
```

### Fretes Por Cliente

Acao: `fretesCliente`

Filtros:

- cliente;
- data inicial;
- data final.

Objetivo:

- gerar extrato de fretes vinculados a um cliente;
- mostrar se o cliente participou como remetente ou destinatario;
- somar valor movimentado.

Consulta principal:

```text
RelatorioDAO.listarFretesPorCliente()
```

Condicao:

```text
id_remetente = cliente OR id_destinatario = cliente
```

Como explicar:

```text
Esse relatorio tem valor comercial e gerencial, porque mostra o historico de movimentacao de um cliente no periodo.
```

### Ocorrencias Por Periodo

Acao: `ocorrenciasPeriodo`

Filtros:

- data inicial;
- data final.

Objetivo:

- auditar eventos registrados no ciclo do frete;
- acompanhar avarias, entregas, tentativas e movimentacoes.

Consulta principal:

```text
RelatorioDAO.listarOcorrenciasPorPeriodo()
```

Fonte principal:

```text
ocorrencia_frete
  JOIN frete
  JOIN motorista
  JOIN veiculo
```

Como explicar:

```text
Esse relatorio funciona como trilha historica da operacao, mostrando o que aconteceu, quando, onde e em qual frete.
```

### Desempenho De Motoristas

Acao: `desempenhoMotoristas`

Filtros:

- data inicial;
- data final.

Objetivo:

- avaliar entregas concluidas;
- medir pontualidade;
- somar peso, volumes e valor transportado.

Consulta principal:

```text
RelatorioDAO.listarDesempenhoMotoristas()
```

Considera apenas:

```text
status = R
data_entrega IS NOT NULL
```

Indicadores:

- entregas;
- entregas no prazo;
- entregas atrasadas;
- percentual no prazo;
- media de dias de atraso;
- peso total;
- volumes;
- valor total.

Como explicar:

```text
E o relatorio gerencial de performance. Ele transforma historico operacional em indicador por motorista.
```

## Validacoes De Filtros

O `RelatorioBO` valida:

- motorista obrigatorio no romaneio;
- data obrigatoria no romaneio;
- frete obrigatorio no documento individual;
- cliente obrigatorio no extrato por cliente;
- data inicial e final obrigatorias nos relatorios por periodo;
- data inicial nao pode ser posterior a data final.

Quando a validacao falha:

```text
RelatorioBO lanca CadastroException
RelatorioControlador captura como NegocioException
Controller volta para relatorios.jsp com mensagem de erro
```

## Como Adicionar Um Novo Relatorio

Roteiro recomendado:

1. Criar DTO em `src/main/java/br/com/gw/relatorio`.
2. Criar consulta no `RelatorioDAO`.
3. Criar metodo no `RelatorioBO`.
4. Criar template `.jrxml` em `src/main/resources/report`.
5. Adicionar `case` no `RelatorioControlador`.
6. Adicionar card/formulario em `relatorios.jsp`.
7. Testar com dados reais.

Checklist tecnico:

- O nome do `.jrxml` bate com o nome chamado no BO?
- Os fields do JRXML batem com getters do DTO?
- Os parametros usados no JRXML foram colocados no `Map<String, Object>`?
- O filtro foi validado no BO?
- O SQL esta no DAO, e nao no controller?
- O PDF abre com `target="_blank"`?

## Problemas Comuns

### PDF Nao Gera

Possiveis causas:

- JRXML nao encontrado no classpath;
- nome de field errado no JRXML;
- parametro obrigatorio nao enviado;
- erro SQL;
- lista nula ou DTO incompleto.

Onde olhar:

- logs do servidor;
- `RelatorioBO.gerarPdf`;
- template em `src/main/resources/report`;
- query em `RelatorioDAO`.

### Campo Aparece Em Branco

Possiveis causas:

- DTO nao recebeu valor no DAO;
- getter tem nome diferente do field no JRXML;
- dado realmente esta nulo no banco.

### Erro De Data

As datas vem do HTML como:

```text
YYYY-MM-DD
```

O controller converte com:

```text
LocalDate.parse()
```

Se vier vazio, o BO valida e retorna mensagem.

## Explicacao Tecnica Curta Para Apresentacao

```text
A area de relatorios usa uma arquitetura em camadas. A JSP exibe o catalogo e envia filtros para o servlet /relatorios. O controller identifica a acao, converte os parametros e chama o RelatorioBO. O BO valida os filtros, busca dados no RelatorioDAO, calcula totais e envia uma lista de DTOs para o JasperReports. O Jasper compila o template JRXML em runtime, preenche os campos com JRBeanCollectionDataSource e exporta o resultado em PDF, que o servlet devolve como application/pdf.
```

## Frase-Chave Para Defender A Arquitetura

```text
Os relatorios foram separados da operacao principal: o controller cuida da requisicao, o BO da regra de geracao, o DAO das consultas, os DTOs do formato de impressao e o Jasper do layout final em PDF.
```


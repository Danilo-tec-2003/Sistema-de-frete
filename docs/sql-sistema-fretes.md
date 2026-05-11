# SQL Do Sistema De Fretes

Este documento explica os arquivos SQL do projeto `sistema-fretes`, a ordem de execucao, o papel de cada tabela, constraints, indices, dados iniciais e pontos de atencao para apresentacao tecnica.

Arquivos analisados:

```text
db/01_schema.sql
db/02_indexes.sql
db/03_seed_data.sql
db/04_migration_regras_operacionais_fiscais.sql
db/05_migration_cliente_logo.sql
```

## Papel Do Banco No Sistema

O banco do `sistema-fretes` guarda os dados operacionais da aplicacao Java:

- usuarios;
- clientes;
- motoristas;
- veiculos;
- fretes;
- ocorrencias dos fretes;
- resumo fiscal retornado pelo Motor Fiscal;
- dados usados pelos relatorios.

Ele nao guarda as regras fiscais detalhadas. As regras fiscais ficam no banco do projeto Go `Motor_fiscal`.

## Ordem Recomendada De Execucao

Para montar uma base nova:

```text
1. db/01_schema.sql
2. db/02_indexes.sql
3. db/03_seed_data.sql
4. db/04_migration_regras_operacionais_fiscais.sql
5. db/05_migration_cliente_logo.sql
```

Observacao importante:

```text
O 01_schema.sql ja esta bem atualizado e ja contem varios campos que tambem aparecem nas migrations 04 e 05.
Mesmo assim, as migrations usam ADD COLUMN IF NOT EXISTS e checagens de constraint, entao podem ser executadas com seguranca apos o schema.
```

## Visao Geral Dos Arquivos

| Arquivo | Responsabilidade |
|---|---|
| `01_schema.sql` | Cria sequences, tabelas principais, PKs, FKs e checks |
| `02_indexes.sql` | Cria indices para filtros, joins e relatorios |
| `03_seed_data.sql` | Insere dados demonstrativos |
| `04_migration_regras_operacionais_fiscais.sql` | Evolui regras operacionais e campos fiscais |
| `05_migration_cliente_logo.sql` | Adiciona campos de logo ao cliente |

## 01_schema.sql

Esse e o arquivo principal de DDL. Ele cria a estrutura base do banco.

### Sequences

Sequences criadas:

| Sequence | Usada por |
|---|---|
| `seq_usuario` | `usuario.idusuario` |
| `seq_cliente` | `cliente.idcliente` |
| `seq_motorista` | `motorista.idmotorista` |
| `seq_veiculo` | `veiculo.idveiculo` |
| `seq_frete` | `frete.idfrete` |
| `seq_numero_frete` | Numero operacional `FRT-AAAA-NNNNN` |
| `seq_ocorrencia` | `ocorrencia_frete.idocorrencia` |

Ponto tecnico:

```text
seq_frete gera o ID interno do frete.
seq_numero_frete gera o numero operacional exibido ao usuario.
```

O numero operacional e montado no Java por `GeradorNumeroFrete`, no formato:

```text
FRT-AAAA-NNNNN
```

Exemplo:

```text
FRT-2026-00001
```

### Tabela usuario

Responsavel por login e sessao.

Campos principais:

| Campo | Uso |
|---|---|
| `idusuario` | Identificador |
| `nome` | Nome exibido |
| `login` | Login unico |
| `senha` | Hash SHA-256 |
| `perfil` | `ADMIN` ou `OPERADOR` |
| `is_ativo` | Permite bloquear login |

Constraints:

```text
pk_usuario
uq_usuario_login
ck_usuario_perfil
```

Relacao com Java:

```text
LoginDAO busca usuario por login, senha e is_ativo = TRUE.
```

### Tabela cliente

Guarda remetentes e destinatarios.

Campos principais:

| Campo | Uso |
|---|---|
| `idcliente` | Identificador |
| `razao_social` | Nome juridico/comercial |
| `nome_fantasia` | Nome fantasia |
| `cnpj` | Documento fiscal: CPF ou CNPJ, apenas digitos |
| `tipo` | Compatibilidade: `r`, `d` ou `a` |
| `logradouro`, `numero_end`, `bairro`, `municipio`, `uf`, `cep` | Endereco |
| `telefone`, `email` | Contato |
| `logo_nome_arquivo`, `logo_content_type`, `logo_dados` | Logo armazenada no banco |
| `is_ativo` | Controle de ativo/inativo |

Constraints:

```text
pk_cliente
uq_cliente_cnpj
ck_cliente_documento_tamanho
ck_cliente_tipo
```

Ponto conceitual:

```text
O papel do cliente no frete nao depende mais do campo tipo.
O papel real e definido por frete.id_remetente e frete.id_destinatario.
```

Ponto de atencao:

```text
O ClienteDAO verifica duplicidade de documento apenas entre clientes ativos,
mas o schema possui uq_cliente_cnpj global. Isso significa que, no banco atual,
um mesmo CPF/CNPJ nao pode aparecer nem em cliente inativo.
```

Se a regra desejada for permitir repetir documento quando o cadastro antigo estiver inativo, a constraint global teria que ser revista.

### Tabela motorista

Guarda motoristas e dados de CNH.

Campos principais:

| Campo | Uso |
|---|---|
| `idmotorista` | Identificador |
| `nome` | Nome |
| `cpf` | CPF unico |
| `data_nascimento` | Validacao de idade no Java |
| `telefone` | Contato |
| `cnh_numero` | CNH unica com 11 digitos |
| `cnh_categoria` | Categoria da CNH |
| `cnh_validade` | Vencimento |
| `tipo_vinculo` | Funcionario, agregado ou terceiro |
| `status` | Ativo, inativo ou suspenso |

Constraints:

```text
pk_motorista
uq_motorista_cpf
uq_motorista_cnh
ck_motorista_cnh_numero
ck_motorista_cat
ck_motorista_vinc
ck_motorista_stat
```

Codigos:

```text
cnh_categoria: A, B, C, D, E, AB, AC, AD, AE
tipo_vinculo: F, G, T
status: A, I, S
```

Relacao com Java:

- `MotoristaBO` valida CPF, telefone, idade e validade da CNH.
- `FreteBO` impede uso de motorista inativo, suspenso ou com CNH vencida.

### Tabela veiculo

Guarda veiculos e capacidades.

Campos principais:

| Campo | Uso |
|---|---|
| `idveiculo` | Identificador |
| `placa` | Placa unica |
| `rntrc` | Registro ANTT/RNTRC |
| `ano_fabricacao` | Ano |
| `tipo` | Tipo operacional do veiculo |
| `tara_kg` | Tara |
| `capacidade_kg` | Capacidade de carga |
| `volume_m3` | Volume |
| `status` | Disponivel, em viagem, manutencao |

Tipos:

| Codigo | Tipo |
|---|---|
| `M` | Moto |
| `U` | Carro Utilitario |
| `V` | Van |
| `L` | VUC |
| `Q` | Caminhao 3/4 |
| `O` | Caminhao Toco |
| `K` | Caminhao Truck |
| `C` | Carreta |
| `B` | Bitrem/Rodotrem |

Status:

| Codigo | Status |
|---|---|
| `D` | Disponivel |
| `V` | Em Viagem |
| `M` | Em Manutencao |

Constraints:

```text
pk_veiculo
uq_veiculo_placa
ck_veiculo_tipo
ck_veiculo_capacidade_pos
ck_veiculo_capacidade_tipo
ck_veiculo_stat
```

Ponto tecnico:

```text
O banco valida a faixa de capacidade por tipo de veiculo,
e o Java repete essa regra no enum TipoVeiculo/VeiculoBO.
```

### Tabela frete

E a tabela central do sistema.

Campos principais:

| Grupo | Campos |
|---|---|
| Identificacao | `idfrete`, `numero` |
| Participantes | `id_remetente`, `id_destinatario` |
| Operacao | `id_motorista`, `id_veiculo`, origem, destino |
| Carga | `descricao_carga`, `peso_kg`, `volumes` |
| Valores | `valor_frete`, `valor_total` |
| Impostos | `aliquota_icms`, `valor_icms`, `aliquota_ibs`, `valor_ibs`, `aliquota_cbs`, `valor_cbs` |
| Fiscal | `tipo_operacao`, `tipo_destinatario`, `cfop`, `motivo_cfop`, `status_fiscal`, `regra_fiscal_aplicada`, `total_tributos`, `valor_total_estimado` |
| Status | `status` |
| Datas | `data_emissao`, `data_prev_entrega`, `data_saida`, `data_entrega` |
| Auditoria | `created_at`, `updated_at`, `created_by`, `updated_by` |

Relacionamentos:

```text
frete.id_remetente    -> cliente.idcliente
frete.id_destinatario -> cliente.idcliente
frete.id_motorista    -> motorista.idmotorista
frete.id_veiculo      -> veiculo.idveiculo
```

Status do frete:

| Codigo | Status |
|---|---|
| `E` | Emitido |
| `S` | Saida Confirmada |
| `T` | Em Transito |
| `R` | Entregue |
| `N` | Nao Entregue |
| `C` | Cancelado |

Campos fiscais:

| Campo | Significado |
|---|---|
| `tipo_operacao` | `MUNICIPAL`, `ESTADUAL`, `INTERESTADUAL` |
| `tipo_destinatario` | `PESSOA_FISICA` ou `PESSOA_JURIDICA` |
| `cfop` | CFOP retornado pelo Motor Fiscal |
| `status_fiscal` | `PENDENTE`, `CALCULADO`, `ERRO`, `VALIDADO_CTE` |
| `regra_fiscal_aplicada` | Codigo/versao/status da regra usada |
| `total_tributos` | Soma dos tributos |
| `valor_total_estimado` | Valor do frete + tributos |

Ponto tecnico:

```text
O sistema Java cria o frete primeiro com status_fiscal PENDENTE.
Depois chama o Motor Fiscal Go e atualiza o resumo fiscal.
```

### Tabela ocorrencia_frete

Guarda a linha do tempo do frete.

Campos principais:

| Campo | Uso |
|---|---|
| `idocorrencia` | Identificador |
| `id_frete` | Frete relacionado |
| `tipo` | Tipo da ocorrencia |
| `data_hora` | Momento do evento |
| `municipio`, `uf` | Local |
| `descricao` | Detalhe |
| `nome_recebedor`, `documento_recebedor` | Dados de entrega |
| `created_by` | Usuario que registrou |

Tipos:

| Codigo | Tipo |
|---|---|
| `P` | Saida Patio |
| `R` | Em Rota |
| `T` | Tentativa Entrega |
| `E` | Entrega Realizada |
| `A` | Avaria |
| `X` | Extravio |
| `O` | Outros |

Relacionamento:

```text
ocorrencia_frete.id_frete -> frete.idfrete
```

## 02_indexes.sql

Cria indices para acelerar buscas e joins.

### Indices De Cliente

```text
idx_cli_razao_social
idx_cli_cnpj
idx_cli_is_ativo
```

Usados em listagens, busca por documento e contagem de ativos.

### Indices De Motorista

```text
idx_mot_nome
idx_mot_status
idx_mot_cpf
idx_mot_cnh_categoria
```

Usados em listagem, filtros, validacao de CPF e consultas de frete.

### Indices De Veiculo

```text
idx_vei_placa
idx_vei_status
idx_vei_tipo
```

Usados em filtros, disponibilidade e validacao operacional.

### Indices De Frete

```text
idx_fre_status
idx_fre_data_emissao
idx_fre_data_prev
idx_fre_id_remetente
idx_fre_id_destinatario
idx_fre_id_motorista
idx_fre_id_veiculo
idx_fre_status_fiscal
idx_fre_tipo_operacao
```

Esses indices ajudam em:

- listagem por status;
- relatorios por data;
- joins com cliente, motorista e veiculo;
- consultas fiscais.

### Indices De Ocorrencia

```text
idx_occ_id_frete
idx_occ_data_hora
idx_occ_tipo
```

Usados no historico do frete e no relatorio de ocorrencias por periodo.

Ponto de atencao:

```text
Algumas buscas usam ILIKE com "%texto%".
Indice B-tree comum pode ajudar pouco nesse padrao. Se houver muito volume,
pode valer avaliar pg_trgm e indices GIN para buscas textuais.
```

## 03_seed_data.sql

Insere dados iniciais para demonstracao.

Conteudo:

- usuarios;
- clientes;
- motoristas;
- veiculos;
- fretes em varios status;
- ocorrencias;
- ajuste de sequences.

### Usuarios

Cria:

```text
admin
carlos
ana
lucas
```

As senhas estao em SHA-256.

### Clientes

Cria clientes demonstrativos em diferentes estados do Nordeste.

Ponto de atencao:

```text
O banco valida apenas tamanho do documento.
O Java valida digito de CPF/CNPJ.
Alguns documentos demonstrativos podem passar no SQL e serem rejeitados se editados pela tela.
```

### Motoristas

Inclui motoristas ativos, suspenso e um caso de CNH vencida para testar regras.

Ponto de atencao:

```text
O seed consegue inserir CNH vencida porque o banco nao valida data de vencimento.
Essa regra fica no Java, no MotoristaBO/FreteBO.
```

### Veiculos

Inclui veiculos disponiveis, em viagem e em manutencao.

Os status do seed tentam refletir o estado dos fretes iniciais.

### Fretes

Cria fretes nos status:

```text
E, S, T, R, N, C
```

Isso e bom para demonstrar:

- listagem;
- detalhes;
- ocorrencias;
- relatorios;
- dashboard.

### Ocorrencias

Cria eventos para fretes em saida, rota, avaria, entrega e tentativa de entrega.

### Ajuste De Sequences

No final, o seed executa:

```sql
SELECT setval('seq_frete', (SELECT COALESCE(MAX(idfrete), 0) + 1 FROM frete), FALSE);
```

Como usa `is_called = FALSE`, o proximo `nextval` retorna exatamente o valor informado.

Exemplo:

```text
Se MAX(idfrete) = 6
setval recebe 7 com FALSE
proximo nextval retorna 7
```

Ponto de atencao:

```text
O seed nao usa ON CONFLICT nos inserts principais.
Rodar o 03_seed_data.sql duas vezes na mesma base tende a gerar erro de unique constraint.
```

## 04_migration_regras_operacionais_fiscais.sql

Essa migration evolui bases existentes para regras operacionais e fiscais mais novas.

Ela faz:

1. amplia `motorista.cnh_categoria` para `VARCHAR(2)`;
2. recria constraint de categoria de CNH;
3. garante constraint de CNH numerica;
4. amplia tipos de veiculo;
5. adiciona constraints de capacidade;
6. adiciona campos fiscais ao frete;
7. preenche `tipo_operacao` em fretes antigos;
8. preenche `tipo_destinatario` em fretes antigos;
9. preenche `valor_total_estimado`;
10. cria checks fiscais;
11. cria indices unicos auxiliares.

### Atualizacao De Tipo Operacao

Regra:

```text
UF origem diferente da UF destino -> INTERESTADUAL
Mesma UF, municipio diferente -> ESTADUAL
Mesmo municipio e mesma UF -> MUNICIPAL
```

### Atualizacao De Tipo Destinatario

Regra:

```text
Documento com 11 digitos -> PESSOA_FISICA
Documento com 14 digitos -> PESSOA_JURIDICA
```

### Constraints NOT VALID

Algumas constraints sao criadas como `NOT VALID`.

Isso significa:

```text
A constraint passa a valer para novos dados,
mas o PostgreSQL nao valida imediatamente todos os dados antigos.
```

E uma boa tecnica para evoluir base legada sem quebrar a migracao por dados historicos ruins.

## 05_migration_cliente_logo.sql

Adiciona campos para armazenar logo do cliente:

```text
logo_nome_arquivo
logo_content_type
logo_dados
```

No schema atual esses campos ja aparecem no `01_schema.sql`, mas a migration continua util para bases antigas.

## Relacionamentos Principais

```text
cliente 1 --- N frete como remetente
cliente 1 --- N frete como destinatario
motorista 1 --- N frete
veiculo 1 --- N frete
frete 1 --- N ocorrencia_frete
```

Diagrama textual:

```text
cliente(idcliente)
   ^             ^
   |             |
frete.id_remetente
frete.id_destinatario

motorista(idmotorista) <- frete.id_motorista
veiculo(idveiculo)     <- frete.id_veiculo
frete(idfrete)         <- ocorrencia_frete.id_frete
```

## Como O SQL Conversa Com O Java

| SQL | Java |
|---|---|
| `usuario` | `LoginDAO`, `Usuario` |
| `cliente` | `ClienteDAO`, `ClienteBO`, `Cliente` |
| `motorista` | `MotoristaDAO`, `MotoristaBO`, `Motorista` |
| `veiculo` | `VeiculoDAO`, `VeiculoBO`, `Veiculo` |
| `frete` | `FreteDAO`, `FreteBO`, `Frete` |
| `ocorrencia_frete` | `FreteDAO`, `OcorrenciaFrete` |

Enums Java espelham codigos do banco:

```text
StatusFrete
StatusFiscal
StatusMotorista
StatusVeiculo
TipoCliente
TipoDestinatario
TipoOcorrencia
TipoOperacao
TipoVeiculo
TipoVinculo
CategoriaCNH
```

## Pontos Bons Para Explicar

- O banco usa PKs e FKs para garantir integridade.
- O ciclo do frete e protegido por check constraint e enum Java.
- Frete separa ID interno de numero operacional.
- Ocorrencias criam trilha historica do frete.
- Campos fiscais guardam apenas resumo retornado pelo Motor Fiscal.
- Relatorios usam joins sobre as tabelas operacionais.
- Scripts sao separados por schema, indices, seed e migrations.
- Migrations usam `IF NOT EXISTS` e blocos `DO $$` para serem mais seguras.

## Pontos De Atencao

- `CREATE TABLE IF NOT EXISTS` nao altera tabela existente; por isso migrations sao importantes.
- O seed nao e totalmente idempotente.
- O banco valida formato basico de documento, mas CPF/CNPJ completo e validado no Java.
- `uq_cliente_cnpj` global pode impedir reutilizar documento de cliente inativo.
- Regras fiscais completas nao ficam neste banco; ficam no banco do Motor Fiscal.
- Os campos fiscais em `frete` sao resumo operacional, nao memoria completa de calculo.

## Explicacao Tecnica Curta

```text
O banco do sistema-fretes guarda a operacao logistica. Ele possui tabelas para usuario, cliente, motorista, veiculo, frete e ocorrencias. O frete e a tabela central, ligada por chaves estrangeiras aos participantes da operacao. Os codigos de status e tipos sao controlados por constraints no banco e enums no Java. O banco tambem guarda um resumo fiscal no frete, mas a regra e a auditoria fiscal detalhada ficam no microservico Motor Fiscal. Os scripts SQL sao separados em schema, indices, seed e migrations para facilitar criacao e evolucao da base.
```


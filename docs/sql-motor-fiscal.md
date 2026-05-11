# SQL Do Motor Fiscal Go

Este documento explica as migrations SQL do projeto Go `Motor_fiscal`, o modelo de dados fiscal, a ordem de execucao, as tabelas principais e como esse banco se integra ao sistema Java de fretes.

Projeto local:

```text
/home/danilo/Documentos/Projetos/Motor_fiscal
```

Migrations analisadas:

```text
migrations/001_create_fiscal_tables.sql
migrations/002_model_fiscal_rule_engine.sql
migrations/003_add_fiscal_rule_source_and_review_tracking.sql
migrations/004_persist_fiscal_calculation_audit.sql
migrations/005_seed_demonstrative_fallback_rules.sql
```

## Papel Do Banco Do Motor Fiscal

O banco do Motor Fiscal e diferente do banco operacional do sistema de fretes.

Ele guarda:

- regras fiscais;
- condicoes para aplicar regras;
- impostos e aliquotas;
- fontes legais ou referencias;
- revisoes contabeis;
- simulacoes fiscais;
- memoria de calculo por imposto.

Ele nao guarda:

- cadastro de clientes do sistema Java;
- motoristas;
- veiculos;
- ocorrencias operacionais;
- status logistico do frete.

## Relacao Com O Sistema Java

Fluxo resumido:

```text
Sistema Java
  -> envia freight_id, UF origem, UF destino, valor, tipo cliente e tipo operacao
  -> Motor Fiscal consulta seu banco de regras
  -> Motor Fiscal calcula impostos
  -> Motor Fiscal salva auditoria no proprio banco
  -> Motor Fiscal devolve JSON
  -> Java salva resumo fiscal na tabela frete
```

O banco do Motor Fiscal e, portanto, o banco de decisao e auditoria fiscal.

## Ordem Das Migrations

Ordem obrigatoria:

```text
1. 001_create_fiscal_tables.sql
2. 002_model_fiscal_rule_engine.sql
3. 003_add_fiscal_rule_source_and_review_tracking.sql
4. 004_persist_fiscal_calculation_audit.sql
5. 005_seed_demonstrative_fallback_rules.sql
```

Por que a ordem importa:

- a `002` adiciona colunas e tabelas usadas pelas regras modernas;
- a `003` depende de `fiscal_rules`;
- a `004` depende de `fiscal_simulations` e `fiscal_rules`;
- a `005` usa `rule_code` e tabelas criadas nas migrations anteriores.

## Visao Geral Das Tabelas

| Tabela | Papel |
|---|---|
| `fiscal_rules` | Cabecalho da regra fiscal |
| `fiscal_rule_conditions` | Condicoes para a regra casar com o request |
| `fiscal_rule_taxes` | Impostos, aliquotas e reducoes |
| `fiscal_rule_sources` | Fonte legal ou referencia da regra |
| `fiscal_rule_accounting_reviews` | Revisao contabil |
| `fiscal_simulations` | Historico de simulacoes fiscais |
| `fiscal_simulation_tax_details` | Memoria de calculo por imposto |

Diagrama textual:

```text
fiscal_rules
  1 -> N fiscal_rule_conditions
  1 -> N fiscal_rule_taxes
  1 -> N fiscal_rule_sources
  1 -> N fiscal_rule_accounting_reviews
  1 -> N fiscal_simulations

fiscal_simulations
  1 -> N fiscal_simulation_tax_details
```

## 001_create_fiscal_tables.sql

Essa migration cria o modelo inicial.

### fiscal_rules Inicial

Campos iniciais:

| Campo | Uso |
|---|---|
| `id` | Identificador da regra |
| `rule_version` | Versao da regra |
| `origin_uf` | UF origem |
| `destination_uf` | UF destino |
| `operation_type` | `INTERNA` ou `INTERESTADUAL` |
| `customer_type` | `PF` ou `PJ` |
| `icms_rate` | Aliquota ICMS |
| `ibs_rate` | Aliquota IBS |
| `cbs_rate` | Aliquota CBS |
| `cfop` | CFOP retornado |
| `valid_from`, `valid_to` | Vigencia |
| `active` | Regra ativa/inativa |

No modelo inicial, as aliquotas ficavam diretamente em `fiscal_rules`.

### fiscal_simulations Inicial

Guarda historico resumido de simulacoes:

| Campo | Uso |
|---|---|
| `freight_id` | ID do frete no sistema Java |
| `operation_date` | Data da operacao |
| `origin_uf`, `destination_uf` | UFs |
| `freight_value` | Valor do frete |
| `icms_rate`, `icms_amount` | ICMS |
| `ibs_rate`, `ibs_amount` | IBS |
| `cbs_rate`, `cbs_amount` | CBS |
| `total_tax` | Total de tributos |
| `total_with_tax` | Valor com tributos |
| `cfop` | CFOP aplicado |
| `rule_version` | Versao da regra |
| `from_cache` | Indicador de cache |

### Seed Inicial

Insere duas regras demonstrativas:

- PE -> SP interestadual PJ;
- PE -> PE interna PF.

Essas regras iniciais depois sao evoluidas pelas migrations seguintes.

## 002_model_fiscal_rule_engine.sql

Essa migration transforma o modelo simples em um motor de regras mais flexivel.

### Novas Colunas Em fiscal_rules

| Campo | Uso |
|---|---|
| `rule_code` | Codigo unico legivel da regra |
| `description` | Descricao |
| `priority` | Prioridade de aplicacao |
| `status` | Status da regra |
| `calculation_basis` | Base de calculo |

Status aceitos:

```text
DRAFT
PENDING_REVIEW
APPROVED
INACTIVE
```

Base aceita:

```text
FREIGHT_VALUE
```

### fiscal_rule_conditions

Guarda condicoes que precisam ser verdadeiras para uma regra ser aplicada.

Campos:

| Campo | Uso |
|---|---|
| `fiscal_rule_id` | Regra dona da condicao |
| `field_name` | Campo avaliado |
| `operator` | Operador |
| `field_value` | Valor esperado |

Operadores:

```text
EQUALS
NOT_EQUALS
IN
BETWEEN
```

Campos avaliados pelo Go:

```text
operation_date
origin_uf
destination_uf
operation_type
customer_type
```

Exemplo conceitual:

```text
field_name = origin_uf
operator = EQUALS
field_value = PE
```

### fiscal_rule_taxes

Move os impostos para uma tabela filha.

Campos:

| Campo | Uso |
|---|---|
| `fiscal_rule_id` | Regra dona do imposto |
| `tax_name` | `ICMS`, `IBS` ou `CBS` |
| `rate` | Aliquota |
| `base_reduction_rate` | Reducao da base |
| `calculation_order` | Ordem do calculo |

Ponto importante:

```text
O Go exige que a regra final tenha ICMS, IBS e CBS.
Se faltar algum, retorna FISCAL_RULE_INCOMPLETE.
```

### Migracao Dos Dados Antigos

A migration pega as regras antigas e cria automaticamente:

- condicao por `origin_uf`;
- condicao por `destination_uf`;
- condicao por `operation_type`;
- condicao por `customer_type`;
- imposto ICMS;
- imposto IBS;
- imposto CBS.

Assim, o modelo antigo continua funcionando no novo motor.

## 003_add_fiscal_rule_source_and_review_tracking.sql

Essa migration adiciona rastreabilidade de fonte e revisao contabil.

### fiscal_rule_sources

Guarda a fonte da regra.

Campos:

| Campo | Uso |
|---|---|
| `fiscal_rule_id` | Regra relacionada |
| `source_type` | Tipo de fonte |
| `source_status` | Status da fonte |
| `title` | Titulo |
| `reference` | Referencia |
| `url` | Link opcional |
| `published_at` | Data de publicacao |
| `notes` | Observacoes |

Tipos de fonte:

```text
FEDERAL_LAW
STATE_LAW
CONFAZ
SEFAZ
SENATE_RESOLUTION
ACCOUNTING_GUIDANCE
INTERNAL_NOTE
```

Status de fonte:

```text
PENDING_CONFIRMATION
CONFIRMED
REPLACED
```

### fiscal_rule_accounting_reviews

Guarda revisao contabil/fiscal da regra.

Campos:

| Campo | Uso |
|---|---|
| `fiscal_rule_id` | Regra revisada |
| `review_status` | Resultado da revisao |
| `reviewer_name` | Nome do revisor |
| `reviewer_role` | Papel/cargo |
| `reviewed_at` | Data/hora da revisao |
| `notes` | Observacoes |

Status:

```text
PENDING_REVIEW
APPROVED
REJECTED
CHANGES_REQUESTED
```

### Efeito Sobre Regras Existentes

A migration marca regras sem revisao aprovada como:

```text
PENDING_REVIEW
```

E cria fonte padrao:

```text
source_type = INTERNAL_NOTE
source_status = PENDING_CONFIRMATION
reference = A_CONFIRMAR
```

Como explicar:

```text
Essa migration torna explicito que regra fiscal precisa de fonte e revisao antes de uso produtivo.
```

## 004_persist_fiscal_calculation_audit.sql

Essa migration melhora a auditoria das simulacoes.

### Campos Novos Em fiscal_simulations

| Campo | Uso |
|---|---|
| `rule_id` | FK para regra aplicada |
| `rule_code` | Codigo da regra aplicada |
| `rule_status` | Status da regra no momento |
| `calculation_basis` | Base usada |

### fiscal_simulation_tax_details

Guarda a memoria de calculo detalhada por imposto.

Campos:

| Campo | Uso |
|---|---|
| `fiscal_simulation_id` | Simulacao relacionada |
| `tax_name` | `ICMS`, `IBS` ou `CBS` |
| `base_value` | Base original |
| `base_reduction_rate` | Reducao aplicada |
| `effective_base_value` | Base apos reducao |
| `rate` | Aliquota |
| `amount` | Valor calculado |
| `formula` | Formula usada |

Formula atual:

```text
effective_base_value * rate / 100
```

Ponto tecnico:

```text
Essa tabela permite explicar como cada valor foi calculado, nao apenas o total final.
```

## 005_seed_demonstrative_fallback_rules.sql

Cria regras fallback demonstrativas para o MVP.

Objetivo:

```text
Permitir que o Motor Fiscal calcule uma resposta mesmo quando nao existe regra especifica por UF.
```

Regras criadas:

| Regra | Operacao | Cliente | ICMS | IBS | CBS | CFOP |
|---|---|---|---:|---:|---:|---|
| `FALLBACK_INTERESTADUAL_PJ_2026_01` | Interestadual | PJ | 12.00 | 3.60 | 0.90 | 6351 |
| `FALLBACK_INTERESTADUAL_PF_2026_01` | Interestadual | PF | 12.00 | 3.60 | 0.90 | 6351 |
| `FALLBACK_INTERNA_PJ_2026_01` | Interna | PJ | 18.00 | 3.60 | 0.90 | 5351 |
| `FALLBACK_INTERNA_PF_2026_01` | Interna | PF | 18.00 | 3.60 | 0.90 | 5351 |

Caracteristicas:

```text
priority = 900
status = PENDING_REVIEW
calculation_basis = FREIGHT_VALUE
source_type = INTERNAL_NOTE
source_status = PENDING_CONFIRMATION
review_status = PENDING_REVIEW
```

Como funciona a prioridade:

```text
O motor ordena por prioridade ASC.
Prioridade 100 ganha de prioridade 900.
Logo, uma regra especifica vence o fallback.
```

Ponto de atencao:

```text
Fallback e demonstrativo. Nao deve ser defendido como regra fiscal oficial.
```

## Como O Go Usa Essas Tabelas

### Busca De Regra

Arquivo Go:

```text
internal/repository/fiscal_rule_repository.go
```

Busca regras candidatas:

```text
active = TRUE
status IN ('APPROVED', 'PENDING_REVIEW')
operation_date BETWEEN valid_from AND valid_to
```

Depois carrega:

- `fiscal_rule_conditions`;
- `fiscal_rule_taxes`.

### Matching Da Regra

Arquivo Go:

```text
internal/service/fiscal_rule_service.go
```

Fluxo:

```text
1. Recebe regras candidatas
2. Testa todas as condicoes
3. Mantem apenas regras que casam com o request
4. Ordena por priority
5. Desempata por valid_from mais recente
6. Detecta conflito se priority e valid_from empatam
7. Retorna regra final
```

### Calculo

Arquivo Go:

```text
internal/service/tax_calculator.go
```

Usa os impostos da tabela:

```text
fiscal_rule_taxes
```

Calcula:

```text
amount = effective_base_value * rate / 100
total_tax = soma dos impostos
total_with_tax = freight_value + total_tax
```

### Persistencia Da Simulacao

Arquivo Go:

```text
internal/repository/fiscal_simulation_repository.go
```

Quando o endpoint e `simulate`, salva:

```text
fiscal_simulations
fiscal_simulation_tax_details
```

Quando o endpoint e `preview`, calcula mas nao salva auditoria oficial.

## Diferenca Entre Banco Java E Banco Motor Fiscal

| Tema | Sistema Java | Motor Fiscal Go |
|---|---|---|
| Frete operacional | Sim | Nao |
| Cliente/motorista/veiculo | Sim | Nao |
| Resumo fiscal no frete | Sim | Nao diretamente |
| Regra fiscal | Nao | Sim |
| Fonte legal/revisao | Nao | Sim |
| Memoria de calculo | Nao | Sim |
| Historico de simulacao fiscal | Nao | Sim |

Explicacao boa:

```text
O Java guarda o resultado fiscal necessario para a operacao do frete.
O Go guarda a inteligencia fiscal e a auditoria detalhada.
```

## Idempotencia Das Migrations

As migrations usam muito:

```sql
CREATE TABLE IF NOT EXISTS
ADD COLUMN IF NOT EXISTS
CREATE INDEX IF NOT EXISTS
ON CONFLICT DO NOTHING
ON CONFLICT DO UPDATE
```

Isso torna a execucao mais segura em ambiente de desenvolvimento.

Ponto de atencao:

```text
Mesmo com IF NOT EXISTS, a ordem continua importante.
Por exemplo, a migration 005 depende de rule_code criado na 002.
```

## Erros Que O SQL Ajuda A Evitar

| Mecanismo | Evita |
|---|---|
| FK com `ON DELETE CASCADE` nas tabelas filhas de regra | Condicoes/impostos orfaos |
| Unique em `rule_code` | Duas regras com mesmo codigo |
| Unique em condicoes | Condicoes repetidas na mesma regra |
| Unique em impostos | Mesmo imposto duplicado na regra |
| Checks de status | Status invalido |
| Checks de tax_name | Imposto fora de ICMS/IBS/CBS |
| Checks de reducao | Reducao fora de 0 a 100 |

## Pontos De Atencao Tecnica

- `PENDING_REVIEW` e aceito pelo motor, mas deve ser visto como regra nao homologada.
- Regras fallback existem para demonstracao e continuidade do MVP.
- O campo `from_cache` existe, mas o codigo atual retorna `false`; cache real nao esta implementado.
- `fiscal_rule_sources` e `fiscal_rule_accounting_reviews` sao essenciais para defender governanca fiscal.
- A memoria completa do calculo fica no banco Go, nao no banco Java.
- Se nao houver regra vigente, a API retorna erro e o Java marca o frete como erro fiscal.

## Explicacao Tecnica Curta

```text
O banco do Motor Fiscal e um banco de regras e auditoria. A tabela fiscal_rules guarda o cabecalho da regra, fiscal_rule_conditions define quando ela se aplica e fiscal_rule_taxes define quais impostos e aliquotas entram no calculo. As tabelas de sources e accounting_reviews documentam fonte e revisao da regra. Quando o Java chama o endpoint simulate, o Go escolhe a regra, calcula os tributos e grava fiscal_simulations e fiscal_simulation_tax_details, mantendo a memoria completa do calculo.
```

## Como Apresentar O Modelo Em 1 Minuto

```text
No Motor Fiscal, a regra nao esta hardcoded no Go. Ela esta no banco.
O Go apenas interpreta essas regras.
Primeiro ele filtra por vigencia e status.
Depois avalia as condicoes da regra contra o request.
Em seguida aplica os impostos configurados.
Por fim, salva a simulacao e os detalhes de calculo para auditoria.
```


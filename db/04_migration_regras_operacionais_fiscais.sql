-- ============================================================
-- 04_migration_regras_operacionais_fiscais.sql
-- Regras operacionais: CNH, tipos/capacidade de veiculo e resumo fiscal.
-- Seguro para bases existentes: constraints críticas em dados legados
-- potencialmente sujos são criadas como NOT VALID quando necessário.
-- ============================================================

-- CNH com categorias compostas.
ALTER TABLE motorista
    ALTER COLUMN cnh_categoria TYPE VARCHAR(2);

DO $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM pg_constraint
         WHERE conname = 'ck_motorista_cat'
           AND conrelid = 'motorista'::regclass
    ) THEN
        ALTER TABLE motorista DROP CONSTRAINT ck_motorista_cat;
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
         WHERE conname = 'ck_motorista_cat'
           AND conrelid = 'motorista'::regclass
    ) THEN
        ALTER TABLE motorista
            ADD CONSTRAINT ck_motorista_cat
            CHECK (cnh_categoria IN ('A','B','C','D','E','AB','AC','AD','AE'));
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
         WHERE conname = 'ck_motorista_cnh_numero'
           AND conrelid = 'motorista'::regclass
    ) THEN
        ALTER TABLE motorista
            ADD CONSTRAINT ck_motorista_cnh_numero
            CHECK (cnh_numero ~ '^[0-9]{11}$') NOT VALID;
    END IF;
END $$;

-- Tipos de veiculo ampliados.
DO $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM pg_constraint
         WHERE conname = 'ck_veiculo_tipo'
           AND conrelid = 'veiculo'::regclass
    ) THEN
        ALTER TABLE veiculo DROP CONSTRAINT ck_veiculo_tipo;
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
         WHERE conname = 'ck_veiculo_tipo'
           AND conrelid = 'veiculo'::regclass
    ) THEN
        ALTER TABLE veiculo
            ADD CONSTRAINT ck_veiculo_tipo
            CHECK (tipo IN ('M','U','V','L','Q','O','K','C','B'));
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
         WHERE conname = 'ck_veiculo_capacidade_pos'
           AND conrelid = 'veiculo'::regclass
    ) THEN
        ALTER TABLE veiculo
            ADD CONSTRAINT ck_veiculo_capacidade_pos
            CHECK (capacidade_kg IS NULL OR capacidade_kg > 0) NOT VALID;
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
         WHERE conname = 'ck_veiculo_capacidade_tipo'
           AND conrelid = 'veiculo'::regclass
    ) THEN
        ALTER TABLE veiculo
            ADD CONSTRAINT ck_veiculo_capacidade_tipo
            CHECK (
                capacidade_kg IS NULL OR
                (tipo = 'M' AND capacidade_kg BETWEEN 1 AND 30) OR
                (tipo = 'U' AND capacidade_kg BETWEEN 50 AND 500) OR
                (tipo = 'V' AND capacidade_kg BETWEEN 300 AND 1500) OR
                (tipo = 'L' AND capacidade_kg BETWEEN 1000 AND 3000) OR
                (tipo = 'Q' AND capacidade_kg BETWEEN 1500 AND 4000) OR
                (tipo = 'O' AND capacidade_kg BETWEEN 3000 AND 6000) OR
                (tipo = 'K' AND capacidade_kg BETWEEN 6000 AND 14000) OR
                (tipo = 'C' AND capacidade_kg BETWEEN 14000 AND 30000) OR
                (tipo = 'B' AND capacidade_kg BETWEEN 30000 AND 57000)
            ) NOT VALID;
    END IF;
END $$;

-- Campos fiscais e classificacoes automáticas no frete.
ALTER TABLE frete
    ADD COLUMN IF NOT EXISTS tipo_operacao VARCHAR(20),
    ADD COLUMN IF NOT EXISTS tipo_destinatario VARCHAR(20),
    ADD COLUMN IF NOT EXISTS cfop VARCHAR(20) NOT NULL DEFAULT 'Não calculado',
    ADD COLUMN IF NOT EXISTS motivo_cfop VARCHAR(160) NOT NULL DEFAULT 'Aguardando integração fiscal',
    ADD COLUMN IF NOT EXISTS status_fiscal VARCHAR(20) NOT NULL DEFAULT 'PENDENTE',
    ADD COLUMN IF NOT EXISTS regra_fiscal_aplicada VARCHAR(160) NOT NULL DEFAULT 'Aguardando integração',
    ADD COLUMN IF NOT EXISTS total_tributos NUMERIC(12,2) NOT NULL DEFAULT 0,
    ADD COLUMN IF NOT EXISTS valor_total_estimado NUMERIC(12,2) NOT NULL DEFAULT 0;

UPDATE frete f
   SET tipo_operacao = CASE
        WHEN UPPER(TRIM(f.uf_origem)) <> UPPER(TRIM(f.uf_destino)) THEN 'INTERESTADUAL'
        WHEN UPPER(TRIM(f.municipio_origem)) <> UPPER(TRIM(f.municipio_destino)) THEN 'ESTADUAL'
        ELSE 'MUNICIPAL'
       END
 WHERE tipo_operacao IS NULL;

UPDATE frete f
   SET tipo_destinatario = CASE
        WHEN length(regexp_replace(c.cnpj, '[^0-9]', '', 'g')) = 11 THEN 'PESSOA_FISICA'
        WHEN length(regexp_replace(c.cnpj, '[^0-9]', '', 'g')) = 14 THEN 'PESSOA_JURIDICA'
        ELSE tipo_destinatario
       END
  FROM cliente c
 WHERE f.id_destinatario = c.idcliente
   AND f.tipo_destinatario IS NULL;

UPDATE frete
   SET valor_total_estimado = CASE
        WHEN valor_total_estimado = 0 THEN valor_frete + total_tributos
        ELSE valor_total_estimado
       END;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
         WHERE conname = 'ck_frete_tipo_operacao'
           AND conrelid = 'frete'::regclass
    ) THEN
        ALTER TABLE frete
            ADD CONSTRAINT ck_frete_tipo_operacao
            CHECK (tipo_operacao IS NULL OR tipo_operacao IN ('MUNICIPAL','ESTADUAL','INTERESTADUAL'));
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
         WHERE conname = 'ck_frete_tipo_destinatario'
           AND conrelid = 'frete'::regclass
    ) THEN
        ALTER TABLE frete
            ADD CONSTRAINT ck_frete_tipo_destinatario
            CHECK (tipo_destinatario IS NULL OR tipo_destinatario IN ('PESSOA_FISICA','PESSOA_JURIDICA'));
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
         WHERE conname = 'ck_frete_status_fiscal'
           AND conrelid = 'frete'::regclass
    ) THEN
        ALTER TABLE frete
            ADD CONSTRAINT ck_frete_status_fiscal
            CHECK (status_fiscal IN ('PENDENTE','CALCULADO','ERRO','VALIDADO_CTE'));
    END IF;
END $$;

-- Unicidade crítica. Caso existam duplicados ativos, limpe-os antes de criar os índices.
DO $$
BEGIN
    IF EXISTS (
        SELECT 1
          FROM cliente
         WHERE is_ativo = TRUE AND cnpj IS NOT NULL
         GROUP BY cnpj
        HAVING COUNT(*) > 1
    ) THEN
        RAISE NOTICE 'Existem clientes ativos com CPF/CNPJ duplicado. Regularize antes de criar uq_cliente_documento_ativo.';
    ELSE
        CREATE UNIQUE INDEX IF NOT EXISTS uq_cliente_documento_ativo
            ON cliente(cnpj)
         WHERE is_ativo = TRUE AND cnpj IS NOT NULL;
    END IF;

    IF EXISTS (
        SELECT 1
          FROM motorista
         WHERE cpf IS NOT NULL
         GROUP BY cpf
        HAVING COUNT(*) > 1
    ) THEN
        RAISE NOTICE 'Existem motoristas com CPF duplicado. Regularize antes de reforçar a unicidade.';
    ELSE
        CREATE UNIQUE INDEX IF NOT EXISTS uq_motorista_cpf_idx ON motorista(cpf);
    END IF;
END $$;

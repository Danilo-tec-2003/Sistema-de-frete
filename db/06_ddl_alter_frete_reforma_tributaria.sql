-- ============================================================
-- 06_ddl_alter_frete_reforma_tributaria.sql
-- Compatibiliza bases existentes com as colunas IBS/CBS usadas
-- pelo modulo de frete.
-- ============================================================

ALTER TABLE frete
    ADD COLUMN IF NOT EXISTS aliquota_ibs NUMERIC(5,2) NOT NULL DEFAULT 0,
    ADD COLUMN IF NOT EXISTS valor_ibs    NUMERIC(12,2) NOT NULL DEFAULT 0,
    ADD COLUMN IF NOT EXISTS aliquota_cbs NUMERIC(5,2) NOT NULL DEFAULT 0,
    ADD COLUMN IF NOT EXISTS valor_cbs    NUMERIC(12,2) NOT NULL DEFAULT 0;

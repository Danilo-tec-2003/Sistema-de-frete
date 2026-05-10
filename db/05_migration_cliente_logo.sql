-- ============================================================
-- 05_migration_cliente_logo.sql
-- Armazena a logo do cliente diretamente no cadastro.
-- ============================================================

ALTER TABLE cliente
    ADD COLUMN IF NOT EXISTS logo_nome_arquivo VARCHAR(160),
    ADD COLUMN IF NOT EXISTS logo_content_type VARCHAR(80),
    ADD COLUMN IF NOT EXISTS logo_dados BYTEA;

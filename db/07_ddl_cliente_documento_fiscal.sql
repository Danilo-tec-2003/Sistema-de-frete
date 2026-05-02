-- ============================================================
-- 07_ddl_cliente_documento_fiscal.sql
-- Cliente pode atuar como remetente ou destinatário por frete.
-- O cadastro guarda apenas a identidade fiscal: CPF ou CNPJ.
-- ============================================================

UPDATE cliente
   SET tipo = 'a',
       updated_at = NOW()
 WHERE tipo <> 'a';

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
          FROM pg_constraint
         WHERE conname = 'ck_cliente_documento_tamanho'
           AND conrelid = 'cliente'::regclass
    ) THEN
        ALTER TABLE cliente
            ADD CONSTRAINT ck_cliente_documento_tamanho
            CHECK (cnpj IS NULL OR length(cnpj) IN (11, 14));
    END IF;
END $$;

COMMENT ON COLUMN cliente.cnpj IS 'Documento fiscal do cliente: CPF com 11 dígitos ou CNPJ com 14 dígitos.';
COMMENT ON COLUMN cliente.tipo IS 'Compatibilidade: papel do cliente é definido no frete; usar a=Ambos.';

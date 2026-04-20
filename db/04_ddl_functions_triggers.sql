-- ============================================================
-- 04_ddl_functions_triggers.sql
-- TRIGGERS e FUNÇÕES — Atualização automática de timestamp
-- ============================================================

CREATE OR REPLACE FUNCTION fn_atualiza_updated_at()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_frete_updated_at
    BEFORE UPDATE ON frete
    FOR EACH ROW EXECUTE FUNCTION fn_atualiza_updated_at();

CREATE TRIGGER trg_motorista_updated_at
    BEFORE UPDATE ON motorista
    FOR EACH ROW EXECUTE FUNCTION fn_atualiza_updated_at();

CREATE TRIGGER trg_veiculo_updated_at
    BEFORE UPDATE ON veiculo
    FOR EACH ROW EXECUTE FUNCTION fn_atualiza_updated_at();
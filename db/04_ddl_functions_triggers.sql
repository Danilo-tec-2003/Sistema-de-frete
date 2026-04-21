-- ============================================================
-- 04_ddl_functions_triggers.sql
-- FUNÇÕES E TRIGGERS
-- ============================================================

-- ============================================================
-- fn_atualiza_updated_at
-- Atualiza updated_at automaticamente em qualquer UPDATE.
-- O Java também atualiza via "updated_at = NOW()" nas queries,
-- mas o trigger garante consistência mesmo em updates diretos no banco.
-- ============================================================
CREATE OR REPLACE FUNCTION fn_atualiza_updated_at()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$;

-- Triggers em todas as tabelas que possuem updated_at
CREATE TRIGGER trg_usuario_updated_at
    BEFORE UPDATE ON usuario
    FOR EACH ROW EXECUTE FUNCTION fn_atualiza_updated_at();

CREATE TRIGGER trg_cliente_updated_at
    BEFORE UPDATE ON cliente
    FOR EACH ROW EXECUTE FUNCTION fn_atualiza_updated_at();

CREATE TRIGGER trg_motorista_updated_at
    BEFORE UPDATE ON motorista
    FOR EACH ROW EXECUTE FUNCTION fn_atualiza_updated_at();

CREATE TRIGGER trg_veiculo_updated_at
    BEFORE UPDATE ON veiculo
    FOR EACH ROW EXECUTE FUNCTION fn_atualiza_updated_at();

CREATE TRIGGER trg_frete_updated_at
    BEFORE UPDATE ON frete
    FOR EACH ROW EXECUTE FUNCTION fn_atualiza_updated_at();

-- ============================================================
-- fn_valida_ocorrencia_cronologia
-- Garante que a data/hora da nova ocorrência nunca seja anterior
-- à ocorrência mais recente do mesmo frete.
-- Regra de negócio duplicada aqui como última linha de defesa
-- (a validação principal está no OcorrenciaBO).
-- ============================================================
CREATE OR REPLACE FUNCTION fn_valida_ocorrencia_cronologia()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
DECLARE
    ultima_data_hora TIMESTAMP;
BEGIN
    SELECT MAX(data_hora)
      INTO ultima_data_hora
      FROM ocorrencia_frete
     WHERE id_frete = NEW.id_frete;

    IF ultima_data_hora IS NOT NULL AND NEW.data_hora < ultima_data_hora THEN
        RAISE EXCEPTION
            'Data/hora da ocorrência (%) não pode ser anterior à última ocorrência do frete (%).',
            NEW.data_hora, ultima_data_hora;
    END IF;

    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_ocorrencia_cronologia
    BEFORE INSERT ON ocorrencia_frete
    FOR EACH ROW EXECUTE FUNCTION fn_valida_ocorrencia_cronologia();
-- ============================================================
-- 02_ddl_indexes.sql
-- ÍNDICES — Otimizações de filtros
-- ============================================================

CREATE INDEX idx_frete_status       ON frete(status);
CREATE INDEX idx_frete_data_emissao ON frete(data_emissao);
CREATE INDEX idx_frete_id_motorista ON frete(id_motorista);
CREATE INDEX idx_frete_id_cliente   ON frete(id_cliente);
CREATE INDEX idx_frete_id_veiculo   ON frete(id_veiculo);
CREATE INDEX idx_ocorrencia_frete   ON ocorrencia(id_frete);
-- ============================================================
-- 02_ddl_indexes.sql
-- ÍNDICES — Otimizações para filtros e JOINs frequentes
-- ============================================================

-- ---- CLIENTE ----
CREATE INDEX IF NOT EXISTS idx_cli_razao_social ON cliente(razao_social);   -- filtro ILIKE no ClienteDAO.listar()
CREATE INDEX IF NOT EXISTS idx_cli_cnpj         ON cliente(cnpj);         -- documento fiscal: CPF ou CNPJ
CREATE INDEX IF NOT EXISTS idx_cli_is_ativo     ON cliente(is_ativo);

-- ---- MOTORISTA ----
CREATE INDEX IF NOT EXISTS idx_mot_nome         ON motorista(nome);          -- filtro ILIKE no MotoristaDAO.listar()
CREATE INDEX IF NOT EXISTS idx_mot_status       ON motorista(status);
CREATE INDEX IF NOT EXISTS idx_mot_cpf          ON motorista(cpf);

-- ---- VEICULO ----
CREATE INDEX IF NOT EXISTS idx_vei_placa        ON veiculo(placa);           -- filtro ILIKE no VeiculoDAO.listar()
CREATE INDEX IF NOT EXISTS idx_vei_status       ON veiculo(status);

-- ---- FRETE ----
CREATE INDEX IF NOT EXISTS idx_fre_status         ON frete(status);
CREATE INDEX IF NOT EXISTS idx_fre_data_emissao   ON frete(data_emissao);
CREATE INDEX IF NOT EXISTS idx_fre_data_prev      ON frete(data_prev_entrega);
CREATE INDEX IF NOT EXISTS idx_fre_id_remetente   ON frete(id_remetente);
CREATE INDEX IF NOT EXISTS idx_fre_id_destinatario ON frete(id_destinatario);
CREATE INDEX IF NOT EXISTS idx_fre_id_motorista   ON frete(id_motorista);
CREATE INDEX IF NOT EXISTS idx_fre_id_veiculo     ON frete(id_veiculo);

-- ---- OCORRENCIA_FRETE ----
CREATE INDEX IF NOT EXISTS idx_occ_id_frete       ON ocorrencia_frete(id_frete);
CREATE INDEX IF NOT EXISTS idx_occ_data_hora      ON ocorrencia_frete(data_hora);
CREATE INDEX IF NOT EXISTS idx_occ_tipo           ON ocorrencia_frete(tipo);

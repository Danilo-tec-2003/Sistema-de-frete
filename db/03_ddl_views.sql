-- ============================================================
-- 03_ddl_views.sql
-- VIEWS — Consultas desnormalizadas para JSPs e relatórios
-- Nomes de colunas alinhados com DAOs Java e enums.
-- ============================================================

-- ============================================================
-- vbi_fretes
-- Usada na listagem, detalhes do frete e relatórios JasperReports.
-- Dois JOINs em cliente: um para remetente, um para destinatário.
-- dias_atraso calculado para todos os status (GREATEST evita negativo).
-- ============================================================
CREATE OR REPLACE VIEW vbi_fretes AS
SELECT
    f.idfrete,
    f.numero,
    f.status,
    f.data_emissao,
    f.data_prev_entrega,
    f.data_saida,
    f.data_entrega,
    f.municipio_origem,
    f.uf_origem,
    f.municipio_destino,
    f.uf_destino,
    f.descricao_carga,
    f.peso_kg,
    f.volumes,
    f.valor_frete,
    f.aliquota_icms,
    f.valor_icms,
    f.valor_total,
    f.observacao,
    -- remetente
    f.id_remetente,
    rem.razao_social   AS nome_remetente,
    rem.cnpj           AS cnpj_remetente,
    rem.municipio      AS municipio_remetente,
    rem.uf             AS uf_remetente,
    -- destinatário
    f.id_destinatario,
    dest.razao_social  AS nome_destinatario,
    dest.cnpj          AS cnpj_destinatario,
    dest.municipio     AS municipio_destinatario,
    dest.uf            AS uf_destinatario,
    -- motorista
    f.id_motorista,
    m.nome             AS nome_motorista,
    m.cpf              AS cpf_motorista,
    m.cnh_numero,
    m.cnh_categoria,
    m.cnh_validade,
    -- veículo
    f.id_veiculo,
    v.placa,
    v.tipo             AS tipo_veiculo,
    v.capacidade_kg,
    v.volume_m3,
    -- dias de atraso em relação à data prevista
    GREATEST(0, CURRENT_DATE - f.data_prev_entrega) AS dias_atraso
FROM frete f
JOIN cliente   rem  ON f.id_remetente    = rem.idcliente
JOIN cliente   dest ON f.id_destinatario = dest.idcliente
JOIN motorista m    ON f.id_motorista    = m.idmotorista
JOIN veiculo   v    ON f.id_veiculo      = v.idveiculo;

-- ============================================================
-- vbi_fretes_aberto
-- Relatório 1 JasperReports: fretes ainda em andamento.
-- status IN ('E','S','T') = Emitido | SaídaConfirmada | EmTrânsito
-- ============================================================
CREATE OR REPLACE VIEW vbi_fretes_aberto AS
SELECT
    idfrete,
    numero,
    status,
    data_emissao,
    data_prev_entrega,
    municipio_origem,
    uf_origem,
    municipio_destino,
    uf_destino,
    nome_remetente,
    nome_destinatario,
    nome_motorista,
    placa,
    peso_kg,
    volumes,
    valor_total,
    dias_atraso
FROM vbi_fretes
WHERE status IN ('E','S','T')
ORDER BY dias_atraso DESC, data_prev_entrega ASC;

-- ============================================================
-- vbi_motoristas
-- Enriquece motorista com flag de CNH vencida e fretes ativos.
-- ============================================================
CREATE OR REPLACE VIEW vbi_motoristas AS
SELECT
    m.idmotorista,
    m.nome,
    m.cpf,
    m.data_nascimento,
    m.telefone,
    m.cnh_numero,
    m.cnh_categoria,
    m.cnh_validade,
    m.tipo_vinculo,
    m.status,
    (m.cnh_validade < CURRENT_DATE)                               AS cnh_vencida,
    COUNT(f.idfrete) FILTER (WHERE f.status = 'T')                AS fretes_em_transito,
    COUNT(f.idfrete) FILTER (WHERE f.status IN ('E','S','T'))     AS fretes_ativos
FROM motorista m
LEFT JOIN frete f ON f.id_motorista = m.idmotorista
GROUP BY m.idmotorista;

-- ============================================================
-- vbi_veiculos
-- Enriquece veículo com contagem de fretes ativos.
-- ============================================================
CREATE OR REPLACE VIEW vbi_veiculos AS
SELECT
    v.idveiculo,
    v.placa,
    v.rntrc,
    v.ano_fabricacao,
    v.tipo,
    v.tara_kg,
    v.capacidade_kg,
    v.volume_m3,
    v.status,
    COUNT(f.idfrete) FILTER (WHERE f.status = 'T')            AS fretes_em_transito,
    COUNT(f.idfrete) FILTER (WHERE f.status IN ('E','S','T')) AS fretes_ativos
FROM veiculo v
LEFT JOIN frete f ON f.id_veiculo = v.idveiculo
GROUP BY v.idveiculo;

-- ============================================================
-- vbi_ocorrencias
-- Histórico cronológico com número do frete desnormalizado.
-- ============================================================
CREATE OR REPLACE VIEW vbi_ocorrencias AS
SELECT
    o.idocorrencia,
    o.id_frete,
    f.numero         AS numero_frete,
    f.status         AS status_frete,
    o.tipo,
    o.data_hora,
    o.municipio,
    o.uf,
    o.descricao,
    o.nome_recebedor,
    o.documento_recebedor,
    o.created_at,
    o.created_by
FROM ocorrencia_frete o
JOIN frete f ON f.idfrete = o.id_frete
ORDER BY o.data_hora ASC;
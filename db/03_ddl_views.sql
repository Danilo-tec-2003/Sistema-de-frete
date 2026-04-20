-- ============================================================
-- 03_ddl_views.sql
-- VIEWS —  Consultas Simplificadas
-- ============================================================

CREATE OR REPLACE VIEW vbi_fretes AS
SELECT
    f.id_frete,
    f.numero_frete,
    f.status,
    f.data_emissao,
    f.data_previsao,
    f.data_entrega,
    f.cidade_origem,
    f.uf_origem,
    f.cidade_destino,
    f.uf_destino,
    f.valor_frete,
    f.aliquota_icms,
    f.valor_icms,
    f.valor_total,
    f.peso_kg,
    GREATEST(0, CURRENT_DATE - f.data_previsao) AS dias_atraso,
    c.nome       AS nome_cliente,
    c.cpf_cnpj   AS cpf_cnpj_cliente,
    m.nome       AS nome_motorista,
    m.cpf        AS cpf_motorista,
    v.placa,
    v.modelo     AS modelo_veiculo,
    v.tipo_veiculo
FROM frete f
JOIN cliente   c ON c.id_cliente   = f.id_cliente
JOIN motorista m ON m.id_motorista = f.id_motorista
JOIN veiculo   v ON v.id_veiculo   = f.id_veiculo;

CREATE OR REPLACE VIEW vbi_motoristas AS
SELECT
    m.id_motorista,
    m.nome,
    m.cpf,
    m.numero_cnh,
    m.categoria_cnh,
    m.validade_cnh,
    m.telefone,
    m.is_ativo,
    m.is_disponivel,
    COUNT(f.id_frete) FILTER (WHERE f.status = 'EM_TRANSITO') AS fretes_em_aberto
FROM motorista m
LEFT JOIN frete f ON f.id_motorista = m.id_motorista
GROUP BY m.id_motorista;

CREATE OR REPLACE VIEW vbi_veiculos AS
SELECT
    v.id_veiculo,
    v.placa,
    v.modelo,
    v.marca,
    v.ano,
    v.tipo_veiculo,
    v.capacidade_kg,
    v.is_ativo,
    v.is_disponivel,
    COUNT(f.id_frete) FILTER (WHERE f.status = 'EM_TRANSITO') AS fretes_em_aberto
FROM veiculo v
LEFT JOIN frete f ON f.id_veiculo = v.id_veiculo
GROUP BY v.id_veiculo;
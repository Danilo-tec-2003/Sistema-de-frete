-- ============================================================
-- 05_dml_seed_data.sql
-- DADOS INICIAIS — Sistema de Gestão de Fretes GW
--
-- ⚠️  ATENÇÃO — senhas em SHA-256 (geradas pelo LoginDAO.sha256()):
--     admin     / admin123    → 240be518fabd2724ddb6f04eeb1da5967448d7e831c08c8fa822809f74c720a9
--     operador  / operador123 → 1725165c9a0b3698a3d01016e0d8205155820b8d7f21835ca64c0f81c728d880
--
-- ⚠️  ATENÇÃO — tipo cliente: 'r'=Remetente | 'd'=Destinatário | 'a'=Ambos (CHAR(1) minúsculo)
-- ⚠️  ATENÇÃO — status frete: 'E'|'S'|'T'|'R'|'N'|'C'  (FreteStatus enum)
-- ⚠️  ATENÇÃO — tipo ocorrência: 'P'|'R'|'T'|'E'|'A'|'X'|'O' (TipoOcorrencia enum)
-- ⚠️  ATENÇÃO — status motorista: 'A'|'I'|'S'  (StatusMotorista enum)
-- ⚠️  ATENÇÃO — status veículo: 'D'|'V'|'M'  (StatusVeiculo enum)
-- ⚠️  ATENÇÃO — tipo veículo: 'K'=Truck | 'C'=Carreta | 'V'=Van | 'U'=Utilitário
-- ⚠️  ATENÇÃO — cnh_categoria: 'A'|'B'|'C'|'D'|'E'
-- ⚠️  ATENÇÃO — tipo_vinculo: 'F'=Funcionário | 'G'=Agregado | 'T'=Terceiro
-- ============================================================


-- ============================================================
-- USUARIOS
-- ============================================================
INSERT INTO usuario (nome, login, senha, perfil) VALUES
('Administrador',  'admin',     '240be518fabd2724ddb6f04eeb1da5967448d7e831c08c8fa822809f74c720a9', 'ADMIN'),
('Carlos Eduardo', 'carlos',    '1725165c9a0b3698a3d01016e0d8205155820b8d7f21835ca64c0f81c728d880', 'OPERADOR'),
('Ana Beatriz',    'ana',       '1725165c9a0b3698a3d01016e0d8205155820b8d7f21835ca64c0f81c728d880', 'OPERADOR'),
('Lucas Santos',   'lucas',     '1725165c9a0b3698a3d01016e0d8205155820b8d7f21835ca64c0f81c728d880', 'OPERADOR');
-- Senhas: admin=admin123 | demais=operador123


-- ============================================================
-- CLIENTES
-- cnpj: apenas dígitos (14 chars) — ClienteDAO.preencherStatement() remove a máscara
-- tipo: 'r'=Remetente | 'd'=Destinatário | 'a'=Ambos
-- ============================================================
INSERT INTO cliente
    (razao_social, nome_fantasia, cnpj, inscricao_est, tipo,
     logradouro, numero_end, complemento, bairro, municipio, uf, cep,
     telefone, email, is_ativo)
VALUES
-- Remetentes
('Transportadora Silva Ltda',    'Trans Silva',   '11222333000181', '0112233-42', 'r',
 'Rua das Palmeiras',       '100', NULL,           'Boa Viagem',    'Recife',        'PE', '51020010',
 '(81) 3000-1111', 'silva@transporte.com.br', TRUE),

('Comércio Nordeste S.A.',       'ComNordeste',   '22333444000160', '0223344-53', 'r',
 'Av. Agamenon Magalhães',  '500', 'Sala 301',     'Espinheiro',    'Recife',        'PE', '52020010',
 '(81) 3000-2222', 'contato@nordeste.com', TRUE),

-- Destinatários
('Distribuidora Boa Vista LTDA', 'Boa Vista',     '33444555000149', '0334455-64', 'd',
 'Rua XV de Novembro',      '200', NULL,           'Centro',        'Natal',         'RN', '59010100',
 '(84) 3000-3333', 'bv@distribuidora.com', TRUE),

('Armazéns Paraíba Log EIRELI',  'APL Logística', '44555666000128', '0445566-75', 'd',
 'Rua Duque de Caxias',     '300', 'Galpão 2',     'Centro',        'João Pessoa',   'PB', '58010000',
 '(83) 3000-4444', 'log@armazens.pb', TRUE),

-- Ambos (usam tanto como remetente quanto destinatário)
('Indústria Ceará Tec LTDA',     'CearáTec',      '55666777000188', '0556677-86', 'a',
 'Rod. CE-060',              'km 5','Bloco B',     'Maracanaú',     'Fortaleza',     'CE', '61900000',
 '(85) 3000-5555', 'contato@cearatec.com', TRUE),

('Bahia Materiais S.A.',         'BahiaMat',      '66777888000167', '0667788-97', 'a',
 'Av. Paralela',            '1500', NULL,           'Paralela',      'Salvador',      'BA', '41730300',
 '(71) 3000-6666', 'vendas@bahiamat.com', TRUE),

-- Inativo (para testar regra de exibição)
('Sergipe Bebidas LTDA',         'SergipeBeb',    '77888999000146', '0778899-08', 'a',
 'Rua João Pessoa',          '50', NULL,           'Centro',        'Aracaju',       'SE', '49010020',
 '(79) 3000-7777', 'logistica@sergipebeb.com', FALSE);


-- ============================================================
-- MOTORISTAS
-- cpf: apenas dígitos (11 chars) — MotoristaDAO.preencher() remove a máscara
-- cnh_categoria: 'A'|'B'|'C'|'D'|'E'
-- tipo_vinculo:  'F'=Funcionário | 'G'=Agregado | 'T'=Terceiro
-- status:        'A'=Ativo | 'I'=Inativo | 'S'=Suspenso
-- ============================================================
INSERT INTO motorista
    (nome, cpf, data_nascimento, telefone,
     cnh_numero, cnh_categoria, cnh_validade,
     tipo_vinculo, status)
VALUES
-- CNH válida, ativo
('Carlos Alberto Silva',   '52998224725', '1985-03-10', '(81) 99001-1111',
 'CNH-00001', 'E', '2027-12-31', 'F', 'A'),

('Marcos Pereira Santos',  '37432720038', '1978-07-22', '(81) 99002-2222',
 'CNH-00002', 'D', '2028-06-30', 'G', 'A'),

('João Carlos Souza',      '56854288027', '1990-11-05', '(81) 99003-3333',
 'CNH-00003', 'E', '2026-09-15', 'F', 'A'),

('Francisco Oliveira',     '98765432100', '1982-04-18', '(84) 99004-4444',
 'CNH-00004', 'D', '2027-03-20', 'T', 'A'),

('Paulo Almeida Costa',    '11144477735', '1975-12-01', '(71) 99005-5555',
 'CNH-00005', 'E', '2029-11-30', 'G', 'A'),

-- CNH vencida (bloqueia novos fretes, não impede cadastro)
('José Oliveira Lima',     '86822582900', '1970-06-14', '(83) 99006-6666',
 'CNH-00006', 'C', '2024-03-01', 'T', 'A'),

-- Suspenso (para testar regra de status)
('Luiz Gonzaga Ferreira',  '72338925073', '1988-09-22', '(87) 99007-7777',
 'CNH-00007', 'E', '2027-07-10', 'F', 'S');


-- ============================================================
-- VEICULOS
-- tipo:   'K'=Truck | 'C'=Carreta | 'V'=Van | 'U'=Utilitário
-- status: 'D'=Disponível | 'V'=EmViagem | 'M'=EmManutenção
-- placa:  Mercosul (ABC1D23) ou antigo (ABC1234)
-- ============================================================
INSERT INTO veiculo
    (placa, rntrc, ano_fabricacao, tipo, tara_kg, capacidade_kg, volume_m3, status)
VALUES
('ABC1D23', 'RNTRC-00001', 2019, 'K', 8000.00,  14000.00,  90.000, 'D'),  -- Truck disponível
('XYZ2E45', 'RNTRC-00002', 2021, 'C', 7000.00,  25000.00, 120.000, 'D'),  -- Carreta disponível
('QWE3F67', 'RNTRC-00003', 2022, 'C', 7500.00,  28000.00, 135.000, 'D'),  -- Carreta disponível
('RST4G89', 'RNTRC-00004', 2020, 'V', 2500.00,   3000.00,  18.000, 'D'),  -- Van disponível
('MNO5H12', 'RNTRC-00005', 2018, 'U', 1200.00,   1500.00,   9.000, 'D'),  -- Utilitário disponível
('DEF6789', 'RNTRC-00006', 2023, 'K', 8500.00,  16000.00,  95.000, 'V'),  -- Truck em viagem (sincronizado com frete EM_TRANSITO abaixo)
('GHI1234', 'RNTRC-00007', 2017, 'C', 6500.00,  22000.00, 110.000, 'M');  -- Carreta em manutenção


-- ============================================================
-- FRETES
-- Cobrir todos os status para demonstração:
--   'E'=Emitido | 'S'=SaídaConfirmada | 'T'=EmTrânsito
--   'R'=Entregue | 'N'=NãoEntregue   | 'C'=Cancelado
--
-- id_remetente e id_destinatario devem referenciar clientes diferentes
-- (ou o mesmo cliente com tipo 'a').
-- ============================================================
INSERT INTO frete
    (numero, id_remetente, id_destinatario, id_motorista, id_veiculo,
     municipio_origem, uf_origem, municipio_destino, uf_destino,
     descricao_carga, peso_kg, volumes,
     valor_frete, aliquota_icms, valor_icms, valor_total,
     status, data_emissao, data_prev_entrega, data_saida, data_entrega,
     created_by)
VALUES
-- 1. EMITIDO — ainda não saiu do pátio
('FRT-2026-00001',
 1, 3,   -- Trans Silva (remetente) → Distribuidora Boa Vista (destinatário)
 1, 1,   -- Carlos Alberto, placa ABC1D23 (Truck)
 'Recife','PE','Natal','RN',
 'Eletrodomésticos', 8000.00, 30,
 2000.00, 12.00, 240.00, 2240.00,
 'E', '2026-04-20', '2026-04-25', NULL, NULL, 'admin'),

-- 2. SAÍDA CONFIRMADA — veículo saiu, ainda não entrou em rota
('FRT-2026-00002',
 2, 4,   -- ComNordeste → Armazéns Paraíba
 2, 2,   -- Marcos Pereira, placa XYZ2E45 (Carreta)
 'Recife','PE','João Pessoa','PB',
 'Alimentos secos e embalados', 12000.00, 50,
 1800.00, 12.00, 216.00, 2016.00,
 'S', '2026-04-19', '2026-04-22', '2026-04-19 08:00:00', NULL, 'admin'),

-- 3. EM TRÂNSITO — em rota (veículo 6 = DEF6789 com status 'V')
('FRT-2026-00003',
 5, 3,   -- CearáTec (remetente e destinatário ambos) → Distribuidora Boa Vista
 3, 6,   -- João Carlos, placa DEF6789 (Truck em viagem)
 'Fortaleza','CE','Natal','RN',
 'Peças eletrônicas', 5000.00, 20,
 3200.00, 12.00, 384.00, 3584.00,
 'T', '2026-04-18', '2026-04-23', '2026-04-18 07:30:00', NULL, 'admin'),

-- 4. ENTREGUE — concluído com sucesso
('FRT-2026-00004',
 1, 4,   -- Trans Silva → Armazéns Paraíba
 4, 3,   -- Francisco Oliveira, placa QWE3F67 (Carreta — já devolvida como D)
 'Recife','PE','João Pessoa','PB',
 'Produtos têxteis', 10000.00, 80,
 1500.00, 12.00, 180.00, 1680.00,
 'R', '2026-04-10', '2026-04-15', '2026-04-10 06:00:00', '2026-04-15 14:30:00', 'carlos'),

-- 5. NÃO ENTREGUE — tentativa frustrada
('FRT-2026-00005',
 2, 6,   -- ComNordeste → BahiaMat
 5, 4,   -- Paulo Almeida, placa RST4G89 (Van — já devolvida como D)
 'Recife','PE','Salvador','BA',
 'Materiais de construção', 2800.00, 15,
 2100.00, 12.00, 252.00, 2352.00,
 'N', '2026-04-12', '2026-04-17', '2026-04-12 08:00:00', NULL, 'carlos'),

-- 6. CANCELADO — cancelado antes da saída
('FRT-2026-00006',
 6, 3,   -- BahiaMat → Distribuidora Boa Vista
 2, 2,   -- Marcos Pereira, Carreta (retornou como D)
 'Salvador','BA','Natal','RN',
 'Bebidas diversas', 18000.00, 120,
 4500.00, 12.00, 540.00, 5040.00,
 'C', '2026-04-15', '2026-04-20', NULL, NULL, 'ana');


-- ============================================================
-- OCORRÊNCIAS
-- tipo: 'P'=SaídaPátio | 'R'=EmRota | 'T'=TentativaEntrega
--       'E'=EntregaRealizada | 'A'=Avaria | 'X'=Extravio | 'O'=Outros
-- ============================================================
INSERT INTO ocorrencia_frete
    (id_frete, tipo, data_hora, municipio, uf, descricao,
     nome_recebedor, documento_recebedor, created_by)
VALUES
-- Frete 2 (SAÍDA CONFIRMADA) — ocorrência de saída do pátio
(2, 'P', '2026-04-19 08:00:00', 'Recife',       'PE',
 'Veículo saiu do pátio em perfeitas condições. Carga conferida e lacrada.',
 NULL, NULL, 'carlos'),

-- Frete 3 (EM TRÂNSITO) — saída e ocorrência de rota
(3, 'P', '2026-04-18 07:30:00', 'Fortaleza',    'CE',
 'Veículo saiu do pátio da Ceará Tec.',
 NULL, NULL, 'admin'),

(3, 'R', '2026-04-19 14:00:00', 'Mossoró',      'RN',
 'Em rota, passagem por Mossoró sem intercorrências. Abastecimento realizado.',
 NULL, NULL, 'admin'),

(3, 'A', '2026-04-20 09:30:00', 'São Gonçalo do Amarante', 'RN',
 'Pequena avaria na embalagem de uma caixa identificada na vistoria. Conteúdo preservado.',
 NULL, NULL, 'admin'),

-- Frete 4 (ENTREGUE) — histórico completo
(4, 'P', '2026-04-10 06:00:00', 'Recife',       'PE',
 'Veículo saiu do pátio pontualmente.',
 NULL, NULL, 'carlos'),

(4, 'R', '2026-04-11 10:00:00', 'Caruaru',      'PE',
 'Em rota normal, sem intercorrências. Parada para descanso do motorista.',
 NULL, NULL, 'carlos'),

(4, 'E', '2026-04-15 14:30:00', 'João Pessoa',  'PB',
 'Entrega realizada com sucesso. Carga conferida pelo responsável.',
 'Pedro Henrique Almeida', '123.456.789-00', 'carlos'),

-- Frete 5 (NÃO ENTREGUE) — tentativa frustrada
(5, 'P', '2026-04-12 08:00:00', 'Recife',       'PE',
 'Veículo saiu do pátio.',
 NULL, NULL, 'carlos'),

(5, 'R', '2026-04-13 16:00:00', 'Feira de Santana', 'BA',
 'Em rota, parada para abastecimento e descanso obrigatório.',
 NULL, NULL, 'carlos'),

(5, 'T', '2026-04-17 09:00:00', 'Salvador',     'BA',
 'Tentativa de entrega frustrada: responsável ausente no estabelecimento. Retentativa agendada.',
 NULL, NULL, 'carlos');


-- ============================================================
-- Ajuste de sequências após seed (garante que os próximos
-- INSERTs peguem o próximo valor correto)
-- ============================================================
SELECT setval('seq_usuario',       (SELECT COALESCE(MAX(idusuario),  0) + 1 FROM usuario),  FALSE);
SELECT setval('seq_cliente',       (SELECT COALESCE(MAX(idcliente),  0) + 1 FROM cliente),  FALSE);
SELECT setval('seq_motorista',     (SELECT COALESCE(MAX(idmotorista),0) + 1 FROM motorista),FALSE);
SELECT setval('seq_veiculo',       (SELECT COALESCE(MAX(idveiculo),  0) + 1 FROM veiculo),  FALSE);
SELECT setval('seq_frete',         (SELECT COALESCE(MAX(idfrete),    0) + 1 FROM frete),    FALSE);
SELECT setval('seq_numero_frete',  (SELECT COALESCE(MAX(idfrete),    0) + 1 FROM frete),    FALSE);
SELECT setval('seq_ocorrencia',    (SELECT COALESCE(MAX(idocorrencia),0)+ 1 FROM ocorrencia_frete), FALSE);
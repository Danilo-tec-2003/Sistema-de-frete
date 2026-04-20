-- ============================================================
-- 05_dml_seed_data.sql
-- DADOS INICIAIS (Seed)
-- ============================================================

-- USUARIOS
INSERT INTO usuario (login, senha_hash, nome, perfil) VALUES 
('admin', 'admin123', 'Administrador', 'ADMIN'),
('operador1', 'hash123', 'Carlos Eduardo', 'OPERADOR'),
('operador2', 'hash123', 'Ana Beatriz', 'OPERADOR'),
('operador3', 'hash123', 'Lucas Santos', 'OPERADOR'),
('operador4', 'hash123', 'Mariana Costa', 'OPERADOR'),
('admin2', 'admin456', 'Roberto Almeida', 'ADMIN'),
('operador5', 'hash123', 'Fernanda Lima', 'OPERADOR'),
('operador6', 'hash123', 'Pedro Henrique', 'OPERADOR'),
('operador7', 'hash123', 'Camila Alves', 'OPERADOR'),
('operador8', 'hash123', 'João Vitor', 'OPERADOR');

-- CLIENTES
INSERT INTO cliente (nome, cpf_cnpj, telefone, email, cidade, uf) VALUES
('Transportadora Silva Ltda', '12.345.678/0001-90', '(81) 3000-1111', 'silva@transp.com.br', 'Recife', 'PE'),
('Comércio Nordeste S.A.', '98.765.432/0001-10', '(81) 3000-2222', 'contato@nordeste.com', 'Caruaru', 'PE'),
('Distribuidora Boa Vista', '11.222.333/0001-44', '(84) 3000-3333', 'bv@distribuidora.com', 'Natal', 'RN'),
('Armazéns Paraíba Log', '33.444.555/0001-66', '(83) 3000-4444', 'log@armazens.pb', 'João Pessoa', 'PB'),
('Indústria Ceará Tec', '55.666.777/0001-88', '(85) 3000-5555', 'contato@cearatec.com', 'Fortaleza', 'CE'),
('Mercadinho São José', '77.888.999/0001-00', '(81) 3000-6666', 'saojose@mercado.com', 'Olinda', 'PE'),
('Agropecuária Sertão', '22.111.000/0001-22', '(87) 3000-7777', 'agro@sertao.com', 'Petrolina', 'PE'),
('Lojas Alagoas Varejo', '44.333.222/0001-33', '(82) 3000-8888', 'varejo@alagoas.com', 'Maceió', 'AL'),
('Bahia Materiais', '66.555.444/0001-55', '(71) 3000-9999', 'vendas@bahiamat.com', 'Salvador', 'BA'),
('Sergipe Bebidas', '88.777.666/0001-77', '(79) 3000-0000', 'logistica@sergipebebidas.com', 'Aracaju', 'SE');

-- MOTORISTAS
INSERT INTO motorista (nome, cpf, numero_cnh, categoria_cnh, validade_cnh, telefone) VALUES
('João Carlos Souza', '123.456.789-09', 'CNH0001234', 'E', '2027-12-31', '(81) 99001-1111'),
('Maria Fernanda Lima', '987.654.321-00', 'CNH0005678', 'D', '2026-06-30', '(81) 99002-2222'),
('Antônio Silva', '111.222.333-44', 'CNH0009012', 'E', '2028-05-15', '(83) 99003-3333'),
('Francisco Oliveira', '555.666.777-88', 'CNH0003456', 'E', '2026-10-20', '(84) 99004-4444'),
('José Santos', '999.888.777-66', 'CNH0007890', 'C', '2027-01-10', '(85) 99005-5555'),
('Paulo Almeida', '444.333.222-11', 'CNH0002468', 'D', '2029-03-25', '(81) 99006-6666'),
('Marcos Rocha', '222.333.444-55', 'CNH0001357', 'E', '2026-08-12', '(82) 99007-7777'),
('Raimundo Nonato', '666.555.444-33', 'CNH0008642', 'E', '2028-11-05', '(71) 99008-8888'),
('Luiz Gonzaga', '777.888.999-00', 'CNH0009753', 'D', '2027-09-18', '(87) 99009-9999'),
('Severino Ramos', '000.111.222-33', 'CNH0005555', 'E', '2026-12-01', '(79) 99010-0000');

-- VEICULOS
INSERT INTO veiculo (placa, modelo, marca, ano, tipo_veiculo, capacidade_kg) VALUES
('ABC-1234', 'Axor 2544', 'Mercedes-Benz', 2020, 'CARRETA', 28000.00),
('XYZ-5678', 'FH 460', 'Volvo', 2021, 'BITRUCK', 18000.00),
('DEF-9012', 'Constellation', 'Volkswagen', 2019, 'TOCO', 6000.00),
('GHI-3456', 'Stralis', 'Iveco', 2022, 'RODOTREM', 50000.00),
('JKL-7890', 'R450', 'Scania', 2023, 'CARRETA', 32000.00),
('MNO-1111', 'Atego 2426', 'Mercedes-Benz', 2018, 'TRUCK', 14000.00),
('PQR-2222', 'VM 270', 'Volvo', 2020, 'TRUCK', 14500.00),
('STU-3333', 'Cargo 2429', 'Ford', 2017, 'TRUCK', 13000.00),
('VWX-4444', 'Meteor', 'Volkswagen', 2022, 'CARRETA', 30000.00),
('YZA-5555', 'S500', 'Scania', 2024, 'RODOTREM', 52000.00);

-- FRETES
INSERT INTO frete (numero_frete, id_cliente, id_motorista, id_veiculo, status, cidade_origem, uf_origem, cidade_destino, uf_destino, data_emissao, peso_kg, valor_frete, aliquota_icms, valor_icms, valor_total) VALUES
('FRT-2026-00001', 1, 1, 1, 'ENTREGUE', 'Recife', 'PE', 'João Pessoa', 'PB', '2026-04-10', 15000.00, 2000.00, 12.00, 240.00, 2240.00),
('FRT-2026-00002', 2, 2, 2, 'EM_TRANSITO', 'Caruaru', 'PE', 'Campina Grande', 'PB', '2026-04-18', 12000.00, 1500.00, 12.00, 180.00, 1680.00),
('FRT-2026-00003', 3, 3, 3, 'PENDENTE', 'Natal', 'RN', 'Fortaleza', 'CE', '2026-04-20', 5000.00, 1000.00, 12.00, 120.00, 1120.00),
('FRT-2026-00004', 4, 4, 4, 'ENTREGUE', 'João Pessoa', 'PB', 'Recife', 'PE', '2026-04-05', 45000.00, 4500.00, 12.00, 540.00, 5040.00),
('FRT-2026-00005', 5, 5, 5, 'CANCELADO', 'Fortaleza', 'CE', 'Mossoró', 'RN', '2026-04-12', 20000.00, 2800.00, 12.00, 336.00, 3136.00),
('FRT-2026-00006', 6, 6, 6, 'EM_TRANSITO', 'Olinda', 'PE', 'Maceió', 'AL', '2026-04-19', 10000.00, 1200.00, 12.00, 144.00, 1344.00),
('FRT-2026-00007', 7, 7, 7, 'PENDENTE', 'Petrolina', 'PE', 'Juazeiro', 'BA', '2026-04-20', 14000.00, 1600.00, 12.00, 192.00, 1792.00),
('FRT-2026-00008', 8, 8, 8, 'ENTREGUE', 'Maceió', 'AL', 'Aracaju', 'SE', '2026-04-15', 11000.00, 1300.00, 12.00, 156.00, 1456.00),
('FRT-2026-00009', 9, 9, 9, 'EM_TRANSITO', 'Salvador', 'BA', 'Feira de Santana', 'BA', '2026-04-19', 25000.00, 2200.00, 18.00, 396.00, 2596.00),
('FRT-2026-00010', 10, 10, 10, 'PENDENTE', 'Aracaju', 'SE', 'Salvador', 'BA', '2026-04-20', 48000.00, 5000.00, 12.00, 600.00, 5600.00);

-- OCORRENCIAS
INSERT INTO ocorrencia (id_frete, tipo, descricao) VALUES
(1, 'AVARIA', 'Carga levemente molhada devido à chuva forte na estrada.'),
(2, 'ATRASO', 'Pneu furado na BR-232, atraso de 3 horas.'),
(3, 'INFORMATIVO', 'Aguardando liberação da nota fiscal na origem.'),
(4, 'ENTREGA', 'Mercadoria descarregada sem avarias no cliente final.'),
(5, 'CANCELAMENTO', 'Cliente cancelou o pedido antes do embarque.'),
(6, 'FISCALIZACAO', 'Parada no posto fiscal de fronteira, aguardando vistoria.'),
(7, 'MANUTENCAO', 'Troca de lâmpada do farol antes de iniciar a viagem.'),
(8, 'ENTREGA', 'Recebedor ausente na primeira tentativa, entregue na segunda.'),
(9, 'CLIMA', 'Pista alagada, velocidade reduzida por segurança.'),
(10, 'INFORMATIVO', 'Veículo carregado e aguardando horário de saída autorizado.');
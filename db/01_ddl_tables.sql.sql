-- ============================================================
-- 01_ddl_tables.sql
-- SISTEMA DE GESTÃO DE FRETES — DDL Tabelas e Sequências

-- ============================================================
-- SEQUENCES
-- ============================================================
CREATE SEQUENCE IF NOT EXISTS seq_usuario       START 1 INCREMENT 1;
CREATE SEQUENCE IF NOT EXISTS seq_cliente       START 1 INCREMENT 1;
CREATE SEQUENCE IF NOT EXISTS seq_motorista     START 1 INCREMENT 1;
CREATE SEQUENCE IF NOT EXISTS seq_veiculo       START 1 INCREMENT 1;
CREATE SEQUENCE IF NOT EXISTS seq_frete         START 1 INCREMENT 1;
CREATE SEQUENCE IF NOT EXISTS seq_numero_frete  START 1 INCREMENT 1; 
CREATE SEQUENCE IF NOT EXISTS seq_ocorrencia    START 1 INCREMENT 1;

-- ============================================================
-- USUARIO
-- ============================================================
CREATE TABLE IF NOT EXISTS usuario (
    idusuario   INTEGER       NOT NULL DEFAULT nextval('seq_usuario'),
    nome        VARCHAR(120)  NOT NULL,
    login       VARCHAR(60)   NOT NULL,
    senha       VARCHAR(200)  NOT NULL,   -- SHA-256 hex: LoginDAO.sha256()
    perfil      VARCHAR(20)   NOT NULL DEFAULT 'OPERADOR',
    is_ativo    BOOLEAN       NOT NULL DEFAULT TRUE,
    created_at  TIMESTAMP     NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMP     NOT NULL DEFAULT NOW(),
    CONSTRAINT pk_usuario        PRIMARY KEY (idusuario),
    CONSTRAINT uq_usuario_login  UNIQUE      (login),
    CONSTRAINT ck_usuario_perfil CHECK (perfil IN ('ADMIN','OPERADOR'))
);

-- ============================================================
-- CLIENTE
-- tipo CHAR(1): r=Remetente | d=Destinatário | a=Ambos
-- ============================================================
CREATE TABLE IF NOT EXISTS cliente (
    idcliente     INTEGER       NOT NULL DEFAULT nextval('seq_cliente'),
    razao_social  VARCHAR(120)  NOT NULL,
    nome_fantasia VARCHAR(100),
    cnpj          VARCHAR(14),  
    inscricao_est VARCHAR(20),
    tipo          CHAR(1)       NOT NULL DEFAULT 'a',
    logradouro    VARCHAR(80),
    numero_end    VARCHAR(10),
    complemento   VARCHAR(120),
    bairro        VARCHAR(60),
    municipio     VARCHAR(80),
    uf            CHAR(2),
    cep           VARCHAR(9), 
    telefone      VARCHAR(20),
    email         VARCHAR(100),
    is_ativo      BOOLEAN       NOT NULL DEFAULT TRUE,
    created_at    TIMESTAMP     NOT NULL DEFAULT NOW(),
    updated_at    TIMESTAMP     NOT NULL DEFAULT NOW(),
    created_by    VARCHAR(60),
    updated_by    VARCHAR(60),
    CONSTRAINT pk_cliente       PRIMARY KEY (idcliente),
    CONSTRAINT uq_cliente_cnpj  UNIQUE      (cnpj),
    CONSTRAINT ck_cliente_tipo  CHECK (tipo IN ('r','d','a'))
);

-- ============================================================
-- MOTORISTA
-- cnh_categoria CHAR(1): A | B | C | D | E   → CategoriaCNH.java
-- tipo_vinculo  CHAR(1): F=Funcionário | G=Agregado | T=Terceiro → TipoVinculo.java
-- status        CHAR(1): A=Ativo | I=Inativo | S=Suspenso       → StatusMotorista.java
-- ============================================================
CREATE TABLE IF NOT EXISTS motorista (
    idmotorista    INTEGER       NOT NULL DEFAULT nextval('seq_motorista'),
    nome           VARCHAR(120)  NOT NULL,
    cpf            VARCHAR(11)   NOT NULL, 
    data_nascimento DATE,
    telefone       VARCHAR(20),
    cnh_numero     VARCHAR(20)   NOT NULL,
    cnh_categoria  CHAR(1)       NOT NULL DEFAULT 'B',
    cnh_validade   DATE          NOT NULL,
    tipo_vinculo   CHAR(1)       NOT NULL DEFAULT 'F',
    status         CHAR(1)       NOT NULL DEFAULT 'A',
    created_at     TIMESTAMP     NOT NULL DEFAULT NOW(),
    updated_at     TIMESTAMP     NOT NULL DEFAULT NOW(),
    created_by     VARCHAR(60),
    updated_by     VARCHAR(60),
    CONSTRAINT pk_motorista       PRIMARY KEY (idmotorista),
    CONSTRAINT uq_motorista_cpf   UNIQUE      (cpf),
    CONSTRAINT uq_motorista_cnh   UNIQUE      (cnh_numero),
    CONSTRAINT ck_motorista_cat   CHECK (cnh_categoria IN ('A','B','C','D','E')),
    CONSTRAINT ck_motorista_vinc  CHECK (tipo_vinculo  IN ('F','G','T')),
    CONSTRAINT ck_motorista_stat  CHECK (status         IN ('A','I','S'))
);

-- ============================================================
-- VEICULO
-- tipo   CHAR(1): K=Truck | C=Carreta | V=Van | U=Utilitário → TipoVeiculo.java
-- status CHAR(1): D=Disponível | V=EmViagem | M=EmManutenção → StatusVeiculo.java
-- ============================================================
CREATE TABLE IF NOT EXISTS veiculo (
    idveiculo      INTEGER       NOT NULL DEFAULT nextval('seq_veiculo'),
    placa          VARCHAR(8)    NOT NULL,   -- Mercosul ABC1D23 ou antigo ABC1234
    rntrc          VARCHAR(15),
    ano_fabricacao SMALLINT,
    tipo           CHAR(1)       NOT NULL DEFAULT 'K',
    tara_kg        NUMERIC(10,2),
    capacidade_kg  NUMERIC(10,2),
    volume_m3      NUMERIC(10,3),
    status         CHAR(1)       NOT NULL DEFAULT 'D',
    created_at     TIMESTAMP     NOT NULL DEFAULT NOW(),
    updated_at     TIMESTAMP     NOT NULL DEFAULT NOW(),
    created_by     VARCHAR(60),
    updated_by     VARCHAR(60),
    CONSTRAINT pk_veiculo       PRIMARY KEY (idveiculo),
    CONSTRAINT uq_veiculo_placa UNIQUE      (placa),
    CONSTRAINT ck_veiculo_tipo  CHECK (tipo   IN ('K','C','V','U')),
    CONSTRAINT ck_veiculo_stat  CHECK (status IN ('D','V','M'))
);

-- ============================================================
-- FRETE
-- status CHAR(1):
--   E=Emitido | S=SaídaConfirmada | T=EmTrânsito
--   R=Entregue | N=NãoEntregue   | C=Cancelado
-- → FreteStatus.java
--
-- numero: gerado pelo GeradorNumeroFrete.gerar(seq_numero_frete)
--   no FreteBO — NUNCA pelo banco nem pelo Controller.
--   Formato: FRT-AAAA-NNNNN  ex: FRT-2026-00001
--
-- id_remetente / id_destinatario: ambos FK para cliente.idcliente
-- ============================================================
CREATE TABLE IF NOT EXISTS frete (
    idfrete           INTEGER        NOT NULL DEFAULT nextval('seq_frete'),
    numero            VARCHAR(15)    NOT NULL, 
    id_remetente      INTEGER        NOT NULL,
    id_destinatario   INTEGER        NOT NULL,
    id_motorista      INTEGER        NOT NULL,
    id_veiculo        INTEGER        NOT NULL,
    municipio_origem  VARCHAR(80)    NOT NULL,
    uf_origem         CHAR(2)        NOT NULL,
    municipio_destino VARCHAR(80)    NOT NULL,
    uf_destino        CHAR(2)        NOT NULL,
    descricao_carga   VARCHAR(200),
    peso_kg           NUMERIC(10,2),
    volumes           INTEGER,
    valor_frete       NUMERIC(12,2)  NOT NULL DEFAULT 0,
    aliquota_icms     NUMERIC(5,2)   NOT NULL DEFAULT 0,
    valor_icms        NUMERIC(12,2)  NOT NULL DEFAULT 0,
    aliquota_ibs      NUMERIC(5,2)   NOT NULL DEFAULT 0,
    valor_ibs         NUMERIC(12,2)  NOT NULL DEFAULT 0,
    aliquota_cbs      NUMERIC(5,2)   NOT NULL DEFAULT 0,
    valor_cbs         NUMERIC(12,2)  NOT NULL DEFAULT 0,
    valor_total       NUMERIC(12,2)  NOT NULL DEFAULT 0,
    status            CHAR(1)        NOT NULL DEFAULT 'E',
    data_emissao      DATE           NOT NULL DEFAULT CURRENT_DATE,
    data_prev_entrega DATE           NOT NULL,
    data_saida        TIMESTAMP,  
    data_entrega      TIMESTAMP,    
    observacao        TEXT,
    created_at        TIMESTAMP      NOT NULL DEFAULT NOW(),
    updated_at        TIMESTAMP      NOT NULL DEFAULT NOW(),
    created_by        VARCHAR(60),
    updated_by        VARCHAR(60),
    CONSTRAINT pk_frete              PRIMARY KEY (idfrete),
    CONSTRAINT uq_frete_numero       UNIQUE      (numero),
    CONSTRAINT fk_frete_remetente    FOREIGN KEY (id_remetente)    REFERENCES cliente(idcliente),
    CONSTRAINT fk_frete_destinatario FOREIGN KEY (id_destinatario) REFERENCES cliente(idcliente),
    CONSTRAINT fk_frete_motorista    FOREIGN KEY (id_motorista)    REFERENCES motorista(idmotorista),
    CONSTRAINT fk_frete_veiculo      FOREIGN KEY (id_veiculo)      REFERENCES veiculo(idveiculo),
    CONSTRAINT ck_frete_status       CHECK (status IN ('E','S','T','R','N','C')),
    CONSTRAINT ck_frete_valor        CHECK (valor_frete >= 0)
);

-- ============================================================
-- OCORRENCIA_FRETE
-- tipo CHAR(1):
--   P=SaídaPátio | R=EmRota    | T=TentativaEntrega
--   E=EntregaRealizada         | A=Avaria
--   X=Extravio  | O=Outros
-- → TipoOcorrencia.java
--
-- nome_recebedor + documento_recebedor: obrigatórios para tipo 'E'
-- descricao: obrigatória para tipos A, X, O
-- ============================================================
CREATE TABLE IF NOT EXISTS ocorrencia_frete (
    idocorrencia         INTEGER       NOT NULL DEFAULT nextval('seq_ocorrencia'),
    id_frete             INTEGER       NOT NULL,
    tipo                 CHAR(1)       NOT NULL,
    data_hora            TIMESTAMP     NOT NULL DEFAULT NOW(),
    municipio            VARCHAR(80),
    uf                   CHAR(2),
    descricao            TEXT,
    nome_recebedor       VARCHAR(100),
    documento_recebedor  VARCHAR(20),
    created_at           TIMESTAMP     NOT NULL DEFAULT NOW(),
    created_by           VARCHAR(60),
    CONSTRAINT pk_ocorrencia       PRIMARY KEY (idocorrencia),
    CONSTRAINT fk_occ_frete        FOREIGN KEY (id_frete) REFERENCES frete(idfrete),
    CONSTRAINT ck_occ_tipo         CHECK (tipo IN ('P','R','T','E','A','X','O'))
);

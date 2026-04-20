-- ============================================================
-- 01_ddl_tables.sql
-- SISTEMA DE GESTÃO DE FRETES — DDL Tabelas e Sequências
-- ============================================================

-- SEQUENCES
CREATE SEQUENCE IF NOT EXISTS seq_cliente    START 1 INCREMENT 1;
CREATE SEQUENCE IF NOT EXISTS seq_motorista  START 1 INCREMENT 1;
CREATE SEQUENCE IF NOT EXISTS seq_veiculo    START 1 INCREMENT 1;
CREATE SEQUENCE IF NOT EXISTS seq_frete      START 1 INCREMENT 1;
CREATE SEQUENCE IF NOT EXISTS seq_ocorrencia START 1 INCREMENT 1;
CREATE SEQUENCE IF NOT EXISTS seq_usuario    START 1 INCREMENT 1;

-- ============================================================
-- CLIENTE
-- ============================================================
CREATE TABLE cliente (
    id_cliente  INTEGER      NOT NULL DEFAULT nextval('seq_cliente'),
    nome        VARCHAR(120) NOT NULL,
    cpf_cnpj    VARCHAR(18)  NOT NULL,
    telefone    VARCHAR(20),
    email       VARCHAR(100),
    endereco    VARCHAR(200),
    cidade      VARCHAR(80),
    uf          CHAR(2),
    is_ativo    BOOLEAN      NOT NULL DEFAULT TRUE,
    created_at  TIMESTAMP    NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMP    NOT NULL DEFAULT NOW(),
    created_by  VARCHAR(60),
    updated_by  VARCHAR(60),
    CONSTRAINT pk_cliente        PRIMARY KEY (id_cliente),
    CONSTRAINT uq_cliente_cpf_cnpj UNIQUE (cpf_cnpj)
);

-- ============================================================
-- MOTORISTA
-- ============================================================
CREATE TABLE motorista (
    id_motorista  INTEGER    NOT NULL DEFAULT nextval('seq_motorista'),
    nome          VARCHAR(120) NOT NULL,
    cpf           VARCHAR(14)  NOT NULL,
    numero_cnh    VARCHAR(20)  NOT NULL,
    categoria_cnh CHAR(3)      NOT NULL,
    validade_cnh  DATE         NOT NULL,
    telefone      VARCHAR(20),
    is_ativo      BOOLEAN      NOT NULL DEFAULT TRUE,
    is_disponivel BOOLEAN      NOT NULL DEFAULT TRUE,
    created_at    TIMESTAMP    NOT NULL DEFAULT NOW(),
    updated_at    TIMESTAMP    NOT NULL DEFAULT NOW(),
    created_by    VARCHAR(60),
    updated_by    VARCHAR(60),
    CONSTRAINT pk_motorista     PRIMARY KEY (id_motorista),
    CONSTRAINT uq_motorista_cpf UNIQUE (cpf),
    CONSTRAINT uq_motorista_cnh UNIQUE (numero_cnh)
);

-- ============================================================
-- VEICULO
-- ============================================================
CREATE TABLE veiculo (
    id_veiculo    INTEGER      NOT NULL DEFAULT nextval('seq_veiculo'),
    placa         VARCHAR(8)   NOT NULL,
    modelo        VARCHAR(80)  NOT NULL,
    marca         VARCHAR(60)  NOT NULL,
    ano           INTEGER      NOT NULL,
    tipo_veiculo  VARCHAR(30)  NOT NULL,
    capacidade_kg NUMERIC(10,2),
    is_ativo      BOOLEAN      NOT NULL DEFAULT TRUE,
    is_disponivel BOOLEAN      NOT NULL DEFAULT TRUE,
    created_at    TIMESTAMP    NOT NULL DEFAULT NOW(),
    updated_at    TIMESTAMP    NOT NULL DEFAULT NOW(),
    created_by    VARCHAR(60),
    updated_by    VARCHAR(60),
    CONSTRAINT pk_veiculo       PRIMARY KEY (id_veiculo),
    CONSTRAINT uq_veiculo_placa UNIQUE (placa)
);

-- ============================================================
-- FRETE 
-- Status: PENDENTE | EM_TRANSITO | ENTREGUE | CANCELADO
-- valor_icms e valor_total calculados no BO [EXTRA!]
-- ============================================================
CREATE TABLE frete (
    id_frete       INTEGER        NOT NULL DEFAULT nextval('seq_frete'),
    numero_frete   VARCHAR(20)    NOT NULL,  -- FRT-AAAA-NNNNN, gerado via GeradorNumeroFrete
    id_cliente     INTEGER        NOT NULL,
    id_motorista   INTEGER        NOT NULL,
    id_veiculo     INTEGER        NOT NULL,
    status         VARCHAR(20)    NOT NULL DEFAULT 'PENDENTE',
    cidade_origem  VARCHAR(80)    NOT NULL,
    uf_origem      CHAR(2)        NOT NULL,
    cidade_destino VARCHAR(80)    NOT NULL,
    uf_destino     CHAR(2)        NOT NULL,
    data_emissao   DATE           NOT NULL DEFAULT CURRENT_DATE,
    data_previsao  DATE,
    data_entrega   DATE,
    peso_kg        NUMERIC(10,2)  NOT NULL DEFAULT 0,
    valor_frete    NUMERIC(15,2)  NOT NULL DEFAULT 0,
    aliquota_icms  NUMERIC(5,2)   NOT NULL DEFAULT 0,
    valor_icms     NUMERIC(15,2)  NOT NULL DEFAULT 0,
    valor_total    NUMERIC(15,2)  NOT NULL DEFAULT 0,
    observacao     TEXT,
    created_at     TIMESTAMP      NOT NULL DEFAULT NOW(),
    updated_at     TIMESTAMP      NOT NULL DEFAULT NOW(),
    created_by     VARCHAR(60),
    updated_by     VARCHAR(60),
    CONSTRAINT pk_frete           PRIMARY KEY (id_frete),
    CONSTRAINT uq_frete_numero    UNIQUE (numero_frete),
    CONSTRAINT fk_frete_cliente   FOREIGN KEY (id_cliente)   REFERENCES cliente(id_cliente),
    CONSTRAINT fk_frete_motorista FOREIGN KEY (id_motorista) REFERENCES motorista(id_motorista),
    CONSTRAINT fk_frete_veiculo   FOREIGN KEY (id_veiculo)   REFERENCES veiculo(id_veiculo),
    CONSTRAINT ck_frete_status    CHECK (status IN ('PENDENTE','EM_TRANSITO','ENTREGUE','CANCELADO')),
    CONSTRAINT ck_frete_valor     CHECK (valor_frete >= 0)
);

-- ============================================================
-- OCORRENCIA
-- ============================================================
CREATE TABLE ocorrencia (
    id_ocorrencia   INTEGER      NOT NULL DEFAULT nextval('seq_ocorrencia'),
    id_frete        INTEGER      NOT NULL,
    tipo            VARCHAR(50)  NOT NULL,
    descricao       TEXT         NOT NULL,
    data_ocorrencia TIMESTAMP    NOT NULL DEFAULT NOW(),
    created_at      TIMESTAMP    NOT NULL DEFAULT NOW(),
    created_by      VARCHAR(60),
    CONSTRAINT pk_ocorrencia       PRIMARY KEY (id_ocorrencia),
    CONSTRAINT fk_ocorrencia_frete FOREIGN KEY (id_frete) REFERENCES frete(id_frete)
);

-- ============================================================
-- USUARIO (login)
-- ============================================================
CREATE TABLE usuario (
    id_usuario  INTEGER      NOT NULL DEFAULT nextval('seq_usuario'),
    login       VARCHAR(60)  NOT NULL,
    senha_hash  VARCHAR(200) NOT NULL,
    nome        VARCHAR(120) NOT NULL,
    perfil      VARCHAR(20)  NOT NULL DEFAULT 'OPERADOR',
    is_ativo    BOOLEAN      NOT NULL DEFAULT TRUE,
    created_at  TIMESTAMP    NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMP    NOT NULL DEFAULT NOW(),
    CONSTRAINT pk_usuario       PRIMARY KEY (id_usuario),
    CONSTRAINT uq_usuario_login UNIQUE (login),
    CONSTRAINT ck_usuario_perfil CHECK (perfil IN ('ADMIN','OPERADOR'))
);

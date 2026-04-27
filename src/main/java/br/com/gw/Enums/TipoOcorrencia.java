package br.com.gw.Enums;

/**
 * Tipos de ocorrência de frete — CHAR(1) mapeado no banco.
 * Validações de obrigatoriedade de campos por tipo estão em OcorrenciaFreteBO.
 */
public enum TipoOcorrencia {

    SAIDA_PATIO       ('P', "Saída do Pátio",        false, false),
    EM_ROTA           ('R', "Em Rota",                false, false),
    TENTATIVA_ENTREGA ('T', "Tentativa de Entrega",   false, false),
    ENTREGA_REALIZADA ('E', "Entrega Realizada",      true,  false),
    AVARIA            ('A', "Avaria na Carga",         false, true),
    EXTRAVIO          ('X', "Extravio",               false, true),
    OUTROS            ('O', "Outros",                 false, true);

    private final char    codigo;
    private final String  descricao;
    /** Exige nome e documento do recebedor */
    private final boolean exigeRecebedor;
    /** Exige campo descrição preenchido */
    private final boolean exigeDescricao;

    TipoOcorrencia(char codigo, String descricao,
                   boolean exigeRecebedor, boolean exigeDescricao) {
        this.codigo         = codigo;
        this.descricao      = descricao;
        this.exigeRecebedor = exigeRecebedor;
        this.exigeDescricao = exigeDescricao;
    }

    public char    getCodigo()        { return codigo; }
    public String  getDescricao()     { return descricao; }
    public boolean isExigeRecebedor() { return exigeRecebedor; }
    public boolean isExigeDescricao() { return exigeDescricao; }

    public static TipoOcorrencia fromCodigo(char codigo) {
        for (TipoOcorrencia t : values()) {
            if (t.codigo == codigo) return t;
        }
        throw new IllegalArgumentException("TipoOcorrencia desconhecido: " + codigo);
    }

    public static TipoOcorrencia fromCodigo(String codigo) {
        if (codigo == null || codigo.isEmpty())
            throw new IllegalArgumentException("Código de TipoOcorrencia nulo/vazio");
        return fromCodigo(codigo.charAt(0));
    }

    @Override
    public String toString() { return descricao; }
}
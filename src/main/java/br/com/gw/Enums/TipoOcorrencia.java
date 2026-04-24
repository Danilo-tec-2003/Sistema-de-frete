package br.com.gw.Enums;

public enum TipoOcorrencia {

    SAIDA_PATIO        ('P', "Saída do Pátio",         false, false),
    EM_ROTA            ('R', "Em Rota",                 false, false),
    TENTATIVA_ENTREGA  ('T', "Tentativa de Entrega",    false, false),
    ENTREGA_REALIZADA  ('E', "Entrega Realizada",       false, true),
    AVARIA             ('A', "Avaria",                  true,  false),
    EXTRAVIO           ('X', "Extravio",                true,  false),
    OUTROS             ('O', "Outros",                  true,  false);

    private final char    codigo;
    private final String  descricao;
    /** Descrição livre obrigatória para este tipo? */
    private final boolean descricaoObrigatoria;
    /** Exige nome/documento do recebedor? */
    private final boolean recebedorObrigatorio;

    TipoOcorrencia(char codigo, String descricao,
                   boolean descricaoObrigatoria, boolean recebedorObrigatorio) {
        this.codigo               = codigo;
        this.descricao            = descricao;
        this.descricaoObrigatoria = descricaoObrigatoria;
        this.recebedorObrigatorio = recebedorObrigatorio;
    }

    public char    getCodigo()               { return codigo; }
    public String  getDescricao()            { return descricao; }
    public boolean isDescricaoObrigatoria()  { return descricaoObrigatoria; }
    public boolean isRecebedorObrigatorio()  { return recebedorObrigatorio; }

    public static TipoOcorrencia fromCodigo(char c) {
        for (TipoOcorrencia t : values()) if (t.codigo == c) return t;
        throw new IllegalArgumentException("TipoOcorrencia desconhecido: " + c);
    }

    public static TipoOcorrencia fromCodigo(String s) {
        if (s == null || s.isEmpty()) throw new IllegalArgumentException("Código nulo/vazio");
        return fromCodigo(s.charAt(0));
    }

    @Override public String toString() { return descricao; }
}
package br.com.gw.Enums;

/**
 * Status do frete — nunca usar String solta em comparações.
 * Mapeados para o CHAR(1) do banco conforme 01_schema.sql.
 */
public enum StatusFrete {

    EMITIDO          ('E', "Emitido"),
    SAIDA_CONFIRMADA ('S', "Saída Confirmada"),
    EM_TRANSITO      ('T', "Em Trânsito"),
    ENTREGUE         ('R', "Entregue"),
    NAO_ENTREGUE     ('N', "Não Entregue"),
    CANCELADO        ('C', "Cancelado");

    private final char   codigo;
    private final String descricao;

    StatusFrete(char codigo, String descricao) {
        this.codigo    = codigo;
        this.descricao = descricao;
    }

    public char   getCodigo()    { return codigo; }
    public String getCodigoString() { return String.valueOf(codigo); }
    public String getDescricao() { return descricao; }

    /** Converte o CHAR(1) vindo do banco para o enum. */
    public static StatusFrete fromCodigo(char codigo) {
        for (StatusFrete s : values()) {
            if (s.codigo == codigo) return s;
        }
        throw new IllegalArgumentException("StatusFrete desconhecido: " + codigo);
    }

    public static StatusFrete fromCodigo(String codigo) {
        if (codigo == null || codigo.isEmpty())
            throw new IllegalArgumentException("Código de StatusFrete nulo/vazio");
        return fromCodigo(codigo.charAt(0));
    }

    @Override
    public String toString() { return descricao; }
}

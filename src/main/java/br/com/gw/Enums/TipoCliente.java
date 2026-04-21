package br.com.gw.Enums;

public enum TipoCliente {
    REMETENTE   ('r', "Remetente"),
    DESTINATARIO('d', "Destinatário"),
    AMBOS       ('a', "Ambos");

    private final char   codigo;
    private final String descricao;

    TipoCliente(char codigo, String descricao) { this.codigo = codigo; this.descricao = descricao; }
    public char   getCodigo()    { return codigo; }
    public String getDescricao() { return descricao; }

    public static TipoCliente fromCodigo(char c) {
        for (TipoCliente t : values()) if (t.codigo == c) return t;
        throw new IllegalArgumentException("TipoCliente desconhecido: " + c);
    }
    public static TipoCliente fromCodigo(String s) {
        if (s == null || s.isEmpty()) throw new IllegalArgumentException("Código nulo/vazio");
        return fromCodigo(s.charAt(0));
    }
    @Override public String toString() { return descricao; }
}
package br.com.gw.Enums;

public enum TipoVinculo {
    FUNCIONARIO ('F', "Funcionário"),
    AGREGADO    ('G', "Agregado"),
    TERCEIRO    ('T', "Terceiro");

    private final char   codigo;
    private final String descricao;

    TipoVinculo(char codigo, String descricao) { this.codigo = codigo; this.descricao = descricao; }
    public char   getCodigo()    { return codigo; }
    public String getDescricao() { return descricao; }

    public static TipoVinculo fromCodigo(char c) {
        for (TipoVinculo t : values()) if (t.codigo == c) return t;
        throw new IllegalArgumentException("TipoVinculo desconhecido: " + c);
    }
    public static TipoVinculo fromCodigo(String s) {
        if (s == null || s.isEmpty()) throw new IllegalArgumentException("Código nulo/vazio");
        return fromCodigo(s.charAt(0));
    }
    @Override public String toString() { return descricao; }
}
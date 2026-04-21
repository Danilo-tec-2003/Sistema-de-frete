package br.com.gw.Enums;

public enum TipoVeiculo {
    TRUCK      ('K', "Truck"),
    CARRETA    ('C', "Carreta"),
    VAN        ('V', "Van"),
    UTILITARIO ('U', "Utilitário");

    private final char   codigo;
    private final String descricao;

    TipoVeiculo(char codigo, String descricao) { this.codigo = codigo; this.descricao = descricao; }

    public char   getCodigo()    { return codigo; }
    public String getDescricao() { return descricao; }

    public static TipoVeiculo fromCodigo(char c) {
        for (TipoVeiculo t : values()) if (t.codigo == c) return t;
        throw new IllegalArgumentException("TipoVeiculo desconhecido: " + c);
    }
    public static TipoVeiculo fromCodigo(String s) {
        if (s == null || s.isEmpty()) throw new IllegalArgumentException("Código nulo/vazio");
        return fromCodigo(s.charAt(0));
    }
    @Override public String toString() { return descricao; }
}
package br.com.gw.Enums;

public enum StatusMotorista {
    ATIVO     ('A', "Ativo"),
    INATIVO   ('I', "Inativo"),
    SUSPENSO  ('S', "Suspenso");

    private final char   codigo;
    private final String descricao;

    StatusMotorista(char codigo, String descricao) { this.codigo = codigo; this.descricao = descricao; }

    public char   getCodigo()    { return codigo; }
    public String getDescricao() { return descricao; }

    public static StatusMotorista fromCodigo(char c) {
        for (StatusMotorista s : values()) if (s.codigo == c) return s;
        throw new IllegalArgumentException("StatusMotorista desconhecido: " + c);
    }
    public static StatusMotorista fromCodigo(String s) {
        if (s == null || s.isEmpty()) throw new IllegalArgumentException("Código nulo/vazio");
        return fromCodigo(s.charAt(0));
    }
    @Override public String toString() { return descricao; }
}
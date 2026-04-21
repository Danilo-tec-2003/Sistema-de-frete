package br.com.gw.Enums;

public enum StatusVeiculo {

    DISPONIVEL    ('D', "Disponível"),
    EM_VIAGEM     ('V', "Em Viagem"),
    EM_MANUTENCAO ('M', "Em Manutenção");

    private final char   codigo;
    private final String descricao;

    StatusVeiculo(char codigo, String descricao) {
        this.codigo    = codigo;
        this.descricao = descricao;
    }

    public char   getCodigo()    { return codigo; }
    public String getDescricao() { return descricao; }

    public static StatusVeiculo fromCodigo(char c) {
        for (StatusVeiculo s : values()) if (s.codigo == c) return s;
        throw new IllegalArgumentException("StatusVeiculo desconhecido: " + c);
    }
    public static StatusVeiculo fromCodigo(String s) {
        if (s == null || s.isEmpty()) throw new IllegalArgumentException("Código nulo/vazio");
        return fromCodigo(s.charAt(0));
    }

    @Override public String toString() { return descricao; }
}
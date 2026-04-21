package br.com.gw.Enums;

public enum CategoriaCNH {
    A('A'), B('B'), C('C'), D('D'), E('E');

    private final char codigo;
    CategoriaCNH(char codigo) { this.codigo = codigo; }
    public char getCodigo() { return codigo; }
    public static CategoriaCNH fromCodigo(char c) {
        for (CategoriaCNH cat : values()) if (cat.codigo == c) return cat;
        throw new IllegalArgumentException("CategoriaCNH desconhecida: " + c);
    }
    public static CategoriaCNH fromCodigo(String s) {
        if (s == null || s.isEmpty()) throw new IllegalArgumentException("Código nulo/vazio");
        return fromCodigo(s.charAt(0));
    }
}
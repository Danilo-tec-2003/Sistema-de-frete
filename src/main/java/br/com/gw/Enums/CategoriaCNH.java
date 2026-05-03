package br.com.gw.Enums;

public enum CategoriaCNH {
    A ("A",  "Categoria A",  true,  0),
    B ("B",  "Categoria B",  false, 1),
    C ("C",  "Categoria C",  false, 2),
    D ("D",  "Categoria D",  false, 3),
    E ("E",  "Categoria E",  false, 4),
    AB("AB", "Categorias A/B", true,  1),
    AC("AC", "Categorias A/C", true,  2),
    AD("AD", "Categorias A/D", true,  3),
    AE("AE", "Categorias A/E", true,  4);

    private final String  codigo;
    private final String  descricao;
    private final boolean possuiA;
    private final int     nivelRodoviario;

    CategoriaCNH(String codigo, String descricao, boolean possuiA, int nivelRodoviario) {
        this.codigo           = codigo;
        this.descricao        = descricao;
        this.possuiA          = possuiA;
        this.nivelRodoviario  = nivelRodoviario;
    }

    public String  getCodigo()           { return codigo; }
    public String  getDescricao()        { return descricao; }
    public boolean isPossuiA()           { return possuiA; }
    public int     getNivelRodoviario()  { return nivelRodoviario; }

    /**
     * Regra operacional do sistema:
     * - A atende apenas veículos que exigem A.
     * - B/C/D/E seguem hierarquia rodoviária crescente.
     * - AB/AC/AD/AE acumulam A com a categoria rodoviária correspondente.
     */
    public boolean atende(CategoriaCNH exigida) {
        if (exigida == null) return false;
        if (exigida == A) return possuiA;
        return nivelRodoviario >= exigida.nivelRodoviario;
    }

    public static CategoriaCNH fromCodigo(char c) {
        return fromCodigo(String.valueOf(c));
    }

    public static CategoriaCNH fromCodigo(String s) {
        if (s == null || s.trim().isEmpty()) {
            throw new IllegalArgumentException("Código nulo/vazio");
        }
        String codigo = s.trim().toUpperCase();
        for (CategoriaCNH cat : values()) {
            if (cat.codigo.equals(codigo) || cat.name().equals(codigo)) return cat;
        }
        throw new IllegalArgumentException("CategoriaCNH desconhecida: " + s);
    }

    @Override public String toString() { return codigo; }
}

package br.com.gw.Enums;

public enum TipoOperacao {
    MUNICIPAL("Municipal"),
    ESTADUAL("Estadual"),
    INTERESTADUAL("Interestadual");

    private final String descricao;

    TipoOperacao(String descricao) {
        this.descricao = descricao;
    }

    public String getDescricao() {
        return descricao;
    }
}

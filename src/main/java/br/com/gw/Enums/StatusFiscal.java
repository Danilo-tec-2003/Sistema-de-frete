package br.com.gw.Enums;

public enum StatusFiscal {
    PENDENTE("Pendente"),
    CALCULADO("Calculado"),
    ERRO("Erro"),
    VALIDADO_CTE("Validado CT-e");

    private final String descricao;

    StatusFiscal(String descricao) {
        this.descricao = descricao;
    }

    public String getDescricao() {
        return descricao;
    }
}

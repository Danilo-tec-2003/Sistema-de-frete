package br.com.gw.Enums;

import java.math.BigDecimal;

public enum TipoVeiculo {
    MOTO            ('M', "Moto",             "1",     "30",    CategoriaCNH.A),
    CARRO_UTILITARIO('U', "Carro Utilitário", "50",    "500",   CategoriaCNH.B),
    VAN             ('V', "Van",              "300",   "1500",  CategoriaCNH.B),
    VUC             ('L', "VUC",              "1000",  "3000",  CategoriaCNH.C),
    CAMINHAO_3_4    ('Q', "Caminhão 3/4",     "1500",  "4000",  CategoriaCNH.C),
    CAMINHAO_TOCO   ('O', "Caminhão Toco",    "3000",  "6000",  CategoriaCNH.C),
    CAMINHAO_TRUCK  ('K', "Caminhão Truck",   "6000",  "14000", CategoriaCNH.C),
    CARRETA         ('C', "Carreta",          "14000", "30000", CategoriaCNH.E),
    BITREM_RODOTREM ('B', "Bitrem/Rodotrem",  "30000", "57000", CategoriaCNH.E);

    private final char         codigo;
    private final String       descricao;
    private final BigDecimal   capacidadeMinimaKg;
    private final BigDecimal   capacidadeMaximaKg;
    private final CategoriaCNH cnhMinima;

    TipoVeiculo(char codigo, String descricao, String capacidadeMinimaKg,
                String capacidadeMaximaKg, CategoriaCNH cnhMinima) {
        this.codigo              = codigo;
        this.descricao           = descricao;
        this.capacidadeMinimaKg  = new BigDecimal(capacidadeMinimaKg);
        this.capacidadeMaximaKg  = new BigDecimal(capacidadeMaximaKg);
        this.cnhMinima           = cnhMinima;
    }

    public char         getCodigo()             { return codigo; }
    public String       getDescricao()          { return descricao; }
    public BigDecimal   getCapacidadeMinimaKg() { return capacidadeMinimaKg; }
    public BigDecimal   getCapacidadeMaximaKg() { return capacidadeMaximaKg; }
    public CategoriaCNH getCnhMinima()          { return cnhMinima; }

    public boolean permiteCapacidade(BigDecimal capacidadeKg) {
        if (capacidadeKg == null) return false;
        return capacidadeKg.compareTo(capacidadeMinimaKg) >= 0
            && capacidadeKg.compareTo(capacidadeMaximaKg) <= 0;
    }

    public String getFaixaCapacidadeDescricao() {
        return capacidadeMinimaKg.toPlainString() + " kg a "
            + capacidadeMaximaKg.toPlainString() + " kg";
    }

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

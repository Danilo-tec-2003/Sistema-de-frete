package br.com.gw.relatorio;

import java.math.BigDecimal;

/**
 * Linha do relatório de desempenho de motoristas.
 */
public class DesempenhoMotoristaRelatorio {

    private String motorista;
    private String cpf;
    private Integer entregas;
    private Integer entregasNoPrazo;
    private Integer entregasAtrasadas;
    private BigDecimal percentualNoPrazo;
    private BigDecimal mediaDiasAtraso;
    private BigDecimal pesoTotalKg;
    private Integer volumesTotal;
    private BigDecimal valorTotal;

    public String getMotorista() { return motorista; }
    public void setMotorista(String motorista) { this.motorista = motorista; }

    public String getCpf() { return cpf; }
    public void setCpf(String cpf) { this.cpf = cpf; }

    public Integer getEntregas() { return entregas; }
    public void setEntregas(Integer entregas) { this.entregas = entregas; }

    public Integer getEntregasNoPrazo() { return entregasNoPrazo; }
    public void setEntregasNoPrazo(Integer entregasNoPrazo) { this.entregasNoPrazo = entregasNoPrazo; }

    public Integer getEntregasAtrasadas() { return entregasAtrasadas; }
    public void setEntregasAtrasadas(Integer entregasAtrasadas) { this.entregasAtrasadas = entregasAtrasadas; }

    public BigDecimal getPercentualNoPrazo() { return percentualNoPrazo; }
    public void setPercentualNoPrazo(BigDecimal percentualNoPrazo) { this.percentualNoPrazo = percentualNoPrazo; }

    public BigDecimal getMediaDiasAtraso() { return mediaDiasAtraso; }
    public void setMediaDiasAtraso(BigDecimal mediaDiasAtraso) { this.mediaDiasAtraso = mediaDiasAtraso; }

    public BigDecimal getPesoTotalKg() { return pesoTotalKg; }
    public void setPesoTotalKg(BigDecimal pesoTotalKg) { this.pesoTotalKg = pesoTotalKg; }

    public Integer getVolumesTotal() { return volumesTotal; }
    public void setVolumesTotal(Integer volumesTotal) { this.volumesTotal = volumesTotal; }

    public BigDecimal getValorTotal() { return valorTotal; }
    public void setValorTotal(BigDecimal valorTotal) { this.valorTotal = valorTotal; }
}

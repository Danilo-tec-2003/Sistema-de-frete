package br.com.gw.relatorio;

import java.math.BigDecimal;

/**
 * Linha impressa no romaneio de carga.
 * Cada registro representa um frete do motorista na data operacional informada.
 */
public class RomaneioCargaRelatorio {

    private String numero;
    private String nomeRemetente;
    private String nomeDestinatario;
    private String destino;
    private BigDecimal pesoKg;
    private Integer volumes;
    private BigDecimal valorTotal;

    public String getNumero() { return numero; }
    public void setNumero(String numero) { this.numero = numero; }

    public String getNomeRemetente() { return nomeRemetente; }
    public void setNomeRemetente(String nomeRemetente) { this.nomeRemetente = nomeRemetente; }

    public String getNomeDestinatario() { return nomeDestinatario; }
    public void setNomeDestinatario(String nomeDestinatario) { this.nomeDestinatario = nomeDestinatario; }

    public String getDestino() { return destino; }
    public void setDestino(String destino) { this.destino = destino; }

    public BigDecimal getPesoKg() { return pesoKg; }
    public void setPesoKg(BigDecimal pesoKg) { this.pesoKg = pesoKg; }

    public Integer getVolumes() { return volumes; }
    public void setVolumes(Integer volumes) { this.volumes = volumes; }

    public BigDecimal getValorTotal() { return valorTotal; }
    public void setValorTotal(BigDecimal valorTotal) { this.valorTotal = valorTotal; }
}

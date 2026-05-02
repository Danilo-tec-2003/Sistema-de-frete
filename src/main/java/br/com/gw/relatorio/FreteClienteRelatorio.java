package br.com.gw.relatorio;

import java.math.BigDecimal;

/**
 * Linha do extrato de fretes por cliente.
 */
public class FreteClienteRelatorio {

    private String numero;
    private String dataEmissao;
    private String papelCliente;
    private String contraparte;
    private String origem;
    private String destino;
    private String motorista;
    private String statusDescricao;
    private BigDecimal valorTotal;

    public String getNumero() { return numero; }
    public void setNumero(String numero) { this.numero = numero; }

    public String getDataEmissao() { return dataEmissao; }
    public void setDataEmissao(String dataEmissao) { this.dataEmissao = dataEmissao; }

    public String getPapelCliente() { return papelCliente; }
    public void setPapelCliente(String papelCliente) { this.papelCliente = papelCliente; }

    public String getContraparte() { return contraparte; }
    public void setContraparte(String contraparte) { this.contraparte = contraparte; }

    public String getOrigem() { return origem; }
    public void setOrigem(String origem) { this.origem = origem; }

    public String getDestino() { return destino; }
    public void setDestino(String destino) { this.destino = destino; }

    public String getMotorista() { return motorista; }
    public void setMotorista(String motorista) { this.motorista = motorista; }

    public String getStatusDescricao() { return statusDescricao; }
    public void setStatusDescricao(String statusDescricao) { this.statusDescricao = statusDescricao; }

    public BigDecimal getValorTotal() { return valorTotal; }
    public void setValorTotal(BigDecimal valorTotal) { this.valorTotal = valorTotal; }
}

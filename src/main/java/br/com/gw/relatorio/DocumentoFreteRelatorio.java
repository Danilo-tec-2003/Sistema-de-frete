package br.com.gw.relatorio;

import java.math.BigDecimal;

/**
 * Dados do documento individual de frete para impressão operacional.
 */
public class DocumentoFreteRelatorio {

    private String numero;
    private String statusDescricao;
    private String dataEmissao;
    private String dataPrevista;
    private String dataSaida;
    private String dataEntrega;

    private String remetenteRazao;
    private String remetenteCnpj;
    private String remetenteEndereco;
    private String destinatarioRazao;
    private String destinatarioCnpj;
    private String destinatarioEndereco;

    private String motoristaNome;
    private String motoristaCpf;
    private String motoristaCnh;
    private String veiculoPlaca;
    private String veiculoTipo;
    private BigDecimal veiculoCapacidadeKg;

    private String origem;
    private String destino;
    private String descricaoCarga;
    private BigDecimal pesoKg;
    private Integer volumes;

    private BigDecimal valorFrete;
    private BigDecimal aliquotaIcms;
    private BigDecimal valorIcms;
    private BigDecimal aliquotaIbs;
    private BigDecimal valorIbs;
    private BigDecimal aliquotaCbs;
    private BigDecimal valorCbs;
    private BigDecimal valorTotal;
    private String observacao;

    public String getNumero() { return numero; }
    public void setNumero(String numero) { this.numero = numero; }

    public String getStatusDescricao() { return statusDescricao; }
    public void setStatusDescricao(String statusDescricao) { this.statusDescricao = statusDescricao; }

    public String getDataEmissao() { return dataEmissao; }
    public void setDataEmissao(String dataEmissao) { this.dataEmissao = dataEmissao; }

    public String getDataPrevista() { return dataPrevista; }
    public void setDataPrevista(String dataPrevista) { this.dataPrevista = dataPrevista; }

    public String getDataSaida() { return dataSaida; }
    public void setDataSaida(String dataSaida) { this.dataSaida = dataSaida; }

    public String getDataEntrega() { return dataEntrega; }
    public void setDataEntrega(String dataEntrega) { this.dataEntrega = dataEntrega; }

    public String getRemetenteRazao() { return remetenteRazao; }
    public void setRemetenteRazao(String remetenteRazao) { this.remetenteRazao = remetenteRazao; }

    public String getRemetenteCnpj() { return remetenteCnpj; }
    public void setRemetenteCnpj(String remetenteCnpj) { this.remetenteCnpj = remetenteCnpj; }

    public String getRemetenteEndereco() { return remetenteEndereco; }
    public void setRemetenteEndereco(String remetenteEndereco) { this.remetenteEndereco = remetenteEndereco; }

    public String getDestinatarioRazao() { return destinatarioRazao; }
    public void setDestinatarioRazao(String destinatarioRazao) { this.destinatarioRazao = destinatarioRazao; }

    public String getDestinatarioCnpj() { return destinatarioCnpj; }
    public void setDestinatarioCnpj(String destinatarioCnpj) { this.destinatarioCnpj = destinatarioCnpj; }

    public String getDestinatarioEndereco() { return destinatarioEndereco; }
    public void setDestinatarioEndereco(String destinatarioEndereco) { this.destinatarioEndereco = destinatarioEndereco; }

    public String getMotoristaNome() { return motoristaNome; }
    public void setMotoristaNome(String motoristaNome) { this.motoristaNome = motoristaNome; }

    public String getMotoristaCpf() { return motoristaCpf; }
    public void setMotoristaCpf(String motoristaCpf) { this.motoristaCpf = motoristaCpf; }

    public String getMotoristaCnh() { return motoristaCnh; }
    public void setMotoristaCnh(String motoristaCnh) { this.motoristaCnh = motoristaCnh; }

    public String getVeiculoPlaca() { return veiculoPlaca; }
    public void setVeiculoPlaca(String veiculoPlaca) { this.veiculoPlaca = veiculoPlaca; }

    public String getVeiculoTipo() { return veiculoTipo; }
    public void setVeiculoTipo(String veiculoTipo) { this.veiculoTipo = veiculoTipo; }

    public BigDecimal getVeiculoCapacidadeKg() { return veiculoCapacidadeKg; }
    public void setVeiculoCapacidadeKg(BigDecimal veiculoCapacidadeKg) { this.veiculoCapacidadeKg = veiculoCapacidadeKg; }

    public String getOrigem() { return origem; }
    public void setOrigem(String origem) { this.origem = origem; }

    public String getDestino() { return destino; }
    public void setDestino(String destino) { this.destino = destino; }

    public String getDescricaoCarga() { return descricaoCarga; }
    public void setDescricaoCarga(String descricaoCarga) { this.descricaoCarga = descricaoCarga; }

    public BigDecimal getPesoKg() { return pesoKg; }
    public void setPesoKg(BigDecimal pesoKg) { this.pesoKg = pesoKg; }

    public Integer getVolumes() { return volumes; }
    public void setVolumes(Integer volumes) { this.volumes = volumes; }

    public BigDecimal getValorFrete() { return valorFrete; }
    public void setValorFrete(BigDecimal valorFrete) { this.valorFrete = valorFrete; }

    public BigDecimal getAliquotaIcms() { return aliquotaIcms; }
    public void setAliquotaIcms(BigDecimal aliquotaIcms) { this.aliquotaIcms = aliquotaIcms; }

    public BigDecimal getValorIcms() { return valorIcms; }
    public void setValorIcms(BigDecimal valorIcms) { this.valorIcms = valorIcms; }

    public BigDecimal getAliquotaIbs() { return aliquotaIbs; }
    public void setAliquotaIbs(BigDecimal aliquotaIbs) { this.aliquotaIbs = aliquotaIbs; }

    public BigDecimal getValorIbs() { return valorIbs; }
    public void setValorIbs(BigDecimal valorIbs) { this.valorIbs = valorIbs; }

    public BigDecimal getAliquotaCbs() { return aliquotaCbs; }
    public void setAliquotaCbs(BigDecimal aliquotaCbs) { this.aliquotaCbs = aliquotaCbs; }

    public BigDecimal getValorCbs() { return valorCbs; }
    public void setValorCbs(BigDecimal valorCbs) { this.valorCbs = valorCbs; }

    public BigDecimal getValorTotal() { return valorTotal; }
    public void setValorTotal(BigDecimal valorTotal) { this.valorTotal = valorTotal; }

    public String getObservacao() { return observacao; }
    public void setObservacao(String observacao) { this.observacao = observacao; }
}

package br.com.gw.relatorio;

/**
 * Linha do relatório de ocorrências por período.
 */
public class OcorrenciaPeriodoRelatorio {

    private String numeroFrete;
    private String dataHora;
    private String tipoDescricao;
    private String localizacao;
    private String descricao;
    private String motorista;
    private String placa;
    private String statusFrete;
    private String recebedor;

    public String getNumeroFrete() { return numeroFrete; }
    public void setNumeroFrete(String numeroFrete) { this.numeroFrete = numeroFrete; }

    public String getDataHora() { return dataHora; }
    public void setDataHora(String dataHora) { this.dataHora = dataHora; }

    public String getTipoDescricao() { return tipoDescricao; }
    public void setTipoDescricao(String tipoDescricao) { this.tipoDescricao = tipoDescricao; }

    public String getLocalizacao() { return localizacao; }
    public void setLocalizacao(String localizacao) { this.localizacao = localizacao; }

    public String getDescricao() { return descricao; }
    public void setDescricao(String descricao) { this.descricao = descricao; }

    public String getMotorista() { return motorista; }
    public void setMotorista(String motorista) { this.motorista = motorista; }

    public String getPlaca() { return placa; }
    public void setPlaca(String placa) { this.placa = placa; }

    public String getStatusFrete() { return statusFrete; }
    public void setStatusFrete(String statusFrete) { this.statusFrete = statusFrete; }

    public String getRecebedor() { return recebedor; }
    public void setRecebedor(String recebedor) { this.recebedor = recebedor; }
}

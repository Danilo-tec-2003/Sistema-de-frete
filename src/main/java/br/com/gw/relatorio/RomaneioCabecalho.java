package br.com.gw.relatorio;

/**
 * Dados de cabeçalho do romaneio.
 * Fica separado das linhas porque o relatório precisa exibir motorista/veículo mesmo sem fretes.
 */
public class RomaneioCabecalho {

    private String motoristaNome;
    private String motoristaCpf;
    private String motoristaCnh;
    private String veiculoPlacas;

    public String getMotoristaNome() { return motoristaNome; }
    public void setMotoristaNome(String motoristaNome) { this.motoristaNome = motoristaNome; }

    public String getMotoristaCpf() { return motoristaCpf; }
    public void setMotoristaCpf(String motoristaCpf) { this.motoristaCpf = motoristaCpf; }

    public String getMotoristaCnh() { return motoristaCnh; }
    public void setMotoristaCnh(String motoristaCnh) { this.motoristaCnh = motoristaCnh; }

    public String getVeiculoPlacas() { return veiculoPlacas; }
    public void setVeiculoPlacas(String veiculoPlacas) { this.veiculoPlacas = veiculoPlacas; }
}

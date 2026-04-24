package br.com.gw.veiculos;

import br.com.gw.Enums.StatusVeiculo;
import br.com.gw.Enums.TipoVeiculo;

import java.math.BigDecimal;

public class Veiculo {

    private int           id;
    private String        placa;
    private String        rntrc;
    private Integer       anoFabricacao;
    private TipoVeiculo   tipo;
    private BigDecimal    taraKg;
    private BigDecimal    capacidadeKg;
    private BigDecimal    volumeM3;
    private StatusVeiculo status;

    public Veiculo() {}

    public int           getId()            { return id; }
    public String        getPlaca()         { return placa; }
    public String        getRntrc()         { return rntrc; }
    public Integer       getAnoFabricacao() { return anoFabricacao; }
    public TipoVeiculo   getTipo()          { return tipo; }
    public BigDecimal    getTaraKg()        { return taraKg; }
    public BigDecimal    getCapacidadeKg()  { return capacidadeKg; }
    public BigDecimal    getVolumeM3()      { return volumeM3; }
    public StatusVeiculo getStatus()        { return status; }

    public void setId(int id)                      { this.id            = id; }
    public void setPlaca(String v)                 { this.placa         = v; }
    public void setRntrc(String v)                 { this.rntrc         = v; }
    public void setAnoFabricacao(Integer v)        { this.anoFabricacao = v; }
    public void setTipo(TipoVeiculo v)             { this.tipo          = v; }
    public void setTaraKg(BigDecimal v)            { this.taraKg        = v; }
    public void setCapacidadeKg(BigDecimal v)      { this.capacidadeKg  = v; }
    public void setVolumeM3(BigDecimal v)          { this.volumeM3      = v; }
    public void setStatus(StatusVeiculo v)         { this.status        = v; }
}
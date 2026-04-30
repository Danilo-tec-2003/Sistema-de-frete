package br.com.gw.frete;

import br.com.gw.Enums.StatusFrete;
import br.com.gw.cliente.Cliente;
import br.com.gw.motorista.Motorista;
import br.com.gw.veiculos.Veiculo;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

/**
 * Entidade principal de frete.
 * Todos os valores monetários são BigDecimal — nunca double/float.
 *
 * Os campos ibs/cbs são do Diferencial B (IBS/CBS da Reforma Tributária)
 * e ficam em zero quando não informados.
 */
public class Frete {

    private static final DateTimeFormatter FMT_DATA =
        DateTimeFormatter.ofPattern("dd/MM/yyyy");
    private static final DateTimeFormatter FMT_DATA_HORA =
        DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");

    /* ---- Identificação ---- */
    private int          id;
    private String       numero;         // FRT-AAAA-NNNNN
    private StatusFrete  status;

    /* ---- Relacionamentos (IDs para persistência) ---- */
    private int          idRemetente;
    private int          idDestinatario;
    private int          idMotorista;
    private int          idVeiculo;

    /* ---- Objetos navegáveis (preenchidos no DAO para exibição) ---- */
    private Cliente      remetente;
    private Cliente      destinatario;
    private Motorista    motorista;
    private Veiculo      veiculo;

    /* ---- Rota ---- */
    private String       municipioOrigem;
    private String       ufOrigem;
    private String       municipioDestino;
    private String       ufDestino;

    /* ---- Carga ---- */
    private String       descricaoCarga;
    private BigDecimal   pesoKg;
    private Integer      volumes;

    /* ---- Valores fiscais ---- */
    private BigDecimal   valorFrete    = BigDecimal.ZERO;
    private BigDecimal   aliquotaIcms  = BigDecimal.ZERO;
    private BigDecimal   valorIcms     = BigDecimal.ZERO;

    /* Diferencial B — IBS/CBS */
    private BigDecimal   aliquotaIbs   = BigDecimal.ZERO;
    private BigDecimal   valorIbs      = BigDecimal.ZERO;
    private BigDecimal   aliquotaCbs   = BigDecimal.ZERO;
    private BigDecimal   valorCbs      = BigDecimal.ZERO;

    private BigDecimal   valorTotal    = BigDecimal.ZERO;

    /* ---- Datas ---- */
    private LocalDate     dataEmissao;
    private LocalDate     dataPrevEntrega;
    private LocalDateTime dataSaida;
    private LocalDateTime dataEntrega;

    /* ---- Texto livre ---- */
    private String       observacao;

    /* ---- Auditoria ---- */
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    private String        createdBy;
    private String        updatedBy;

    /* =========================================================
       Getters e Setters
       ========================================================= */

    public int          getId()              { return id; }
    public void         setId(int id)        { this.id = id; }

    public String       getNumero()          { return numero; }
    public void         setNumero(String n)  { this.numero = n; }

    public StatusFrete  getStatus()              { return status; }
    public void         setStatus(StatusFrete s) { this.status = s; }

    public int   getIdRemetente()                  { return idRemetente; }
    public void  setIdRemetente(int idRemetente)   { this.idRemetente = idRemetente; }

    public int   getIdDestinatario()                       { return idDestinatario; }
    public void  setIdDestinatario(int idDestinatario)     { this.idDestinatario = idDestinatario; }

    public int   getIdMotorista()                   { return idMotorista; }
    public void  setIdMotorista(int idMotorista)    { this.idMotorista = idMotorista; }

    public int   getIdVeiculo()                  { return idVeiculo; }
    public void  setIdVeiculo(int idVeiculo)     { this.idVeiculo = idVeiculo; }

    public Cliente     getRemetente()                      { return remetente; }
    public void        setRemetente(Cliente remetente)     { this.remetente = remetente; }

    public Cliente     getDestinatario()                         { return destinatario; }
    public void        setDestinatario(Cliente destinatario)     { this.destinatario = destinatario; }

    public Motorista   getMotorista()                     { return motorista; }
    public void        setMotorista(Motorista motorista)  { this.motorista = motorista; }

    public Veiculo     getVeiculo()                   { return veiculo; }
    public void        setVeiculo(Veiculo veiculo)    { this.veiculo = veiculo; }

    public String  getMunicipioOrigem()                        { return municipioOrigem; }
    public void    setMunicipioOrigem(String municipioOrigem)  { this.municipioOrigem = municipioOrigem; }

    public String  getUfOrigem()                   { return ufOrigem; }
    public void    setUfOrigem(String ufOrigem)    { this.ufOrigem = ufOrigem; }

    public String  getMunicipioDestino()                         { return municipioDestino; }
    public void    setMunicipioDestino(String municipioDestino)  { this.municipioDestino = municipioDestino; }

    public String  getUfDestino()                    { return ufDestino; }
    public void    setUfDestino(String ufDestino)    { this.ufDestino = ufDestino; }

    public String      getDescricaoCarga()                         { return descricaoCarga; }
    public void        setDescricaoCarga(String descricaoCarga)    { this.descricaoCarga = descricaoCarga; }

    public BigDecimal  getPesoKg()                   { return pesoKg; }
    public void        setPesoKg(BigDecimal pesoKg)  { this.pesoKg = pesoKg; }

    public Integer     getVolumes()                    { return volumes; }
    public void        setVolumes(Integer volumes)     { this.volumes = volumes; }

    public BigDecimal  getValorFrete()                       { return valorFrete; }
    public void        setValorFrete(BigDecimal valorFrete)  { this.valorFrete = valorFrete; }

    public BigDecimal  getAliquotaIcms()                           { return aliquotaIcms; }
    public void        setAliquotaIcms(BigDecimal aliquotaIcms)    { this.aliquotaIcms = aliquotaIcms; }

    public BigDecimal  getValorIcms()                        { return valorIcms; }
    public void        setValorIcms(BigDecimal valorIcms)    { this.valorIcms = valorIcms; }

    public BigDecimal  getAliquotaIbs()                          { return aliquotaIbs; }
    public void        setAliquotaIbs(BigDecimal aliquotaIbs)   { this.aliquotaIbs = aliquotaIbs; }

    public BigDecimal  getValorIbs()                       { return valorIbs; }
    public void        setValorIbs(BigDecimal valorIbs)    { this.valorIbs = valorIbs; }

    public BigDecimal  getAliquotaCbs()                          { return aliquotaCbs; }
    public void        setAliquotaCbs(BigDecimal aliquotaCbs)   { this.aliquotaCbs = aliquotaCbs; }

    public BigDecimal  getValorCbs()                       { return valorCbs; }
    public void        setValorCbs(BigDecimal valorCbs)    { this.valorCbs = valorCbs; }

    public BigDecimal  getValorTotal()                         { return valorTotal; }
    public void        setValorTotal(BigDecimal valorTotal)    { this.valorTotal = valorTotal; }

    public LocalDate      getDataEmissao()                         { return dataEmissao; }
    public void           setDataEmissao(LocalDate dataEmissao)    { this.dataEmissao = dataEmissao; }

    public LocalDate      getDataPrevEntrega()                            { return dataPrevEntrega; }
    public void           setDataPrevEntrega(LocalDate dataPrevEntrega)   { this.dataPrevEntrega = dataPrevEntrega; }

    public LocalDateTime  getDataSaida()                       { return dataSaida; }
    public void           setDataSaida(LocalDateTime dataSaida){ this.dataSaida = dataSaida; }

    public LocalDateTime  getDataEntrega()                         { return dataEntrega; }
    public void           setDataEntrega(LocalDateTime dataEntrega){ this.dataEntrega = dataEntrega; }

    public String         getObservacao()                        { return observacao; }
    public void           setObservacao(String observacao)       { this.observacao = observacao; }

    public LocalDateTime  getCreatedAt()                         { return createdAt; }
    public void           setCreatedAt(LocalDateTime createdAt)  { this.createdAt = createdAt; }

    public LocalDateTime  getUpdatedAt()                         { return updatedAt; }
    public void           setUpdatedAt(LocalDateTime updatedAt)  { this.updatedAt = updatedAt; }

    public String         getCreatedBy()                         { return createdBy; }
    public void           setCreatedBy(String createdBy)         { this.createdBy = createdBy; }

    public String         getUpdatedBy()                         { return updatedBy; }
    public void           setUpdatedBy(String updatedBy)         { this.updatedBy = updatedBy; }

    /* ---- Helpers de exibição ---- */

    /** Rota resumida: Recife/PE → São Paulo/SP */
    public String getRota() {
        return municipioOrigem + "/" + ufOrigem + " → " + municipioDestino + "/" + ufDestino;
    }

    /**
     * Dias em atraso em relação à data prevista de entrega.
     * Retorna 0 se ainda não venceu ou já foi entregue.
     */
    public long getDiasAtraso() {
        if (status == StatusFrete.ENTREGUE || status == StatusFrete.CANCELADO
                || dataPrevEntrega == null) return 0;
        long diff = java.time.temporal.ChronoUnit.DAYS.between(dataPrevEntrega, LocalDate.now());
        return Math.max(0, diff);
    }

    /** True se está em um status que ainda pode ser movimentado. */
    public boolean isAberto() {
        return status == StatusFrete.EMITIDO
            || status == StatusFrete.SAIDA_CONFIRMADA
            || status == StatusFrete.EM_TRANSITO;
    }

    public boolean isStatusEmitido() {
        return status == StatusFrete.EMITIDO;
    }

    public boolean isStatusSaidaConfirmada() {
        return status == StatusFrete.SAIDA_CONFIRMADA;
    }

    public boolean isStatusEmTransito() {
        return status == StatusFrete.EM_TRANSITO;
    }

    public boolean isStatusEntregue() {
        return status == StatusFrete.ENTREGUE;
    }

    public boolean isStatusNaoEntregue() {
        return status == StatusFrete.NAO_ENTREGUE;
    }

    public boolean isStatusCancelado() {
        return status == StatusFrete.CANCELADO;
    }

    public boolean isTimelineEmitidoDone() {
        return status != null;
    }

    public boolean isTimelineSaidaDone() {
        return status == StatusFrete.SAIDA_CONFIRMADA
            || status == StatusFrete.EM_TRANSITO
            || status == StatusFrete.ENTREGUE
            || status == StatusFrete.NAO_ENTREGUE;
    }

    public boolean isTimelineTransitoDone() {
        return status == StatusFrete.EM_TRANSITO
            || status == StatusFrete.ENTREGUE
            || status == StatusFrete.NAO_ENTREGUE;
    }

    public boolean isTimelineFinalDone() {
        return status == StatusFrete.ENTREGUE
            || status == StatusFrete.NAO_ENTREGUE
            || status == StatusFrete.CANCELADO;
    }

    public String getStatusFinalLabel() {
        if (status == StatusFrete.NAO_ENTREGUE) return "Não Entregue";
        if (status == StatusFrete.CANCELADO) return "Cancelado";
        return "Entregue";
    }

    public String getDataEmissaoFormatada() {
        return dataEmissao != null ? dataEmissao.format(FMT_DATA) : "";
    }

    public String getDataPrevEntregaFormatada() {
        return dataPrevEntrega != null ? dataPrevEntrega.format(FMT_DATA) : "";
    }

    public String getDataPrevEntregaIso() {
        return dataPrevEntrega != null ? dataPrevEntrega.toString() : "";
    }

    public String getDataSaidaFormatada() {
        return dataSaida != null ? dataSaida.format(FMT_DATA_HORA) : "";
    }

    public String getDataEntregaFormatada() {
        return dataEntrega != null ? dataEntrega.format(FMT_DATA_HORA) : "";
    }
}

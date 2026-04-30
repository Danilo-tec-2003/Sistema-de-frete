package br.com.gw.frete;

import br.com.gw.Enums.TipoOcorrencia;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

/**
 * Registro de ocorrência vinculado a um frete.
 * Cada movimentação de status gera ao menos uma ocorrência.
 */
public class OcorrenciaFrete {

    private static final DateTimeFormatter FMT_DATA_HORA =
        DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");

    private int             id;
    private int             idFrete;
    private TipoOcorrencia  tipo;
    private LocalDateTime   dataHora;
    private String          municipio;
    private String          uf;
    private String          descricao;
    private String          nomeRecebedor;
    private String          documentoRecebedor;
    private LocalDateTime   createdAt;
    private String          createdBy;

    /* =========================================================
       Getters e Setters
       ========================================================= */

    public int            getId()                      { return id; }
    public void           setId(int id)                { this.id = id; }

    public int            getIdFrete()                        { return idFrete; }
    public void           setIdFrete(int idFrete)             { this.idFrete = idFrete; }

    public TipoOcorrencia getTipo()                           { return tipo; }
    public void           setTipo(TipoOcorrencia tipo)        { this.tipo = tipo; }

    public LocalDateTime  getDataHora()                       { return dataHora; }
    public void           setDataHora(LocalDateTime dataHora) { this.dataHora = dataHora; }

    public String         getMunicipio()                       { return municipio; }
    public void           setMunicipio(String municipio)       { this.municipio = municipio; }

    public String         getUf()                    { return uf; }
    public void           setUf(String uf)           { this.uf = uf; }

    public String         getDescricao()                       { return descricao; }
    public void           setDescricao(String descricao)       { this.descricao = descricao; }

    public String         getNomeRecebedor()                           { return nomeRecebedor; }
    public void           setNomeRecebedor(String nomeRecebedor)       { this.nomeRecebedor = nomeRecebedor; }

    public String         getDocumentoRecebedor()                              { return documentoRecebedor; }
    public void           setDocumentoRecebedor(String documentoRecebedor)     { this.documentoRecebedor = documentoRecebedor; }

    public LocalDateTime  getCreatedAt()                         { return createdAt; }
    public void           setCreatedAt(LocalDateTime createdAt)  { this.createdAt = createdAt; }

    public String         getCreatedBy()                         { return createdBy; }
    public void           setCreatedBy(String createdBy)         { this.createdBy = createdBy; }

    /** Localização formatada para exibição: Recife/PE */
    public String getLocalizacao() {
        if (municipio == null || municipio.isEmpty()) return "—";
        if (uf == null || uf.isEmpty()) return municipio;
        return municipio + "/" + uf;
    }

    public String getDataHoraFormatada() {
        return dataHora != null ? dataHora.format(FMT_DATA_HORA) : "";
    }

    public String getIcone() {
        if (tipo == null) return "📝";
        switch (tipo) {
            case SAIDA_PATIO:       return "🚦";
            case EM_ROTA:           return "🚛";
            case TENTATIVA_ENTREGA: return "📦";
            case ENTREGA_REALIZADA: return "✅";
            case AVARIA:            return "⚠️";
            case EXTRAVIO:          return "❌";
            default:                return "📝";
        }
    }
}

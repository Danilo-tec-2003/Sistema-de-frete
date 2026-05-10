package br.com.gw.motorfiscal;

import br.com.gw.Enums.TipoDestinatario;
import br.com.gw.Enums.TipoOperacao;
import br.com.gw.frete.Frete;
import com.google.gson.annotations.SerializedName;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDate;

public class TaxSimulationRequest {

    @SerializedName("freight_id")
    private long freightId;

    @SerializedName("operation_date")
    private String operationDate;

    @SerializedName("origin_uf")
    private String originUf;

    @SerializedName("destination_uf")
    private String destinationUf;

    @SerializedName("freight_value")
    private String freightValue;

    @SerializedName("customer_type")
    private String customerType;

    @SerializedName("operation_type")
    private String operationType;

    public static TaxSimulationRequest fromFrete(Frete frete) {
        TaxSimulationRequest request = new TaxSimulationRequest();
        request.setFreightId(frete.getId());
        request.setOperationDate(operationDate(frete));
        request.setOriginUf(frete.getUfOrigem());
        request.setDestinationUf(frete.getUfDestino());
        request.setFreightValue(money(frete.getValorFrete()));
        request.setCustomerType(customerType(frete));
        request.setOperationType(operationType(frete));
        return request;
    }

    private static String operationDate(Frete frete) {
        LocalDate data = frete.getDataEmissao() != null ? frete.getDataEmissao() : LocalDate.now();
        return data.toString();
    }

    private static String money(BigDecimal value) {
        BigDecimal safeValue = value != null ? value : BigDecimal.ZERO;
        return safeValue.setScale(2, RoundingMode.HALF_UP).toPlainString();
    }

    private static String customerType(Frete frete) {
        if (frete.getTipoDestinatario() == TipoDestinatario.PESSOA_FISICA) {
            return "PF";
        }

        String documento = frete.getDestinatario() != null
            ? frete.getDestinatario().getDocumentoFiscal()
            : null;
        String digits = documento == null ? "" : documento.replaceAll("[^0-9]", "");
        if (digits.length() == 11) {
            return "PF";
        }

        return "PJ";
    }

    private static String operationType(Frete frete) {
        if (frete.getTipoOperacao() == TipoOperacao.INTERESTADUAL) {
            return "INTERESTADUAL";
        }

        String origem = frete.getUfOrigem() == null ? "" : frete.getUfOrigem().trim();
        String destino = frete.getUfDestino() == null ? "" : frete.getUfDestino().trim();
        if (!origem.isEmpty() && !destino.isEmpty() && !origem.equalsIgnoreCase(destino)) {
            return "INTERESTADUAL";
        }

        return "INTERNA";
    }

    public long getFreightId() {
        return freightId;
    }

    public void setFreightId(long freightId) {
        this.freightId = freightId;
    }

    public String getOperationDate() {
        return operationDate;
    }

    public void setOperationDate(String operationDate) {
        this.operationDate = operationDate;
    }

    public String getOriginUf() {
        return originUf;
    }

    public void setOriginUf(String originUf) {
        this.originUf = originUf;
    }

    public String getDestinationUf() {
        return destinationUf;
    }

    public void setDestinationUf(String destinationUf) {
        this.destinationUf = destinationUf;
    }

    public String getFreightValue() {
        return freightValue;
    }

    public void setFreightValue(String freightValue) {
        this.freightValue = freightValue;
    }

    public String getCustomerType() {
        return customerType;
    }

    public void setCustomerType(String customerType) {
        this.customerType = customerType;
    }

    public String getOperationType() {
        return operationType;
    }

    public void setOperationType(String operationType) {
        this.operationType = operationType;
    }
}

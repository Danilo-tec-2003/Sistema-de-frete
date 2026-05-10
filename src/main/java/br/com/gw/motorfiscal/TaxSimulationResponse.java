package br.com.gw.motorfiscal;

import com.google.gson.annotations.SerializedName;

public class TaxSimulationResponse {

    @SerializedName("freight_id")
    private long freightId;

    @SerializedName("base_value")
    private String baseValue;

    @SerializedName("icms")
    private TaxAmount icms;

    @SerializedName("ibs")
    private TaxAmount ibs;

    @SerializedName("cbs")
    private TaxAmount cbs;

    @SerializedName("total_tax")
    private String totalTax;

    @SerializedName("total_with_tax")
    private String totalWithTax;

    @SerializedName("cfop")
    private String cfop;

    @SerializedName("rule_id")
    private Long ruleId;

    @SerializedName("rule_code")
    private String ruleCode;

    @SerializedName("rule_version")
    private String ruleVersion;

    @SerializedName("rule_status")
    private String ruleStatus;

    @SerializedName("calculation_basis")
    private String calculationBasis;

    @SerializedName("from_cache")
    private boolean fromCache;

    public long getFreightId() {
        return freightId;
    }

    public void setFreightId(long freightId) {
        this.freightId = freightId;
    }

    public String getBaseValue() {
        return baseValue;
    }

    public void setBaseValue(String baseValue) {
        this.baseValue = baseValue;
    }

    public TaxAmount getIcms() {
        return icms;
    }

    public void setIcms(TaxAmount icms) {
        this.icms = icms;
    }

    public TaxAmount getIbs() {
        return ibs;
    }

    public void setIbs(TaxAmount ibs) {
        this.ibs = ibs;
    }

    public TaxAmount getCbs() {
        return cbs;
    }

    public void setCbs(TaxAmount cbs) {
        this.cbs = cbs;
    }

    public String getTotalTax() {
        return totalTax;
    }

    public void setTotalTax(String totalTax) {
        this.totalTax = totalTax;
    }

    public String getTotalWithTax() {
        return totalWithTax;
    }

    public void setTotalWithTax(String totalWithTax) {
        this.totalWithTax = totalWithTax;
    }

    public String getCfop() {
        return cfop;
    }

    public void setCfop(String cfop) {
        this.cfop = cfop;
    }

    public Long getRuleId() {
        return ruleId;
    }

    public void setRuleId(Long ruleId) {
        this.ruleId = ruleId;
    }

    public String getRuleCode() {
        return ruleCode;
    }

    public void setRuleCode(String ruleCode) {
        this.ruleCode = ruleCode;
    }

    public String getRuleVersion() {
        return ruleVersion;
    }

    public void setRuleVersion(String ruleVersion) {
        this.ruleVersion = ruleVersion;
    }

    public String getRuleStatus() {
        return ruleStatus;
    }

    public void setRuleStatus(String ruleStatus) {
        this.ruleStatus = ruleStatus;
    }

    public String getCalculationBasis() {
        return calculationBasis;
    }

    public void setCalculationBasis(String calculationBasis) {
        this.calculationBasis = calculationBasis;
    }

    public boolean isFromCache() {
        return fromCache;
    }

    public void setFromCache(boolean fromCache) {
        this.fromCache = fromCache;
    }
}

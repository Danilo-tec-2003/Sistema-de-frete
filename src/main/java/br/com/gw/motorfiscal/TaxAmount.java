package br.com.gw.motorfiscal;

import com.google.gson.annotations.SerializedName;

public class TaxAmount {

    @SerializedName("rate")
    private String rate;

    @SerializedName("amount")
    private String amount;

    public String getRate() {
        return rate;
    }

    public void setRate(String rate) {
        this.rate = rate;
    }

    public String getAmount() {
        return amount;
    }

    public void setAmount(String amount) {
        this.amount = amount;
    }
}

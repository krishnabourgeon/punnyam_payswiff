package com.punnyam.staff.print;

import java.io.Serializable;

public class TaxModel implements Serializable {
    public String taxType;
    public double taxVal;
    public double taxableAmount;

    public String getTaxType() {
        return taxType;
    }

    public void setTaxType(String taxType) {
        this.taxType = taxType;
    }

    public double getTaxVal() {
        return taxVal;
    }

    public void setTaxVal(double taxVal) {
        this.taxVal = taxVal;
    }

    public double getTaxableAmount() {
        return taxableAmount;
    }

    public void setTaxableAmount(double taxableAmount) {
        this.taxableAmount = taxableAmount;
    }
}

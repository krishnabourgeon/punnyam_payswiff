package com.punnyam.staff.print;

import java.io.Serializable;

public class ItemModel implements Serializable {
    public int qty;
    public double amount;
    public String itemName;
    public double itemTotal;

    public int getQty() {
        return qty;
    }

    public void setQty(int qty) {
        this.qty = qty;
    }

    public double getAmount() {
        return amount;
    }

    public void setAmount(double amount) {
        this.amount = amount;
    }

    public String getItemName() {
        return itemName;
    }

    public void setItemName(String itemName) {
        this.itemName = itemName;
    }

    public double getItemTotal() {
        return itemTotal;
    }

    public void setItemTotal(double itemTotal) {
        this.itemTotal = itemTotal;
    }

    public double getItemTax() {
        return itemTax;
    }

    public void setItemTax(double itemTax) {
        this.itemTax = itemTax;
    }

    public String getBarcodeType() {
        return barcodeType;
    }

    public void setBarcodeType(String barcodeType) {
        this.barcodeType = barcodeType;
    }

    public String getBarcodeValue() {
        return barcodeValue;
    }

    public void setBarcodeValue(String barcodeValue) {
        this.barcodeValue = barcodeValue;
    }

    public double itemTax;
    public double itemTaxPercent;

    public double getItemTaxPercent() {
        return itemTaxPercent;
    }

    public void setItemTaxPercent(double itemTaxPercent) {
        this.itemTaxPercent = itemTaxPercent;
    }

    public String barcodeType;
    public String barcodeValue;
}
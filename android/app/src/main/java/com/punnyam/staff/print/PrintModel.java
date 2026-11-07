package com.punnyam.staff.print;

import java.io.Serializable;
import java.util.ArrayList;

public class PrintModel implements Serializable {
    public String header;
    public String footer;
    public String barcodeValue;
    public String qrcodeValue;
    public String barcodeBottomValue;
    public String fillingType;
    public String businessName;
    public String shopCode;
    public String shopCodeNo;
    public String sector;
    public String city;
    public String state;
    public String pinCode;
    public String contactNo;
    public String email;
    public String gstn;
    public String invoiceNo;
    public String billNo;
    public String address;

    public String billTime;
    public String printTime;
    public String userId;
    public ArrayList<ItemModel> itemModelList;
    public ArrayList<TaxModel> taxList;
    public double totalAmount;
    public double itemsAmount;

    public String getAddress() {
        return address;
    }

    public void setAddress(String address) {
        this.address = address;
    }

    public String getHeader() {
        return header;
    }

    public void setHeader(String header) {
        this.header = header;
    }

    public String getFooter() {
        return footer;
    }

    public void setFooter(String footer) {
        this.footer = footer;
    }

    public String getBarcodeValue() {
        return barcodeValue;
    }

    public void setBarcodeValue(String barcodeValue) {
        this.barcodeValue = barcodeValue;
    }

    public String getQrcodeValue() {
        return qrcodeValue;
    }

    public void setQrcodeValue(String qrcodeValue) {
        this.qrcodeValue = qrcodeValue;
    }

    public String getBarcodeBottomValue() {
        return barcodeBottomValue;
    }

    public void setBarcodeBottomValue(String barcodeBottomValue) {
        this.barcodeBottomValue = barcodeBottomValue;
    }

    public String getFillingType() {
        return fillingType;
    }

    public void setFillingType(String fillingType) {
        this.fillingType = fillingType;
    }

    public String getBusinessName() {
        return businessName;
    }

    public void setBusinessName(String businessName) {
        this.businessName = businessName;
    }

    public String getShopCode() {
        return shopCode;
    }

    public void setShopCode(String shopCode) {
        this.shopCode = shopCode;
    }

    public String getShopCodeNo() {
        return shopCodeNo;
    }

    public void setShopCodeNo(String shopCodeNo) {
        this.shopCodeNo = shopCodeNo;
    }

    public String getSector() {
        return sector;
    }

    public void setSector(String sector) {
        this.sector = sector;
    }

    public String getCity() {
        return city;
    }

    public void setCity(String city) {
        this.city = city;
    }

    public String getState() {
        return state;
    }

    public void setState(String state) {
        this.state = state;
    }

    public String getPinCode() {
        return pinCode;
    }

    public void setPinCode(String pinCode) {
        this.pinCode = pinCode;
    }

    public String getContactNo() {
        return contactNo;
    }

    public void setContactNo(String contactNo) {
        this.contactNo = contactNo;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getGstn() {
        return gstn;
    }

    public void setGstn(String gstn) {
        this.gstn = gstn;
    }

    public String getInvoiceNo() {
        return invoiceNo;
    }

    public void setInvoiceNo(String invoiceNo) {
        this.invoiceNo = invoiceNo;
    }

    public String getBillNo() {
        return billNo;
    }

    public void setBillNo(String billNo) {
        this.billNo = billNo;
    }

    public String getBillTime() {
        return billTime;
    }

    public void setBillTime(String billTime) {
        this.billTime = billTime;
    }

    public String getPrintTime() {
        return printTime;
    }

    public void setPrintTime(String printTime) {
        this.printTime = printTime;
    }

    public String getUserId() {
        return userId;
    }

    public void setUserId(String userId) {
        this.userId = userId;
    }

    public ArrayList<ItemModel> getItemModelList() {
        return itemModelList;
    }

    public void setItemModelList(ArrayList<ItemModel> itemModelList) {
        this.itemModelList = itemModelList;
    }

    public double getTotalAmount() {
        return totalAmount;
    }

    public void setTotalAmount(double totalAmount) {
        this.totalAmount = totalAmount;
    }

    public int getTotalItems() {
        return totalItems;
    }

    public void setTotalItems(int totalItems) {
        this.totalItems = totalItems;
    }

    public double getRoundingAmount() {
        return roundingAmount;
    }

    public void setRoundingAmount(double roundingAmount) {
        this.roundingAmount = roundingAmount;
    }


    public double getCashReceived() {
        return cashReceived;
    }

    public void setCashReceived(double cashReceived) {
        this.cashReceived = cashReceived;
    }

    public String getAppVersion() {
        return appVersion;
    }

    public void setAppVersion(String appVersion) {
        this.appVersion = appVersion;
    }


    public double getItemsAmount() {
        return itemsAmount;
    }

    public void setItemsAmount(double itemsAmount) {
        this.itemsAmount = itemsAmount;
    }

    public ArrayList<TaxModel> getTaxList() {
        return taxList;
    }

    public void setTaxList(ArrayList<TaxModel> taxList) {
        this.taxList = taxList;
    }

    public int totalItems;
    public double roundingAmount;

    public double cashReceived;
    public String appVersion;
}

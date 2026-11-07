class BillDetailsResponseModel {
  bool? status;
  Temple? temple;
  BillSummary? billSummary;
  List<BillDetails>? billDetails;
  BillDetailsResponseModel(
      {this.status, this.temple, this.billSummary, this.billDetails});
  BillDetailsResponseModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    temple = json['temple'] != null ? Temple.fromJson(json['temple']) : null;
    billSummary = json['bill_summary'] != null
        ? BillSummary.fromJson(json['bill_summary'])
        : null;
    if (json['bill_details'] != null) {
      billDetails = <BillDetails>[];
      json['bill_details'].forEach((v) {
        billDetails!.add(BillDetails.fromJson(v));
      });
    }
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    if (temple != null) {
      data['temple'] = temple!.toJson();
    }
    if (billSummary != null) {
      data['bill_summary'] = billSummary!.toJson();
    }
    if (billDetails != null) {
      data['bill_details'] = billDetails!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Temple {
  String? name;
  String? nameMal;
  String? addressLine1;
  String? addressLine2;
  String? phone;
  String? email;
  String? website;
  Temple(
      {this.name,
      this.nameMal,
      this.addressLine1,
      this.addressLine2,
      this.phone,
      this.email,
      this.website});
  Temple.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    nameMal = json['name_mal'];
    addressLine1 = json['address_line_1'];
    addressLine2 = json['address_line_2'];
    phone = json['phone'];
    email = json['email'];
    website = json['website'];
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['name_mal'] = nameMal;
    data['address_line_1'] = addressLine1;
    data['address_line_2'] = addressLine2;
    data['phone'] = phone;
    data['email'] = email;
    data['website'] = website;
    return data;
  }
}

class BillSummary {
  int? billId;
  String? billDate;
  String? counter;
  String? devotee;
  String? paymentMode;
  var total;
  BillSummary(
      {this.billId,
      this.billDate,
      this.counter,
      this.devotee,
      this.paymentMode,
      this.total});
  BillSummary.fromJson(Map<String, dynamic> json) {
    billId = json['bill_id'];
    billDate = json['bill_date'];
    counter = json['counter'];
    devotee = json['devotee'];
    paymentMode = json['payment_mode'];
    total = json['total'];
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['bill_id'] = billId;
    data['bill_date'] = billDate;
    data['counter'] = counter;
    data['devotee'] = devotee;
    data['payment_mode'] = paymentMode;
    data['total'] = total;
    return data;
  }
}

class BillDetails {
  String? dietyname;
  String? dietynameMal;
  String? poojaname;
  String? poojanameMal;
  String? name;
  String? starname;
  String? starnameMal;
  int? quantity;
  int? rate;
  int? total;
  String? time;
  String? poojaDate;
  BillDetails(
      {this.dietyname,
      this.dietynameMal,
      this.poojaname,
      this.poojanameMal,
      this.name,
      this.starname,
      this.starnameMal,
      this.quantity,
      this.rate,
      this.total,
      this.time,
      this.poojaDate});
  BillDetails.fromJson(Map<String, dynamic> json) {
    dietyname = json['dietyname'];
    dietynameMal = json['dietyname_mal'];
    poojaname = json['poojaname'];
    poojanameMal = json['poojaname_mal'];
    name = json['name'];
    starname = json['starname'];
    starnameMal = json['starname_mal'];
    quantity = json['quantity'];
    rate = json['rate'];
    total = json['total'];
    time = json['time'];
    poojaDate = json['pooja_date'];
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['dietyname'] = dietyname;
    data['dietyname_mal'] = dietynameMal;
    data['poojaname'] = poojaname;
    data['poojaname_mal'] = poojanameMal;
    data['name'] = name;
    data['starname'] = starname;
    data['starname_mal'] = starnameMal;
    data['quantity'] = quantity;
    data['rate'] = rate;
    data['total'] = total;
    data['time'] = time;
    data['pooja_date'] = poojaDate;
    return data;
  }
}

class SavequickbillDatamodel {
  bool? status;
  Temples? temple;
  String? billImage;
  Summarys? summary;
  List<Detailss>? details;
  String? message;

  SavequickbillDatamodel(
      {this.status,
      this.temple,
      this.billImage,
      this.summary,
      this.details,
      this.message});

  SavequickbillDatamodel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    temple = json['temple'] != null ? Temples.fromJson(json['temple']) : null;
    billImage = json['bill_image'];
    summary =
        json['summary'] != null ? Summarys.fromJson(json['summary']) : null;
    if (json['details'] != null) {
      details = <Detailss>[];
      json['details'].forEach((v) {
        details!.add(Detailss.fromJson(v));
      });
    }
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    if (temple != null) {
      data['temple'] = temple!.toJson();
    }
    data['bill_image'] = billImage;
    if (summary != null) {
      data['summary'] = summary!.toJson();
    }
    if (details != null) {
      data['details'] = details!.map((v) => v.toJson()).toList();
    }
    data['message'] = message;
    return data;
  }
}

class Temples {
  String? name;
  String? nameMal;
  String? addressLine1;
  String? addressLine2;
  String? phone;
  String? email;
  String? website;

  Temples(
      {this.name,
      this.nameMal,
      this.addressLine1,
      this.addressLine2,
      this.phone,
      this.email,
      this.website});

  Temples.fromJson(Map<String, dynamic> json) {
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

class Summarys {
  int? id;
  String? name;
  String? billDate;
  String? mode;
  String? total;
  String? recvAmt;

  Summarys(
      {this.id, this.name, this.billDate, this.mode, this.total, this.recvAmt});

  Summarys.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    billDate = json['bill_date'];
    mode = json['mode'];
    total = json['total'];
    recvAmt = json['recv_amt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['bill_date'] = billDate;
    data['mode'] = mode;
    data['total'] = total;
    data['recv_amt'] = recvAmt;
    return data;
  }
}

class Detailss {
  String? pooja;
  String? qty;
  String? rate;
  String? amount;

  Detailss({this.pooja, this.qty, this.rate, this.amount});

  Detailss.fromJson(Map<String, dynamic> json) {
    pooja = json['pooja'];
    qty = json['qty'];
    rate = json['rate'];
    amount = json['amount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['pooja'] = pooja;
    data['qty'] = qty;
    data['rate'] = rate;
    data['amount'] = amount;
    return data;
  }
}

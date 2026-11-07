class QuickbillDatamodel {
  bool? status;
  List<Data>? data;

  QuickbillDatamodel({this.status, this.data});

  QuickbillDatamodel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  int? id;
  String? name;
  String? rate;

  Data({this.id, this.name, this.rate});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    rate = json['rate'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['rate'] = rate;
    return data;
  }
}

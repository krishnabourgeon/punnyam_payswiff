class QuickbillDatamodel {
  bool? status;
  List<Data>? data;

  QuickbillDatamodel({this.status, this.data});

  QuickbillDatamodel.fromJson(Map<String, dynamic> json) {
    status = json['status'] == true ||
        json['status'] == 1 ||
        json['status'] == 'true';
    if (json['data'] is List) {
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
    // API / SQLite may send numbers or strings - accept both
    id = json['id'] is int ? json['id'] : int.tryParse('${json['id']}');
    name = json['name']?.toString();
    rate = json['rate']?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['rate'] = rate;
    return data;
  }
}

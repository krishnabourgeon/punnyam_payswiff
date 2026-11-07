class RashiDatamodel {
  bool? status;
  List<Data>? data;

  RashiDatamodel({this.status, this.data});

  RashiDatamodel.fromJson(Map<String, dynamic> json) {
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
  String? nameEng;
  String? nameLocale;
  int? status;
  int? deleted;

  Data({this.id, this.nameEng, this.nameLocale, this.status, this.deleted});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    nameEng = json['name_eng'];
    nameLocale = json['name_locale'];
    status = json['status'];
    deleted = json['deleted'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name_eng'] = nameEng;
    data['name_locale'] = nameLocale;
    data['status'] = status;
    data['deleted'] = deleted;
    return data;
  }
}

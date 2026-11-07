class VersionDatamodel {
  bool? success;
  List<Data>? data;

  VersionDatamodel({this.success, this.data});

  VersionDatamodel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  String? name;
  int? iosVersion;
  int? androidVersion;
  String? description;

  Data({this.name, this.iosVersion, this.androidVersion, this.description});

  Data.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    iosVersion = json['ios_version'];
    androidVersion = json['android_version'];
    description = json['description'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['ios_version'] = iosVersion;
    data['android_version'] = androidVersion;
    data['description'] = description;
    return data;
  }
}

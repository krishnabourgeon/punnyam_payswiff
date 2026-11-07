class SpecialStarResponse {
  bool? status;
  List<SpecialStar>? data;
  SpecialStarResponse({this.status, this.data});
  SpecialStarResponse.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    if (json['data'] != null) {
      data = <SpecialStar>[];
      json['data'].forEach((v) {
        data!.add(SpecialStar.fromJson(v));
      });
    }
  }
}

class SpecialStar {
  String? otherCode;
  String? otherDetail;
  SpecialStar({this.otherCode, this.otherDetail});
  SpecialStar.fromJson(Map<String, dynamic> json) {
    otherCode = json['other_code'];
    otherDetail = json['other_detail'];
  }
}

class CreateCustomer {
  String? name;
  String? mobileNumber;
  String? email;
  String? houseName;
  String? street;
  String? post;
  String? district;
  String? state;
  String? pinCode;
  CreateCustomer(
      {this.name,
      this.mobileNumber,
      this.email,
      this.houseName,
      this.street,
      this.post,
      this.district,
      this.state,
      this.pinCode});
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['mobile'] = mobileNumber;
    data['email'] = email;
    data['house'] = houseName;
    data['street'] = street;
    data['post'] = post;
    data['district'] = district;
    data['state'] = state;
    data['pincode'] = pinCode;
    return data;
  }
}

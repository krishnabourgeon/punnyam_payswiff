class CounterWiseSummaryResponse {
  bool? status;
  String? selectedDate;
  String? counter;
  List<CounterWiseData>? data;
  double? grossTotal;
  var totalCollection;
  int? slNo;
  CounterWiseSummaryResponse(
      {this.status,
      this.selectedDate,
      this.counter,
      this.data,
      this.totalCollection,
      this.slNo,
      this.grossTotal});
  CounterWiseSummaryResponse.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    selectedDate = json['selected_date'];
    counter = json['counter'];
    totalCollection = json['total_collection'];
    grossTotal = json['gross_total'];
    if (json['data'] != null) {
      data = <CounterWiseData>[];
      json['data'].forEach((v) {
        data!.add(CounterWiseData.fromJson(v));
        slNo = (slNo ?? 0) + 1;
      });
    }
  }
}

class CounterWiseData {
  String? paymentMode;
  var totalAmount;
  CounterWiseData({this.paymentMode, this.totalAmount});
  CounterWiseData.fromJson(Map<String, dynamic> json) {
    paymentMode = json['payment_mode'];
    totalAmount = json['total_amount'];
  }
}

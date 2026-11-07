import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:punnyam/models/bill_details_response_model.dart';
import 'package:punnyam/services/base_client.dart';

class BillDetailprovider with ChangeNotifier {
  static int? id;
  BillDetailsResponseModel? poojaResponse;
  BillDetailsResponseModel? post;
  bool load = false;
  bool get circular => load;
  getbill() async {
    load = true;
    post = await getbilldetails();
    load = false;
    notifyListeners();
  }

  Future<BillDetailsResponseModel?> getbilldetails() async {
    try {
      var res = await BaseClient.get('reports/bill-details?id=$id');
      var response = res.asValue!.value;
      poojaResponse = BillDetailsResponseModel.fromJson(response);
      if (kDebugMode) {
        print("..bill-details......$poojaResponse");
      }
    } catch (e) {
      log(e.toString());
    }
    return poojaResponse;
  }
}

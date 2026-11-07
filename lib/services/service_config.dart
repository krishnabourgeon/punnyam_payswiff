import 'package:flutter/foundation.dart';
import 'package:punnyam/models/bill_list_response_model.dart';
import 'package:punnyam/models/counter_wise_summary_response.dart';
import 'package:punnyam/models/counters_model.dart';
import 'package:punnyam/models/create_customer_body.dart';
import 'package:punnyam/models/dieties_response_model.dart';
import 'package:punnyam/models/error_response_model.dart';
import 'package:punnyam/models/gothra_response.dart';
import 'package:punnyam/models/login_response_model.dart';
import 'package:punnyam/models/payment_mode_response.dart';
import 'package:punnyam/models/pooja_response_model.dart';
import 'package:punnyam/models/pooja_summary_response.dart';
import 'package:punnyam/models/preview_bill_response.dart';
import 'package:punnyam/models/quickbill_datamodel.dart';
import 'package:punnyam/models/rashi_datamodel.dart';
import 'package:punnyam/models/register_body.dart';
import 'package:punnyam/models/save_bill_body.dart';
import 'package:punnyam/models/save_bill_response.dart';
import 'package:punnyam/models/savequickbillresponse_datamodel.dart';
import 'package:punnyam/models/search_response_model.dart';
import 'package:punnyam/models/special_star_response.dart';
import 'package:punnyam/models/starts_response_model.dart';
import 'package:punnyam/models/version_datamodel.dart';
import 'package:punnyam/services/app_config.dart';
import 'package:punnyam/services/base_client.dart';
import 'package:async/async.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:punnyam/services/app_exceptions.dart';
import 'package:punnyam/services/database_helper.dart';

class ServiceConfig {
  /// Endpoint used to upload bills that were saved offline. The payload is the
  /// same JSON body as `save-bill`. Change this (and [syncOfflineBill]) once
  /// the dedicated sync API is available.
  static const String offlineBillSyncEndpoint = 'save-bill';

  /// Uploads one bill that was queued while offline. Throws on network errors.
  Future<Result> syncOfflineBill(Map<String, dynamic> payload) async {
    final res = await BaseClient.post(offlineBillSyncEndpoint, body: payload);
    if (res.isError) return Result.error('Sync failed');
    final response = res.asValue!.value;
    return (response is Map && response['status'] == true)
        ? Result.value(response)
        : Result.error(
            response is Map ? (response['message'] ?? 'Rejected') : 'Rejected');
  }

  Future<Result> login({String? email, String? password}) async {
    Map<String, dynamic> body = {
      'email': email ?? '',
      'password': password ?? ''
    };

    Result res;
    try {
      res = await BaseClient.post('auth/login', body: body);
    } on NoInternetException {
      return Result.error(ErrorResponseModel(
          errorMessage: 'No internet. Login needs a connection.'));
    }
    if (res.isError) {
      ErrorResponseModel errorResponseModel =
          ErrorResponseModel(errorMessage: 'OOps...!, login failed');
      return Result.error(errorResponseModel);
    } else {
      var response = res.asValue!.value;
      debugPrint('login response $response');
      LoginResponseModel loginResponseModel =
          LoginResponseModel.fromJson(response);
      return (loginResponseModel.status ?? false)
          ? Result.value(loginResponseModel)
          : Result.error(loginResponseModel);
    }
  }

  Future<Result> register(RegisterBody registerBody) async {
    Result res;
    try {
      res = await BaseClient.post('auth/register', body: registerBody.toJson());
    } on NoInternetException {
      return Result.error(ErrorResponseModel(
          errorMessage: 'No internet. Registration needs a connection.'));
    }
    if (res.isError) {
      ErrorResponseModel errorResponseModel =
          ErrorResponseModel(errorMessage: 'OOps...!, Registration failed');
      return Result.error(errorResponseModel);
    } else {
      var response = res.asValue!.value;
      debugPrint('login response $response');
      LoginResponseModel loginResponseModel =
          LoginResponseModel.fromJson(response);
      return (loginResponseModel.status ?? false)
          ? Result.value(loginResponseModel)
          : Result.error(loginResponseModel);
    }
  }

  Future<Result> getDeities() async {
    Result res = await BaseClient.get('deities');
    if (res.isError) {
      ErrorResponseModel errorResponseModel =
          ErrorResponseModel(errorMessage: 'OOps...!, Something went wrong');
      return Result.error(errorResponseModel);
    } else {
      var response = res.asValue!.value;
      debugPrint('deities response $response');
      DeitiesResponse deitiesResponse = DeitiesResponse.fromJson(response);
      return (deitiesResponse.status ?? false)
          ? Result.value(deitiesResponse)
          : Result.error(deitiesResponse);
    }
  }

  Future<Result> getStarts() async {
    Result res = await BaseClient.get('stars');
    if (res.isError) {
      ErrorResponseModel errorResponseModel =
          ErrorResponseModel(errorMessage: 'OOps...!, Something went wrong');
      return Result.error(errorResponseModel);
    } else {
      var response = res.asValue!.value;
      debugPrint('stars response $response');
      StarsResponse starsResponse = StarsResponse.fromJson(response);
      return (starsResponse.status ?? false)
          ? Result.value(starsResponse)
          : Result.error(starsResponse);
    }
  }

  Future<Result> getgothra() async {
    Result res = await BaseClient.post('gothra');
    if (res.isError) {
      ErrorResponseModel errorResponseModel =
          ErrorResponseModel(errorMessage: 'OOps...!, Something went wrong');
      return Result.error(errorResponseModel);
    } else {
      var response = res.asValue!.value;
      debugPrint('gothra response $response');
      GothraDatamodel gothraResponse = GothraDatamodel.fromJson(response);
      return (gothraResponse.status ?? false)
          ? Result.value(gothraResponse)
          : Result.error(gothraResponse);
    }
  }

  Future<Result> getrashi() async {
    Result res = await BaseClient.post('rashi');
    if (res.isError) {
      ErrorResponseModel errorResponseModel =
          ErrorResponseModel(errorMessage: 'OOps...!, Something went wrong');
      return Result.error(errorResponseModel);
    } else {
      var response = res.asValue!.value;
      debugPrint('gothra response $response');
      RashiDatamodel rashiResponse = RashiDatamodel.fromJson(response);
      return (rashiResponse.status ?? false)
          ? Result.value(rashiResponse)
          : Result.error(rashiResponse);
    }
  }

  Future<Result> getSpecialStars() async {
    Result res = await BaseClient.get('special-stars');
    if (res.isError) {
      ErrorResponseModel errorResponseModel =
          ErrorResponseModel(errorMessage: 'OOps...!, Something went wrong');
      return Result.error(errorResponseModel);
    } else {
      var response = res.asValue!.value;
      debugPrint('special star response $response');
      SpecialStarResponse specialStarResponse =
          SpecialStarResponse.fromJson(response);
      return (specialStarResponse.status ?? false)
          ? Result.value(specialStarResponse)
          : Result.error(specialStarResponse);
    }
  }

  Future<Result> getPoojas(String deityId) async {
    Result res =
        await BaseClient.post('deity/poojas', body: {'deity': deityId});
    if (res.isError) {
      ErrorResponseModel errorResponseModel =
          ErrorResponseModel(errorMessage: 'OOps...!, Something went wrong');
      return Result.error(errorResponseModel);
    } else {
      var response = res.asValue!.value;
      debugPrint('pooja response $response');
      PoojaResponse poojaResponse = PoojaResponse.fromJson(response);

      return (poojaResponse.status ?? false)
          ? Result.value(poojaResponse)
          : Result.error(poojaResponse);
    }
  }

  Future<Result> getCounters() async {
    Result res = await BaseClient.post('counters');
    if (res.isError) {
      ErrorResponseModel errorResponseModel =
          ErrorResponseModel(errorMessage: 'OOps...!, Something went wrong');
      return Result.error(errorResponseModel);
    } else {
      var response = res.asValue!.value;
      debugPrint('counters response $response');
      CounterModel counterResponse = CounterModel.fromJson(response);
      return (counterResponse.status ?? false)
          ? Result.value(counterResponse)
          : Result.error(counterResponse);
    }
  }

  Future<Result> searchCustomer(String mobileNumber) async {
    Result res =
        await BaseClient.post('devotees', body: {'mobile': mobileNumber});
    if (res.isError) {
      ErrorResponseModel errorResponseModel =
          ErrorResponseModel(errorMessage: 'OOps...!, Something went wrong');
      return Result.error(errorResponseModel);
    } else {
      var response = res.asValue!.value;
      debugPrint('search response $response');
      SearchResponse searchResponse = SearchResponse.fromJson(response);
      return (searchResponse.status ?? false)
          ? Result.value(searchResponse)
          : Result.error(searchResponse);
    }
  }

  Future<Result> createCustomer(CreateCustomer createCustomer) async {
    Result res =
        await BaseClient.post('create-devotee', body: createCustomer.toJson());
    if (res.isError) {
      ErrorResponseModel errorResponseModel = ErrorResponseModel(
          errorMessage:
              'Mobile number already exists. Please try another one.');
      return Result.error(errorResponseModel);
    } else {
      var response = res.asValue!.value;
      debugPrint('create customer response $response');
      return response['status'] == true
          ? Result.value('Customer created successfully')
          : Result.error(
              'Mobile number already exists. Please try another one.');
    }
  }

  Future<Result> getPreviewBill(SaveBillBody previewBillBody) async {
    Result res =
        await BaseClient.post('preview-bill', body: previewBillBody.toJson());
    if (res.isError) {
      ErrorResponseModel errorResponseModel =
          ErrorResponseModel(errorMessage: 'OOps...!, Something went wrong');

      return Result.error(errorResponseModel);
    } else {
      var response = res.asValue!.value;
      PreviewBillResponse previewBillResponse =
          PreviewBillResponse.fromJson(response);
      return (previewBillResponse.status ?? false)
          ? Result.value(previewBillResponse)
          : Result.error(previewBillResponse);
    }
  }

  Future<Result> getversion() async {
    Result res = await BaseClient.get(
      'app-versions',
    );
    if (res.isError) {
      ErrorResponseModel errorResponseModel =
          ErrorResponseModel(errorMessage: 'OOps...!, Something went wrong');

      return Result.error(errorResponseModel);
    } else {
      var response = res.asValue!.value;
      VersionDatamodel versionResponse = VersionDatamodel.fromJson(response);
      return (versionResponse.success ?? false)
          ? Result.value(versionResponse)
          : Result.error(versionResponse);
    }
  }

  Future<Result> saveBill(SaveBillBody saveBillBody) async {
    if (kDebugMode) {
      print("savebill..............${saveBillBody.toJson()}");
    }
    Result res =
        await BaseClient.post('save-bill', body: saveBillBody.toJson());
    if (res.isError) {
      ErrorResponseModel errorResponseModel =
          ErrorResponseModel(errorMessage: 'OOps...!, Something went wrong');
      return Result.error(errorResponseModel);
    } else {
      var response = res.asValue!.value;
      if (response is Map && response['temple'] != null) {
        // Remembered so a receipt can still be printed while offline.
        DatabaseHelper.instance
            .saveTemple(Map<String, dynamic>.from(response['temple']))
            .catchError((_) {});
      }

      SaveBillResponse saveBillResponse = SaveBillResponse.fromJson(response);
      return (saveBillResponse.status ?? false)
          ? Result.value(saveBillResponse)
          : Result.error(saveBillResponse);
    }
  }

  Future<Result> getquickbill() async {
    Result res = await BaseClient.get('quick-bill-pooja');
    if (res.isError) {
      ErrorResponseModel errorResponseModel =
          ErrorResponseModel(errorMessage: 'OOps...!, Something went wrong');

      return Result.error(errorResponseModel);
    } else {
      var response = res.asValue!.value;
      QuickbillDatamodel quickbillResponse =
          QuickbillDatamodel.fromJson(response);

      return (quickbillResponse.status ?? false)
          ? Result.value(quickbillResponse)
          : Result.error(quickbillResponse);
    }
  }

  Future<Result> savequickbill(
      {int? modeid, String? amt, List? poojalist}) async {
    final body = {
      "counter_id": AppConfig.counterID,
      "payment_mode": modeid,
      "bill_amount": amt,
      "paid_amount": amt,
      "pooja_details": poojalist
    };

    Result res = await BaseClient.post('quick-bill', body: body);
    if (res.isError) {
      ErrorResponseModel errorResponseModel =
          ErrorResponseModel(errorMessage: 'OOps...!, Something went wrong');
      return Result.error(errorResponseModel);
    } else {
      var response = res.asValue!.value;
      SavequickbillDatamodel quickbillResponse =
          SavequickbillDatamodel.fromJson(response);
      return (quickbillResponse.status ?? false)
          ? Result.value(quickbillResponse)
          : Result.error(quickbillResponse);
    }
  }

  Future<Result> getPaymentModes() async {
    Result res = await BaseClient.get('payment-modes');
    if (res.isError) {
      ErrorResponseModel errorResponseModel =
          ErrorResponseModel(errorMessage: 'OOps...!, Something went wrong');
      return Result.error(errorResponseModel);
    } else {
      var response = res.asValue!.value;
      PaymentModeResponse paymentModeResponse =
          PaymentModeResponse.fromJson(response);
      return (paymentModeResponse.status ?? false)
          ? Result.value(paymentModeResponse)
          : Result.error(paymentModeResponse);
    }
  }

  Future<Result> getBillList(String date) async {
    Result res = await BaseClient.get(
      'bill-list?date=${date.toString()}',
    );
    if (res.isError) {
      ErrorResponseModel errorResponseModel =
          ErrorResponseModel(errorMessage: 'OOps...!, Something went wrong');
      return Result.error(errorResponseModel);
    } else {
      var response = res.asValue!.value;
      if (kDebugMode) {
        print(response);
      }
      BillListResponseModel billListResponseModel =
          BillListResponseModel.fromJson(response);
      return (billListResponseModel.status ?? false)
          ? Result.value(billListResponseModel)
          : Result.error(billListResponseModel);
    }
  }

  Future<Result> getPoojaSummary(String fromDate, String toDate) async {
    // print("pagein api....${page}");
    Result res = await BaseClient.get(
      'reports/pooja-summary?from_date=${fromDate.toString()}&to_date=${toDate.toString()}',
    );
    if (res.isError) {
      ErrorResponseModel errorResponseModel =
          ErrorResponseModel(errorMessage: 'OOps...!, Something went wrong');
      return Result.error(errorResponseModel);
    } else {
      var response = res.asValue!.value;
      PoojaSummaryResponse poojaSummaryResponse =
          PoojaSummaryResponse.fromJson(response);
      // print("....responsepoojasummary...${response}");n
      return (poojaSummaryResponse.status ?? false)
          ? Result.value(poojaSummaryResponse)
          : Result.error(poojaSummaryResponse);
    }
  }

  CounterWiseSummaryResponse? counterWiseSummaryResponse;
  Future<Result> getCounterWiseSummary(String? fromDate) async {
    counterWiseSummaryResponse = null;
    final prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString("counterid");
    if (kDebugMode) {
      print("...id...$id...$fromDate");
    }
    Result res = await BaseClient.get('reports/counter-wise',
        map: {'from_date': fromDate ?? '', 'counter_id': id ?? '0'});
    if (res.isError) {
      ErrorResponseModel errorResponseModel =
          ErrorResponseModel(errorMessage: 'OOps...!, Something went wrong');
      return Result.error(errorResponseModel);
    } else {
      var response = res.asValue!.value;
      counterWiseSummaryResponse =
          CounterWiseSummaryResponse.fromJson(response);
      if (kDebugMode) {
        print(
            "${counterWiseSummaryResponse?.status}..${counterWiseSummaryResponse?.counter}");
      }
      if (kDebugMode) {
        print(counterWiseSummaryResponse?.selectedDate);
      }
      return (counterWiseSummaryResponse?.status ?? false)
          ? Result.value(counterWiseSummaryResponse)
          : Result.error(counterWiseSummaryResponse!);
    }
  }
}

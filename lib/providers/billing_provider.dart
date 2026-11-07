import 'dart:typed_data';
import 'package:async/async.dart';
import 'package:punnyam/services/app_exceptions.dart';
import 'package:punnyam/services/offline_sync_service.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_sunmi_printer_plus/flutter_sunmi_printer_plus.dart';
import 'package:intl/intl.dart';
import 'package:punnyam/common/common_functions.dart';
import 'package:punnyam/models/card_payment_result.dart';
import 'package:punnyam/models/dieties_response_model.dart';
import 'package:punnyam/models/gothra_response.dart';
import 'package:punnyam/models/payment_mode_response.dart';
import 'package:punnyam/models/pooja_response_model.dart';
import 'package:punnyam/models/quickbill_datamodel.dart';
import 'package:punnyam/models/rashi_datamodel.dart';
import 'package:punnyam/models/save_bill_body.dart';
import 'package:punnyam/models/save_bill_response.dart';
import 'package:punnyam/models/savequickbillresponse_datamodel.dart';
import 'package:punnyam/models/special_star_response.dart';
import 'package:punnyam/models/starts_response_model.dart';
import 'package:punnyam/models/version_datamodel.dart';
import 'package:punnyam/screens/billing/preview_bill.dart';
import 'package:punnyam/services/apos_payment.dart';
import 'package:punnyam/services/apos_printer.dart';
import 'package:punnyam/services/app_config.dart';
import 'package:punnyam/services/database_helper.dart';
import 'package:punnyam/services/helpers.dart';
import 'package:punnyam/services/provider_helper_class.dart';
import 'package:punnyam/services/validation_helper.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:whatsapp_unilink/whatsapp_unilink.dart';

import '../models/preview_bill_response.dart';
import '../screens/billing/widgets/preview_bill_btn.dart';

class BillingProvider extends ChangeNotifier with ProviderHelperClass {
  final DatabaseHelper databaseHelper = DatabaseHelper.instance;

// printer
  String printerErrorMessage = '';
  int? sunmiPrinter;
  bool isConnected = false;
  static bool ratefield = false;
// print close

  checkPrinter() async {
    try {
      isConnected = await SunmiPrinter.initPrinter() ?? false;

      notifyListeners();
    } catch (err) {
      printerErrorMessage = err.toString();
      notifyListeners();
    }
  }

  DeitiesResponse? deitiesResponse;
  SavequickbillDatamodel? savequickbills;

  List<DeitiesData> deitiesList = [];
  List<DeitiesData> allDeitiesList = [];
  StarsResponse? starsResponse;
  GothraDatamodel? gothraResponse;
  RashiDatamodel? rashiResponse;
  List<StartsData> starsList = [];
  List<StartsData> allStarsList = [];
  PoojaResponse? poojaResponse;
  List<PoojaDetails> poojaDetailsList = [];
  List<PoojaData> poojaDataList = [];
  List<PoojaData> allPoojaDataList = [];
  SaveBillResponse? saveBillResponse;
  SpecialStarResponse? specialStarResponse;
  List<SpecialStar> specialStarList = [];
  List<SpecialStar> allSpecialStarList = [];
  PaymentModeResponse? paymentModeResponse;

  List<PaymentModeDataList> paymentModeDataList = [];
  List<String> scheduleTypesList = const [
    "Daily",
    "Weekly",
    "Monthly",
    "Other"
  ];

  List<String> prasadamList = const [
    "Yes",
    "No",
  ];

  List<String> weekDayList = const [
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
    "Saturday",
    "Sunday"
  ];

  List<PoojaPersons> person = [];
  Temple? temple;
  Summary? summary;
  Uint8List? imageData;
  String deityId = '1';
  String poojaId = '';
  String? scheduleTypes;
  String? starId = '';
  String? gothraId = '';
  String? rashiId = '';
  String? starId1 = '';
  int? specialStarId;
  String? fromDate;
  String? date;
  String? scheduledType;
  String? weekDays;
  String? poojaName;
  String? deityname;
  String? starName = '';
  String? starName1 = '';
  String? specialStarName;
  String? nameErrorMessage;
  String? qtyErrorMessage;
  String? rateErrorMessage;
  String? paidAmountErrorMessage;
  String? totalRateErrorMessage;
  String? mobileErrorMessage;
  String? errorMessage;
  String? paymentMode = 'COD';
  String? gothraName = '';
  String? rashiName = '';
  int? numberOfDays;
  int? numberOfMonths;
  int? numberOfWeeks;
  int? paymentModeId;
  int currentDropDownIndex = -1;
  double? poojaRate;
  double paidAmount = 0;
  double billAmount = 0;
  String? transid;

  // ---- Payswiff card payment ----
  CardPaymentResult? lastCardPayment; // printed on the receipt
  bool _savingBill = false; // stops a double tap = double charge

  bool isBillingFormValidated = false;
  bool isPreviewBillingFormValidated = false;
  bool? isPrasadhamIncluded;
  bool isDeityUpdated = false;
  bool isScheduled = false;
  bool isSearching = false;
  static bool address = false;

  TextEditingController mobileNumberController = TextEditingController();
  TextEditingController noOfMonthsController = TextEditingController();
  TextEditingController paidAmountController = TextEditingController();
  TextEditingController noOfWeeksController = TextEditingController();
  TextEditingController totalRateController = TextEditingController();
  TextEditingController noOfDaysController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController nameController2 = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController rateController = TextEditingController();
  TextEditingController qtyController = TextEditingController();
  int? poojacountrow;
  List<PoojaDetails> previewDetailsList = [];
  PreviewBillResponse? previewBillResponse;
  double totalAmount = 0;
  getInitialDataList() async {
    await clearValues();
    await getDeities();
    await getStars();
    await getStarIdFromName("Nodata");
    getSpecialStars();
    await getPoojas();
    updateFromDate(DateFormat('y-MM-dd').format(DateTime.now()));
    mobileNumberController.text = AppConfig.customerNumber ?? '';
    nameController.text = AppConfig.customerName ?? '';
    await updateBillingFormState();
  }

  /// Works offline: falls back to the last SQLite copy when the API call
  /// fails or throws (no network).
  Future<void> getPaymentModes(BuildContext context,
      {Function? onFailure}) async {
    updateLoadState(LoaderState.loading);

    try {
      var res = await serviceConfig.getPaymentModes();
      if (res.isValue) {
        paymentModeResponse = res.asValue!.value;
        final apiModes = paymentModeResponse?.data ?? [];
        if (apiModes.isNotEmpty) {
          final modeMaps = apiModes.map((mode) {
            return {'id': mode.id, 'name': mode.name};
          }).toList();
          await databaseHelper.clearPaymentModes();
          await databaseHelper.insertPaymentModes(modeMaps);
          debugPrint('Payment modes saved to SQLite');
        }
        updatePaymentModeList(paymentModeResponse);
        updateLoadState(LoaderState.loaded);
      } else {
        debugPrint('Payment modes API failed. Loading from SQLite...');
        await loadPaymentModesFromDatabase();
        updateLoadState(LoaderState.loaded);
        if (onFailure != null) onFailure();
      }
    } catch (e) {
      debugPrint('exception in payment modes: $e');
      await loadPaymentModesFromDatabase();
      updateLoadState(LoaderState.loaded);
    }
    notifyListeners();
  }

  Future<void> loadPaymentModesFromDatabase() async {
    try {
      final localData = await databaseHelper.getPaymentModes();
      if (localData.isEmpty) {
        debugPrint('No payment modes in database');
        return;
      }
      paymentModeResponse =
          PaymentModeResponse.fromJson({'status': true, 'data': localData});
      updatePaymentModeList(paymentModeResponse);
    } catch (e) {
      debugPrint('Error loading payment modes from SQLite: $e');
    }
  }

  VersionDatamodel? version;
  Future<void> getversion(BuildContext context, {Function? onFailure}) async {
    final network = await CommonFunctions.checkInternetConnection(enableToast: false);
    if (network) {
      updateLoadState(LoaderState.loading);
      try {
        var res = await serviceConfig.getversion();
        if (res.isValue) {
          version = res.asValue!.value;
        } else {
          updateLoadState(LoaderState.loaded);
          if (onFailure != null) onFailure();
        }
      } catch (e) {
        debugPrint('exception in deities: $e');
        updateLoadState(LoaderState.loaded);
      }
      notifyListeners();
    }
  }

  Future<void> getPreviewBill(BuildContext context,
      {Function? onSuccess, Function? onFailure}) async {
    updateLoadState(LoaderState.loading);
    SaveBillBody previewBillBody = SaveBillBody(
      counterId: int.parse(AppConfig.counterID ?? '0'),
      customerId: AppConfig.customerId ?? 0,
      poojaDetails: poojaDetailsList,
    );
    try {
      Result? res;
      final network =
          await CommonFunctions.checkInternetConnection(enableToast: false);
      if (network) {
        try {
          res = await serviceConfig.getPreviewBill(previewBillBody);
        } on NoInternetException {
          res = null; // connection dropped – fall back to local preview
        }
      }

      if (res == null) {
        // Offline: the server cannot expand/price the poojas, so preview the
        // entries exactly as they were entered.
        previewBillResponse = null;
        imageData = null;
        previewDetailsList = [...poojaDetailsList];
        updatePreviewRate();
        updateLoadState(previewDetailsList.isNotEmpty
            ? LoaderState.loaded
            : LoaderState.noData);
        Helpers.successToast('Offline – bill preview is not verified');
        if (onSuccess != null) onSuccess();
      } else if (res.isValue) {
        previewBillResponse = res.asValue!.value;
        updatePoojaDetailsLength(previewBillResponse);
        print(previewBillResponse?.data?.billimage);
        String? imageUrl = previewBillResponse?.data?.billimage == null ||
                previewBillResponse?.data?.billimage == ''
            ? null
            : "${previewBillResponse?.data?.billimage}";

        imageData = imageUrl == null ? null : await getImageData(imageUrl);
        if (onSuccess != null) onSuccess();
      } else {
        if (onFailure != null) onFailure();
        updateLoadState(LoaderState.loaded);
      }
    } catch (e) {
      debugPrint('exception in preview bill: $e');
      updateLoadState(LoaderState.loaded);
    }
    notifyListeners();
  }

  Future<void> savequickbill(
      {Function? onSuccess,
      Function? onFailure,
      bool enableLoaderState = false,
      int? modeid,
      String? amt,
      List? poojalist}) async {
    if (enableLoaderState) updateBtnLoader(true);
    if (!enableLoaderState) updateLoadState(LoaderState.loading);
    // SaveBillBody saveBillBody = SaveBillBody(
    //     billAmount: double.parse(totalRateController.text.trim()),
    //     // counterId: int.parse(AppConfig.counterID ?? '0'),
    //     customerId: AppConfig.customerId ?? 1,
    //     paidAmount: double.parse(paidAmountController.text.trim()),
    //     paymentMode: paymentModeId ?? 0,
    //     // transactionid: transid == null || transid == '' ? null : transid,
    //     poojaDetails: previewBillResponse?.data?.poojaDetails);
    try {
      var res = await serviceConfig.savequickbill(
          amt: amt, modeid: modeid, poojalist: poojalist);
      if (res.isValue) {
        savequickbills = res.asValue!.value;
        String? imageUrl =
            savequickbills?.billImage == null || savequickbills?.billImage == ''
                ? null
                : "${savequickbills?.billImage}";

        imageData = imageUrl == null ? null : await getImageData(imageUrl);
        if (onSuccess != null) onSuccess();
        if (enableLoaderState) updateBtnLoader(false);
        if (!enableLoaderState) updateLoadState(LoaderState.loaded);
      } else {
        errorMessage = 'Oops...! Something went wrong';
        if (onFailure != null) onFailure();
        if (enableLoaderState) updateBtnLoader(false);
        if (!enableLoaderState) updateLoadState(LoaderState.loaded);
      }
    } catch (e) {
      debugPrint('exception in save quick bill: $e');
      if (enableLoaderState) updateBtnLoader(false);
      if (!enableLoaderState) updateLoadState(LoaderState.loaded);
      Helpers.successToast('Internal Server Error...');
    }
    updateStarId('');
  }

  updatePoojaDetailsLength(PreviewBillResponse? previewBillResponse) {
    poojaDetailsList.clear();
    previewDetailsList = previewBillResponse?.data?.poojaDetails ?? [];
    poojaDetailsList = [...previewDetailsList];

    updatePreviewRate();
    if (previewDetailsList.isNotEmpty) {
      updateLoadState(LoaderState.loaded);
    } else {
      updateLoadState(LoaderState.noData);
    }
    notifyListeners();
  }

  removeFromPoojaList(int index) {
    previewDetailsList.removeAt(index);
    updatePreviewRate();
    if (previewDetailsList.isEmpty) {
      updateLoadState(LoaderState.noData);
    }
    notifyListeners();
  }

  updatePreviewRate() {
    totalAmount = 0;
    if (previewDetailsList.isNotEmpty) {
      for (var element in previewDetailsList) {
        totalAmount = totalAmount + element.rate;
      }
    }
    totalRateController.text = totalAmount.toStringAsFixed(0);
    paidAmountController.text = totalAmount.toStringAsFixed(0);
    notifyListeners();
  }

  Future<Uint8List?> getImageData(String imageUrl) async {
    try {
      final network =
          await CommonFunctions.checkInternetConnection(enableToast: false);

      if (!network) {
        return null;
      }

      final response = await http.get(Uri.parse(imageUrl));

      if (response.statusCode == 200) {
        return response.bodyBytes;
      }

      print("Image load failed: ${response.statusCode}");
      return null;
    } catch (e) {
      print("Image exception: $e");
      return null;
    }
  }

  Future<void> saveBill(
      {Function? onSuccess,
      Function? onFailure,
      bool enableLoaderState = false}) async {
    if (_savingBill) return;
    _savingBill = true;
    if (enableLoaderState) updateBtnLoader(true);
    if (!enableLoaderState) updateLoadState(LoaderState.loading);
    void stopLoader() {
      _savingBill = false;
      if (enableLoaderState) updateBtnLoader(false);
      if (!enableLoaderState) updateLoadState(LoaderState.loaded);
    }

    lastCardPayment = null;
    try {
      SaveBillBody saveBillBody = SaveBillBody(
          billAmount: double.parse(totalRateController.text.trim()),
          counterId: int.parse(AppConfig.counterID ?? '0'),
          customerId: AppConfig.customerId ?? 1,
          paidAmount: double.parse(paidAmountController.text.trim()),
          paymentMode: paymentModeId ?? 0,
          transactionid: transid == null || transid == '' ? null : transid,
          poojaDetails:
              previewBillResponse?.data?.poojaDetails ?? previewDetailsList);

      // ---- Card: charge through Payswiff first ----
      if (_isCardMode) {
        final card = await _takeCardPayment(saveBillBody);
        if (card == null) {
          stopLoader();
          return; // declined / cancelled -> bill is NOT saved
        }
        lastCardPayment = card;
      }

      SaveBillResponse? response;
      final network =
          await CommonFunctions.checkInternetConnection(enableToast: false);
      if (network) {
        try {
          var res = await serviceConfig.saveBill(saveBillBody);
          if (res.isValue) {
            response = res.asValue!.value;
          } else if (lastCardPayment == null) {
            errorMessage = 'Oops...! Something went wrong';
            if (onFailure != null) onFailure();
            stopLoader();
            return;
          }
          // Card already charged but the server rejected the bill: it falls
          // through to the offline queue below so it is retried, not lost.
        } on NoInternetException {
          response = null; // never reached the server – safe to queue
        }
      }

      if (response == null) {
        response = await _saveBillOffline(saveBillBody);
        Helpers.successToast('Saved offline. It will sync when online.');
      }

      saveBillResponse = response;
      List<Details> details = response.details ?? [];
      person.clear();
      for (int i = 0; i < details.length; i++) {
        person.add(PoojaPersons(
            id: (i + 1).toString(),
            date: details[i].date.toString(),
            dietyName: details[i].deity.toString(),
            name: details[i].name ?? 'Customer'.toString(),
            address: details[i].address ?? ''.toString(),
            poojaName: details[i].pooja.toString(),
            rate: "${details[i].qty}/${details[i].rate}",
            star: details[i].star.toString()));
      }

      if (onSuccess != null) onSuccess();
      stopLoader();
    } catch (e) {
      debugPrint('exception in save bill: $e');
      stopLoader();
      Helpers.successToast(lastCardPayment != null
          ? 'Payment received (Ref ${lastCardPayment!.referenceNumber}), '
              'but the bill was not saved. Please note the Ref No.'
          : 'Internal Server Error...');
    }
  }

  /// True when the selected payment mode is "Card" (name from the API).
  bool get _isCardMode => (paymentMode ?? '').trim().toLowerCase() == 'card';

  /// Called from the payment-mode popup: sets the name and the API id.
  void selectPaymentMode(PaymentModeDataList mode) {
    paymentMode = mode.name;
    paymentModeId = mode.id;
    notifyListeners();
  }

  /// Runs the card sale. Returns null if the bill must not be saved.
  /// On success only [SaveBillBody.transactionid] is filled (no card details).
  Future<CardPaymentResult?> _takeCardPayment(SaveBillBody body) async {
    if (!await AposPrinter.isPosDevice()) {
      Helpers.successToast('Card payment works only on the POS machine');
      return null;
    }
    if (!await CommonFunctions.checkInternetConnection(enableToast: false)) {
      Helpers.successToast('Card payment needs internet');
      return null;
    }
    if (!await AposPayment.ensureActivated()) {
      Helpers.successToast('Payment device is not activated');
      return null;
    }

    final amount = body.paidAmount ?? body.billAmount ?? 0;
    final merchantRef =
        'PN${AppConfig.counterID ?? 0}${DateTime.now().millisecondsSinceEpoch}';

    final card = await AposPayment.startSale(
      amount: amount,
      merchantRefNo: merchantRef,
      mobile: AppConfig.customerNumber,
      name: AppConfig.customerName,
    );

    if (!card.isApproved) {
      Helpers.successToast(card.responseMessage ?? 'Payment ${card.status}');
      return null;
    }

    body.transactionid = card.referenceNumber;
    return card;
  }

  /// Queues the bill in SQLite (uploaded later by [OfflineSyncService]) and
  /// builds a local receipt so the bill can still be printed.
  Future<SaveBillResponse> _saveBillOffline(SaveBillBody body) async {
    await OfflineSyncService.instance.queueBill(body.toJson());

    Temple? savedTemple;
    final cachedTemple = await databaseHelper.getTemple();
    if (cachedTemple != null) {
      savedTemple = Temple.fromJson(cachedTemple);
    }

    final now = DateTime.now();
    final today = DateFormat('dd-MM-yyyy').format(now);
    final time = DateFormat('hh:mm a').format(now);

    // Malayalam names for printing come from the SQLite lookup tables (we
    // are already offline here, so a network call would just fail again).
    final Map<String, PoojaData> poojaByKey = {};
    final Set<int> deityIds = {
      for (final d in body.poojaDetails ?? <PoojaDetails>[])
        if (d.deityId != null) d.deityId!
    };
    for (final id in deityIds) {
      try {
        final localData = await databaseHelper.getPoojas('$id');
        for (final data in localData) {
          final p = PoojaData.fromJson(data);
          poojaByKey['$id-${p.poojaId}'] = p;
        }
      } catch (_) {}
    }

    final details = <Details>[];
    for (final d in body.poojaDetails ?? <PoojaDetails>[]) {
      final deity = allDeitiesList.where((e) => e.id == d.deityId);
      final star = allStarsList.where((e) => e.id == d.starId);
      final pooja = poojaByKey['${d.deityId}-${d.poojaId}'];
      details.add(Details(
        name: d.name ?? 'Customer',
        poojaId: d.poojaId,
        qty: '${d.qty ?? 1}',
        rate: '${d.rate ?? 0}',
        amount: '${d.rate ?? 0}',
        address: d.address,
        star: star.isEmpty ? d.star : star.first.nameEng,
        starMal: star.isEmpty ? d.star : star.first.nameMal,
        deity: deity.isEmpty ? d.diety : deity.first.name,
        deityMal: deity.isEmpty ? d.diety : deity.first.nameMal,
        pooja: pooja?.name ?? d.pooja,
        poojaMal: pooja?.nameMal ?? d.pooja,
        time: time,
        date: _displayDate(d.date ?? d.fromDate) ?? today,
        gothra: '',
        gothraLocale: '',
        rashi: '',
        rashiLocale: '',
      ));
    }

    String? modeName;
    for (final m in paymentModeDataList) {
      if (m.id == body.paymentMode) modeName = m.name;
    }

    return SaveBillResponse(
      status: true,
      message: 'Saved offline',
      temple: savedTemple,
      summary: Summary(
        id: null,
        billDate: today,
        mode: modeName ?? paymentMode,
        counter: AppConfig.counterID,
        devotee: AppConfig.customerName ?? 'Customer',
        total: '${body.billAmount}',
        recvAmt: '${body.paidAmount}',
      ),
      details: details,
    );
  }

  /// yyyy-MM-dd -> dd-MM-yyyy (the receipt printer expects the latter).
  String? _displayDate(String? value) {
    if (value == null || value.isEmpty) return null;
    try {
      return DateFormat('dd-MM-yyyy').format(DateTime.parse(value));
    } catch (_) {
      return value;
    }
  }

  /// Works offline: falls back to the last SQLite copy when the API call
  /// fails or throws (no network).
  Future<void> getDeities() async {
    updateLoadState(LoaderState.loading);
    try {
      final res = await serviceConfig.getDeities();
      if (res.isValue) {
        deitiesResponse = res.asValue!.value;
        final apiDeities = deitiesResponse?.data ?? [];
        if (apiDeities.isNotEmpty) {
          final deityMaps = apiDeities.map((deity) {
            return {
              'id': deity.id,
              'name': deity.name,
              'name_mal': deity.nameMal,
            };
          }).toList();
          await databaseHelper.clearDeities();
          await databaseHelper.insertDeities(deityMaps);
          debugPrint('Deities saved to SQLite');
        }
        updateDeitiesList(deitiesResponse);
        updateLoadState(LoaderState.loaded);
      } else {
        debugPrint('Deity API failed. Loading from SQLite...');
        await loadDeitiesFromDatabase();
        updateLoadState(LoaderState.loaded);
      }
    } catch (e) {
      debugPrint('Exception in deities API: $e');
      await loadDeitiesFromDatabase();
      updateLoadState(LoaderState.loaded);
    }
  }

  Future<void> loadDeitiesFromDatabase() async {
    try {
      final localData = await databaseHelper.getDeities();
      if (localData.isEmpty) {
        debugPrint('No deities in database');
        return;
      }
      final localDeities =
          localData.map((data) => DeitiesData.fromJson(data)).toList();
      deitiesResponse = DeitiesResponse(data: localDeities, status: true);
      updateDeitiesList(deitiesResponse);
    } catch (e) {
      debugPrint('Error loading deities from SQLite: $e');
    }
  }

  Future<void> getStars() async {
    try {
      var res = await serviceConfig.getStarts();
      if (res.isValue) {
        starsResponse = res.asValue!.value;
        final apiStars = starsResponse?.data ?? [];
        if (apiStars.isNotEmpty) {
          final starMaps = apiStars.map((star) {
            return {
              'id': star.id,
              'name_eng': star.nameEng,
              'name_mal': star.nameMal,
            };
          }).toList();
          await databaseHelper.clearStars();
          await databaseHelper.insertStars(starMaps);
          debugPrint('Stars saved to SQLite');
        }
        updateStarsList(starsResponse);
      } else {
        debugPrint('Stars API failed. Loading from SQLite...');
        await loadStarsFromDatabase();
      }
    } catch (e) {
      debugPrint('exception in stars: $e');
      await loadStarsFromDatabase();
    }
  }

  Future<void> loadStarsFromDatabase() async {
    try {
      final localData = await databaseHelper.getStars();
      if (localData.isEmpty) {
        debugPrint('No stars in database');
        return;
      }
      final localStars =
          localData.map((data) => StartsData.fromJson(data)).toList();
      starsResponse = StarsResponse(data: localStars, status: true);
      updateStarsList(starsResponse);
    } catch (e) {
      debugPrint('Error loading stars from SQLite: $e');
    }
  }

  Future<void> getgothra() async {
    try {
      var res = await serviceConfig.getgothra();
      if (res.isValue) {
        gothraResponse = res.asValue!.value;
        final apiGothra = gothraResponse?.data ?? [];
        if (apiGothra.isNotEmpty) {
          final gothraMaps = apiGothra.map((item) {
            return {
              'id': item.id,
              'name_eng': item.nameEng,
              'name_locale': item.nameLocale,
              'status': item.status,
              'deleted': item.deleted,
            };
          }).toList();
          await databaseHelper.clearGothra();
          await databaseHelper.insertGothra(gothraMaps);
          debugPrint('Gothra saved to SQLite');
        }
      } else {
        debugPrint('Gothra API failed. Loading from SQLite...');
        await loadGothraFromDatabase();
      }
    } catch (e) {
      debugPrint('exception in gothra: $e');
      await loadGothraFromDatabase();
    }
  }

  Future<void> loadGothraFromDatabase() async {
    try {
      final localData = await databaseHelper.getGothra();
      if (localData.isEmpty) {
        debugPrint('No gothra in database');
        return;
      }
      // Built through fromJson (rather than naming the model's inner `Data`
      // class) because gothra/rashi/quickbill each declare their own `Data`.
      gothraResponse =
          GothraDatamodel.fromJson({'status': true, 'data': localData});
    } catch (e) {
      debugPrint('Error loading gothra from SQLite: $e');
    }
  }

  Future<void> getrashi() async {
    try {
      var res = await serviceConfig.getrashi();
      if (res.isValue) {
        rashiResponse = res.asValue!.value;
        final apiRashi = rashiResponse?.data ?? [];
        if (apiRashi.isNotEmpty) {
          final rashiMaps = apiRashi.map((item) {
            return {
              'id': item.id,
              'name_eng': item.nameEng,
              'name_locale': item.nameLocale,
              'status': item.status,
              'deleted': item.deleted,
            };
          }).toList();
          await databaseHelper.clearRashi();
          await databaseHelper.insertRashi(rashiMaps);
          debugPrint('Rashi saved to SQLite');
        }
      } else {
        debugPrint('Rashi API failed. Loading from SQLite...');
        await loadRashiFromDatabase();
      }
    } catch (e) {
      debugPrint('exception in rashi: $e');
      await loadRashiFromDatabase();
    }
  }

  Future<void> loadRashiFromDatabase() async {
    try {
      final localData = await databaseHelper.getRashi();
      if (localData.isEmpty) {
        debugPrint('No rashi in database');
        return;
      }
      rashiResponse =
          RashiDatamodel.fromJson({'status': true, 'data': localData});
    } catch (e) {
      debugPrint('Error loading rashi from SQLite: $e');
    }
  }

  Future<void> getSpecialStars() async {
    try {
      var res = await serviceConfig.getSpecialStars();
      if (res.isValue) {
        specialStarResponse = res.asValue!.value;
        final apiSpecialStars = specialStarResponse?.data ?? [];
        if (apiSpecialStars.isNotEmpty) {
          final maps = apiSpecialStars.map((item) {
            return {
              'other_code': item.otherCode,
              'other_detail': item.otherDetail,
            };
          }).toList();
          await databaseHelper.clearSpecialStars();
          await databaseHelper.insertSpecialStars(maps);
          debugPrint('Special stars saved to SQLite');
        }
        updateSpecialStarsList(specialStarResponse);
      } else {
        debugPrint('Special stars API failed. Loading from SQLite...');
        await loadSpecialStarsFromDatabase();
      }
    } catch (e) {
      debugPrint('exception in special stars: $e');
      await loadSpecialStarsFromDatabase();
    }
  }

  Future<void> loadSpecialStarsFromDatabase() async {
    try {
      final localData = await databaseHelper.getSpecialStars();
      if (localData.isEmpty) {
        debugPrint('No special stars in database');
        return;
      }
      specialStarResponse =
          SpecialStarResponse.fromJson({'status': true, 'data': localData});
      updateSpecialStarsList(specialStarResponse);
    } catch (e) {
      debugPrint('Error loading special stars from SQLite: $e');
    }
  }

  Future<void> getPoojas({bool isEnableBtnLoader = false}) async {
    if (isEnableBtnLoader) updateBtnLoader(true);
    try {
      var res = await serviceConfig.getPoojas(deityId);
      if (res.isValue) {
        poojaResponse = res.asValue!.value;
        final apiPoojas = poojaResponse?.data ?? [];
        if (apiPoojas.isNotEmpty) {
          final poojaMaps = apiPoojas.map((pooja) {
            return {
              'deity_pooja_id': pooja.deityPoojaId,
              'pooja_id': pooja.poojaId,
              'name': pooja.name,
              'name_mal': pooja.nameMal,
              'rate': pooja.rate,
              'row_count': pooja.rowcount,
            };
          }).toList();
          await databaseHelper.clearPoojas(deityId);
          await databaseHelper.insertPoojas(deityId, poojaMaps);
          debugPrint('Poojas saved to SQLite');
        }
        updatePoojasList(poojaResponse);
        updateBtnLoader(false);
        updateLoadState(LoaderState.loaded);
      } else {
        debugPrint('Poojas API failed. Loading from SQLite...');
        await loadPoojasFromDatabase();
        updateBtnLoader(false);
        updateLoadState(LoaderState.loaded);
      }
    } catch (e) {
      debugPrint('exception in poojas: $e');
      await loadPoojasFromDatabase();
      updateBtnLoader(false);
      updateLoadState(LoaderState.loaded);
    }
  }

  Future<void> loadPoojasFromDatabase() async {
    try {
      final localData = await databaseHelper.getPoojas(deityId);
      if (localData.isEmpty) {
        debugPrint('No poojas in database for deity $deityId');
        return;
      }
      final localPoojas =
          localData.map((data) => PoojaData.fromJson(data)).toList();
      poojaResponse = PoojaResponse(data: localPoojas, status: true);
      updatePoojasList(poojaResponse);
    } catch (e) {
      debugPrint('Error loading poojas from SQLite: $e');
    }
  }

  updateDeitiesList(DeitiesResponse? deitiesResponse) {
    deitiesList = deitiesResponse?.data ?? [];
    allDeitiesList = deitiesResponse?.data ?? [];
    // updateDeityId('${deitiesList[0].id}');  // cleared
    notifyListeners();
  }

  searchDeity(String value) {
    isSearching = true;

    deitiesList = allDeitiesList
        .where((element) =>
            (element.name ?? '').toLowerCase().contains(value.toLowerCase()))
        .toList();

    isSearching = false;
    debugPrint('length ${deitiesList.length}');
    notifyListeners();
  }

  updateStarsList(StarsResponse? starsResponse) {
    starsList = starsResponse?.data ?? [];
    allStarsList = starsList;
    notifyListeners();
  }

  searchStar(String value) {
    starsList = allStarsList
        .where((element) =>
            (element.nameEng ?? '').toLowerCase().contains(value.toLowerCase()))
        .toList();

    notifyListeners();
  }

  updateSpecialStarsList(SpecialStarResponse? specialStarResponse) {
    specialStarList = specialStarResponse?.data ?? [];
    allSpecialStarList = specialStarList;
    notifyListeners();
  }

  searchSpecialStar(String value) {
    specialStarList = allSpecialStarList
        .where((element) => (element.otherDetail ?? '')
            .toLowerCase()
            .contains(value.toLowerCase()))
        .toList();

    notifyListeners();
  }

  updatePoojasList(PoojaResponse? poojaResponse) {
    poojaDataList.clear();
    poojaDataList = poojaResponse?.data ?? [];
    // print(poojaResponse?.data![0].name);
    allPoojaDataList = poojaDataList;
    notifyListeners();
  }

  searchPooja(String value) {
    poojaDataList = allPoojaDataList
        .where((element) =>
            (element.name ?? '').toLowerCase().contains(value.toLowerCase()))
        .toList();

    notifyListeners();
  }

  removeElementFromPoojaList(int index, {Function? onSuccess}) {
    poojaDetailsList.removeAt(index);
    if (onSuccess != null) onSuccess();
    notifyListeners();
  }

  updateDeityId(String id) {
    deityId = id;
    notifyListeners();
  }

  ayyapanpooja(String? name) {
    if (deityname == name) {
      getPoojaIdFromName('ARI PARA');
    }
    notifyListeners();
  }

  getDeityIdFromName(String name) async {
    deityname = name;

    updateIsDeityUpdated(true);
    for (var element in deitiesList) {
      if (name == element.name) {
        deityId = '${element.id}';
      }
      if (name == "DONATION") {
        ratefield = true;
        isScheduled = false;
      } else {
        ratefield = false;
      }
    }
    // ayyapanpooja(deityname); for default pooja selection
    notifyListeners();
  }

  updatePoojaId(String id) {
    poojaId = id;
    notifyListeners();
  }

  getPoojaIdFromName(String name) {
    poojaName = name;
    updateIsDeityUpdated(true);
    for (var element in poojaDataList) {
      if (name == element.name) {
        poojaId = '${element.poojaId}';

        poojacountrow = element.rowcount;
        qtyController.text = '1';
        // print(rateController.text);
        poojaRate = double.parse(element.rate ?? '0');
        updateRate();
      }
    }

    notifyListeners();
  }

  String? name;
  String getPoojanamefromid(int id, QuickbillDatamodel? quickdata) {
    for (var element in quickdata!.data!) {
      if (id == element.id) {
        name = '${element.name}';
      } else {}
    }

    notifyListeners();
    return name ?? '';
  }

  updateRate() {
    if (qtyController.text.isNotEmpty) {
      var totalRate = (poojaRate ?? 0) * (int.parse(qtyController.text));
      rateController.text = totalRate == 0 ? '' : totalRate.toStringAsFixed(0);
    } else {
      rateController.text = '';
    }
    notifyListeners();
  }

  updateStarId(String id) {
    starId = id;
    notifyListeners();
  }

//? for setting initial star as nodata .........................................

  getStarIdFromName(String name) {
    starName = name;
    print("..star..star..$starName");
    updateIsDeityUpdated(true);
    for (var element in starsList) {
      if (name == element.nameEng) {
        starId = '${element.id}';
      }
    }
    notifyListeners();
  }

  getgothraIdFromName(String name) {
    gothraName = name;
    updateIsDeityUpdated(true);
    for (var element in gothraResponse?.data ?? []) {
      if (name == element.nameEng) {
        gothraId = '${element.id}';
      }
    }
    notifyListeners();
  }

  String? getgothranameFromid(int id) {
    return gothraResponse?.data!.firstWhere((g) => g.id == id).nameEng;
  }

  String? getrashianameFromid(int id) {
    return rashiResponse?.data!
        .firstWhere((element) => element.id == id)
        .nameEng;
  }

  getrashiIdFromName(String name) {
    rashiName = name;
    // updateIsDeityUpdated(true);
    for (var element in rashiResponse?.data ?? []) {
      if (name == element.nameEng) {
        rashiId = '${element.id}';
      }
    }
    notifyListeners();
  }

  getStarIdFromName1(String name) {
    starName1 = name;
    updateIsDeityUpdated(true);
    for (var element in starsList) {
      if (name == element.nameEng) {
        starId1 = '${element.id}';
      }
    }
    notifyListeners();
  }

  getSpecialStarIdFromName(String name) {
    specialStarName = name;
    for (var element in specialStarList) {
      if (name == element.otherDetail) {
        specialStarId = int.parse(element.otherCode ?? '0');
      }
    }
    notifyListeners();
  }

  updateIsDeityUpdated(bool value) {
    isDeityUpdated = value;
    notifyListeners();
  }

  updateSheduleType(String type) {
    scheduleTypes = type;
    updateScheduledType(type);
    notifyListeners();
  }

  updateSwitch(bool val) {
    isScheduled = val;
    notifyListeners();
  }

  updateFromDate(String date) {
    fromDate = date;
    notifyListeners();
  }

  updateDate(String value) {
    date = value;
    notifyListeners();
  }

  updateNumberOfDays(int days) {
    numberOfDays = days;
    notifyListeners();
  }

  updateNumberOfWeeks(int weeks) {
    numberOfWeeks = weeks;
    notifyListeners();
  }

  updateNumberOfMonths(int months) {
    numberOfMonths = months;
    notifyListeners();
  }

  updateIsPrasadhamIncluded(String value) {
    if (value == 'Yes') {
      isPrasadhamIncluded = true;
    } else {
      isPrasadhamIncluded = false;
    }
    notifyListeners();
  }

  updateScheduledType(String value) {
    switch (value) {
      case 'Daily':
        scheduledType = 'D';
        break;
      case 'Weekly':
        scheduledType = 'W';
        break;
      case 'Monthly':
        scheduledType = 'M';
        break;
      case 'Other':
        scheduledType = 'O';
        break;
    }
    notifyListeners();
  }

  updateWeekDays(String value) {
    weekDays = value;
    notifyListeners();
  }

  updateSpecialStarId(int id) {
    specialStarId = id;
    notifyListeners();
  }

  updatePaymentModeList(PaymentModeResponse? paymentModeResponse) {
    paymentModeDataList = paymentModeResponse?.data ?? [];
    if (paymentModeDataList.isNotEmpty) {
      paymentMode = paymentModeDataList[0].name ?? '';
      paymentModeId = 1;
    }
    updateLoadState(LoaderState.loaded);
    notifyListeners();
  }

  updatePaymentMode(String value) {
    paymentMode = value;
    notifyListeners();
  }

  updatePaymentModeId() {
    for (var element in paymentModeDataList) {
      if (element.name == paymentMode) {
        paymentModeId = element.id ?? 0;
      }
    }
    notifyListeners();
  }

  updatetransid(String? val) {
    transid = val;
    notifyListeners();
  }

  updateValidationMessage(
      {required ValidationTypes validationTypes,
      required String validationMessage}) {
    switch (validationTypes) {
      case ValidationTypes.name:
        if (validationMessage.isNotEmpty) {
          nameErrorMessage = validationMessage;
        } else {
          nameErrorMessage = null;
        }
        break;
      case ValidationTypes.rate:
        if (validationMessage.isNotEmpty) {
          rateErrorMessage = validationMessage;
        } else {
          rateErrorMessage = null;
        }
        break;
      case ValidationTypes.totalRate:
        if (validationMessage.isNotEmpty) {
          totalRateErrorMessage = validationMessage;
        } else {
          totalRateErrorMessage = null;
        }
        break;
      case ValidationTypes.paidAmount:
        if (validationMessage.isNotEmpty) {
          paidAmountErrorMessage = validationMessage;
        } else {
          paidAmountErrorMessage = null;
        }
        break;
      case ValidationTypes.qty:
        if (validationMessage.isNotEmpty) {
          qtyErrorMessage = validationMessage;
        } else {
          qtyErrorMessage = null;
        }
        break;
      case ValidationTypes.mobileNumber:
        if (validationMessage.isNotEmpty) {
          mobileErrorMessage = validationMessage;
        } else {
          mobileErrorMessage = null;
        }
    }
    updateBillingFormState();
  }

  updateBillingFormState() {
    print("..$gothraId...$gothraName..$rashiId..$rashiName");
    if (!isScheduled) {
      if (deityId.isNotEmpty &&
          poojaId.isNotEmpty &&
          // gothraId != null &&
          // rashiId != null &&
          // gothraId != '' &&
          // rashiId != '' &&
          starId != null &&
          starId != '' &&
          // nameController.text.isNotEmpty &&
          qtyController.text.isNotEmpty &&
          rateController.text.isNotEmpty &&
          fromDate != null &&
          nameErrorMessage == null &&
          qtyErrorMessage == null &&
          rateErrorMessage == null) {
        isBillingFormValidated = true;
      } else {
        isBillingFormValidated = false;
      }
    } else {
      if (deityId.isNotEmpty &&
          poojaId.isNotEmpty &&
          // gothraId != null &&
          // rashiId != null &&
          // gothraId != '' &&
          // rashiId != '' &&
          starId != null &&
          starId != '' &&
          // starId.isNotEmpty &&
          // nameController.text.isNotEmpty &&
          qtyController.text.isNotEmpty &&
          rateController.text.isNotEmpty &&
          // totalRateController.text.isNotEmpty &&
          nameErrorMessage == null &&
          qtyErrorMessage == null &&
          rateErrorMessage == null &&
          paidAmountErrorMessage == null &&
          totalRateErrorMessage == null &&
          scheduledType != null &&
          fromDate != null &&
          (noOfDaysController.text.isNotEmpty ||
              noOfWeeksController.text.isNotEmpty ||
              noOfMonthsController.text.isNotEmpty)) {
        if (scheduledType == 'O') {
          if (specialStarId != null) {
            isBillingFormValidated = true;
          }
        } else {
          isBillingFormValidated = true;
        }
      } else {
        isBillingFormValidated = false;
      }
    }
    notifyListeners();
  }

  updatePreviewBillingFormValidated() {
    if ((AppConfig.customerNumber ?? '').isEmpty) {
      if (mobileNumberController.text.isNotEmpty &&
          mobileErrorMessage == null) {
        isPreviewBillingFormValidated = true;
      } else {
        isPreviewBillingFormValidated = false;
      }
    } else {
      if (paidAmountErrorMessage == null &&
          paidAmountController.text.trim().isNotEmpty) {
        isPreviewBillingFormValidated = true;
      } else {
        isPreviewBillingFormValidated = false;
      }
    }
    notifyListeners();
  }

  updateTemple(Temple? value) {
    temple = value;
    notifyListeners();
  }

  updateSummary(Summary? value) {
    summary = value;
    notifyListeners();
  }

  updatePersonList(List<PoojaPersons> poojaPersons) {
    person = poojaPersons;
    notifyListeners();
  }

  saveAndNextFunction() {
    updateLoadState(LoaderState.loading);
    Future.delayed(const Duration(seconds: 1), () {
      PoojaDetails poojaDetails = PoojaDetails(
          // gothraname: gothraName,
          // rashiname: rashiName,
          // gothra: int.parse(gothraId ?? '0'),
          // rashi: int.parse(rashiId ?? '0'),
          name: nameController.text.isEmpty
              ? 'Customer'
              : nameController.text.trim(),
          address: addressController.text,
          date: isScheduled ? date : null,
          deityId: int.parse(deityId),
          dwmo: scheduledType,
          fromDate: fromDate,
          isScheduled: isScheduled ? 1 : 0,
          noOfDays: noOfDaysController.text.isNotEmpty
              ? int.parse(noOfDaysController.text.trim())
              : null,
          noOfMonths: noOfMonthsController.text.isNotEmpty
              ? int.parse(noOfMonthsController.text.trim())
              : null,
          noOfWeeks: noOfWeeksController.text.isNotEmpty
              ? int.parse(noOfWeeksController.text.trim())
              : null,
          poojaId: int.parse(poojaId),
          pooja: poojaName,
          diety: deityname,
          prasadamStatus: (isPrasadhamIncluded ?? false) ? 1 : 0,
          qty: int.parse(qtyController.text.trim()),
          rate: double.parse(rateController.text.trim()),
          starId: starName == null || starId == null
              ? 28
              : int.parse(starId ?? '28'),
          specialStarId: specialStarId,
          monthStar: starName,
          weekDays: weekDays);
      if (paidAmountController.text.isNotEmpty) {
        paidAmount = paidAmount + int.parse(paidAmountController.text.trim());
      }
      if (totalRateController.text.isNotEmpty) {
        billAmount = billAmount + int.parse(totalRateController.text.trim());
      }
      poojaDetailsList.add(poojaDetails);
      if (poojacountrow == 2) {
        PoojaDetails poojaDetails1 = PoojaDetails(
            // gothraname: gothraName,
            // rashiname: rashiName,
            // gothra: int.parse(gothraId ?? '0'),
            // rashi: int.parse(rashiId ?? '0'),
            name: nameController2.text.isEmpty
                ? 'Customer'
                : nameController2.text.trim(),
            address: addressController.text,
            date: isScheduled ? date : null,
            deityId: int.parse(deityId),
            dwmo: scheduledType,
            fromDate: fromDate,
            isScheduled: 0,
            noOfDays: noOfDaysController.text.isNotEmpty
                ? int.parse(noOfDaysController.text.trim())
                : null,
            noOfMonths: noOfMonthsController.text.isNotEmpty
                ? int.parse(noOfMonthsController.text.trim())
                : null,
            noOfWeeks: noOfWeeksController.text.isNotEmpty
                ? int.parse(noOfWeeksController.text.trim())
                : null,
            poojaId: int.parse(poojaId),
            pooja: poojaName,
            diety: deityname,
            prasadamStatus: (isPrasadhamIncluded ?? false) ? 1 : 0,
            qty: 0,
            rate: 0,
            starId: starName1 == null || starId == null
                ? 28
                : int.parse(starId ?? '28'),
            specialStarId: specialStarId,
            monthStar: starName1,
            weekDays: weekDays);
        poojaDetailsList.add(poojaDetails1);
      }
      clearValues(isClearDate: false);
      updateFromDate(DateFormat('y-MM-dd').format(DateTime.now()));
      getDeityIdFromName(deityname!);
      getPoojaIdFromName(poojaName!);
      updateBillingFormState();
      updateLoadState(LoaderState.loaded);
    });
  }

  saveAndPreviewFunction(BuildContext context) {
    PoojaDetails poojaDetails = PoojaDetails(
        // gothra: int.parse(gothraId ?? '0'),
        // rashi: int.parse(rashiId ?? '0'),
        // gothraname: gothraName,
        // rashiname: rashiName,
        name: nameController.text.isEmpty
            ? 'Customer'
            : nameController.text.trim(),
        address: addressController.text,
        date: !isScheduled ? date : null,
        deityId: int.parse(deityId),
        dwmo: scheduledType,
        fromDate: fromDate,
        isScheduled: isScheduled == true ? 1 : 0,
        noOfDays: noOfDaysController.text.isNotEmpty
            ? int.parse(noOfDaysController.text.trim())
            : null,
        noOfMonths: noOfMonthsController.text.isNotEmpty
            ? int.parse(noOfMonthsController.text.trim())
            : null,
        noOfWeeks: noOfWeeksController.text.isNotEmpty
            ? int.parse(noOfWeeksController.text.trim())
            : null,
        poojaId: int.parse(poojaId),
        pooja: poojaName,
        diety: deityname,
        prasadamStatus: (isPrasadhamIncluded ?? false) ? 1 : 0,
        qty: int.parse(qtyController.text.trim()),
        rate: double.parse(rateController.text.trim()),
        starId: int.parse(starId ?? '28'),
        specialStarId: specialStarId,
        monthStar: starName,
        weekDays: weekDays);
    if (paidAmountController.text.isNotEmpty) {
      paidAmount = paidAmount + int.parse(paidAmountController.text.trim());
    }
    if (totalRateController.text.isNotEmpty) {
      billAmount = billAmount + int.parse(totalRateController.text.trim());
    }
    poojaDetailsList.add(poojaDetails);
    if (poojacountrow == 2) {
      PoojaDetails poojaDetails1 = PoojaDetails(
          // gothraname: gothraName,
          // rashiname: rashiName,
          // gothra: int.parse(gothraId ?? '0'),
          // rashi: int.parse(rashiId ?? '0'),
          name: nameController2.text.isEmpty
              ? 'Customer'
              : nameController2.text.trim(),
          address: addressController.text,
          date: isScheduled ? date : null,
          deityId: int.parse(deityId),
          dwmo: scheduledType,
          fromDate: fromDate,
          isScheduled: 0,
          noOfDays: noOfDaysController.text.isNotEmpty
              ? int.parse(noOfDaysController.text.trim())
              : null,
          noOfMonths: noOfMonthsController.text.isNotEmpty
              ? int.parse(noOfMonthsController.text.trim())
              : null,
          noOfWeeks: noOfWeeksController.text.isNotEmpty
              ? int.parse(noOfWeeksController.text.trim())
              : null,
          poojaId: int.parse(poojaId),
          pooja: poojaName,
          diety: deityname,
          prasadamStatus: (isPrasadhamIncluded ?? false) ? 1 : 0,
          qty: 0,
          rate: 0,
          starId: starName1 == null || starId1 == null || starId == null
              ? 28
              : int.parse(starId ?? '28'),
          specialStarId: specialStarId,
          monthStar: starName1,
          weekDays: weekDays);
      poojaDetailsList.add(poojaDetails1);
    }
    clearValues(isClearPaymentMode: false, isClearDate: false);
    getStarIdFromName("Nodata");
    updateRate();
    navigateToPreviewBill(context);
  }

  navigateToPreviewBill(BuildContext context) {
    if (isBillingFormValidated) {
      // getStarIdFromName("Nodata");
      saveAndPreviewFunction(context);
    } else {
      getStarIdFromName("Nodata");
      getPreviewBill(context,
          onSuccess: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PreviewBillScreen(),
                  )).then((value) {
                totalAmount = 0;
                mobileNumberController.clear();
                updateFromDate(DateFormat('y-MM-dd').format(DateTime.now()));
              }),
          onFailure: () => Helpers.successToast(errorMessage ?? ''));
    }
  }

  launchWhatsAppUri(String text) async {
    String mobileNumber =
        AppConfig.customerNumber ?? mobileNumberController.text.trim();
    final link = WhatsAppUnilink(
      phoneNumber: '91$mobileNumber}',
      text: text,
    );
    // Convert the WhatsAppUnilink instance to a Uri.
    // The "launch" method is part of "url_launcher".
    try {
      await launchUrl(
        link.asUri(),
        mode: LaunchMode.externalApplication,
      );
    } catch (e) {
      debugPrint('Exception in whatsapp url $e');
    }
  }

  logoutclear() {
    rateController.clear();
    qtyController.clear();
    deityname = null;
    poojaName = null;
    notifyListeners();
  }

  clearValues({bool isClearPaymentMode = true, bool isClearDate = true}) {
    addressController.clear();
    nameController.clear();
    nameController2.clear();
    gothraId = '';
    rashiId = '';
    starId = '';
    // rateController.clear();
    qtyController = TextEditingController(text: '1');
    totalRateController.clear();
    paidAmountController.clear();
    noOfDaysController.clear();
    noOfWeeksController.clear();
    noOfMonthsController.clear();
    isBillingFormValidated = false;
    transid = null;
    if (isClearDate) fromDate = null;
    starName = null;
    starName1 = null;
    specialStarName = null;
    // deityname = null;
    // poojaName = null;
    if (isClearPaymentMode) paymentMode = 'COD';
    numberOfDays = null;
    numberOfWeeks = null;
    numberOfMonths = null;
    isPrasadhamIncluded = null;
    scheduleTypes = null;
    scheduledType = null;
    isScheduled = false;
    nameErrorMessage = null;
    qtyErrorMessage == null;
    rateErrorMessage = null;
    notifyListeners();
  }

  clearschedule() {
    isScheduled = false;
    notifyListeners();
  }

  clearPaymentValues() {
    billAmount = 0;
    paidAmount = 0;
    notifyListeners();
  }

  @override
  void updateLoadState(LoaderState state) {
    loaderState = state;
    notifyListeners();
  }

  @override
  void updateBtnLoader(bool value) {
    btnLoader = value;
    notifyListeners();
  }
}

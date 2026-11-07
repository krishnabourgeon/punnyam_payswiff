import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:punnyam/models/counters_model.dart';
import 'package:punnyam/models/quickbill_datamodel.dart';
import 'package:punnyam/screens/customer_creation/customer_selection_screen.dart';
import 'package:punnyam/screens/home/bill_list_table.dart';
import 'package:punnyam/screens/home/counter_summary_table.dart';
import 'package:punnyam/screens/home/pooja_list_table.dart';
import 'package:punnyam/services/database_helper.dart';
import 'package:punnyam/services/provider_helper_class.dart';
import 'billing_provider.dart';
import 'create_cutomer_provider.dart';

class HomeProvider extends ChangeNotifier with ProviderHelperClass {
  final DatabaseHelper databaseHelper = DatabaseHelper.instance;
  List<Datum>? counterdata = [];
  List<Item> data = [];
  addtolist(
      {int? id, int? qty, String? name, String? rs, String? basefare}) async {
    final newItem =
        Item(id: id!, name: name!, qty: qty!, rs: rs!, basefare: basefare!);

    // Add the new item to the list
    data.add(newItem);
    getTotalAmount();
    notifyListeners();
    int? len = data.length;
    for (int i = 0; i < len; i++) {}
  }

  updateQtyamt({int? id}) async {
    int index = data.indexWhere((item) => item.id == id);
    data[index].qty = data[index].qty + 1;
    double base = double.parse(data[index].basefare);
    double rs = base * data[index].qty;
    data[index].rs = rs.toString();
    getTotalAmount();
    notifyListeners();
    int? len = data.length;
    for (int i = 0; i < len; i++) {}
  }

  removelist({int? id}) async {
    int index = data.indexWhere((item) => item.id == id);
    data.removeAt(index);
    getTotalAmount();
    notifyListeners();
    int? len = data.length;
    for (int i = 0; i < len; i++) {}
  }

  double getTotalAmount() {
    double totalAmount = 0;
    for (var item in data) {
      totalAmount += double.parse(item.rs);
    }
    return totalAmount;
  }

  removeQtyamt({int? id}) async {
    int index = data.indexWhere((item) => item.id == id);
    if (data[index].qty <= 1) {
      data.removeAt(index);
    } else {
      data[index].qty = data[index].qty - 1;
      double base = double.parse(data[index].basefare);
      double rs = base * data[index].qty;
      data[index].rs = rs.toString();

      int? len = data.length;
      for (int i = 0; i < len; i++) {}
    }
    getTotalAmount();
    notifyListeners();
  }

  List<String> counterName = [];
  List<String> counterId = [];
  QuickbillDatamodel? quickbills;

// vadakkunnathanpos@temple.com
  void clearCounters() {
    counterdata = [];
    counterName = [];
    counterId = [];
    notifyListeners();
  }

  Future<void> getquickbill() async {
    updateLoadState(LoaderState.loading);
    try {
      var res = await serviceConfig.getquickbill();
      if (res.isValue) {
        quickbills = res.asValue!.value;
        final apiPoojas = quickbills?.data ?? [];
        if (apiPoojas.isNotEmpty) {
          final poojaMaps = apiPoojas.map((pooja) {
            return {
              'id': pooja.id,
              'name': pooja.name,
              'rate': pooja.rate,
            };
          }).toList();
          await databaseHelper.clearQuickBillPoojas();
          await databaseHelper.insertQuickBillPoojas(poojaMaps);
          log('Quick bill poojas saved to SQLite');
        }
        notifyListeners();
        updateLoadState(LoaderState.loaded);
      } else {
        log('Quick bill API failed. Loading from SQLite...');
        await loadQuickBillPoojasFromDatabase();
        updateLoadState(LoaderState.loaded);
      }
    } catch (e) {
      debugPrint('exception in quickbills: $e');
      await loadQuickBillPoojasFromDatabase();
      updateLoadState(LoaderState.loaded);
    }
  }

  Future<void> loadQuickBillPoojasFromDatabase() async {
    try {
      final localData = await databaseHelper.getQuickBillPoojas();
      if (localData.isEmpty) {
        log('No quick bill poojas in database');
        return;
      }
      quickbills =
          QuickbillDatamodel.fromJson({'status': true, 'data': localData});
      notifyListeners();
    } catch (e) {
      log('Error loading quick bill poojas from SQLite: $e');
    }
  }

  /// Works offline: falls back to the last SQLite copy when the API call
  /// fails or throws (no network).
  Future<void> getCounter() async {
    clearCounters();
    updateLoadState(LoaderState.loading);
    try {
      final res = await serviceConfig.getCounters();

      if (res.isValue) {
        final CounterModel counters = res.asValue!.value;

        if (counters.data != null && counters.data!.isNotEmpty) {
          final List<Datum> apiCounters = counters.data!;

          // ------------------------------------------------------
          // SAVE API COUNTERS TO SQLITE
          // ------------------------------------------------------

          final List<Map<String, dynamic>> counterMaps =
              apiCounters.map((counter) {
            return counter.toJson();
          }).toList();

          await databaseHelper.clearCounters();

          await databaseHelper.insertCounters(
            counterMaps,
          );

          log('Counters saved to SQLite');

          // ------------------------------------------------------
          // SET PROVIDER DATA
          // ------------------------------------------------------

          counterdata = apiCounters;

          counterName.clear();
          counterId.clear();

          for (final counter in apiCounters) {
            counterName.add(counter.name ?? '');
            counterId.add('${counter.id}');
          }

          log('Counter names: $counterName');
          log('Counter IDs: $counterId');

          notifyListeners();
        }

        updateLoadState(LoaderState.loaded);
      } else {
        // --------------------------------------------------------
        // API FAILED
        // LOAD FROM SQLITE
        // --------------------------------------------------------

        await loadCountersFromDatabase();

        updateLoadState(LoaderState.loaded);
      }
    } catch (e) {
      log('Counter API exception: $e');

      // ----------------------------------------------------------
      // NETWORK ERROR
      // LOAD FROM SQLITE
      // ----------------------------------------------------------

      await loadCountersFromDatabase();

      updateLoadState(LoaderState.loaded);
    }
  }

  Future<void> loadCountersFromDatabase() async {
    try {
      final List<Map<String, dynamic>> localData =
          await databaseHelper.getCounters();

      if (localData.isEmpty) {
        log('No counters available in SQLite');

        counterdata = [];
        counterName.clear();
        counterId.clear();

        notifyListeners();

        return;
      }

      final List<Datum> localCounters =
          localData.map((data) => Datum.fromJson(data)).toList();

      counterdata = localCounters;

      counterName.clear();
      counterId.clear();

      for (final counter in localCounters) {
        counterName.add(counter.name ?? '');
        counterId.add('${counter.id}');
      }

      log('OFFLINE COUNTERS FROM SQLITE');
      log('Names: $counterName');
      log('IDs: $counterId');

      notifyListeners();
    } catch (e) {
      log('Error loading counters from SQLite: $e');
    }
  }

  navigationSwitch(
    BuildContext context,
    int index,
  ) {
    switch (index) {
      case 0:
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CustomerSelectionScreen(),
            )).then((value) {
          context.read<CreateCustomerProvider>().clearValues();
          context.read<BillingProvider>()
            ..getInitialDataList()
            ..clearValues()
            ..clearPaymentValues()
            ..poojaDetailsList.clear();
        });
        break;
      // case 1:
      //   Navigator.push(
      //       context,
      //       MaterialPageRoute(
      //         builder: (context) => const DailyReport(),
      //       ));
      //   break;
      case 1:
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const BillListTable(),
            ));
        break;
      case 2:
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const PoojaListTable(),
            ));
        break;
      case 3:
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CounterSummaryTable(),
            ));
        break;
    }
  }

  @override
  void updateLoadState(LoaderState state) {
    loaderState = state;
    notifyListeners();
  }
}

class Item {
  int id;
  String name;
  int qty;
  String rs;
  final String basefare;

  Item(
      {required this.id,
      required this.name,
      required this.basefare,
      required this.qty,
      required this.rs});
}

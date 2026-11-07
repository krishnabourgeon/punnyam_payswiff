import 'package:flutter/cupertino.dart';
import 'package:punnyam/models/counter_wise_summary_response.dart';
import 'package:punnyam/services/provider_helper_class.dart';

class CounterWiseSummaryProvider extends ChangeNotifier
    with ProviderHelperClass {
  String? fromDate;
  int? counterId;
  int currentPageIndex = 0;
  CounterWiseSummaryResponse? counterWiseSummaryResponse;
  List<CounterWiseData> counterWiseDataList = [];
  List<CounterWiseData> tempCounterWiseData = [];
  PageController pageController = PageController();

  Future<void> getCounterWiseData({int? counterid}) async {
    updateLoadState(LoaderState.loading);
    try {
      var res = await serviceConfig.getCounterWiseSummary(fromDate ?? '');
      if (res.isValue) {
        counterWiseSummaryResponse = res.asValue!.value;
        updateCounterWiseDataList(counterWiseSummaryResponse);
      } else {
        updateLoadState(LoaderState.loaded);
      }
    } catch (e) {
      debugPrint('exception in counter wise summary: $e');
      updateLoadState(LoaderState.loaded);
    }
    notifyListeners();
  }

  updateCounterWiseDataList(
      CounterWiseSummaryResponse? counterWiseSummaryResponse) {
    counterWiseDataList = counterWiseSummaryResponse?.data ?? [];
    tempCounterWiseData = counterWiseDataList;
    if (counterWiseDataList.isNotEmpty) {
      updateLoadState(LoaderState.loaded);
    } else {
      updateLoadState(LoaderState.noData);
    }
    notifyListeners();
  }

  updateFromDate(String date) {
    fromDate = date;
    notifyListeners();
  }

  updateCurrentIndex(int index) {
    currentPageIndex = index;
    notifyListeners();
  }

  @override
  void updateLoadState(LoaderState state) {
    loaderState = state;
    notifyListeners();
  }
}

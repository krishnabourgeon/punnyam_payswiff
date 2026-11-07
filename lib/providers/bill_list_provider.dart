import 'package:flutter/cupertino.dart';
import 'package:punnyam/models/bill_list_response_model.dart';
import 'package:punnyam/services/provider_helper_class.dart';

class BillListProvider extends ChangeNotifier with ProviderHelperClass {
  String? date;
  // int page = 1;
  BillListResponseModel? billListResponseModel;
  List<Bills> billListDataList = [];
  List<Bills> tempBillListDataList = [];
  int totalPageLength = 0;
  int pageCount = 1;
  int currentPageIndex = 0;
  bool right = false;
  bool left = false;
  bool paginationLoader = false;
  PageController pageController = PageController();
  Future<void> getBillList({bool enableLoaderState = true}) async {
    if (enableLoaderState) updateLoadState(LoaderState.loading);
    if (!enableLoaderState) updatePaginationLoader(true);
    try {
      var res = await serviceConfig.getBillList(date ?? '');
      if (res.isValue) {
        billListResponseModel = res.asValue!.value;

        if (billListResponseModel != null) {
          updateBillDataList(billListResponseModel);
          updatePaginationLoader(false);
          paginationLoader = false;
        } else {
          if (enableLoaderState) updateLoadState(LoaderState.loaded);
          paginationLoader = false;
          updatePaginationLoader(false);
        }
      }
    } catch (e) {
      debugPrint('exception in bill list: $e');
      if (enableLoaderState) updateLoadState(LoaderState.loaded);
      paginationLoader = false;
      updatePaginationLoader(false);
    }
    notifyListeners();
  }

  Future<void> loadMoreBills() async {
    if (totalPageLength > pageCount && !paginationLoader) {
      right = true;
      updatePaginationLoader(true);
      updatePageCount(pageCount + 1);
      debugPrint('pagination loader $paginationLoader');
      await getBillList(enableLoaderState: false);
      notifyListeners();
      right = false;
    }
  }

  Future<void> loadless() async {
    if (pageCount != 0 && !paginationLoader) {
      left = true;
      updatePaginationLoader(true);
      updatePageCount(pageCount - 1);
      debugPrint('pagination loader $paginationLoader');
      await getBillList(enableLoaderState: false);
      notifyListeners();
      left = false;
    }
  }

  updateBillDataList(BillListResponseModel? billListResponseModel) {
    // print("pagecount in updatebill.............${pageCount}");
    if (pageCount == 1) {
      // print("count 1...............");
      billListDataList.clear();
      tempBillListDataList.clear();
      billListDataList = billListResponseModel?.list ?? [];
      tempBillListDataList = billListDataList;
      // if (billListDataList.isNotEmpty) {
      //   tempBillListDataList.add(billListDataList);
      //   print(tempBillListDataList);
      // }
    } else {
      //   billListDataList.clear();
      //   tempBillListDataList.clear();
      //   billListDataList = billListResponseModel?.list ?? [];
      //   tempBillListDataList = billListDataList;
      // }
      tempBillListDataList = billListResponseModel?.list ?? [];
      List<Bills> tempBillList = [...billListDataList];
      billListDataList = [
        ...tempBillList,
        ...billListResponseModel?.list ?? []
      ];
    }

    totalPageLength = billListResponseModel?.meta?.lastPage ?? 0;
    if (billListDataList.isNotEmpty) {
      updateLoadState(LoaderState.loaded);
    } else {
      updateLoadState(LoaderState.noData);
    }
    notifyListeners();
  }

  updateFromDate(String fromDate) {
    date = fromDate;
    notifyListeners();
  }

  updateCurrentIndex(int value) {
    currentPageIndex = value;
    notifyListeners();
  }

  removeFromTempList(int index) {
    tempBillListDataList.removeLast();
    notifyListeners();
  }

  clearPageLoader() {
    pageCount = 1;
    totalPageLength = 0;
    billListDataList.clear();
    tempBillListDataList.clear();
    notifyListeners();
  }

  @override
  void updateLoadState(LoaderState state) {
    loaderState = state;
    notifyListeners();
  }

  void updatePaginationLoader(bool value) {
    paginationLoader = value;
    notifyListeners();
  }

  void updatePageCount(int count) {
    pageCount = count;
    notifyListeners();
  }
}

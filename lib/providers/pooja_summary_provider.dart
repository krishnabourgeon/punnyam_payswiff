import 'package:flutter/cupertino.dart';
import 'package:punnyam/models/pooja_summary_response.dart';
import 'package:punnyam/services/provider_helper_class.dart';

class PoojaSummaryProvider extends ChangeNotifier with ProviderHelperClass {
  String? fromDate;
  String? toDate;
  PoojaSummaryResponse? poojaSummaryResponse;
  List<PoojaSummaryData> poojaDataList = [];
  List<PoojaSummaryData> tempPoojaDataList = [];
  bool paginationLoader = false;
  bool left = false;
  bool right = false;
  int pageCount = 1;
  int totalPageLength = 0;
  int currentIndex = 0;
  PageController pageController = PageController();
  Future<void> getPoojaSummary({bool enableLoaderState = true}) async {
    if (enableLoaderState) updateLoadState(LoaderState.loading);
    if (!enableLoaderState) updatePaginationLoader(true);
    try {
      var res =
          await serviceConfig.getPoojaSummary(fromDate ?? '', toDate ?? '');
      if (res.isValue) {
        poojaSummaryResponse = res.asValue!.value;
        if (poojaSummaryResponse != null) {
          updatePoojaDataList(poojaSummaryResponse);
          paginationLoader = false;
          updatePaginationLoader(false);
        } else {
          if (enableLoaderState) updateLoadState(LoaderState.loaded);
          paginationLoader = false;
          updatePaginationLoader(false);
        }
      }
    } catch (e) {
      debugPrint('exception in pooja summary: $e');
      if (enableLoaderState) updateLoadState(LoaderState.loaded);
      paginationLoader = false;
      updatePaginationLoader(false);
    }
    notifyListeners();
  }

  Future<void> loadMorePoojaSummary() async {
    if (totalPageLength > pageCount && !paginationLoader) {
      right = true;
      updatePaginationLoader(true);
      updatePageCount(pageCount + 1);
      debugPrint('pagination loader $paginationLoader');
      await getPoojaSummary(enableLoaderState: false);
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
      await getPoojaSummary(enableLoaderState: false);
      notifyListeners();
      left = false;
    }
  }
  // loadMorePoojaSummary() async {
  //   if (totalPageLength > pageCount && !paginationLoader) {
  //     right = true;
  //     pageCount = pageCount + 1;
  //     await getPoojaSummary(enableLoaderState: false);
  //   }
  //   notifyListeners();
  //   right = false;
  // }

  // loadless() async {
  //   if (pageCount != 0 && !paginationLoader) {
  //     left = true;
  //     pageCount = pageCount - 1;
  //     await getPoojaSummary(enableLoaderState: false);
  //   }
  //   notifyListeners();
  //   left = false;
  // }
  updatePoojaDataList(PoojaSummaryResponse? poojaSummaryResponse) {
    if (pageCount == 1) {
      poojaDataList.clear();
      tempPoojaDataList.clear();
      poojaDataList = poojaSummaryResponse?.data ?? [];
      tempPoojaDataList = poojaDataList;
    } else {
      tempPoojaDataList = poojaSummaryResponse?.data ?? [];
      List<PoojaSummaryData> tempPoojaSummaryDataList = [...poojaDataList];
      poojaDataList = [
        ...tempPoojaSummaryDataList,
        ...poojaSummaryResponse?.data ?? []
      ];
    }
    if (poojaDataList.isNotEmpty) {
      updateLoadState(LoaderState.loaded);
    } else {
      updateLoadState(LoaderState.noData);
    }
    totalPageLength = poojaSummaryResponse?.meta?.lastPage ?? 0;
    notifyListeners();
  }

  updateFromDate(String date) {
    fromDate = date;
    notifyListeners();
  }

  updateToDate(String date) {
    toDate = date;
    notifyListeners();
  }

  updateCurrentIndex(int value) {
    currentIndex = value;
    notifyListeners();
  }

  removeFromTempList(int index) {
    tempPoojaDataList.removeLast();
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

  @override
  void updateLoadState(LoaderState state) {
    loaderState = state;
    notifyListeners();
  }
}

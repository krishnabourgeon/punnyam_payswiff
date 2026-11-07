import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:punnyam/common/color_palette.dart';
import 'package:punnyam/common/common_functions.dart';
import 'package:punnyam/common/date_picker.dart';
import 'package:punnyam/providers/pooja_summary_provider.dart';
import 'package:punnyam/services/provider_helper_class.dart';

class PoojaListTable extends StatefulWidget {
  const PoojaListTable({Key? key}) : super(key: key);
  @override
  State<PoojaListTable> createState() => _PoojaListTableState();
}

class _PoojaListTableState extends State<PoojaListTable> {
  PoojaSummaryProvider? poojaSummaryProvider;
  @override
  void initState() {
    poojaSummaryProvider = PoojaSummaryProvider();
    final DateFormat formatter = DateFormat('y-MM-dd');
    poojaSummaryProvider?.updateFromDate(formatter.format(DateTime.now()));
    poojaSummaryProvider?.updateToDate(formatter.format(DateTime.now()));
    CommonFunctions.afterInit(() {
      poojaSummaryProvider?.getPoojaSummary();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Center(
          child: InkWell(
            onTap: (() => Navigator.pop(context)),
            child: SizedBox(
                height: 25.h,
                width: 25.h,
                child: Image.asset("assets/image/backIcon.png")),
          ),
        ),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.white,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
        title: const Text(
          "Pooja Summary List",
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: ChangeNotifierProvider.value(
        value: poojaSummaryProvider,
        child: Consumer<PoojaSummaryProvider>(
            builder: (context, value, child) =>
                _switchView(poojaSummaryProvider)),
      ),
    );
  }

  _switchView(PoojaSummaryProvider? poojaSummaryProvider) {
    Widget child = const SizedBox.shrink();
    switch (poojaSummaryProvider?.loaderState) {
      case LoaderState.initial:
        break;
      case LoaderState.loaded:
        child = PageView.builder(
            onPageChanged: (value) =>
                poojaSummaryProvider?.updateCurrentIndex(value),
            physics: const NeverScrollableScrollPhysics(),
            controller: poojaSummaryProvider?.pageController,
            itemBuilder: (context, index) {
              return _pageView(poojaSummaryProvider);
            });
        break;
      case LoaderState.loading:
        child = const LinearProgressIndicator();
        break;
      case LoaderState.error:
        break;
      case LoaderState.networkErr:
        child = const Center(
          child: Text('Network Error !'),
        );
        break;
      case LoaderState.noData:
        child = Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Row(
                children: [
                  Flexible(
                    child: PunnyamDatePicker(
                      isEndDate: true,
                      isFirstDate: true,
                      title: poojaSummaryProvider?.fromDate
                              ?.split('-')
                              .reversed
                              .join('-') ??
                          "From Date",
                      onChanged: (date) => poojaSummaryProvider
                        ?..updateFromDate(date)
                        // ..updateCurrentIndex(0)
                        ..getPoojaSummary(),
                    ),
                  ),
                  5.horizontalSpace,
                  Flexible(
                    child: PunnyamDatePicker(
                      isEndDate: true,
                      isFirstDate: true,
                      title: poojaSummaryProvider?.toDate
                              ?.split('-')
                              .reversed
                              .join('-') ??
                          "To Date",
                      onChanged: (date) => poojaSummaryProvider
                        ?..updateToDate(date)
                        ..getPoojaSummary(),
                    ),
                  ),
                ],
              ),
            ),
            const Expanded(
              child: Align(
                alignment: Alignment.center,
                child: Center(
                  child: Text('No Data Found !'),
                ),
              ),
            )
          ],
        );
        break;
    }
    return child;
  }

  _pageView(PoojaSummaryProvider? poojaSummaryProvider) {
    return Stack(
      children: [
        Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Row(
              children: [
                Flexible(
                  child: PunnyamDatePicker(
                    isEndDate: true,
                    isFirstDate: true,
                    title: poojaSummaryProvider?.fromDate
                            ?.split('-')
                            .reversed
                            .join('-') ??
                        "From Date",
                    onChanged: (date) => poojaSummaryProvider
                      ?..updateFromDate(date)
                      ..getPoojaSummary(),
                  ),
                ),
                5.horizontalSpace,
                Flexible(
                  child: PunnyamDatePicker(
                    isEndDate: true,
                    isFirstDate: true,
                    title: poojaSummaryProvider?.toDate
                            ?.split('-')
                            .reversed
                            .join('-') ??
                        "To Date",
                    onChanged: (date) => poojaSummaryProvider
                      ?..updateToDate(date)
                      ..updateCurrentIndex(0)
                      ..getPoojaSummary(),
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 60.h),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              physics: const BouncingScrollPhysics(),
              child: DataTable(
                headingRowHeight: 45.h,
                dataRowMinHeight: 50.h,
                dataRowMaxHeight: 50.h,
                decoration: BoxDecoration(color: ColorPalette.primaryColor),
                border: TableBorder.symmetric(
                  outside: BorderSide(color: Colors.grey, width: .5.w),
                ),
                // columnSpacing: 6,
                columns: const [
                  DataColumn(
                      label: Text(
                    'Pooja Name',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  )),
                  DataColumn(
                      label: Text(
                    'Pooja Count',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  )),
                  DataColumn(
                      label: Text(
                    'Total',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  )),
                ],
                rows: List.generate(
                    poojaSummaryProvider?.poojaSummaryResponse?.data?.length ??
                        0, (index) {
                  // List<PoojaSummaryData>? element=poojaSummaryProvider?.tempPoojaDataList[poojaSummaryProvider.currentIndex??0];
                  return DataRow(
                      color: index % 2 == 0
                          ? MaterialStateProperty.all<Color>(Colors.white)
                          : MaterialStateProperty.all<Color>(
                              Colors.grey.shade100),
                      cells: [
                        DataCell(SizedBox(
                          width: 185.w,
                          child: Text(
                              poojaSummaryProvider?.poojaSummaryResponse
                                      ?.data![index].poojaName ??
                                  '',
                              strutStyle: StrutStyle(height: 1.5.h)),
                        )),
                        DataCell(Center(
                          child: Text(
                              "${poojaSummaryProvider?.poojaSummaryResponse?.data![index].poojaCount ?? ''}"),
                        )),
                        DataCell(Center(
                          child: Text(
                              "${poojaSummaryProvider?.poojaSummaryResponse?.data![index].totalRate ?? ''}"),
                        )),
                      ]);
                }),
              ),
            ),
          ),
        ),
        // Padding(
        //   padding: EdgeInsets.only(bottom: 60.h, right: 10.w),
        //   child: Align(
        //     alignment: Alignment.bottomRight,
        //     child: Row(
        //       mainAxisAlignment: MainAxisAlignment.end,
        //       children: [
        //         FloatingActionButton(
        //           heroTag: 1,
        //           onPressed: () {
        //             // print("count..${poojaSummaryProvider?.pageCount}");
        //             if (poojaSummaryProvider?.currentIndex != 0 &&
        //                 (!poojaSummaryProvider!.paginationLoader)) {
        //               // print("frst");
        //               // print("2nd");
        //               poojaSummaryProvider.loadless().then((value) {
        //                 poojaSummaryProvider.pageController.animateToPage(
        //                     (poojaSummaryProvider.pageCount) - 1,
        //                     duration: const Duration(milliseconds: 200),
        //                     curve: Curves.easeIn);
        //               });
        //               if ((poojaSummaryProvider.tempPoojaDataList.length ?? 0) >
        //                   1) {
        //                 if (kDebugMode) {
        //                   print("count...${poojaSummaryProvider.pageCount}");
        //                 }
        //               }
        //             } else {
        //               Helpers.successToast('There is no previous page');
        //             }
        //           },
        //           child: (poojaSummaryProvider?.left ?? false)
        //               ? SizedBox(
        //                   height: 20.h,
        //                   width: 20.w,
        //                   child: CircularProgressIndicator(
        //                     strokeWidth: 2.w,
        //                     color: Colors.white,
        //                   ),
        //                 )
        //               : Icon(
        //                   Icons.arrow_left_outlined,
        //                   size: 45.h,
        //                 ),
        //         ),
        //         20.horizontalSpace,
        //         FloatingActionButton(
        //             heroTag: 2,
        //             onPressed: () async {
        //               // print("count...${poojaSummaryProvider?.pageCount}");
        //               if ((poojaSummaryProvider?.currentIndex ?? 0) + 1 !=
        //                       poojaSummaryProvider?.totalPageLength &&
        //                   !(poojaSummaryProvider?.paginationLoader ?? false)) {
        //                 // print("frst");
        //                 poojaSummaryProvider
        //                     ?.loadMorePoojaSummary()
        //                     .then((value) {
        //                   // print(
        //                   //     "....${(poojaSummaryProvider.currentIndex) + 1}");
        //                   // print("2nd");
        //                   poojaSummaryProvider.pageController.animateToPage(
        //                       (poojaSummaryProvider.currentIndex) + 1,
        //                       duration: const Duration(milliseconds: 200),
        //                       curve: Curves.easeIn);
        //                 });
        //               } else {
        //                 Helpers.successToast('There is no next page');
        //               }
        //             },
        //             child: (poojaSummaryProvider?.right ?? false)
        //                 ? SizedBox(
        //                     height: 20.h,
        //                     width: 20.w,
        //                     child: CircularProgressIndicator(
        //                       strokeWidth: 2.w,
        //                       color: Colors.white,
        //                     ),
        //                   )
        //                 : Icon(
        //                     Icons.arrow_right_outlined,
        //                     size: 45.h,
        //                   ))
        //       ],
        //     ),
        //   ),
        // ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            color: Colors.green,
            width: double.infinity,
            height: 50.h,
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Gross Total :',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14.sp),
                    ),
                    10.horizontalSpace,
                    Text(
                        poojaSummaryProvider?.poojaSummaryResponse?.grossTotal
                                .toString() ??
                            '0',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14.sp)),
                  ],
                )
              ],
            ),
          ),
        )
      ],
    );
  }
}

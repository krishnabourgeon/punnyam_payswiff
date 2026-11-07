import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:punnyam/common/color_palette.dart';
import 'package:punnyam/common/common_functions.dart';
import 'package:punnyam/common/date_picker.dart';
import 'package:punnyam/providers/counter_wise_summary_provider.dart';
import 'package:punnyam/services/provider_helper_class.dart';

class CounterSummaryTable extends StatefulWidget {
  const CounterSummaryTable({Key? key}) : super(key: key);
  @override
  State<CounterSummaryTable> createState() => _CounterSummaryTableState();
}

class _CounterSummaryTableState extends State<CounterSummaryTable> {
  late CounterWiseSummaryProvider counterWiseSummaryProvider;

  @override
  void initState() {
    counterWiseSummaryProvider = CounterWiseSummaryProvider();
    final DateFormat formatter = DateFormat('y-MM-dd');
    counterWiseSummaryProvider.updateFromDate(formatter.format(DateTime.now()));
    CommonFunctions.afterInit(() {
      counterWiseSummaryProvider.getCounterWiseData();
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
          "Counter Wise List",
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: SafeArea(
        child: ChangeNotifierProvider.value(
          value: counterWiseSummaryProvider,
          child: Consumer<CounterWiseSummaryProvider>(
              builder: (context, value, child) =>
                  _switchView(counterWiseSummaryProvider)),
        ),
      ),
    );
  }

  _switchView(CounterWiseSummaryProvider? counterWiseSummaryProvider) {
    Widget child = const SizedBox.shrink();
    switch (counterWiseSummaryProvider?.loaderState) {
      case LoaderState.initial:
        break;
      case LoaderState.loaded:
        child = PageView.builder(
          onPageChanged: (value) =>
              counterWiseSummaryProvider?.updateCurrentIndex(value),
          physics: const NeverScrollableScrollPhysics(),
          controller: counterWiseSummaryProvider?.pageController,
          itemBuilder: (context, index) =>
              _pageView(counterWiseSummaryProvider),
        );
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
        child = Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: double.maxFinite,
                child: PunnyamDatePicker(
                  isEndDate: true,
                  isFirstDate: true,
                  title: counterWiseSummaryProvider?.fromDate
                          ?.split('-')
                          .reversed
                          .join('-') ??
                      "Date",
                  onChanged: (date) => counterWiseSummaryProvider
                    ?..updateFromDate(date)
                    ..updateCurrentIndex(0)
                    ..getCounterWiseData(),
                ),
              ),
              const Expanded(
                child: Align(
                  alignment: Alignment.center,
                  child: Center(
                    child: Text('No Dat Found !'),
                  ),
                ),
              )
            ],
          ),
        );
        break;
    }
    return child;
  }

  _pageView(CounterWiseSummaryProvider? counterWiseSummaryProvider) {
    return LayoutBuilder(builder: (context, constraints) {
      return Stack(
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: SizedBox(
                width: double.maxFinite,
                // height: 40.h,
                child:
                    // TextDatePicker(
                    //   isEndDate: true,
                    //   isFirstDate: true,
                    //   title: counterWiseSummaryProvider?.fromDate
                    //           ?.split('-')
                    //           .reversed
                    //           .join('-') ??
                    //       "Date",
                    //   onChanged: (date) => counterWiseSummaryProvider
                    //     ?..updateFromDate(date)
                    //     ..updateCurrentIndex(0)
                    //     ..getCounterWiseData(),
                    // )
                    // TextButton(
                    //   child:
                    //   Text(counterWiseSummaryProvider?.fromDate
                    //           ?.split('-')
                    //           .reversed
                    //           .join('-') ??
                    //       'Date'),
                    //   onPressed: () {},
                    // )
                    PunnyamDatePicker(
                  isEndDate: true,
                  isFirstDate: true,
                  title: counterWiseSummaryProvider?.fromDate
                          ?.split('-')
                          .reversed
                          .join('-') ??
                      "Date",
                  onChanged: (date) => counterWiseSummaryProvider
                    ?..updateFromDate(date)
                    ..updateCurrentIndex(0)
                    ..getCounterWiseData(),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 60.h),
              child: SingleChildScrollView(
                // scrollDirection: Axis.horizontal,
                child: DataTable(
                  columnSpacing: constraints.maxWidth / 2.7,
                  decoration: BoxDecoration(color: ColorPalette.primaryColor),
                  border: TableBorder.symmetric(
                    outside: BorderSide(color: Colors.grey, width: .5.w),
                  ),
                  columns: const [
                    DataColumn(
                        label: Text(
                      'Payment Mode',
                      style: TextStyle(color: Colors.white),
                    )),
                    DataColumn(
                        label: Text(
                      'Total',
                      style: TextStyle(color: Colors.white),
                    )),
                  ],
                  rows: List.generate(
                      counterWiseSummaryProvider?.tempCounterWiseData.length ??
                          0, (index) {
                    return DataRow(
                        color: index % 2 == 0
                            ? MaterialStateProperty.all<Color>(Colors.white)
                            : MaterialStateProperty.all<Color>(
                                Colors.grey.shade100),
                        cells: [
                          DataCell(Text(counterWiseSummaryProvider
                                  ?.tempCounterWiseData[index].paymentMode ??
                              '')),
                          DataCell(Center(
                            child: Text(
                              counterWiseSummaryProvider
                                      ?.tempCounterWiseData[index].totalAmount
                                      .toString() ??
                                  '0',
                            ),
                          )),
                        ]);
                  }),
                ),
              ),
            ),
          ),
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
                          counterWiseSummaryProvider
                                  ?.counterWiseSummaryResponse?.totalCollection
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
    });
  }
}

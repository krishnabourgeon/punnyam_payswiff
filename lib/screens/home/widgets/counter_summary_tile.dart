import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:punnyam/common/color_palette.dart';
import 'package:punnyam/common/date_picker.dart';
import 'package:punnyam/models/counter_wise_summary_response.dart';
import 'package:punnyam/providers/counter_wise_summary_provider.dart';
import 'package:punnyam/screens/billing/widgets/preview_bill_row_widget.dart';

class CounterSummaryTile extends StatefulWidget {
  CounterSummaryTile(
      {Key? key,
      required this.counterWiseDataList,
      required this.counterWiseSummaryProvider})
      : super(key: key);
  List<CounterWiseData> counterWiseDataList = [];
  CounterWiseSummaryProvider? counterWiseSummaryProvider;
  @override
  State<CounterSummaryTile> createState() => _CounterSummaryTileState();
}

class _CounterSummaryTileState extends State<CounterSummaryTile> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.w),
            child: PunnyamDatePicker(
              isEndDate: true,
              isFirstDate: true,
              title: widget.counterWiseSummaryProvider?.fromDate
                      ?.split('-')
                      .reversed
                      .join('-') ??
                  "Date",
              onChanged: (date) => widget.counterWiseSummaryProvider
                ?..updateFromDate(date)
                ..getCounterWiseData(),
            )),
        Expanded(
          child: ListView.builder(
            itemCount: widget.counterWiseDataList.length,
            itemBuilder: (context, index) {
              return Container(
                height: 200.h,
                width: double.maxFinite,
                margin: EdgeInsets.symmetric(vertical: 10.h, horizontal: 10.w),
                padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 20.w),
                decoration: BoxDecoration(
                    color: ColorPalette.orange,
                    borderRadius: BorderRadius.circular(20.r)),
                child: Column(
                  children: [
                    PreviewBillRowWidget(
                        labelText: 'Payment Mode',
                        valueText:
                            widget.counterWiseDataList[index].paymentMode ??
                                ''),
                    PreviewBillRowWidget(
                        labelText: 'Total Amount',
                        valueText:
                            widget.counterWiseDataList[index].totalAmount ??
                                '0'),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

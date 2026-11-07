import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:punnyam/common/color_palette.dart';
import 'package:punnyam/common/date_picker.dart';
import 'package:punnyam/models/pooja_summary_response.dart';
import 'package:punnyam/providers/pooja_summary_provider.dart';
import 'package:punnyam/screens/billing/widgets/preview_bill_row_widget.dart';

class PoojaSummaryTile extends StatefulWidget {
  PoojaSummaryTile(
      {Key? key,
      required this.poojaDataList,
      required this.poojaSummaryProvider})
      : super(key: key);
  List<PoojaSummaryData> poojaDataList = [];
  PoojaSummaryProvider? poojaSummaryProvider;
  @override
  State<PoojaSummaryTile> createState() => _PoojaSummaryTileState();
}

class _PoojaSummaryTileState extends State<PoojaSummaryTile> {
  late ScrollController scrollController;
  @override
  void initState() {
    scrollController = ScrollController()
      ..addListener(() {
        if (scrollController.offset >=
            (scrollController.position.maxScrollExtent * 0.75)) {
          widget.poojaSummaryProvider?.loadMorePoojaSummary();
        }
      });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Row(
            children: [
              Flexible(
                child: PunnyamDatePicker(
                  isEndDate: true,
                  isFirstDate: true,
                  title: widget.poojaSummaryProvider?.fromDate
                          ?.split('-')
                          .reversed
                          .join('-') ??
                      "From Date",
                  onChanged: (date) => widget.poojaSummaryProvider
                    ?..updateFromDate(date)
                    ..getPoojaSummary(),
                ),
              ),
              5.horizontalSpace,
              Flexible(
                child: PunnyamDatePicker(
                  isEndDate: true,
                  isFirstDate: true,
                  title: widget.poojaSummaryProvider?.toDate
                          ?.split('-')
                          .reversed
                          .join('-') ??
                      "To Date",
                  onChanged: (date) => widget.poojaSummaryProvider
                    ?..updateToDate(date)
                    ..getPoojaSummary(),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: widget.poojaDataList.length,
            itemBuilder: (context, index) {
              return Container(
                height: 200.h,
                margin: EdgeInsets.symmetric(vertical: 10.h, horizontal: 10.w),
                padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 20.w),
                decoration: BoxDecoration(
                    color: ColorPalette.orange,
                    borderRadius: BorderRadius.circular(20.r)),
                child: Column(
                  children: [
                    PreviewBillRowWidget(
                        labelText: 'Pooja Name',
                        valueText: widget.poojaDataList[index].poojaName ?? ''),
                    PreviewBillRowWidget(
                        labelText: 'Pooja Count',
                        valueText:
                            widget.poojaDataList[index].poojaCount.toString()),
                    PreviewBillRowWidget(
                        labelText: 'Total',
                        valueText:
                            widget.poojaDataList[index].totalRate.toString()),
                  ],
                ),
              );
            },
          ),
        )
      ],
    );
  }
}

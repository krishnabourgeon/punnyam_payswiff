import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:punnyam/common/color_palette.dart';
import 'package:punnyam/models/bill_list_response_model.dart';
import 'package:punnyam/providers/bill_list_provider.dart';
import 'package:punnyam/screens/billing/widgets/preview_bill_row_widget.dart';

import '../../../common/date_picker.dart';

class BillTile extends StatefulWidget {
  BillTile(
      {Key? key, required this.billListData, required this.billListProvider})
      : super(key: key);
  List<Bills> billListData = [];
  BillListProvider? billListProvider;

  @override
  State<BillTile> createState() => _BillTileState();
}

class _BillTileState extends State<BillTile> {
  late ScrollController scrollController;
  @override
  void initState() {
    scrollController = ScrollController()
      ..addListener(() {
        if (scrollController.offset >=
            (scrollController.position.maxScrollExtent * 0.75)) {
          widget.billListProvider?.loadMoreBills();
        }
      });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.w),
          child: PunnyamDatePicker(
            isEndDate: true,
            isFirstDate: true,
            title:
                widget.billListProvider?.date?.split('-').reversed.join('-') ??
                    "Date",
            onChanged: (date) => widget.billListProvider
              ?..updateFromDate(date)
              ..getBillList(),
          ),
        ),
        Expanded(
          child: ListView.builder(
            controller: scrollController,
            shrinkWrap: true,
            itemCount: widget.billListData.length,
            itemBuilder: (context, index) {
              return Container(
                height: 250.h,
                width: double.maxFinite,
                margin: EdgeInsets.symmetric(vertical: 10.h, horizontal: 10.w),
                padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 20.w),
                decoration: BoxDecoration(
                    color: ColorPalette.orange,
                    borderRadius: BorderRadius.circular(20.r)),
                child: Column(
                  children: [
                    PreviewBillRowWidget(
                        labelText: 'Bill ID',
                        valueText:
                            widget.billListData[index].billId.toString()),
                    PreviewBillRowWidget(
                        labelText: 'Bill Date',
                        valueText: widget.billListData[index].billDate
                                ?.split('-')
                                .reversed
                                .join('-') ??
                            '0'),
                    PreviewBillRowWidget(
                        labelText: 'Counter',
                        valueText: widget.billListData[index].counter ??
                            '0'.toString()),
                    PreviewBillRowWidget(
                        labelText: 'Devotee',
                        valueText: widget.billListData[index].devotee ?? ''),
                    PreviewBillRowWidget(
                        labelText: 'Total',
                        valueText:
                            widget.billListData[index].total ?? '0'.toString()),
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

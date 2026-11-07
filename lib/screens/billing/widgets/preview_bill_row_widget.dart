import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PreviewBillRowWidget extends StatelessWidget {
  const PreviewBillRowWidget(
      {Key? key, required this.labelText, required this.valueText})
      : super(key: key);
  final String? labelText;
  final String? valueText;
  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: Row(
      children: [
        Flexible(
            flex: 3,
            fit: FlexFit.tight,
            child: Text(
              labelText ?? '',
              style: TextStyle(fontSize: 17.sp),
            )),
        Flexible(
            flex: 2,
            child: Text(
              ':',
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
            )),
        5.horizontalSpace,
        Flexible(
          fit: FlexFit.tight,
          flex: 6,
          child: Text(
            valueText ?? '',
            style: TextStyle(fontSize: 17.sp, overflow: TextOverflow.ellipsis),
            maxLines: 1,
          ),
        ),
      ],
    ));
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LoadingDropDown extends StatelessWidget {
  const LoadingDropDown({Key? key, this.title}) : super(key: key);
  final String? title;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 45.h,
      width: double.maxFinite,
      padding: EdgeInsets.only(left: 13.w, right: 11.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(40.r),
        color: Colors.grey.shade200,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title ?? '',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey.shade600,
            ),
          ),
          Icon(
            Icons.arrow_drop_down,
            size: 24,
            color: Colors.grey.shade600,
          )
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:punnyam/common/color_palette.dart';

class SelectCard extends StatelessWidget {
  final String? title;
  final void Function()? onTap;
  const SelectCard({super.key, this.title, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(25.r),
      highlightColor: Colors.white,
      hoverColor: Colors.white,
      splashColor: Colors.white,
      onTap: onTap,
      child: Container(
          height: 150.h,
          width: 150.w,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25.r),
              gradient: LinearGradient(
                  colors: [ColorPalette.primaryColor, ColorPalette.orange])),
          child: Center(
              child: Text(
            title ?? "title",
            style: TextStyle(color: Colors.white, fontSize: 18.sp),
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ))),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:punnyam/common/color_palette.dart';

class CommonButton extends StatelessWidget {
  final Widget? child;
  final String? title;
  final Gradient? gradient;
  final double? width;
  final double? height;
  final List<Color>? colors;
  final Function()? onPressed;
  final bool? isLoading;
  final EdgeInsetsGeometry? margin;
  const CommonButton(
      {Key? key,
      this.child,
      this.gradient,
      this.width = double.infinity,
      this.height = 50.0,
      this.onPressed,
      this.title,
      this.colors,
      this.isLoading = false,
      this.margin})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height ?? 50.h,
      margin: margin ?? EdgeInsets.symmetric(vertical: 10.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30.r),
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          stops: const [.1, 3],
          colors: colors ??
              <Color>[
                onPressed != null
                    ? ColorPalette.orange
                    : ColorPalette.orange.withOpacity(.5),
                onPressed != null
                    ? ColorPalette.primaryColor
                    : ColorPalette.primaryColor.withOpacity(.5),
              ],
        ),
        // boxShadow: [
        //   BoxShadow(
        //     color: Colors.grey.shade500,
        //     offset: const Offset(0.0, 1.5),
        //     blurRadius: 1.5,
        //   ),
        // ]
      ),
      child: (isLoading ?? false)
          ? Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 5.h),
                child: const CircularProgressIndicator(
                  color: Colors.white,
                ),
              ),
            )
          : Material(
              color: Colors.transparent,
              child: InkWell(
                  highlightColor: ColorPalette.orange,
                  splashColor: Colors.white,
                  hoverColor: Colors.white,
                  borderRadius: BorderRadius.circular(30.r),
                  onTap: (isLoading ?? false) ? null : onPressed,
                  child: Center(
                    child: child ??
                        Text(
                          title ?? "Button",
                          style: const TextStyle(color: Colors.white),
                        ),
                  )),
            ),
    );
  }
}

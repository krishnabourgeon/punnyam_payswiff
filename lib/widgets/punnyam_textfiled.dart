import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PunnyamTextField extends StatefulWidget {
  final String hintText;
  final IconData? prefixIcon;
  final bool makePasswordField;
  final TextEditingController? textEditingController;
  final Function(String value)? onChanged;
  final TextInputAction? textInputAction;
  final TextStyle? hintStyle;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatter;
  final bool? isEnabled;
  final int? maxLength;
  final EdgeInsets? contentpadding;

  final double? height;
  final double? width;
  const PunnyamTextField(
      {super.key,
      this.hintText = "test",
      this.prefixIcon,
      this.contentpadding,
      this.makePasswordField = false,
      this.textEditingController,
      this.onChanged,
      this.textInputAction,
      this.hintStyle,
      this.keyboardType,
      this.inputFormatter,
      this.isEnabled,
      this.maxLength,
      this.height,
      this.width,
      required});
  @override
  State<PunnyamTextField> createState() => _PunnyamTextFieldState();
}

class _PunnyamTextFieldState extends State<PunnyamTextField> {
  bool enableObscure = true;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height ?? 55.h,
      width: widget.width ?? MediaQuery.of(context).size.width,
      padding: EdgeInsets.symmetric(horizontal: 10.w),
      decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(17.r)),
      child: Center(
        child: TextFormField(
            maxLength: widget.maxLength,
            enabled: widget.isEnabled ?? true,
            inputFormatters: widget.inputFormatter,
            controller: widget.textEditingController,
            obscureText: widget.makePasswordField ? enableObscure : false,
            onChanged: widget.onChanged,
            textInputAction: widget.textInputAction ?? TextInputAction.next,
            keyboardType: widget.keyboardType ?? TextInputType.name,
            decoration: InputDecoration(
                contentPadding: widget.contentpadding,
                counterText: '',
                focusColor: Colors.black,
                hintText: widget.hintText,
                hintStyle: widget.hintStyle ?? TextStyle(fontSize: 15.sp),
                border: InputBorder.none,
                prefixIcon: widget.prefixIcon != null
                    ? Icon(
                        widget.prefixIcon,
                        color: Colors.grey.shade600,
                      )
                    : null,
                suffixIcon: widget.makePasswordField
                    ? Padding(
                        padding: EdgeInsets.only(right: 8.w),
                        child: IconButton(
                          highlightColor: Colors.white,
                          splashColor: Colors.white,
                          icon: Icon(
                            enableObscure
                                ? Icons.visibility_off
                                : Icons.visibility,
                            size: 20.r,
                            color: enableObscure
                                ? Colors.grey.shade700
                                : Colors.grey.shade700,
                          ),
                          onPressed: () => setState(() {
                            enableObscure = !enableObscure;
                          }),
                        ),
                      )
                    : null)),
      ),
    );
  }
}

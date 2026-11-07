import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:punnyam/common/color_palette.dart';

class CommonTextField extends StatefulWidget {
  final String? labelText;
  final String hintText;
  final TextInputType? inputType;
  final Function? validator;
  final Function? onTap;
  final Function? onEditingComplete;
  final bool isObscure;
  final Widget? prefix;
  final TextStyle? hintFontStyle;
  final Function? onSaved;
  final Function? onChanged;
  final TextInputAction? inputAction;
  final int? maxLines;
  final int? maxLength;
  final bool autoFocus;
  final TextEditingController? controller;
  final List<TextInputFormatter>? inputFormatters;
  final bool defaultFont;
  final bool removeOutlineBorder;
  const CommonTextField(
      {Key? key,
      this.hintText = '',
      this.labelText,
      this.prefix,
      this.inputType,
      this.validator,
      this.hintFontStyle,
      this.onTap,
      this.onEditingComplete,
      this.autoFocus = false,
      this.isObscure = false,
      this.onSaved,
      this.onChanged,
      this.inputAction,
      this.inputFormatters,
      this.controller,
      this.maxLength,
      this.maxLines,
      this.defaultFont = true,
      this.removeOutlineBorder = false})
      : super(key: key);

  @override
  State<CommonTextField> createState() => _CommonTextFieldState();
}

class _CommonTextFieldState extends State<CommonTextField> {
  bool enableLabel = false;
  bool enableObscure = true;

  @override
  Widget build(BuildContext context) {
    final outlinedBorder = OutlineInputBorder(
        borderRadius: BorderRadius.circular(25.0.r),
        borderSide: BorderSide.none);

    final outlinedErrorBorder = !widget.removeOutlineBorder
        ? OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.all(Radius.circular(25.r)))
        : null;

    return TextFormField(
        controller: widget.controller,
        onChanged:
            widget.onChanged != null ? (val) => widget.onChanged!(val) : null,
        onTap: () => setState(() {
              enableLabel = true;
            }),
        obscureText: widget.isObscure ? enableObscure : false,
        inputFormatters: widget.inputFormatters,
        maxLength: widget.maxLength,
        keyboardType: widget.inputType,
        autofocus: widget.autoFocus,
        validator: widget.validator == null
            ? (val) {
                return null;
              }
            : (val) => widget.validator!(val),
        decoration: InputDecoration(
            fillColor: ColorPalette.grey,
            filled: true,
            border: outlinedBorder,
            counterText: "",
            focusedBorder: outlinedBorder,
            contentPadding: EdgeInsets.only(
                bottom: 13.h, left: 20.w, right: 15.w, top: 15.h),
            errorBorder: outlinedErrorBorder,
            errorMaxLines: 3,
            // labelStyle: FontStyle.primary12Medium,
            hintText: widget.hintText,
            // hintStyle: widget.hintFontStyle ?? FontStyle.grey15Medium,
            prefix: widget.prefix,
            suffixIcon: widget.isObscure
                ? Padding(
                    padding: EdgeInsets.only(right: 8.w),
                    child: IconButton(
                      icon: Icon(
                        enableObscure ? Icons.visibility_off : Icons.visibility,
                        size: 20.r,
                        color: enableObscure
                            ? ColorPalette.primaryColor
                            : ColorPalette.primaryColor,
                      ),
                      onPressed: () => setState(() {
                        enableObscure = !enableObscure;
                      }),
                    ),
                  )
                : null));
  }
}

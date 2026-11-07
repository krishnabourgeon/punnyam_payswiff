import 'package:flutter/material.dart';

import 'package:intl/intl.dart';
import 'package:punnyam/common/color_palette.dart';

class TextDatePicker extends StatefulWidget {
  final String? title;
  final void Function(String date)? onChanged;
  final bool? isFromDate;
  final bool? isFirstDate;
  final bool? isEndDate;
  const TextDatePicker(
      {super.key,
      this.onChanged,
      this.title,
      this.isFromDate,
      this.isFirstDate,
      this.isEndDate});
  @override
  State<TextDatePicker> createState() => _TextDatePickerState();
}

class _TextDatePickerState extends State<TextDatePicker> {
  String? pickedDate;
  final DateFormat formatter = DateFormat('y-MM-dd');
  DateTime selectedDate = DateTime.now();
  _selectDate(BuildContext context) async {
    final DateTime? selected = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: (widget.isFirstDate ?? false)
            ? DateTime(1900)
            : DateTime.now().subtract(const Duration(days: 0)),
        lastDate: (widget.isEndDate ?? false) ? DateTime.now() : DateTime(2100),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.light(
                primary: ColorPalette.orange,
              ),
            ),
            child: child!,
          );
        });
    if (selected != null) {
      selectedDate = selected;
      pickedDate = formatter.format(selectedDate);
      if (widget.onChanged != null) {
        widget.onChanged!(pickedDate!);
      }
      setState(() {});
      debugPrint('$selected');
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () async {
        await _selectDate(context);
      },
      child: Text(
        widget.title == null
            ? (widget.isFromDate ?? true)
                ? 'From Date'
                : 'Date'
            : widget.title!,
        //  (pickedDate ?? widget.title ?? ""),
        // style: TextStyle(
        //     color: widget.title != null ? Colors.black : Colors.grey.shade600),
      ),
    );
    //   InkWell(
    //   onTap: () async {
    //     await _selectDate(context);
    //   },
    //   child: Container(
    //     width: double.maxFinite,
    //     height: 45.h,
    //     decoration: BoxDecoration(
    //         color: Colors.grey.shade200,
    //         borderRadius: BorderRadius.circular(30.r)),
    //     child: Column(
    //       crossAxisAlignment: CrossAxisAlignment.start,
    //       mainAxisAlignment: MainAxisAlignment.center,
    //       children: [
    //         Padding(
    //           padding: EdgeInsets.symmetric(horizontal: 20.w),
    //           child: Text(
    //             widget.title == null
    //                 ? (widget.isFromDate ?? true)
    //                 ? 'From Date'
    //                 : 'Date'
    //                 : widget.title!,
    //             //  (pickedDate ?? widget.title ?? ""),
    //             style: TextStyle(
    //                 color: widget.title != null
    //                     ? Colors.black
    //                     : Colors.grey.shade600),
    //           ),
    //         ),
    //       ],
    //     ),
    //   ),
    // );
  }
}

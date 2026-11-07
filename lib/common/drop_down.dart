import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PunnyamDropDown extends StatefulWidget {
  final void Function(String val)? getCorrespondValue;
  final String? title;
  final List<String> items;
  const PunnyamDropDown(
      {super.key, this.getCorrespondValue, this.title, required this.items});
  @override
  State<PunnyamDropDown> createState() => _PunnyamDropDownState();
}

class _PunnyamDropDownState extends State<PunnyamDropDown> {
  String? selectedValue;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.maxFinite,
      child: DropdownButtonHideUnderline(
        child: InkWell(
          child: DropdownButton2(
            // dropdownFullScreen: true,
            alignment: Alignment.center,
            isExpanded: true,
            dropdownMaxHeight: 500.h,
            hint: Row(
              children: [
                // Icon(
                //   Icons.list,
                //   size: 16,
                //   color: Colors.black,
                // ),
                SizedBox(
                  width: 4.w,
                ),
                Expanded(
                  child: Text(
                    widget.title ?? '',
                    style: (widget.title ?? '').isNotEmpty
                        ? TextStyle(
                            fontSize: 14.sp,
                            // fontWeight: FontWeight.bold,
                          )
                        : TextStyle(
                            fontSize: 14.sp,
                            // fontWeight: FontWeight.bold,
                            color: Colors.grey.shade600,
                          ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            //value: widget.title??'',
            items: widget.items
                .map((item) => DropdownMenuItem<String>(
                      value: item,
                      child: Text(
                        item,
                        // style: const TextStyle(
                        //   fontSize: 12,
                        //   // fontWeight: FontWeight.bold,
                        //   color: Colors.black,
                        // ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ))
                .toList(),
            // value: null,
            onChanged: (value) {
              setState(() {
                selectedValue = value as String;
                if (widget.getCorrespondValue != null) {
                  widget.getCorrespondValue!(selectedValue ?? "");
                }
              });
            },
            icon: const Icon(
              Icons.arrow_drop_down_sharp,
            ),
            iconSize: 20,
            iconEnabledColor: Colors.black,
            iconDisabledColor: Colors.grey,
            buttonHeight: 50.h,
            buttonWidth: 160.w,
            buttonPadding: const EdgeInsets.only(left: 14, right: 14),
            buttonDecoration: BoxDecoration(
              borderRadius: BorderRadius.circular(40.r),
              color: Colors.grey.shade200,
            ),
            buttonElevation: 0,
            itemHeight: 40,
            dropdownDecoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20.r),
              color: Colors.grey.shade200,
              border: Border.all(
                color: Colors.black12,
              ),
            ),
            dropdownElevation: 20,
            scrollbarRadius: Radius.circular(30.r),
            scrollbarThickness: 6,
            scrollbarAlwaysShow: true,
          ),
        ),
      ),
    );
  }
}

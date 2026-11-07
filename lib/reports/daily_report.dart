import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:punnyam/common/color_palette.dart';
import 'package:punnyam/common/date_picker.dart';

class DailyReport extends StatefulWidget {
  const DailyReport({super.key});
  @override
  State<DailyReport> createState() => _DailyReportState();
}

class _DailyReportState extends State<DailyReport> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Center(
          child: InkWell(
            onTap: (() => Navigator.pop(context)),
            child: SizedBox(
                height: 25.h,
                width: 25.h,
                child: Image.asset("assets/image/backIcon.png")),
          ),
        ),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.white,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
        title: const Text(
          "Daily Collection",
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Row(
                  children: [
                    Flexible(
                      child: PunnyamDatePicker(
                        title: "From Date",
                        onChanged: (date) => debugPrint(date),
                      ),
                    ),
                    5.horizontalSpace,
                    Flexible(
                      child: PunnyamDatePicker(
                        title: "To Date",
                        onChanged: (date) => debugPrint(date),
                      ),
                    ),
                  ],
                ),
              ),
              20.verticalSpace,
              Container(
                margin: EdgeInsets.symmetric(horizontal: 20.w),
                padding: EdgeInsets.all(20.w),
                height: 200.h,
                width: double.maxFinite,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.r),
                  color: ColorPalette.orange,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Counter 1",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    5.verticalSpace,
                    const Text(
                      "Cash: 4500",
                      style: TextStyle(color: Colors.white),
                    ),
                    5.verticalSpace,
                    const Text(
                      "QR: 10",
                      style: TextStyle(color: Colors.white),
                    ),
                    5.verticalSpace,
                    const Text(
                      "Postal : 0",
                      style: TextStyle(color: Colors.white),
                    ),
                    5.verticalSpace,
                    const Text(
                      "NEFT: 10",
                      style: TextStyle(color: Colors.white),
                    ),
                    5.verticalSpace,
                    const Text(
                      "Others: 10",
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
              20.verticalSpace,
              Container(
                margin: EdgeInsets.symmetric(horizontal: 20.w),
                padding: EdgeInsets.all(20.w),
                height: 200.h,
                width: double.maxFinite,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.r),
                  color: ColorPalette.orange,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Counter 1",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    5.verticalSpace,
                    const Text(
                      "Cash: 4500",
                      style: TextStyle(color: Colors.white),
                    ),
                    5.verticalSpace,
                    const Text(
                      "QR: 10",
                      style: TextStyle(color: Colors.white),
                    ),
                    5.verticalSpace,
                    const Text(
                      "Postal : 0",
                      style: TextStyle(color: Colors.white),
                    ),
                    5.verticalSpace,
                    const Text(
                      "NEFT: 10",
                      style: TextStyle(color: Colors.white),
                    ),
                    5.verticalSpace,
                    const Text(
                      "Others: 10",
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Container(
            height: 100.h,
            width: double.maxFinite,
            color: Colors.green,
            padding: EdgeInsets.all(20.w),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Total Cash: 9000 ",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.white),
                ),
                Text(
                  "Total Booking: 10000 ",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

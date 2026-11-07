import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:punnyam/common/select_card.dart';
import 'package:punnyam/screens/home/home.dart';

class SelectCounter extends StatefulWidget {
  const SelectCounter({super.key});
  @override
  State<SelectCounter> createState() => _SelectCounterState();
}

class _SelectCounterState extends State<SelectCounter> {
  List<String> counters = [
    "counter 1",
    "Counter 2",
  ];
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
          "Choose Counter",
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SizedBox(
              width: double.maxFinite,
              child: GridView.count(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  crossAxisCount: 2,
                  crossAxisSpacing: 5.w,
                  mainAxisSpacing: 5.w,
                  children: List.generate(counters.length, (index) {
                    return Center(
                      child: SelectCard(
                        title: counters[index],
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const Home(),
                              ));
                        },
                      ),
                    );
                  })),
            ),
          )
        ],
      ),
    );
  }
}

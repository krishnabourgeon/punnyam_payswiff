import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:punnyam/common/common_functions.dart';
import 'package:punnyam/providers/counter_wise_summary_provider.dart';
import 'package:punnyam/screens/home/widgets/counter_summary_tile.dart';
import 'package:punnyam/services/provider_helper_class.dart';

class CounterSummaryScreen extends StatefulWidget {
  const CounterSummaryScreen({Key? key}) : super(key: key);
  @override
  State<CounterSummaryScreen> createState() => _CounterSummaryScreenState();
}

class _CounterSummaryScreenState extends State<CounterSummaryScreen> {
  CounterWiseSummaryProvider? counterWiseSummaryProvider;

  @override
  void initState() {
    counterWiseSummaryProvider = CounterWiseSummaryProvider();
    final DateFormat formatter = DateFormat('y-MM-dd');
    counterWiseSummaryProvider
        ?.updateFromDate(formatter.format(DateTime.now()));
    CommonFunctions.afterInit(() {
      counterWiseSummaryProvider?.getCounterWiseData();
    });
    super.initState();
  }

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
          "Counter Summary",
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: ChangeNotifierProvider.value(
        value: counterWiseSummaryProvider,
        child: Consumer<CounterWiseSummaryProvider>(
          builder: (context, value, child) =>
              _switchView(counterWiseSummaryProvider),
        ),
      ),
    );
  }

  _switchView(CounterWiseSummaryProvider? counterWiseSummaryProvider) {
    Widget child = const SizedBox.shrink();
    switch (counterWiseSummaryProvider?.loaderState) {
      case LoaderState.initial:
        break;
      case LoaderState.loaded:
        child = CounterSummaryTile(
            counterWiseSummaryProvider: counterWiseSummaryProvider,
            counterWiseDataList:
                counterWiseSummaryProvider?.counterWiseDataList ?? []);
        break;
      case LoaderState.loading:
        child = const LinearProgressIndicator();
        break;
      case LoaderState.error:
        break;
      case LoaderState.networkErr:
        child = const Center(
          child: Text('Network Error !'),
        );
        break;
      case LoaderState.noData:
        child = const Center(
          child: Text('No Counter Summary Found !'),
        );
        break;
    }
    return child;
  }
}

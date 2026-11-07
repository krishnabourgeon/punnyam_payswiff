import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:punnyam/common/common_functions.dart';
import 'package:punnyam/common/date_picker.dart';
import 'package:punnyam/providers/pooja_summary_provider.dart';
import 'package:punnyam/screens/home/widgets/pooja_summary_tile.dart';
import 'package:punnyam/services/provider_helper_class.dart';

class PoojaSummaryScreen extends StatefulWidget {
  const PoojaSummaryScreen({Key? key}) : super(key: key);
  @override
  State<PoojaSummaryScreen> createState() => _PoojaSummaryScreenState();
}

class _PoojaSummaryScreenState extends State<PoojaSummaryScreen> {
  PoojaSummaryProvider? poojaSummaryProvider;
  @override
  void initState() {
    poojaSummaryProvider = PoojaSummaryProvider();
    final DateFormat formatter = DateFormat('y-MM-dd');
    poojaSummaryProvider?.updateFromDate(formatter.format(DateTime.now()));
    poojaSummaryProvider?.updateToDate(formatter.format(DateTime.now()));
    CommonFunctions.afterInit(() {
      poojaSummaryProvider?.getPoojaSummary();
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
          "Pooja Summary",
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: ChangeNotifierProvider.value(
        value: poojaSummaryProvider,
        child: Consumer<PoojaSummaryProvider>(builder: (context, value, child) {
          return _switchView(poojaSummaryProvider);
        }),
      ),
    );
  }

  _switchView(PoojaSummaryProvider? poojaSummaryProvider) {
    Widget child = const SizedBox.shrink();
    switch (poojaSummaryProvider?.loaderState) {
      case LoaderState.initial:
        break;
      case LoaderState.loaded:
        child = Stack(
          children: [
            PoojaSummaryTile(
              poojaDataList: poojaSummaryProvider?.poojaDataList ?? [],
              poojaSummaryProvider: poojaSummaryProvider,
            ),
            if (poojaSummaryProvider?.paginationLoader ?? false)
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 20.h),
                  child: const CircularProgressIndicator(
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        );
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
        child = Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Row(
                children: [
                  Flexible(
                    child: PunnyamDatePicker(
                      isFirstDate: true,
                      title: poojaSummaryProvider?.fromDate
                              ?.split('-')
                              .reversed
                              .join('-') ??
                          "From Date",
                      onChanged: (date) => poojaSummaryProvider
                        ?..updateFromDate(date)
                        ..getPoojaSummary(),
                    ),
                  ),
                  5.horizontalSpace,
                  Flexible(
                    child: PunnyamDatePicker(
                      isFirstDate: true,
                      title: poojaSummaryProvider?.toDate
                              ?.split('-')
                              .reversed
                              .join('-') ??
                          "To Date",
                      onChanged: (date) => poojaSummaryProvider
                        ?..updateToDate(date)
                        ..getPoojaSummary(),
                    ),
                  ),
                ],
              ),
            ),
            40.verticalSpace,
            const Text('No Pooja Summary Found !'),
          ],
        );
        break;
    }
    return child;
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:punnyam/common/common_functions.dart';
import 'package:punnyam/providers/bill_list_provider.dart';
import 'package:punnyam/screens/home/widgets/bill_tile.dart';
import 'package:punnyam/services/provider_helper_class.dart';

class BillListingScreen extends StatefulWidget {
  const BillListingScreen({Key? key}) : super(key: key);
  @override
  State<BillListingScreen> createState() => _BillListingScreenState();
}

class _BillListingScreenState extends State<BillListingScreen> {
  BillListProvider? billListProvider;
  @override
  void initState() {
    billListProvider = BillListProvider();
    final DateFormat formatter = DateFormat('y-MM-dd');
    billListProvider?.updateFromDate(formatter.format(DateTime.now()));
    CommonFunctions.afterInit(() => billListProvider?.getBillList());
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
          "Bill List",
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: ChangeNotifierProvider.value(
        value: billListProvider,
        child: Consumer<BillListProvider>(
          builder: (context, value, child) {
            return _switchView(billListProvider);
          },
        ),
      ),
    );
  }

  _switchView(BillListProvider? billListProvider) {
    Widget child = const SizedBox.shrink();
    switch (billListProvider?.loaderState) {
      case LoaderState.initial:
        break;
      case LoaderState.loaded:
        child = Stack(
          children: [
            BillTile(
              billListData: billListProvider?.billListDataList ?? [],
              billListProvider: billListProvider,
            ),
            if (billListProvider?.paginationLoader ?? false)
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
        // print("no data found...........");
        child = const Center(
          child: Text('No Bills Found !'),
        );
        break;
    }
    return child;
  }
}

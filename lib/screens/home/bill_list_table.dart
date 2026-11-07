// ignore_for_file: deprecated_member_use

// import 'package:bluetooth_print/bluetooth_print.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:punnyam/common/color_palette.dart';
import 'package:punnyam/common/common_functions.dart';
import 'package:punnyam/common/date_picker.dart';
import 'package:punnyam/providers/bill_list_provider.dart';
import 'package:punnyam/services/provider_helper_class.dart';

class BillListTable extends StatefulWidget {
  const BillListTable({Key? key}) : super(key: key);
  @override
  State<BillListTable> createState() => _BillListTableState();
}

class _BillListTableState extends State<BillListTable> {
  // BluetoothPrint bluetoothPrint = BluetoothPrint.instance;
  BillListProvider? billListProvider;
  // BlueThermalPrinter bluetoothPrinter = BlueThermalPrinter.instance;
  // bool _connected = false;
  // void connectToPrinter() async {
  //   print("object");
  //   bool isConnected = await bluetoothPrinter.isConnected ?? false;
  //   if (!isConnected) {
  //     List<BluetoothDevice> devices = await bluetoothPrinter.getBondedDevices();
  //     print("............${devices.length}");
  //     // Find your printer device in the list
  //     BluetoothDevice printerDevice = devices.firstWhere(
  //       (device) => device.name == 'Printer_9469',
  //       orElse: () => throw Exception('Printer device not found'),
  //     );
  //     bool isPrinterConnected = await bluetoothPrinter.connect(printerDevice);
  //     if (isPrinterConnected) {
  //       print("connectyed....................");
  //       // Printer is now connected, perform necessary operations.
  //     } else {
  //       print("not conect.......................");
  //       // Handle connection failure.
  //     }
  //   } else {
  //     print("settttttt");
  //     // Printer is already connected, perform necessary operations.
  //   }
  // }

  // The Bluetooth device you want to connect to
  // BluetoothDevice? _device;
  // String tips = 'no device connect';
  // BillDetailsProvider? billDetailsProvider;
  // Future<void> initBluetooth() async {
  //   print("inside");
  //   bluetoothPrint.startScan(
  //     timeout: const Duration(seconds: 4),
  //   );
  //   print(_device?.name);

  //   // if (_device?.address == 'DC:0D:30:5F:94:69') {
  //   //   print("correct");
  //   // await bluetoothPrint.connect("DC:0D:30:5F:94:69");
  //   //   Helpers.successToast("connect function");
  //   // } else {
  //   //   print("not");
  //   // }

  //   bluetoothPrint.state.listen((state) {
  //     print('******************* cur device status: $state');

  //     switch (state) {
  //       case BluetoothPrint.CONNECTED:
  //         setState(() {
  //           _connected = true;
  //           tips = 'connect success';
  //         });
  //         Helpers.successToast(tips);
  //         break;
  //       case BluetoothPrint.DISCONNECTED:
  //         setState(() {
  //           _connected = false;
  //           tips = 'disconnect success';
  //         });
  //         Helpers.successToast(tips);
  //         break;
  //       default:
  //         break;
  //     }
  //   });
  // }

  @override
  void initState() {
    billListProvider = BillListProvider();
    // billDetailsProvider = BillDetailsProvider();
    final DateFormat formatter = DateFormat('y-MM-dd');
    billListProvider?.updateFromDate(formatter.format(DateTime.now()));
    CommonFunctions.afterInit(() => billListProvider?.getBillList());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
            builder: (context, value, child) => _switchView(value)),
      ),
    );
  }

  _switchView(BillListProvider? billListProvider) {
    Widget child = const SizedBox();
    switch (billListProvider?.loaderState) {
      case LoaderState.initial:
        break;
      case LoaderState.loaded:
        child = PageView.builder(
            itemCount: billListProvider?.tempBillListDataList.length,
            onPageChanged: (value) =>
                billListProvider?.updateCurrentIndex(value),
            physics: const NeverScrollableScrollPhysics(),
            controller: billListProvider?.pageController,
            itemBuilder: (context, index) {
              return _pageView(billListProvider);
            });
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
        child = Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: double.maxFinite,
                child: PunnyamDatePicker(
                  isEndDate: true,
                  isFirstDate: true,
                  title:
                      billListProvider?.date?.split('-').reversed.join('-') ??
                          "Date",
                  onChanged: (date) => billListProvider
                    ?..updateFromDate(date)
                    ..updateCurrentIndex(0)
                    ..clearPageLoader()
                    ..getBillList(),
                ),
              ),
              const Expanded(
                child: Align(
                  alignment: Alignment.center,
                  child: Center(
                    child: Text('No Data Found !'),
                  ),
                ),
              )
            ],
          ),
        );
        break;
    }
    return child;
  }

  _pageView(BillListProvider? billListProvider) {
    return Stack(
      children: [
        Align(
          alignment: Alignment.topLeft,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: SizedBox(
              width: double.maxFinite,
              child: PunnyamDatePicker(
                isEndDate: true,
                isFirstDate: true,
                title: billListProvider?.date?.split('-').reversed.join('-') ??
                    "Date",
                onChanged: (date) => billListProvider
                  ?..updateFromDate(date)
                  // ..updateCurrentIndex(0)
                  // ..clearPageLoader()
                  ..getBillList(),
              ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 60.h),
          child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                physics: const BouncingScrollPhysics(),
                child: DataTable(
                  headingRowHeight: 45.h,
                  dataRowHeight: 52.h,
                  decoration: BoxDecoration(color: ColorPalette.primaryColor),
                  border: TableBorder.symmetric(
                    outside: BorderSide(color: Colors.grey, width: .5.w),
                  ),
                  columns: const [
                    DataColumn(
                        label: Text(
                      'Id',
                      style: TextStyle(color: Colors.white),
                    )),
                    DataColumn(
                        label: Text(
                      'Bill Date',
                      style: TextStyle(color: Colors.white),
                    )),
                    DataColumn(
                        label: Text(
                      'Counter',
                      style: TextStyle(color: Colors.white),
                    )),
                    DataColumn(
                        label: Text(
                      'Devotee',
                      style: TextStyle(color: Colors.white),
                    )),
                    DataColumn(
                        label: Text(
                      'Payment Mode',
                      style: TextStyle(color: Colors.white),
                    )),
                    DataColumn(
                        label: Text(
                      'Total',
                      style: TextStyle(color: Colors.white),
                    )),
                  ],
                  rows: List.generate(
                      billListProvider?.billListResponseModel?.list?.length ??
                          0, (index) {
                    return DataRow(
                        color: index % 2 == 0
                            ? MaterialStateProperty.all<Color>(Colors.white)
                            : MaterialStateProperty.all<Color>(
                                Colors.grey.shade100),
                        cells: [
                          DataCell(SizedBox(
                              child: Text(billListProvider
                                      ?.billListResponseModel
                                      ?.list?[index]
                                      .billId
                                      .toString() ??
                                  ''))),
                          DataCell(SizedBox(
                              child: Text(billListProvider
                                      ?.billListResponseModel
                                      ?.list?[index]
                                      .billDate
                                      .toString()
                                      .split('-')
                                      .reversed
                                      .join('-') ??
                                  ''))),
                          DataCell(Text(billListProvider
                                  ?.billListResponseModel?.list?[index].counter
                                  .toString() ??
                              '')),
                          DataCell(Text(billListProvider
                                  ?.billListResponseModel?.list?[index].devotee
                                  .toString() ??
                              '')),
                          DataCell(Center(
                              child: Text(billListProvider
                                      ?.billListResponseModel
                                      ?.list?[index]
                                      .paymentMode
                                      .toString() ??
                                  ''))),
                          DataCell(Center(
                              child: Text(billListProvider
                                      ?.billListResponseModel
                                      ?.list?[index]
                                      .total
                                      .toString() ??
                                  ''))),

                          // initBluetooth();
                          // if (CommonFunctions.connect) {
                          //   Map<String, dynamic> config = {};

                          //   List<LineText> list = [];

                          //   DateTime time = DateTime.now();
                          //   String? today =
                          //       "${time.day}/${time.month}/${time.year}";
                          //   list.add(LineText(
                          //       type: LineText.TYPE_TEXT,
                          //       content: '${datass?.temple?.name}',
                          //       size: 33,
                          //       align: LineText.ALIGN_CENTER,
                          //       linefeed: 1));
                          //   list.add(LineText(
                          //       type: LineText.TYPE_TEXT,
                          //       content:
                          //           '${datass?.temple?.addressLine1}',
                          //       size: 22,
                          //       align: LineText.ALIGN_CENTER,
                          //       linefeed: 1));
                          //   list.add(LineText(
                          //       type: LineText.TYPE_TEXT,
                          //       content:
                          //           '${datass?.temple?.addressLine1}',
                          //       size: 22,
                          //       align: LineText.ALIGN_CENTER,
                          //       linefeed: 1));
                          //   list.add(LineText(
                          //       type: LineText.TYPE_TEXT,
                          //       content: '${datass?.temple?.phone}',
                          //       size: 22,
                          //       align: LineText.ALIGN_CENTER,
                          //       linefeed: 1));
                          //   list.add(LineText(linefeed: 1));
                          //   list.add(LineText(
                          //       type: LineText.TYPE_TEXT,
                          //       content:
                          //           'Bill No:${datass?.billSummary?.billId} ',
                          //       size: 25,
                          //       align: LineText.ALIGN_LEFT,
                          //       linefeed: 0));
                          //   list.add(LineText(
                          //     type: LineText.TYPE_TEXT,
                          //     content: today,
                          //     size: 25,
                          //     align: LineText.ALIGN_RIGHT,
                          //   ));
                          //   list.add(LineText(linefeed: 1));
                          //   int? len = datass?.billDetails?.length;
                          //   for (int i = 0; i < len!; i++) {
                          //     String? pooja = DateFormat('dd-MM-yyyy')
                          //         .format(DateTime.parse(
                          //             "${datass?.billDetails![i].poojaDate}"));
                          //     list.add(LineText(
                          //       type: LineText.TYPE_TEXT,
                          //       content: '${i + 1}) ',
                          //       size: 22,
                          //       align: LineText.ALIGN_LEFT,
                          //     ));
                          //     list.add(LineText(
                          //       type: LineText.TYPE_TEXT,
                          //       content: '$pooja ',
                          //       size: 22,
                          //       align: LineText.ALIGN_LEFT,
                          //     ));
                          //     list.add(LineText(
                          //         type: LineText.TYPE_TEXT,
                          //         content:
                          //             '${datass?.billDetails![i].dietyname}',
                          //         size: 22,
                          //         align: LineText.ALIGN_LEFT,
                          //         linefeed: 1));
                          //     list.add(LineText(
                          //       type: LineText.TYPE_TEXT,
                          //       content:
                          //           '${datass?.billDetails![i].name} ',
                          //       size: 22,
                          //       align: LineText.ALIGN_LEFT,
                          //     ));
                          //     list.add(LineText(
                          //         type: LineText.TYPE_TEXT,
                          //         content:
                          //             '${datass?.billDetails![i].starname}',
                          //         size: 22,
                          //         align: LineText.ALIGN_LEFT,
                          //         linefeed: 1));
                          //     list.add(LineText(
                          //       type: LineText.TYPE_TEXT,
                          //       content:
                          //           '${datass?.billDetails![i].poojaname} ',
                          //       size: 22,
                          //       align: LineText.ALIGN_LEFT,
                          //     ));
                          //     list.add(LineText(
                          //         type: LineText.TYPE_TEXT,
                          //         content:
                          //             '${datass?.billDetails![i].quantity}/${datass?.billDetails![i].rate}',
                          //         size: 22,
                          //         align: LineText.ALIGN_LEFT,
                          //         linefeed: 1));
                          //   }
                          //   list.add(LineText(linefeed: 1));
                          //   list.add(LineText(
                          //       type: LineText.TYPE_TEXT,
                          //       content:
                          //           'Mode:${datass?.billSummary?.paymentMode}        ',
                          //       size: 24,
                          //       align: LineText.ALIGN_LEFT,
                          //       linefeed: 0));
                          //   list.add(LineText(
                          //       type: LineText.TYPE_TEXT,
                          //       content:
                          //           '    Total${datass?.billSummary?.total}',
                          //       size: 24,
                          //       align: LineText.ALIGN_RIGHT,
                          //       linefeed: 1));
                          //   list.add(LineText(
                          //       type: LineText.TYPE_TEXT,
                          //       content:
                          //           'Book online ${datass?.temple?.email}',
                          //       weight: 1,
                          //       align: LineText.ALIGN_CENTER,
                          //       linefeed: 1));
                          //   list.add(LineText(linefeed: 1));
                          //   await bluetoothPrint.printReceipt(
                          //       config, list);
                          // } else {
                          //   Helpers.successToast("printer disconnected");
                          // }

                          // InkWell(onTap: () async {
                          //   BillDetailprovider.id =
                          //       "${billListProvider?.billListResponseModel?.list?[index].billId}";

                          //   Navigator.of(context).push(MaterialPageRoute(
                          //     builder: (context) => PrintPage(),
                          //   ));
                          // }),
                        ]);
                  }),
                ),
              )),
        ),
        // Padding(
        //   padding: EdgeInsets.only(bottom: 55.h, right: 10.w),
        //   child: Align(
        //     alignment: Alignment.bottomRight,
        //     child: Row(
        //       mainAxisAlignment: MainAxisAlignment.end,
        //       children: [
        //         FloatingActionButton(
        //           heroTag: 1,
        //           onPressed: () {
        //             // print(
        //             //     "currentpageindex.....${billListProvider?.currentPageIndex}");
        //             if (billListProvider?.currentPageIndex != 0 &&
        //                 (!billListProvider!.paginationLoader)) {
        //               billListProvider.loadless().then((value) {
        //                 billListProvider.pageController.animateToPage(
        //                     (billListProvider.currentPageIndex) - 1,
        //                     duration: const Duration(milliseconds: 200),
        //                     curve: Curves.easeIn);
        //               });
        //               if ((billListProvider.tempBillListDataList.length ?? 0) >
        //                   1) {
        //                 // print(
        //                 //     "count left .....${billListProvider.currentPageIndex}");
        //               }
        //             } else {
        //               Helpers.successToast('There is no previous page');
        //             }
        //           },
        //           child: (billListProvider?.left ?? false)
        //               ? SizedBox(
        //                   height: 20.h,
        //                   width: 20.w,
        //                   child: CircularProgressIndicator(
        //                     strokeWidth: 2.w,
        //                     color: Colors.white,
        //                   ),
        //                 )
        //               : Icon(
        //                   Icons.arrow_left_outlined,
        //                   size: 45.h,
        //                 ),
        //         ),
        //         20.horizontalSpace,
        //         FloatingActionButton(
        //             heroTag: 2,
        //             onPressed: () async {
        //               // print(
        //               //     "currentpageindex.....${billListProvider?.currentPageIndex}");
        //               // if ((billListProvider?.currentPageIndex ?? 0) + 1 !=
        //               //         billListProvider?.totalPageLength &&
        //               //     !(billListProvider?.paginationLoader ?? false)) {
        //               //   print(
        //               //       "frst.....................${billListProvider?.totalPageLength}!=${(billListProvider?.currentPageIndex)! + 1}");
        //               //   // print(
        //               //   //     "ontap count...right........${billListProvider?.pageCount}");

        //               //   billListProvider?.loadMoreBills().then((value) {
        //               //     print("2nd");
        //               //     print(
        //               //         "......${(billListProvider.currentPageIndex) + 1}");
        //               //     print(
        //               //         "....data..${billListProvider.tempBillListDataList.length}");
        //               //     billListProvider.pageController.animateToPage(
        //               //         (billListProvider.currentPageIndex) + 1,
        //               //         duration: const Duration(milliseconds: 200),
        //               //         curve: Curves.easeIn);
        //               //   });
        //               //   print("object");
        //               if ((billListProvider?.currentPageIndex ?? 0) + 1 !=
        //                       billListProvider?.totalPageLength &&
        //                   !(billListProvider?.paginationLoader ?? false)) {
        //                 // print("object");
        //                 // print("frst");
        //                 billListProvider?.loadMoreBills().then((value) {
        //                   billListProvider.pageController.animateToPage(
        //                       (billListProvider.currentPageIndex) + 1,
        //                       duration: const Duration(milliseconds: 200),
        //                       curve: Curves.easeIn);
        //                   // print(
        //                   //     ".........${billListProvider.tempBillListDataList.length}");
        //                   // print(
        //                   //     "data in click.......${billListProvider.currentPageIndex}");
        //                 });
        //               } else {
        //                 Helpers.successToast('There is no next page');
        //               }
        //             },
        //             child: (billListProvider?.right ?? false)
        //                 ? SizedBox(
        //                     height: 20.h,
        //                     width: 20.w,
        //                     child: CircularProgressIndicator(
        //                       strokeWidth: 2.w,
        //                       color: Colors.white,
        //                     ),
        //                   )
        //                 : Icon(
        //                     Icons.arrow_right_outlined,
        //                     size: 45.h,
        //                   ))
        //       ],
        //     ),
        //   ),
        // ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            color: Colors.green,
            width: double.infinity,
            height: 50.h,
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Gross Total :',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14.sp),
                    ),
                    10.horizontalSpace,
                    Text(
                        billListProvider?.billListResponseModel?.grossTotal
                                .toString() ??
                            '0',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14.sp)),
                  ],
                )
              ],
            ),
          ),
        )
      ],
    );
  }
}

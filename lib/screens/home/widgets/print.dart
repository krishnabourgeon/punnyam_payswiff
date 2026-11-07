// // import 'package:bluetooth_print/bluetooth_print.dart';
// // import 'package:bluetooth_print/bluetooth_print_model.dart';
// // import 'package:flutter/material.dart';
// // import 'package:intl/intl.dart';
// // import 'package:provider/provider.dart';
// // import 'package:punnyam/providers/bill_details_provider.dart';
// // import 'package:punnyam/services/helpers.dart';

// // class PrintPage extends StatefulWidget {
// //   @override
// //   _PrintPageState createState() => _PrintPageState();
// // }

// // class _PrintPageState extends State<PrintPage> {
// //   BluetoothPrint bluetoothPrint = BluetoothPrint.instance;
// //   List<BluetoothDevice> _devices = [];
// //   String _devicesMsg = "";
// //   bool _connected = false;
// //   BluetoothDevice? _device;
// //   String tips = 'no device connect';
// //   // final f = NumberFormat("\$###,###.00", "en_US");

// //   @override
// //   void initState() {
// //     super.initState();
// //     // Provider.of<BillDetailprovider>(context, listen: false).getbilldetails();
// //     WidgetsBinding.instance.addPostFrameCallback((_) => {initBluetooth()});
// //   }

// //   Future<void> initBluetooth() async {
// //     bluetoothPrint.startScan(timeout: Duration(seconds: 4));

// //     bool isConnected = await bluetoothPrint.isConnected ?? false;

// //     bluetoothPrint.state.listen((state) {
// //       print('******************* cur device status: $state');

// //       switch (state) {
// //         case BluetoothPrint.CONNECTED:
// //           setState(() {
// //             _connected = true;
// //             tips = 'connect success';
// //           });
// //           break;
// //         case BluetoothPrint.DISCONNECTED:
// //           setState(() {
// //             _connected = false;
// //             tips = 'disconnect success';
// //           });
// //           break;
// //         default:
// //           break;
// //       }
// //     });

// //     if (!mounted) return;

// //     if (isConnected) {
// //       setState(() {
// //         _connected = true;
// //       });
// //     }
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(
// //         title: Text('Select Printer'),
// //         backgroundColor: Colors.redAccent,
// //       ),
// //       body: _devices.isEmpty
// //           ? RefreshIndicator(
// //               displacement: 2,
// //               onRefresh:() => bluetoothPrint.startScan(timeout: Duration(seconds: 4)),
// //               child: Center(
// //                 child: Text(tips),
// //               ),
// //             )
// //           : ListView.builder(
// //               itemCount: _devices.length,
// //               itemBuilder: (c, i) {
// //                 return ListTile(
// //                   leading: Icon(Icons.print),
// //                   title: Text(_devices[i].name.toString()),
// //                   subtitle: Text(_devices[i].address.toString()),
// //                   onTap: () {
// //                     _startPrint(_devices[i]);
// //                   },
// //                 );
// //               },
// //             ),
// //     );
// //   }

// //   Future<void> _startPrint(BluetoothDevice device) async {
// //     // final datass =
// //     //      Provider.of<BillDetailprovider>(context, l).getbilldetails();

// //     if (device != null && device.address != null) {
// //       try {
// //         print("...............${device.name}");
// //         print("correct......................");
// //         await bluetoothPrint.connect(device);
// //         bool? connected = await bluetoothPrint.isConnected;
// //         print(connected);
// //         List<LineText> list = [];
// //         Map<String, dynamic> config = Map();

// // ignore_for_file: avoid_print

// //         list.add(
// //           LineText(
// //             type: LineText.TYPE_TEXT,
// //             content: "new temple",
// //             weight: 2,
// //             width: 2,
// //             height: 2,
// //             align: LineText.ALIGN_CENTER,
// //             linefeed: 1,
// //           ),
// //         );
// //         list.add(
// //           LineText(
// //             type: LineText.TYPE_TEXT,
// //             content: "addresss",
// //             weight: 2,
// //             width: 2,
// //             height: 2,
// //             align: LineText.ALIGN_CENTER,
// //             linefeed: 1,
// //           ),
// //         );
// //         list.add(
// //           LineText(
// //             type: LineText.TYPE_TEXT,
// //             content: "address2",
// //             weight: 2,
// //             width: 2,
// //             height: 2,
// //             align: LineText.ALIGN_CENTER,
// //             linefeed: 1,
// //           ),
// //         );
// //         print(list);
// //         bool? dat = await bluetoothPrint.isConnected;
// //         Helpers.successToast(dat.toString());
// //         await bluetoothPrint.printReceipt(config, list);
// //         await bluetoothPrint.printTest();
// //       } catch (e) {
// //         print("${device.name}");
// //         Helpers.successToast(e.toString());
// //         print(".............${e}");
// //       }
// //     }
// //   }
// // }

// import 'package:bluetooth_print/bluetooth_print.dart';
// import 'package:bluetooth_print/bluetooth_print_model.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:provider/provider.dart';
// import 'package:punnyam/providers/bill_details_provider.dart';
// import 'package:punnyam/services/helpers.dart';

// class MyApp extends StatefulWidget {
//   const MyApp({super.key});
//   @override
//   State<MyApp> createState() => _MyAppState();
// }

// class _MyAppState extends State<MyApp> {
//   BluetoothPrint bluetoothPrint = BluetoothPrint.instance;
//   bool connected = false;
//   bool deviceconnect = false;
//   BluetoothDevice? _device;

//   final GlobalKey<State<StatefulWidget>> _buttonKey = GlobalKey();
//   bool? check = false;
//   String tips = 'no device connect';
//   String desiredDeviceName = 'Printer_9469_BLE';
//   funconnect() async {
//     await Provider.of<BillDetailprovider>(context, listen: false)
//         .getbilldetails();
//     Map<String, dynamic> config = {};
//     List<LineText> list = [];
//     // DateTime time = DateTime.now();
//     // String? today = "${time.day}/${time.month}/${time.year}";
//     // list.add(LineText(
//     //     type: LineText.TYPE_TEXT,
//     //     content: '${datass?.temple?.name}',
//     //     size: 33,
//     //     align: LineText.ALIGN_CENTER,
//     //     linefeed: 1));
//     // list.add(LineText(
//     //     type: LineText.TYPE_TEXT,
//     //     content: '${datass?.temple?.addressLine1}',
//     //     size: 22,
//     //     align: LineText.ALIGN_CENTER,
//     //     linefeed: 1));
//     // list.add(LineText(
//     //     type: LineText.TYPE_TEXT,
//     //     content: '${datass?.temple?.addressLine1}',
//     //     size: 22,
//     //     align: LineText.ALIGN_CENTER,
//     //     linefeed: 1));
//     // list.add(LineText(
//     //     type: LineText.TYPE_TEXT,
//     //     content: '${datass?.temple?.phone}',
//     //     size: 22,
//     //     align: LineText.ALIGN_CENTER,
//     //     linefeed: 1));
//     // list.add(LineText(linefeed: 1));
//     // list.add(LineText(
//     //     type: LineText.TYPE_TEXT,
//     //     content: 'Bill No:${datass?.billSummary?.billId} ',
//     //     size: 25,
//     //     align: LineText.ALIGN_LEFT,
//     //     linefeed: 0));
//     // list.add(LineText(
//     //   type: LineText.TYPE_TEXT,
//     //   content: today,
//     //   size: 25,
//     //   align: LineText.ALIGN_RIGHT,
//     // ));
//     // list.add(LineText(linefeed: 1));
//     // int? len = datass?.billDetails?.length;
//     // for (int i = 0; i < len!; i++) {
//     //   print("$i < $len");
//     //   String? pooja = DateFormat('dd-MM-yyyy')
//     //       .format(DateTime.parse("${datass?.billDetails![i].poojaDate}"));
//     //   print(
//     //       "$pooja..${datass?.billDetails![i].dietyname}..${datass?.billDetails![i].name}..${datass?.billDetails![i].starname}...${datass?.billDetails![i].poojaname}");
//     //   list.add(LineText(
//     //     type: LineText.TYPE_TEXT,
//     //     content: '${i + 1}) ',
//     //     size: 22,
//     //     align: LineText.ALIGN_LEFT,
//     //   ));
//     //   list.add(LineText(
//     //     type: LineText.TYPE_TEXT,
//     //     content: '$pooja ',
//     //     size: 22,
//     //     align: LineText.ALIGN_LEFT,
//     //   ));
//     //   list.add(LineText(
//     //       type: LineText.TYPE_TEXT,
//     //       content: '${datass?.billDetails![i].dietyname}',
//     //       size: 22,
//     //       align: LineText.ALIGN_LEFT,
//     //       linefeed: 1));
//     //   list.add(LineText(
//     //     type: LineText.TYPE_TEXT,
//     //     content: '${datass?.billDetails![i].name} ',
//     //     size: 22,
//     //     align: LineText.ALIGN_LEFT,
//     //   ));
//     //   list.add(LineText(
//     //       type: LineText.TYPE_TEXT,
//     //       content: '${datass?.billDetails![i].starname}',
//     //       size: 22,
//     //       align: LineText.ALIGN_LEFT,
//     //       linefeed: 1));
//     //   list.add(LineText(
//     //     type: LineText.TYPE_TEXT,
//     //     content: '${datass?.billDetails![i].poojaname} ',
//     //     size: 22,
//     //     align: LineText.ALIGN_LEFT,
//     //   ));
//     //   list.add(LineText(
//     //       type: LineText.TYPE_TEXT,
//     //       content:
//     //           '${datass?.billDetails![i].quantity}/${datass?.billDetails![i].rate}',
//     //       size: 22,
//     //       align: LineText.ALIGN_LEFT,
//     //       linefeed: 1));
//     // }
//     // list.add(LineText(linefeed: 1));
//     // list.add(LineText(
//     //     type: LineText.TYPE_TEXT,
//     //     content: 'Mode:${datass?.billSummary?.paymentMode}',
//     //     size: 24,
//     //     align: LineText.ALIGN_LEFT,
//     //     linefeed: 0));
//     // list.add(LineText(
//     //     type: LineText.TYPE_TEXT,
//     //     content: 'Total${datass?.billSummary?.total}',
//     //     size: 24,
//     //     align: LineText.ALIGN_RIGHT,
//     //     linefeed: 1));
//     // list.add(LineText(
//     //     type: LineText.TYPE_TEXT,
//     //     content: 'Book online ${datass?.temple?.email}',
//     //     weight: 1,
//     //     align: LineText.ALIGN_CENTER,
//     //     linefeed: 1));
//     list.add(LineText(linefeed: 1));
//     await bluetoothPrint.printReceipt(config, list);
//   }

//   notfun() {
//     print("noooooo..........");
//   }

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) => scanDevices());
//   }

//   void scanDevices() async {
//     try {
//       await bluetoothPrint.startScan(timeout: const Duration(seconds: 4));
//       bluetoothPrint.scanResults.listen((devices) async {
//         for (BluetoothDevice device in devices) {
//           print(device.name);
//           if (device.name == desiredDeviceName) {
//             print("true");
//             try {
//               await bluetoothPrint.connect(device);

//               print('Connected to device: ${device.name}');
//               setState(() {
//                 deviceconnect = true;
//               });
//               final dynamic buttonState = _buttonKey.currentWidget;
//               buttonState?.onPressed?.call();

//               // deviceconnect ? funconnect() : notfun();
//             } catch (error) {
//               print('Error connecting to device: $error');
//             }
//           }
//         }
//       });
//     } catch (error) {
//       print('Error scanning: $error');
//     }
//   }

//   // Future<void> initBluetooth() async {
//   // bluetoothPrint.startScan(timeout: const Duration(seconds: 4));
//   // bool isConnected = await bluetoothPrint.isConnected ?? false;
//   // bluetoothPrint.state.listen((state) {
//   //   print('******************* cur device status: $state');
//   //   switch (state) {
//   //     case BluetoothPrint.CONNECTED:
//   //       setState(() {
//   //         _connected = true;
//   //         tips = 'connect success';
//   //       });
//   //       break;
//   //     case BluetoothPrint.DISCONNECTED:
//   //       setState(() {
//   //         _connected = false;
//   //         tips = 'disconnect success';
//   //       });
//   //       break;
//   //     default:
//   //       break;
//   //   }
//   // });
//   // if (!mounted) return;
//   // if (isConnected) {
//   //   setState(() {
//   //     _connected = true;
//   //   });
//   //   Helpers.successToast(_connected.toString());
//   // }
//   // }

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: Scaffold(
//         backgroundColor: Colors.white,
//         appBar: AppBar(
//           backgroundColor: Colors.white,
//           elevation: 0,
//           leading: Center(
//             child: InkWell(
//               onTap: (() => Navigator.pop(context)),
//               child: SizedBox(
//                   height: 25.h,
//                   width: 25.h,
//                   child: Image.asset("assets/image/backIcon.png")),
//             ),
//           ),
//           systemOverlayStyle: const SystemUiOverlayStyle(
//             statusBarColor: Colors.white,
//             statusBarIconBrightness: Brightness.dark,
//             statusBarBrightness: Brightness.light,
//           ),
//         ),
//         body: RefreshIndicator(
//           onRefresh: () =>
//               bluetoothPrint.startScan(timeout: const Duration(seconds: 4)),
//           child: SingleChildScrollView(
//             child: Column(
//               children: <Widget>[
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: <Widget>[
//                     Padding(
//                       padding: const EdgeInsets.symmetric(
//                           vertical: 10, horizontal: 10),
//                       child: Text(tips),
//                     ),
//                   ],
//                 ),
//                 const Divider(),
//                 StreamBuilder<List<BluetoothDevice>>(
//                     stream: bluetoothPrint.scanResults,
//                     initialData: const [],
//                     builder: (c, snapshot) {
//                       print(snapshot.data?.length);
//                       return Column(
//                         children: snapshot.data!
//                             .map((d) => ListTile(
//                                   title: Text(d.name ?? ''),
//                                   subtitle: Text(d.address ?? ''),
//                                   onTap: () async {
//                                     Helpers.successToast(d.toString());
//                                     setState(() {
//                                       _device = d;
//                                     });
//                                     print(d.name);
//                                   },
//                                   trailing: _device != null &&
//                                           _device!.address == d.address
//                                       ? const Icon(
//                                           Icons.check,
//                                           color: Colors.green,
//                                         )
//                                       : null,
//                                 ))
//                             .toList(),
//                       );
//                     }),
//                 const Divider(),
//                 Container(
//                   padding: const EdgeInsets.fromLTRB(20, 5, 20, 10),
//                   child: Column(
//                     children: <Widget>[
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: <Widget>[
//                           ElevatedButton(
//                             onPressed: connected
//                                 ? null
//                                 : () async {
//                                     if (_device != null &&
//                                         _device!.address != null) {
//                                       setState(() {
//                                         tips = 'connecting...';
//                                       });
//                                       await bluetoothPrint.connect(_device!);
//                                     } else {
//                                       setState(() {
//                                         tips = 'please select device';
//                                       });
//                                     }
//                                   },
//                             child: const Text('connect'),
//                           ),
//                           const SizedBox(width: 10.0),
//                           OutlinedButton(
//                             onPressed: connected
//                                 ? () async {
//                                     setState(() {
//                                       tips = 'disconnecting...';
//                                     });
//                                     await bluetoothPrint.disconnect();
//                                   }
//                                 : null,
//                             child: const Text('disconnect'),
//                           ),
//                         ],
//                       ),
//                       const Divider(),
//                       OutlinedButton(
//                         key: _buttonKey,
//                         onPressed: () async {
//                           print("correct.....clicks.......");
//                           // final datass =
//                           //     await Provider.of<BillDetailprovider>(
//                           //             context,
//                           //             listen: false)
//                           //         .getbilldetails();
//                           Map<String, dynamic> config = {};
//                           List<LineText> list = [];
//                           // DateTime time = DateTime.now();
//                           // String? today =
//                           //     "${time.day}/${time.month}/${time.year}";
//                           // list.add(LineText(
//                           //     type: LineText.TYPE_TEXT,
//                           //     content: '${datass?.temple?.name}',
//                           //     size: 33,
//                           //     align: LineText.ALIGN_CENTER,
//                           //     linefeed: 1));
//                           // list.add(LineText(
//                           //     type: LineText.TYPE_TEXT,
//                           //     content: '${datass?.temple?.addressLine1}',
//                           //     size: 22,
//                           //     align: LineText.ALIGN_CENTER,
//                           //     linefeed: 1));
//                           // list.add(LineText(
//                           //     type: LineText.TYPE_TEXT,
//                           //     content: '${datass?.temple?.addressLine1}',
//                           //     size: 22,
//                           //     align: LineText.ALIGN_CENTER,
//                           //     linefeed: 1));
//                           // list.add(LineText(
//                           //     type: LineText.TYPE_TEXT,
//                           //     content: '${datass?.temple?.phone}',
//                           //     size: 22,
//                           //     align: LineText.ALIGN_CENTER,
//                           //     linefeed: 1));
//                           // list.add(LineText(linefeed: 1));
//                           // list.add(LineText(
//                           //     type: LineText.TYPE_TEXT,
//                           //     content:
//                           //         'Bill No:${datass?.billSummary?.billId} ',
//                           //     size: 25,
//                           //     align: LineText.ALIGN_LEFT,
//                           //     linefeed: 0));
//                           // list.add(LineText(
//                           //   type: LineText.TYPE_TEXT,
//                           //   content: today,
//                           //   size: 25,
//                           //   align: LineText.ALIGN_RIGHT,
//                           // ));
//                           // list.add(LineText(linefeed: 1));
//                           // int? len = datass?.billDetails?.length;
//                           // for (int i = 0; i < len!; i++) {
//                           //   print("$i < $len");
//                           //   String? pooja = DateFormat('dd-MM-yyyy')
//                           //       .format(DateTime.parse(
//                           //           "${datass?.billDetails![i].poojaDate}"));
//                           //   print(
//                           //       "$pooja..${datass?.billDetails![i].dietyname}..${datass?.billDetails![i].name}..${datass?.billDetails![i].starname}...${datass?.billDetails![i].poojaname}");
//                           //   list.add(LineText(
//                           //     type: LineText.TYPE_TEXT,
//                           //     content: '${i + 1}) ',
//                           //     size: 22,
//                           //     align: LineText.ALIGN_LEFT,
//                           //   ));
//                           //   list.add(LineText(
//                           //     type: LineText.TYPE_TEXT,
//                           //     content: '$pooja ',
//                           //     size: 22,
//                           //     align: LineText.ALIGN_LEFT,
//                           //   ));
//                           //   list.add(LineText(
//                           //       type: LineText.TYPE_TEXT,
//                           //       content:
//                           //           '${datass?.billDetails![i].dietyname}',
//                           //       size: 22,
//                           //       align: LineText.ALIGN_LEFT,
//                           //       linefeed: 1));
//                           //   list.add(LineText(
//                           //     type: LineText.TYPE_TEXT,
//                           //     content: '${datass?.billDetails![i].name} ',
//                           //     size: 22,
//                           //     align: LineText.ALIGN_LEFT,
//                           //   ));
//                           //   list.add(LineText(
//                           //       type: LineText.TYPE_TEXT,
//                           //       content:
//                           //           '${datass?.billDetails![i].starname}',
//                           //       size: 22,
//                           //       align: LineText.ALIGN_LEFT,
//                           //       linefeed: 1));
//                           //   list.add(LineText(
//                           //     type: LineText.TYPE_TEXT,
//                           //     content:
//                           //         '${datass?.billDetails![i].poojaname} ',
//                           //     size: 22,
//                           //     align: LineText.ALIGN_LEFT,
//                           //   ));
//                           //   list.add(LineText(
//                           //       type: LineText.TYPE_TEXT,
//                           //       content:
//                           //           '${datass?.billDetails![i].quantity}/${datass?.billDetails![i].rate}',
//                           //       size: 22,
//                           //       align: LineText.ALIGN_LEFT,
//                           //       linefeed: 1));
//                           // }
//                           // list.add(LineText(linefeed: 1));
//                           // list.add(LineText(
//                           //     type: LineText.TYPE_TEXT,
//                           //     content:
//                           //         'Mode:${datass?.billSummary?.paymentMode}',
//                           //     size: 24,
//                           //     align: LineText.ALIGN_LEFT,
//                           //     linefeed: 0));
//                           // list.add(LineText(
//                           //     type: LineText.TYPE_TEXT,
//                           //     content:
//                           //         'Total${datass?.billSummary?.total}',
//                           //     size: 24,
//                           //     align: LineText.ALIGN_RIGHT,
//                           //     linefeed: 1));
//                           // list.add(LineText(
//                           //     type: LineText.TYPE_TEXT,
//                           //     content:
//                           //         'Book online ${datass?.temple?.email}',
//                           //     weight: 1,
//                           //     align: LineText.ALIGN_CENTER,
//                           //     linefeed: 1));
//                           list.add(LineText(linefeed: 1));
//                           await bluetoothPrint.printReceipt(config, list);
//                         },
//                         child: const Text('print receipt'),
//                       ),
//                     ],
//                   ),
//                 )
//               ],
//             ),
//           ),
//         ),
//         floatingActionButton: StreamBuilder<bool>(
//           stream: bluetoothPrint.isScanning,
//           initialData: false,
//           builder: (c, snapshot) {
//             if (snapshot.data == true) {
//               return FloatingActionButton(
//                 onPressed: () => bluetoothPrint.stopScan(),
//                 backgroundColor: Colors.red,
//                 child: const Icon(Icons.stop),
//               );
//             } else {
//               return FloatingActionButton(
//                   child: const Icon(Icons.search),
//                   onPressed: () => bluetoothPrint.startScan(
//                       timeout: const Duration(seconds: 4)));
//             }
//           },
//         ),
//       ),
//     );
//   }
// }

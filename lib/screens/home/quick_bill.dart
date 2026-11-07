// import 'package:auto_height_grid_view/auto_height_grid_view.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:intl/intl.dart';
// import 'package:provider/provider.dart';
// import 'package:punnyam/common/custom_drop_down_search.dart';
// import 'package:punnyam/common/extension.dart';
// import 'package:punnyam/models/payment_mode_response.dart';
// import 'package:punnyam/providers/billing_provider.dart';
// import 'package:punnyam/providers/home_provider.dart';
// import 'package:punnyam/screens/home/home.dart';
// import 'package:punnyam/services/helpers.dart';
// import 'package:punnyam/widgets/punnyam_textfiled.dart';

// class QuickBillScreen extends StatefulWidget {
//   const QuickBillScreen({super.key});

//   @override
//   State<QuickBillScreen> createState() => _QuickBillScreenState();
// }

// class _QuickBillScreenState extends State<QuickBillScreen> {
//   TextEditingController nameController = TextEditingController();

//   bool selected = false;

//   @override
//   void initState() {
//     final billingProvider = context.read<BillingProvider>();

//     Future.microtask(() {
//       // billingProvider.checkPrinter();
//     });
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final billingProvider = context.read<BillingProvider>();
//     return SafeArea(
//       child: Scaffold(
//           resizeToAvoidBottomInset: false,
//           appBar: AppBar(
//             backgroundColor: Colors.white,
//             elevation: 0,
//             leading: Center(
//               child: InkWell(
//                 onTap: (() => Navigator.pop(context)),
//                 child: SizedBox(
//                     height: 25.h,
//                     width: 25.h,
//                     child: Image.asset("assets/image/backIcon.png")),
//               ),
//             ),
//             systemOverlayStyle: const SystemUiOverlayStyle(
//               statusBarColor: Colors.white,
//               statusBarIconBrightness: Brightness.dark,
//               statusBarBrightness: Brightness.light,
//             ),
//             centerTitle: true,
//             title: const Text(
//               "Quick Bill",
//               style: TextStyle(color: Colors.black),
//             ),
//             actions: [
//               Padding(
//                 padding: const EdgeInsets.only(right: 10.0),
//                 child: InkWell(
//                   onTap: () {
//                     Navigator.of(context).pushAndRemoveUntil(
//                         MaterialPageRoute(builder: (context) => const Home()),
//                         (Route<dynamic> route) => false);
//                   },
//                   child: const Icon(
//                     Icons.home,
//                     color: Colors.black,
//                   ),
//                 ),
//               )
//             ],
//           ),
//           body: Consumer<HomeProvider>(
//             builder: (context, homeprovider, child) => RefreshIndicator(
//               onRefresh: () async {
//                 await homeprovider.getquickbill();
//               },
//               child: SizedBox(
//                 // height: MediaQuery.of(context).size.height / 1.17,
//                 child: Column(
//                   // mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     SizedBox(
//                       height: homeprovider.data.isEmpty ? null : 300.h,
//                       child: RefreshIndicator(
//                         onRefresh: () async {
//                           await homeprovider.getquickbill();
//                         },
//                         child: AutoHeightGridView(
//                           itemCount: homeprovider.quickbills?.data?.length ?? 0,
//                           crossAxisCount: 2,
//                           mainAxisSpacing: 10,
//                           crossAxisSpacing: 10,
//                           physics: const BouncingScrollPhysics(),
//                           padding: const EdgeInsets.all(12),
//                           shrinkWrap: true,
//                           builder: (context, index) {
//                             final datass =
//                                 homeprovider.quickbills?.data![index];
//                             return InkWell(
//                               onTap: () async {
//                                 if (homeprovider.data.any(
//                                     (element) => element.id == datass?.id)) {
//                                   homeprovider.updateQtyamt(id: datass?.id);
//                                 } else {
//                                   homeprovider.addtolist(
//                                       name: datass?.name,
//                                       qty: 1,
//                                       rs: datass?.rate,
//                                       basefare: datass?.rate,
//                                       id: datass?.id);
//                                 }
//                               },
//                               child: Container(
//                                 width: double.infinity,
//                                 decoration: BoxDecoration(
//                                     color:
//                                         const Color.fromRGBO(244, 155, 54, 1),
//                                     borderRadius: BorderRadius.circular(10.r)),
//                                 child: Column(
//                                   children: [
//                                     Row(
//                                       children: [
//                                         Expanded(
//                                           child: Text(
//                                             "${homeprovider.quickbills?.data![index].name}",
//                                             style: TextStyle(
//                                                 color: Colors.white,
//                                                 fontSize: 13.sp),
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                     Row(
//                                       mainAxisAlignment: MainAxisAlignment.end,
//                                       children: [
//                                         Text(
//                                           "₹ ${homeprovider.quickbills?.data![index].rate}",
//                                           style: TextStyle(
//                                               color: Colors.white,
//                                               fontSize: 15.sp,
//                                               fontWeight: FontWeight.w500),
//                                         ),
//                                       ],
//                                     ),
//                                   ],
//                                 ).symmetricPadding(
//                                     vertical: 10.h, horizontal: 10.w),
//                               ),
//                             );
//                           },
//                         ),
//                       ),
//                     ).horizontalPadding(8.w),
//                     homeprovider.data.isEmpty
//                         ? const SizedBox()
//                         : Expanded(
//                             child: SizedBox(
//                               // height: 300.h,
//                               child: RefreshIndicator(
//                                 onRefresh: () async {
//                                   await homeprovider.getquickbill();
//                                 },
//                                 child: SingleChildScrollView(
//                                   child: Column(
//                                     children: [
//                                       SizedBox(
//                                         height: 47.h,
//                                         child: PunnyamTextField(
//                                             hintText: "Name",

//                                             // height: 40.h,
//                                             textEditingController:
//                                                 nameController,
//                                             inputFormatter: [
//                                               FilteringTextInputFormatter.allow(
//                                                   RegExp("[a-z A-Z]"))
//                                             ],
//                                             keyboardType: TextInputType.name,
//                                             hintStyle: TextStyle(
//                                               fontSize: 13.5.sp,
//                                               fontWeight: FontWeight.normal,
//                                               color: Colors.grey.shade600,
//                                             ),
//                                             onChanged: (value) {
//                                               billingProvider
//                                                   .updateBillingFormState();
//                                             }),
//                                       ),
//                                       10.verticalSpace,
//                                       CustomDropDownSearch(
//                                         labelText: 'Select Star',
//                                         isShowSearch: true,
//                                         onChanged: (value) {
//                                           FocusScope.of(context).unfocus();
//                                           billingProvider
//                                             ..getStarIdFromName(value)
//                                             ..updateBillingFormState();
//                                         },
//                                         items: List.generate(
//                                             billingProvider.starsList.length,
//                                             (index) =>
//                                                 billingProvider
//                                                     .starsList[index].nameEng ??
//                                                 ''),
//                                       ),
//                                       10.verticalSpace,
//                                       ListView.separated(
//                                         separatorBuilder: (context, index) =>
//                                             7.verticalSpace,
//                                         shrinkWrap: true,
//                                         physics:
//                                             const NeverScrollableScrollPhysics(),
//                                         itemCount: homeprovider.data.length,
//                                         itemBuilder: (context, index) => Row(
//                                           mainAxisAlignment:
//                                               MainAxisAlignment.spaceBetween,
//                                           children: [
//                                             SizedBox(
//                                               width: 200.w,
//                                               child: Row(
//                                                 mainAxisAlignment:
//                                                     MainAxisAlignment
//                                                         .spaceBetween,
//                                                 children: [
//                                                   Expanded(
//                                                     child: SizedBox(
//                                                         // width: 100.w,
//                                                         child: Text(
//                                                       homeprovider
//                                                           .data[index].name,
//                                                       style: TextStyle(
//                                                           fontSize: 13.sp,
//                                                           fontWeight:
//                                                               FontWeight.w500),
//                                                       maxLines: 3,
//                                                       overflow:
//                                                           TextOverflow.ellipsis,
//                                                     )),
//                                                   ),
//                                                   5.horizontalSpace,
//                                                   SizedBox(
//                                                     width: 70.w,
//                                                     child: Row(
//                                                       mainAxisAlignment:
//                                                           MainAxisAlignment
//                                                               .spaceBetween,
//                                                       children: [
//                                                         InkWell(
//                                                           onTap: () async {
//                                                             await homeprovider
//                                                                 .removeQtyamt(
//                                                                     id: homeprovider
//                                                                         .data[
//                                                                             index]
//                                                                         .id);
//                                                           },
//                                                           child: CircleAvatar(
//                                                             backgroundColor:
//                                                                 const Color
//                                                                     .fromRGBO(
//                                                                     244,
//                                                                     155,
//                                                                     54,
//                                                                     1),
//                                                             radius: 11.r,
//                                                             child: Center(
//                                                               child: Icon(
//                                                                 Icons.remove,
//                                                                 color: Colors
//                                                                     .white,
//                                                                 size: 13.sp,
//                                                               ),
//                                                             ),
//                                                           ),
//                                                         ),
//                                                         Text(
//                                                             "${homeprovider.data[index].qty}"),
//                                                         InkWell(
//                                                           onTap: () async {
//                                                             await homeprovider
//                                                                 .updateQtyamt(
//                                                                     id: homeprovider
//                                                                         .data[
//                                                                             index]
//                                                                         .id);
//                                                           },
//                                                           child: CircleAvatar(
//                                                             backgroundColor:
//                                                                 const Color
//                                                                     .fromRGBO(
//                                                                     244,
//                                                                     155,
//                                                                     54,
//                                                                     1),
//                                                             radius: 11.r,
//                                                             child: Center(
//                                                               child: Icon(
//                                                                 color: Colors
//                                                                     .white,
//                                                                 Icons.add,
//                                                                 size: 13.sp,
//                                                               ),
//                                                             ),
//                                                           ),
//                                                         ),
//                                                       ],
//                                                     ),
//                                                   ),
//                                                 ],
//                                               ),
//                                             ),
//                                             Row(
//                                               children: [
//                                                 SizedBox(
//                                                   width: 75.w,
//                                                   child: Text(
//                                                     "₹ ${homeprovider.data[index].rs}",
//                                                     textAlign: TextAlign.end,
//                                                   ),
//                                                 ),
//                                                 Padding(
//                                                   padding: EdgeInsets.all(10.w),
//                                                   child: InkWell(
//                                                     onTap: () {
//                                                       homeprovider.removelist(
//                                                           id: homeprovider
//                                                               .data[index].id);
//                                                     },
//                                                     child: const Icon(
//                                                       Icons.delete,
//                                                       color: Colors.red,
//                                                     ),
//                                                   ),
//                                                 )
//                                               ],
//                                             ),
//                                           ],
//                                         ),
//                                       ),
//                                       15.verticalSpace,
//                                     ],
//                                   ).horizontalPadding(12.w),
//                                 ),
//                               ),
//                             ),
//                           ),
//                     homeprovider.data.isEmpty
//                         ? const SizedBox()
//                         : Row(
//                             mainAxisAlignment: MainAxisAlignment.end,
//                             children: [
//                               InkWell(
//                                 onTap: () async {
//                                   showPaymentModeDialog(
//                                       context,
//                                       billingProvider.paymentModeResponse,
//                                       homeprovider.getTotalAmount().toString());
//                                 },
//                                 child: Container(
//                                         decoration: BoxDecoration(
//                                             borderRadius:
//                                                 BorderRadius.circular(10.r),
//                                             color: Colors.green),
//                                         child: Row(
//                                           children: [
//                                             Text(
//                                               "Pay  ",
//                                               style: TextStyle(
//                                                   color: Colors.white,
//                                                   fontSize: 17.sp),
//                                             ),
//                                             Text(
//                                               "₹ ${homeprovider.getTotalAmount()}",
//                                               style: TextStyle(
//                                                   color: Colors.white,
//                                                   fontSize: 17.sp,
//                                                   fontWeight: FontWeight.w600),
//                                             )
//                                           ],
//                                         ).symmetricPadding(
//                                             vertical: 7.h, horizontal: 15.w))
//                                     .horizontalPadding(15.w),
//                               )
//                             ],
//                           ).bottomPadding(10.h),
//                   ],
//                 ),
//               ),
//             ),
//           )),
//     );
//   }

//   String? _selectedPaymentMode = "Cash";
//   int? modeid = 1;
//   List poojalist = [];
//   final ValueNotifier<bool> isLoading = ValueNotifier(false);

//   void showPaymentModeDialog(
//       BuildContext context, PaymentModeResponse? mode, String? amt) {
//     final bill = context.read<BillingProvider>();
//     final home = context.read<HomeProvider>();

//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return StatefulBuilder(builder: (context, setState) {
//           return AlertDialog(
//             title: Text(
//               'Select Mode',
//               style: TextStyle(fontSize: 15.sp),
//             ),
//             content: SingleChildScrollView(
//               child: SizedBox(
//                   width: 200.w,
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     children: mode!.data!
//                         .map(
//                           (mode) => RadioListTile<String>(
//                             title: Text(mode.name.toString()),
//                             value: mode.name ?? '',
//                             groupValue: _selectedPaymentMode,
//                             onChanged: (String? value) {
//                               setState(() {
//                                 _selectedPaymentMode = value;
//                                 modeid = mode.id;
//                               });
//                             },
//                           ),
//                         )
//                         .toList(),
//                   )),
//             ),
//             actions: [
//               ValueListenableBuilder<bool>(
//                 valueListenable: isLoading,
//                 builder: (context, value, child) => InkWell(
//                   onTap: () async {
//                     isLoading.value = true;
//                     poojalist.clear();
//                     DateTime now = DateTime.now();
//                     int? len = home.data.length;
//                     for (int i = 0; i < len; i++) {
//                       poojalist.add({
//                         "name": nameController.text.isEmpty
//                             ? 'Customer'
//                             : nameController.text,
//                         "star_id": bill.starId == '' || bill.starId!.isEmpty
//                             ? '28'
//                             : bill.starId,
//                         "pooja": home.data[i].name,
//                         "pooja_id": home.data[i].id.toString(),
//                         "qty": home.data[i].qty.toString(),
//                         "date": "${now.year}-${now.month}-${now.day}",
//                         "rate": home.data[i].rs,
//                         "is_scheduled": "0"
//                       });
//                     }
//                     await bill.savequickbill(
//                         amt: amt, modeid: modeid, poojalist: poojalist);
//                     if (bill.savequickbills?.status == true) {
//                       if (bill.isConnected == true) {
//                         await posPrinter(bill);
//                       } else {
//                         await bill.checkPrinter();
//                         if (bill.isConnected == true) {
//                           await posPrinter(bill);
//                         } else {
//                           Helpers.successToast("Printer is not connected");
//                         }
//                       }

//                       isLoading.value = false;
//                       Helpers.successToast("${bill.savequickbills?.message}");
//                       if (!context.mounted) return;
//                       Navigator.of(context).pop(false);
//                       Navigator.of(context).pop(false);
//                     }
//                   },
//                   child: Container(
//                     decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(10.r),
//                         color: Colors.green),
//                     child: isLoading.value == true
//                         ? const CircularProgressIndicator(
//                             color: Colors.white,
//                           ).symmetricPadding(vertical: 7.h, horizontal: 10.w)
//                         : const Text(
//                             "Submit",
//                             style: TextStyle(color: Colors.white),
//                           ).symmetricPadding(vertical: 7.h, horizontal: 10.w),
//                   ),
//                 ),
//               )
//             ],
//           );
//         });
//       },
//     );
//   }

//   posPrinter(BillingProvider previewBillProvider) async {
//     final home = context.read<HomeProvider>();
//     DateTime time = DateTime.parse(
//         "${previewBillProvider.savequickbills?.summary?.billDate}");
//     // String? today = "${time.day}/${time.month}/${time.year} ";
//     String? today = DateFormat('dd/MM/yyyy').format(time);

//     if (previewBillProvider.isConnected) {

//       await SunmiPrinter.initPrinter();
//       SunmiStyle(fontSize: 26, bold: true);
//       await SunmiPrinter.setAlignment(align: SunmiPrintAlign.CENTER);
//       await SunmiPrinter.lineWrap(1);
//       previewBillProvider.savequickbills?.billImage == null ||
//               previewBillProvider.savequickbills?.billImage == ''
//           ? null
//           : await SunmiPrinter.printImage(
//               image: previewBillProvider.imageData!,
//               align: SunmiPrintAlign.CENTER);
//       previewBillProvider.savequickbills?.billImage == null ||
//               previewBillProvider.savequickbills?.billImage == ''
//           ? null
//           : await SunmiPrinter.lineWrap(2);
//       await SunmiPrinter.printText(
//           content: "${previewBillProvider.savequickbills?.temple?.nameMal}",
//           style: SunmiStyle(
//               fontSize: 28,
//               isUnderLine: false,
//               bold: true,
//               align: SunmiPrintAlign.CENTER));
//       await SunmiPrinter.lineWrap(1);
//       await SunmiPrinter.printText(
//           content:
//               "${previewBillProvider.savequickbills?.temple?.addressLine1}\n",
//           style: SunmiStyle(
//               fontSize: 24,
//               isUnderLine: false,
//               bold: true,
//               align: SunmiPrintAlign.CENTER));
//       await SunmiPrinter.printText(
//           content:
//               "${previewBillProvider.savequickbills?.temple?.addressLine2}\n",
//           style: SunmiStyle(
//               fontSize: 24,
//               isUnderLine: false,
//               bold: true,
//               align: SunmiPrintAlign.CENTER));
//       await SunmiPrinter.printText(
//           content: "${previewBillProvider.savequickbills?.temple?.phone}\n",
//           style: SunmiStyle(
//               fontSize: 25,
//               isUnderLine: false,
//               bold: true,
//               align: SunmiPrintAlign.CENTER));

//       await SunmiPrinter.printTable(
//         // style: SunmiStyle(fontSize: 25),
//         cols: [
//           ColumnMaker(
//               text:
//                   "Bill No:${previewBillProvider.savequickbills?.summary?.id}",
//               align: SunmiPrintAlign.LEFT,
//               width: 9),
//           ColumnMaker(text: today, align: SunmiPrintAlign.RIGHT)
//         ],
//       );
//       await SunmiPrinter.lineWrap(1);
//       await SunmiPrinter.printText(
//           content: "${previewBillProvider.savequickbills?.summary?.name}\n",
//           style: SunmiStyle(
//               fontSize: 26,
//               isUnderLine: false,
//               bold: false,
//               align: SunmiPrintAlign.LEFT));
//       await SunmiPrinter.lineWrap(1);
//       int? lenn = previewBillProvider.savequickbills?.details?.length;
//       final data = previewBillProvider.savequickbills?.details;
//       // List<Details>? data = previewBillProvider.saveBillResponse?.details;
//       for (int i = 0; i < lenn!; i++) {
//         previewBillProvider.getPoojanamefromid(
//             int.parse(
//                 "${previewBillProvider.savequickbills?.details![0].pooja}"),
//             home.quickbills);
//         await SunmiPrinter.printText(
//             content:
//                 "${i + 1}) ${previewBillProvider.savequickbills?.details![i].pooja}  ${data![i].qty}x${data[i].rate}\n",
//             style: SunmiStyle(
//                 fontSize: 26,
//                 isUnderLine: false,
//                 bold: false,
//                 align: SunmiPrintAlign.LEFT));

//         // await SunmiPrinter.printText(
//         //     content:
//         //         "${previewBillProvider.person[i].name} ${data[i].starMal}\n",
//         //     style: SunmiStyle(
//         //         fontSize: 26,
//         //         isUnderLine: false,
//         //         bold: false,
//         //         align: SunmiPrintAlign.LEFT));
//         // await SunmiPrinter.printText(
//         //     content: "${data[i].poojaMal} ${data[i].qty}x${data[i].rate}\n",
//         //     style: SunmiStyle(
//         //         fontSize: 26,
//         //         isUnderLine: false,
//         //         bold: false,
//         //         align: SunmiPrintAlign.LEFT));
//         // for (int n = 0; n < datass.length; n += 2) {
//         //   if (n + 1 < datass.length) {
//         //     await SunmiPrinter.printText(
//         //         content: "${datass[n]}, ${datass[n + 1]}",
//         //         style: SunmiStyle(
//         //             fontSize: 26,
//         //             isUnderLine: false,
//         //             bold: false,
//         //             align: SunmiPrintAlign.LEFT));
//         //   } else {
//         //     if (datass.length > 1) {
//         //       await SunmiPrinter.printText(
//         //           content: ",\n${datass[n]}\n",
//         //           style: SunmiStyle(
//         //               fontSize: 26,
//         //               isUnderLine: false,
//         //               bold: false,
//         //               align: SunmiPrintAlign.LEFT));
//         //     } else {
//         //       await SunmiPrinter.printText(
//         //           content: "${datass[n]}\n",
//         //           style: SunmiStyle(
//         //               fontSize: 26,
//         //               isUnderLine: false,
//         //               bold: false,
//         //               align: SunmiPrintAlign.LEFT));
//         //     }
//         // }
//       }
//       // data[i].address == null
//       //     ? ''
//       //     : await SunmiPrinter.printText(
//       //         content: "${data[i].address}\n",
//       //         style: SunmiStyle(
//       //             fontSize: 26,
//       //             isUnderLine: false,
//       //             bold: false,
//       //             align: SunmiPrintAlign.LEFT));

//       await SunmiPrinter.lineWrap(1);
//       await SunmiPrinter.printTable(
//         // style: SunmiStyle(fontSize: 27, bold: true),
//         cols: [
//           ColumnMaker(
//             text: "Mode: ${previewBillProvider.savequickbills?.summary?.mode}",
//             align: SunmiPrintAlign.LEFT,
//           ),
//           ColumnMaker(
//             text:
//                 "Total: ${previewBillProvider.savequickbills?.summary?.total}",
//             align: SunmiPrintAlign.RIGHT,
//           ),
//         ],
//       );
//       await SunmiPrinter.lineWrap(1);
//       await SunmiPrinter.printText(
//           content:
//               "Book Online ${previewBillProvider.savequickbills?.temple?.website} \n",
//           style: SunmiStyle(
//               fontSize: 24,
//               isUnderLine: false,
//               bold: true,
//               align: SunmiPrintAlign.CENTER));
//       await SunmiPrinter.lineWrap(1);
//       await SunmiPrinter.feedPaper();
//       await SunmiPrinter.cutPaper().then((value) {
//         Helpers.successToast('Bill Saved & Printed Successfully');
//       });
//     }
//   }
// }

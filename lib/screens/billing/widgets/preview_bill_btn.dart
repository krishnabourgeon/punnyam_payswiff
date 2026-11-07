import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:punnyam/providers/billing_provider.dart';
import 'package:punnyam/screens/billing/widgets/payment_mode_dialog.dart';
import 'package:punnyam/screens/billing/widgets/qr_payment_dialog.dart';
import 'package:punnyam/screens/customer_creation/customer_selection_screen.dart';
import 'package:punnyam/services/app_config.dart';
import 'package:punnyam/services/apos_payment.dart';
import 'package:punnyam/services/apos_printer.dart';
import 'package:punnyam/services/helpers.dart';
import 'package:punnyam/services/validation_helper.dart';
import 'package:punnyam/widgets/punnyam_textfiled.dart';
import '../../../common/common_button.dart';
import '../../../models/save_bill_response.dart';

class PreviewBillButton extends StatefulWidget {
  const PreviewBillButton(
      {Key? key,
      required this.previewBillProvider,
      required this.buildContext,
      required this.trans})
      : super(key: key);
  final BillingProvider previewBillProvider;
  final BuildContext buildContext;
  final TextEditingController trans;
  @override
  State<PreviewBillButton> createState() => _PreviewBillButtonState();
}

class _PreviewBillButtonState extends State<PreviewBillButton> {
  // BlueThermalPrinter printer = BlueThermalPrinter.instance;
  List<PoojaPersons> person = [];
  List<Details> details = [];
  Temple? temple;
  Summary? summary;
  @override
  void initState() {
    Future.microtask(() {
      widget.previewBillProvider.checkPrinter();
      initAll();
    });
    super.initState();
  }

  BillingProvider? bill;
  routeTo(BuildContext buildContext) {
    Navigator.pushAndRemoveUntil(
      buildContext,
      MaterialPageRoute(
          builder: (buildContext) => const CustomerSelectionScreen()),
      (route) => true,
    ).then((value) {
      widget.previewBillProvider.previewDetailsList.clear();
      widget.previewBillProvider.poojaDetailsList.clear();
    });
  }

  Future<void> initAll() async {
    Future.microtask(() {
      final provider = widget.previewBillProvider;
      widget.previewBillProvider.updatetransid(widget.trans.text);
      details = provider.saveBillResponse?.details ?? [];
      temple = provider.saveBillResponse?.temple;
      summary = provider.saveBillResponse?.summary;
      widget.previewBillProvider
          .updateTemple(provider.saveBillResponse?.temple);
      widget.previewBillProvider
          .updateSummary(provider.saveBillResponse?.summary);
      for (int i = 0; i < details.length; i++) {
        person.add(PoojaPersons(
            id: (i + 1).toString(),
            date: details[i].date.toString(),
            // gothra: details[i].gothra?.nameEng,
            // rashi: details[i].rashi?.nameEng,
            dietyName: details[i].deity.toString(),
            name: details[i].name ?? 'Customer'.toString(),
            address: details[i].address.toString(),
            poojaName: details[i].pooja.toString(),
            rate: "${details[i].qty}/${details[i].rate}",
            star: details[i].star.toString()));
      }
    });

    bill = widget.previewBillProvider;
  }

  @override
  Widget build(BuildContext context) {
    return Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          decoration: BoxDecoration(color: Colors.white, boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(.2),
                spreadRadius: 5.r,
                blurRadius: 10.r),
            BoxShadow(
                color: Colors.black.withOpacity(.2),
                spreadRadius: 5.r,
                blurRadius: 10.r)
          ]),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CommonButton(
                onPressed: () {
                  widget.previewBillProvider.previewDetailsList.clear();
                  widget.previewBillProvider.poojaDetailsList.clear();
                  widget.previewBillProvider.nameController.clear();
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const CustomerSelectionScreen()),
                    (route) => route.isFirst,
                  );
                },
                margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                title: 'Discard',
              ),
              CommonButton(
                onPressed:
                    widget.previewBillProvider.paidAmountErrorMessage == null &&
                            widget.previewBillProvider.paidAmountController.text
                                .trim()
                                .isNotEmpty
                        ? () async {
                            // 1. Ask for the payment mode (list from the API)
                            final choice = await showPaymentModeDialog(
                                context, widget.previewBillProvider);
                            if (choice == null) return; // user cancelled

                            // 2. Pass the selected mode id (+ QR transaction id)
                            widget.previewBillProvider
                              ..selectPaymentMode(choice.mode)
                              ..updatetransid(choice.transactionId);

                            // 2b. QR -> show Payswiff dynamic QR and wait for payment
                            if (isQrMode(choice.mode)) {
                              if (!await AposPrinter.isPosDevice() ||
                                  !await AposPayment.ensureActivated()) {
                                Helpers.successToast(
                                    'QR payment works only on the activated POS machine');
                                return;
                              }
                              final amount = double.tryParse(widget
                                      .previewBillProvider
                                      .paidAmountController
                                      .text
                                      .trim()) ??
                                  0;
                              final orderRef =
                                  'PNQR${AppConfig.counterID ?? 0}${DateTime.now().millisecondsSinceEpoch}';
                              if (!context.mounted) return;
                              final qr = await showQrPaymentDialog(context,
                                  amount: amount, orderRefNo: orderRef);
                              if (!qr.isApproved) {
                                Helpers.successToast(qr.responseMessage ??
                                    'Payment ${qr.status}');
                                return; // bill is NOT saved
                              }
                              widget.previewBillProvider.updatetransid(
                                  qr.transactionRefNo ?? qr.orderId ?? orderRef);
                            }

                            // 3. Save (Card -> opens the Payswiff screen first)
                            widget.previewBillProvider.saveBill(
                                onSuccess: () {
                                  initAll().then((value) async {
                                    // posPrinter(bill!);
                                    if (await AposPrinter.isPosDevice()) {
                                      return aposPrint(widget.previewBillProvider);
                                    }
                                  }).then((value) {
                                    bill?.clearValues();
                                    routeTo(widget.buildContext);
                                    showpop(widget.buildContext);
                                  });
                                },
                                onFailure: () => Helpers.successToast(
                                    'Oops...! Something went wrong...'));
                          }
                        : null,
                margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                title: 'Save Bill',
                colors: [
                  widget.previewBillProvider.paidAmountErrorMessage == null &&
                          widget.previewBillProvider.paidAmountController.text
                              .trim()
                              .isNotEmpty
                      ? Colors.green
                      : Colors.green.withOpacity(.5),
                  widget.previewBillProvider.paidAmountErrorMessage == null &&
                          widget.previewBillProvider.paidAmountController.text
                              .trim()
                              .isNotEmpty
                      ? Colors.greenAccent
                      : Colors.greenAccent.withOpacity(.5)
                ],
              ),
            ],
          ),
        ));
  }

  showPopUp(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "Please enter a mobile number",
            style: TextStyle(fontSize: 13.sp),
          ),
          actions: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.w),
                  child: PunnyamTextField(
                    hintText: 'Mobile Number',
                    maxLength: 10,
                    height: 35.h,
                    textEditingController:
                        context.read<BillingProvider>().mobileNumberController,
                    inputFormatter: [FilteringTextInputFormatter.digitsOnly],
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.number,
                    onChanged: (value) => context.read<BillingProvider>()
                      ..updateValidationMessage(
                          validationTypes: ValidationTypes.mobileNumber,
                          validationMessage:
                              ValidationHelperClass.validateMobileNumber(
                                      value.trim()) ??
                                  '')
                      ..updatePreviewBillingFormValidated(),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      child: const Text("Cancel"),
                      onPressed: () {
                        Navigator.of(context).pop(false);
                        widget.trans.clear();
                        widget.previewBillProvider.clearValues();
                        widget.previewBillProvider.previewDetailsList.clear();
                        widget.previewBillProvider.poojaDetailsList.clear();
                        widget.previewBillProvider.nameController.clear();
                      },
                    ),
                    TextButton(
                      onPressed: () {
                        if (context
                                .read<BillingProvider>()
                                .mobileErrorMessage !=
                            null) {
                          Helpers.successToast(
                              'Please provide a valid mobile number');
                        } else {
                          Navigator.pop(context);
                          FocusScope.of(context).unfocus();
                          List<String> poojaString = [];
                          for (int i = 0;
                              i < context.read<BillingProvider>().person.length;
                              i++) {
                            poojaString.add(
                                "\n*${context.read<BillingProvider>().person[i].id?.trim()})*\nPooja Date: *${context.read<BillingProvider>().person[i].date?.trim()}*,\nDeity Name: *${context.read<BillingProvider>().person[i].dietyName?.trim()}*\nPooja: *${context.read<BillingProvider>().person[i].poojaName?.trim()}* - *${context.read<BillingProvider>().person[i].rate}*\nName: *${context.read<BillingProvider>().person[i].name?.trim()}*\nStar Name: *${context.read<BillingProvider>().person[i].star?.trim()}*");
                          }

                          String text =
                              'Date: *${context.read<BillingProvider>().summary?.billDate?.trim()}*\n\nBill No: *${context.read<BillingProvider>().summary?.id}*\n\nTemple Name: *${context.read<BillingProvider>().temple?.name?.trim()}*\n\nTemple Email: *${context.read<BillingProvider>().temple?.email?.trim()}*\n\nCounter: *${context.read<BillingProvider>().summary?.counter?.trim()}*\n\nPooja Details:\n${poojaString.toString().substring(1, poojaString.toString().length - 1)}\n\nPayment Mode: *${context.read<BillingProvider>().summary?.mode}*\n\nTotal Amount: *${context.read<BillingProvider>().totalRateController.text.toString().trim()}*\n\nAmount Paid: *${context.read<BillingProvider>().paidAmountController.text.trim()}*\n\nBook Online: *${context.read<BillingProvider>().temple?.website}*';

                          context
                              .read<BillingProvider>()
                              .launchWhatsAppUri(text);
                        }
                        widget.trans.clear();
                        widget.previewBillProvider.clearValues();
                        widget.previewBillProvider.previewDetailsList.clear();
                        widget.previewBillProvider.poojaDetailsList.clear();
                        widget.previewBillProvider.nameController.clear();
                      },
                      child: const Text("OK"),
                    ),
                  ],
                ),
              ],
            )
          ],
        );
      },
    );
  }

  showpop(BuildContext context) {
    showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              title: Text(
                "Do you want to share the receipt in whatsapp",
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w400),
              ),
              actions: <Widget>[
                Row(
                  children: [
                    Expanded(
                      child: CommonButton(
                          title: "No",
                          onPressed: () {
                            Navigator.of(context).pop(false);
                            widget.trans.clear();
                            widget.previewBillProvider.clearValues();
                            widget.previewBillProvider.previewDetailsList
                                .clear();
                            widget.previewBillProvider.poojaDetailsList.clear();
                            widget.previewBillProvider.nameController.clear();
                          }),
                    ),
                    10.horizontalSpace,
                    Expanded(
                      child: CommonButton(
                          title: "Yes",
                          onPressed: () {
                            Navigator.of(context).pop(false);
                            showPopUp(widget.buildContext);
                          }),
                    )
                  ],
                )
              ]);
        });
  }

  // biPosPrint(BillingProvider previewBillProvider) async {
  //   DateTime time = DateTime.now();
  //   String? today = "${time.day}/${time.month}/${time.year}";

  //   final connected = await PrinterService.ensureConnected();
  //   if (!connected) return false;

  //   final profile = await CapabilityProfile.load();

  //   final generator = Generator(
  //     PaperSize.mm80,
  //     profile,
  //   );

  //   List<int> bytes = [];

  //   bytes += generator.reset();

  //   // LOGO IMAGE
  //   if (previewBillProvider.imageData != null) {
  //     img.Image? image = img.decodeImage(
  //       previewBillProvider.imageData!,
  //     );
  //     print(previewBillProvider.imageData);
  //     if (image != null
  //         // ||
  //         //     previewBillProvider.imageData !=
  //         //         'https://miro.medium.com/v2/resize:fit:912/1*2EF1A0OGnlsPE8z07zmP9g.jpeg'
  //         ) {
  //       bytes += generator.image(image!, align: PosAlign.center);
  //       // bytes += generator.emptyLines(1);
  //     }
  //   }

  //   // TEMPLE NAME
  //   bytes += generator.text(
  //     "${temple?.name}",
  //     styles: const PosStyles(
  //       align: PosAlign.center,
  //       bold: true,
  //       height: PosTextSize.size2,
  //       width: PosTextSize.size2,
  //     ),
  //   );

  //   // ADDRESS
  //   bytes += generator.text(
  //     "${temple?.addressLine1}",
  //     styles: const PosStyles(
  //       align: PosAlign.center,
  //       bold: true,
  //     ),
  //   );

  //   bytes += generator.text(
  //     "${temple?.addressLine2}",
  //     styles: const PosStyles(
  //       align: PosAlign.center,
  //       bold: true,
  //     ),
  //   );

  //   bytes += generator.text(
  //     "${temple?.phone}",
  //     styles: const PosStyles(
  //       align: PosAlign.center,
  //       bold: true,
  //     ),
  //   );

  //   bytes += generator.emptyLines(1);

  //   // BILL NO + DATE
  //   bytes += generator.row([
  //     PosColumn(
  //       text: "Bill No: ${summary?.id ?? "Offline"}",
  //       width: 6,
  //       styles: const PosStyles(align: PosAlign.left),
  //     ),
  //     PosColumn(
  //       text: today,
  //       width: 6,
  //       styles: const PosStyles(align: PosAlign.right),
  //     ),
  //   ]);

  //   bytes += generator.hr();

  //   int len = previewBillProvider.saveBillResponse?.details?.length ?? 0;

  //   List<Details>? data = previewBillProvider.saveBillResponse?.details;
  //   for (int i = 0; i < len; i++) {
  //     print(data![i].deityMal);

  //     bytes += generator.text(
  //       "${previewBillProvider.person[i].id}) ${data![i].deity}",
  //       styles: const PosStyles(
  //         bold: true,
  //       ),
  //     );
  //     print("${previewBillProvider.person[i].name} - ${data[i].star}");
  //     bytes += generator.text(
  //       "${previewBillProvider.person[i].name} - ${data[i].star}",
  //     );
  //     print("${data[i].pooja} ${data[i].qty} x ${data[i].rate}");
  //     bytes += generator.text(
  //       "${data[i].pooja} ${data[i].qty} x ${data[i].rate}",
  //     );

  //     // DATE EXTRACTION
  //     RegExp datePattern = RegExp(r'\d{2}-\d{2}-\d{4}');
  //     Iterable<Match> matches = datePattern.allMatches("${data[i].date}");

  //     List<String> dates = matches.map((e) => e.group(0)!).toList();

  //     for (String d in dates) {
  //       bytes += generator.text(d);
  //     }

  //     // ADDRESS
  //     if (data[i].address != null) {
  //       bytes += generator.text("${data[i].address}");
  //     }

  //     bytes += generator.emptyLines(1);
  //   }

  //   bytes += generator.hr();

  //   // MODE + TOTAL
  //   bytes += generator.row([
  //     PosColumn(
  //       text: "Mode: ${summary?.mode}",
  //       width: 6,
  //       styles: const PosStyles(
  //         align: PosAlign.left,
  //       ),
  //     ),
  //     PosColumn(
  //       text: "Total: ${summary?.total}",
  //       width: 6,
  //       styles: const PosStyles(
  //         align: PosAlign.right,
  //         bold: true,
  //       ),
  //     ),
  //   ]);

  //   bytes += generator.emptyLines(1);

  //   // WEBSITE
  //   bytes += generator.text(
  //     "Book Online ${temple?.website}",
  //     styles: const PosStyles(
  //       align: PosAlign.center,
  //       bold: true,
  //     ),
  //   );

  //   bytes += generator.feed(0);

  //   bytes += generator.cut();
  //   return await PrintBluetoothThermal.writeBytes(bytes);
  // }

// //? sunmi printer
//   posPrinter(BillingProvider previewBillProvider) async {
//     DateTime time = DateTime.now();
//     String? today = "${time.day}/${time.month}/${time.year}";

//     if (widget.previewBillProvider.isConnected) {
//       if (widget.previewBillProvider.printerErrorMessage.isEmpty) {
//         await SunmiPrinter.initPrinter();
//         SunmiStyle(fontSize: 26, bold: true);
//         await SunmiPrinter.setAlignment(align: SunmiPrintAlign.CENTER);
//         await SunmiPrinter.lineWrap(1);
//         if (previewBillProvider.imageData != null) {
//           await SunmiPrinter.printImage(
//               image: previewBillProvider.imageData!,
//               align: SunmiPrintAlign.CENTER);
//           await SunmiPrinter.lineWrap(2);
//         }
//         await SunmiPrinter.printText(
//             content: "${temple?.nameMal}",
//             style: SunmiStyle(
//                 fontSize: 28,
//                 isUnderLine: false,
//                 bold: true,
//                 align: SunmiPrintAlign.CENTER));
//         await SunmiPrinter.lineWrap(1);
//         await SunmiPrinter.printText(
//             content: "${temple?.addressLine1}\n",
//             style: SunmiStyle(
//                 fontSize: 24,
//                 isUnderLine: false,
//                 bold: true,
//                 align: SunmiPrintAlign.CENTER));
//         await SunmiPrinter.printText(
//             content: "${temple?.addressLine2}\n",
//             style: SunmiStyle(
//                 fontSize: 24,
//                 isUnderLine: false,
//                 bold: true,
//                 align: SunmiPrintAlign.CENTER));
//         await SunmiPrinter.printText(
//             content: "${temple?.phone}\n",
//             style: SunmiStyle(
//                 fontSize: 25,
//                 isUnderLine: false,
//                 bold: true,
//                 align: SunmiPrintAlign.CENTER));
//         await SunmiPrinter.lineWrap(1);
//         await SunmiPrinter.printTable(
//           // style: SunmiStyle(fontSize: 25),
//           cols: [
//             ColumnMaker(
//                 text: "Bill No: ${summary?.id ?? "Offline"}",
//                 align: SunmiPrintAlign.LEFT,
//                 width: 10),
//             ColumnMaker(text: today, align: SunmiPrintAlign.RIGHT)
//           ],
//         );
//         await SunmiPrinter.lineWrap(1);
//         int? lenn = previewBillProvider.saveBillResponse?.details?.length;
//         List<Details>? data = previewBillProvider.saveBillResponse?.details;
//         for (int i = 0; i < lenn!; i++) {
//           List datass = [];
//           RegExp datePattern = RegExp(r'\d{2}-\d{2}-\d{4}');
//           Iterable<Match> matches = datePattern.allMatches("${data![i].date}");

//           for (Match match in matches) {
//             datass.add("${match.group(0)}");
//           }
//           print(
//               "...${previewBillProvider.person[i].id}) ${data[i].deityMal}\n${previewBillProvider.person[i].name} - ${data[i].starMal}\n${data[i].poojaMal} ${data[i].qty}x${data[i].rate}\n");
//           await SunmiPrinter.printText(
//               content:
//                   "${previewBillProvider.person[i].id}) ${data[i].deityMal}\n",
//               style: SunmiStyle(
//                   fontSize: 26,
//                   isUnderLine: false,
//                   bold: false,
//                   align: SunmiPrintAlign.LEFT));

//           await SunmiPrinter.printText(
//               content:
//                   "${previewBillProvider.person[i].name} - ${data[i].starMal}\n",
//               style: SunmiStyle(
//                   fontSize: 26,
//                   isUnderLine: false,
//                   bold: false,
//                   align: SunmiPrintAlign.LEFT));
//           await SunmiPrinter.printText(
//               content: "${data[i].poojaMal} ${data[i].qty}x${data[i].rate}\n",
//               style: SunmiStyle(
//                   fontSize: 26,
//                   isUnderLine: false,
//                   bold: false,
//                   align: SunmiPrintAlign.LEFT));
//           for (int n = 0; n < datass.length; n += 2) {
//             if (n + 1 < datass.length) {
//               print("..${datass[n]}, ${datass[n + 1]}");
//               await SunmiPrinter.printText(
//                   content: "${datass[n]}, ${datass[n + 1]}",
//                   style: SunmiStyle(
//                       fontSize: 26,
//                       isUnderLine: false,
//                       bold: false,
//                       align: SunmiPrintAlign.LEFT));
//             } else {
//               if (datass.length > 1) {
//                 await SunmiPrinter.printText(
//                     content: ",\n${datass[n]}\n",
//                     style: SunmiStyle(
//                         fontSize: 26,
//                         isUnderLine: false,
//                         bold: false,
//                         align: SunmiPrintAlign.LEFT));
//               } else {
//                 await SunmiPrinter.printText(
//                     content: "${datass[n]}\n",
//                     style: SunmiStyle(
//                         fontSize: 26,
//                         isUnderLine: false,
//                         bold: false,
//                         align: SunmiPrintAlign.LEFT));
//               }
//             }
//           }
//           data[i].address == null
//               ? ''
//               : await SunmiPrinter.printText(
//                   content: "${data[i].address}\n",
//                   style: SunmiStyle(
//                       fontSize: 26,
//                       isUnderLine: false,
//                       bold: false,
//                       align: SunmiPrintAlign.LEFT));
//           await SunmiPrinter.lineWrap(1);
//         }
//         await SunmiPrinter.printTable(
//           // style: SunmiStyle(fontSize: 27, bold: true),
//           cols: [
//             ColumnMaker(
//               text: "Mode: ${summary?.mode}",
//               align: SunmiPrintAlign.LEFT,
//             ),
//             ColumnMaker(
//               text: "Total: ${summary?.total}",
//               align: SunmiPrintAlign.RIGHT,
//             ),
//           ],
//         );
//         await SunmiPrinter.lineWrap(1);
//         await SunmiPrinter.printText(
//             content: "Book Online ${temple?.website} \n",
//             style: SunmiStyle(
//                 fontSize: 24,
//                 isUnderLine: false,
//                 bold: true,
//                 align: SunmiPrintAlign.CENTER));
//         await SunmiPrinter.lineWrap(1);
//         await SunmiPrinter.feedPaper();
//         await SunmiPrinter.cutPaper().then((value) {
//           Helpers.successToast('Bill Saved & Printed Successfully');
//         });
//         // bill?.clearValues();
//         // widget.previewBillProvider.clearValues();
//         // widget.previewBillProvider.previewDetailsList.clear();
//         // widget.previewBillProvider.poojaDetailsList.clear();
//       } else {
//         Helpers.successToast(widget.previewBillProvider.printerErrorMessage);
//       }
//     } else {
//       Helpers.successToast('Printer not connected');
//     }

// //? .....thermal bluetooth print

// //     else {
// //       DateTime time = DateTime.now();
// //       String? today = "${time.day}/${time.month}/${time.year}";
// //       // List<LineText> list = [];
// //       previewBillProvider.saveBillResponse?.billimage == null ||
// //               previewBillProvider.saveBillResponse?.billimage == ''
// //           ? null
// //           : await printer.printImageBytes(previewBillProvider.imageData!);
// //       previewBillProvider.saveBillResponse?.billimage == null ||
// //               previewBillProvider.saveBillResponse?.billimage == ''
// //           ? null
// //           : await printer.printNewLine();

// //       await printer.printCustom('${temple?.name}', 3, 1);
// // //  await printer.printCustom('${temple?.addressLine1}', 1, 1);
// // //     await printer.printCustom('${temple?.addressLine2}', 1, 1);
// //       await printer.printCustom('${temple?.phone}', 1, 1);
// //       // await printer.printNewLine();

// //       await printer.printCustom(
// //           "________________________________________", 1, 1);
// //       await printer.printLeftRight(
// //         'Bill No : ${summary?.id} ',
// //         today,
// //         1,
// //       );

// //       await printer.printCustom(
// //           "________________________________________", 1, 1);
// //       previewBillProvider.person.length == 1
// //           ? await printer.printNewLine()
// //           : null;

// // //       // list.add(LineText(
// // //       //     type: LineText.TYPE_TEXT,
// // //       //     content: '${temple?.name}',
// // //       //     size: 33,
// // //       //     align: LineText.ALIGN_CENTER,
// // //       //     linefeed: 1));
// // //       // list.add(LineText(
// // //       //     type: LineText.TYPE_TEXT,
// // //       //     content: '${temple?.addressLine1}',
// // //       //     size: 22,
// // //       //     align: LineText.ALIGN_CENTER,
// // //       //     linefeed: 1));
// // //       // list.add(LineText(
// // //       //     type: LineText.TYPE_TEXT,
// // //       //     content: '${temple?.addressLine1}',
// // //       //     size: 22,
// // //       //     align: LineText.ALIGN_CENTER,
// // //       //     linefeed: 1));
// // //       // list.add(LineText(
// // //       //     type: LineText.TYPE_TEXT,
// // //       //     content: '${temple?.phone}',
// // //       //     size: 22,
// // //       //     align: LineText.ALIGN_CENTER,
// // //       //     linefeed: 1));
// // //       // list.add(LineText(linefeed: 1));
// // //       // list.add(LineText(
// // //       //     type: LineText.TYPE_TEXT,
// // //       //     content: 'Bill No : ${summary?.id} ',
// // //       //     size: 25,
// // //       //     align: LineText.ALIGN_LEFT,
// // //       //     linefeed: 0));

// //       for (int i = 0; i < previewBillProvider.person.length; i++) {
// //         String? date = DateFormat('dd-MM-yyyy').format(DateTime.parse(
// //             "${previewBillProvider.previewDetailsList[i].fromDate}"));
// //         print("..date...$date");
// //         await printer.printCustom(
// //             "${previewBillProvider.person[i].id}) $date ${details[i].name} - ${details[i].star}",
// //             1,
// //             1);
// //         // await printer.printCustom('${details[i].deity}', 1, 1);
// //         await printer.printCustom(
// //             '${details[i].pooja} ${details[i].qty}x${details[i].rate}', 1, 1);
// //         details[i].address == null
// //             ? ''
// //             : await printer.printCustom('${details[i].address} ', 1, 1);

// // //     //? another blutooth printing

// // //     //     list.add(LineText(
// // //     //       type: LineText.TYPE_TEXT,
// // //     //       content:
// // //     //           "${previewBillProvider.person[i].id}) $date ${details[i].starMal}",
// // //     //       size: 25,
// // //     //       align: LineText.ALIGN_RIGHT,
// // //     //     ));

// // //     //     list.add(LineText(
// // //     //       type: LineText.TYPE_TEXT,
// // //     //       content:
// // //     //           '${details[i].poojaMal} ${details[i].qty}x${details[i].rate}',
// // //     //       size: 22,
// // //     //       align: LineText.ALIGN_LEFT,
// // //     //     ));
// // //     //     details[i].address == null
// // //     //         ? ''
// // //     //         : list.add(LineText(
// // //     //             type: LineText.TYPE_TEXT,
// // //     //             content: '${details[i].address} ',
// // //     //             size: 22,
// // //     //             align: LineText.ALIGN_LEFT,
// // //     //           ));
// //         await printer.printNewLine();
// //       }
// //       await printer.printCustom(
// //           "________________________________________", 1, 1);

// //       previewBillProvider.person.length == 1
// //           ? await printer.printNewLine()
// //           : null;

// //       await printer.printLeftRight(
// //           'Mode: ${summary?.mode}', 'Total: ${summary?.total}', 1);
// //       await printer.printNewLine();
// //       await printer.printCustom(
// //           "________________________________________", 1, 1);
// //       await printer.printCustom('Book online ${temple?.email}', 1, 1);
// //       await printer.printNewLine();

// //       await printer.paperCut();
// // //     //? another blutooth printing

// // //     //   list.add(LineText(linefeed: 1));
// // //     //   list.add(LineText(
// // //     //       type: LineText.TYPE_TEXT,
// // //     //       content: 'Mode:${summary?.mode}        ',
// // //     //       size: 24,
// // //     //       align: LineText.ALIGN_LEFT,
// // //     //       linefeed: 0));
// // //     //   list.add(LineText(
// // //     //       type: LineText.TYPE_TEXT,
// // //     //       content: '    Total${summary?.total}',
// // //     //       size: 24,
// // //     //       align: LineText.ALIGN_RIGHT,
// // //     //       linefeed: 1));
// // //     //   list.add(LineText(
// // //     //       type: LineText.TYPE_TEXT,
// // //     //       content: 'Book online ${temple?.email}',
// // //     //       weight: 1,
// // //     //       align: LineText.ALIGN_CENTER,
// // //     //       linefeed: 1));
// // //     //   list.add(LineText(linefeed: 1));
// // //     //   await bluetoothPrint.printReceipt(config, list);
// // //     //   Helpers.successToast("POS Printer not connected");
// //     }
//     bill?.clearValues();
//   }
// }




Future<void> aposPrint(BillingProvider p) async {
  final now = DateTime.now();
  final today = "${now.day}/${now.month}/${now.year}";
  final details = p.saveBillResponse?.details ?? [];

  final items = <Map<String, dynamic>>[];
  for (int i = 0; i < details.length; i++) {
    final d = details[i];
    final qty = int.tryParse(d.qty ?? '') ?? 1;
    final rate = double.tryParse(d.rate ?? '') ?? 0;
    items.add({
      // deity, pooja, devotee + star (same info as the Sunmi bill)
      'itemName': "${d.deityMal} - ${d.poojaMal}\n${p.person[i].name} - ${d.starMal}",
      'qty': qty,
      'amount': rate,
      'itemTotal': qty * rate,
    });
  }

  try {
    final card = p.lastCardPayment;
    final cardLines = card == null
        ? ''
        : "\nCard: ${card.cardBrand ?? ''} ${card.cardNumber ?? ''}"
            "\nRef No: ${card.referenceNumber ?? ''}"
            "\nRRN: ${card.rrn ?? ''}  Auth: ${card.authCode ?? ''}"
            "\nMID: ${card.mid ?? ''}  TID: ${card.tid ?? ''}";

    await AposPrinter.printReceipt({
      'header': temple?.nameMal ?? '',
      'address': "${temple?.addressLine1 ?? ''}\n${temple?.addressLine2 ?? ''}",
      'contactNo': temple?.phone ?? '',
      'billNo': "${summary?.id ?? 'Offline'}",
      'billTime': today,
      'printTime': "$today ${now.hour}:${now.minute.toString().padLeft(2, '0')}",
      'itemModelList': items,
      'totalItems': items.length,
      'totalAmount': double.tryParse("${summary?.total}") ?? 0,
      'itemsAmount': double.tryParse("${summary?.total}") ?? 0,
      'footer': "Mode: ${summary?.mode}$cardLines\nBook Online ${temple?.website ?? ''}",
    }, logo: p.imageData); // bill_image (already downloaded) - printed after the temple name
    Helpers.successToast('Bill Saved & Printed Successfully');
  } on PlatformException catch (e) {
    Helpers.successToast(e.message ?? 'Print failed');
  }
}
}

class PoojaPersons {
  String? name = 'Customer';
  String? address;
  String? id;
  String? date;
  String? rate;
  String? qty;
  String? poojaName;
  String? star;
  String? dietyName;
  String? gothra;
  String? rashi;
  PoojaPersons({
    this.id,
    this.name,
    this.address,
    this.rate,
    this.qty,
    this.gothra,
    this.rashi,
    this.poojaName,
    this.star,
    this.dietyName,
    this.date,
  });
}

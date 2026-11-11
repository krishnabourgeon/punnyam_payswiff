import 'package:auto_height_grid_view/auto_height_grid_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_sunmi_printer_plus/column_maker.dart';
import 'package:flutter_sunmi_printer_plus/enums.dart';
import 'package:flutter_sunmi_printer_plus/flutter_sunmi_printer_plus.dart';
import 'package:flutter_sunmi_printer_plus/sunmi_style.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:punnyam/common/common_functions.dart';
import 'package:punnyam/common/custom_drop_down_search.dart';
import 'package:punnyam/common/extension.dart';
import 'package:punnyam/models/card_payment_result.dart';
import 'package:punnyam/providers/billing_provider.dart';
import 'package:punnyam/providers/home_provider.dart';
import 'package:punnyam/screens/billing/widgets/payment_mode_dialog.dart';
import 'package:punnyam/screens/billing/widgets/qr_payment_dialog.dart';
import 'package:punnyam/screens/home/home.dart';
import 'package:punnyam/services/apos_payment.dart';
import 'package:punnyam/services/apos_printer.dart';
import 'package:punnyam/services/app_config.dart';
import 'package:punnyam/services/helpers.dart';
import 'package:punnyam/services/provider_helper_class.dart';
import 'package:punnyam/widgets/punnyam_textfiled.dart';

class QuickBillScreen extends StatefulWidget {
  const QuickBillScreen({super.key});

  @override
  State<QuickBillScreen> createState() => _QuickBillScreenState();
}

class _QuickBillScreenState extends State<QuickBillScreen> {
  TextEditingController nameController = TextEditingController();

  bool selected = false;

  /// Blocks double taps while a payment / save / print is running.
  bool _paying = false;

  /// Selected star name (shown in the dropdown) and inline validation errors.
  String? _selectedStar;
  String? _nameError;
  String? _starError;

  /// Validates Name and Star; shows inline messages. Returns true when valid.
  bool _validate() {
    final name = nameController.text.trim();
    setState(() {
      if (name.isEmpty) {
        _nameError = 'Please enter the name';
      } else if (name.length < 2) {
        _nameError = 'Name must be at least 2 characters';
      } else {
        _nameError = null;
      }
      _starError = (_selectedStar ?? '').isEmpty ? 'Please select a star' : null;
    });
    if (_nameError != null || _starError != null) {
      Helpers.successToast(_nameError ?? _starError!);
      return false;
    }
    return true;
  }

  Widget _errorText(String? error) {
    if (error == null) return const SizedBox();
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: EdgeInsets.only(left: 12.w, top: 4.h),
        child: Text(
          error,
          style: TextStyle(color: Colors.red, fontSize: 12.sp),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      final home = context.read<HomeProvider>();
      final bill = context.read<BillingProvider>();
      // The list was only loaded at login/splash - load it here too so the
      // screen is never empty when that call failed or ran before the counter
      // was selected.
      if ((home.quickbills?.data ?? []).isEmpty) {
        await home.getquickbill();
      }
      if (!mounted) return;
      if (bill.paymentModeDataList.isEmpty) {
        bill.getPaymentModes(context);
      }
      if (bill.starsList.isEmpty) {
        bill.getStars();
      }
      // Sunmi fallback printer (non-Payswiff devices)
      if (!await AposPrinter.isPosDevice()) {
        bill.checkPrinter();
      }
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final billingProvider = context.read<BillingProvider>();
    return SafeArea(
      child: Scaffold(
          resizeToAvoidBottomInset: false,
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
            centerTitle: true,
            title: const Text(
              "Quick Bill",
              style: TextStyle(color: Colors.black),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 10.0),
                child: InkWell(
                  onTap: () {
                    Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (context) => const Home()),
                        (Route<dynamic> route) => false);
                  },
                  child: const Icon(
                    Icons.home,
                    color: Colors.black,
                  ),
                ),
              )
            ],
          ),
          body: Consumer<HomeProvider>(
            builder: (context, homeprovider, child) => RefreshIndicator(
              onRefresh: () async {
                await homeprovider.getquickbill();
              },
              child: SizedBox(
                // height: MediaQuery.of(context).size.height / 1.17,
                child: Column(
                  // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if ((homeprovider.quickbills?.data ?? []).isEmpty)
                      Expanded(
                        child: homeprovider.loaderState == LoaderState.loading
                            ? const Center(
                                child: CircularProgressIndicator(
                                    color: Color.fromRGBO(244, 155, 54, 1)))
                            : Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'No quick bill poojas found',
                                      style: TextStyle(
                                          fontSize: 14.sp,
                                          color: Colors.grey.shade700),
                                    ),
                                    10.verticalSpace,
                                    ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color.fromRGBO(
                                              244, 155, 54, 1),
                                          foregroundColor: Colors.white),
                                      onPressed: () =>
                                          homeprovider.getquickbill(),
                                      icon: const Icon(Icons.refresh),
                                      label: const Text('Retry'),
                                    ),
                                  ],
                                ),
                              ),
                      )
                    else
                    SizedBox(
                      height: homeprovider.data.isEmpty ? null : 300.h,
                      child: RefreshIndicator(
                        onRefresh: () async {
                          await homeprovider.getquickbill();
                        },
                        child: AutoHeightGridView(
                          itemCount: homeprovider.quickbills?.data?.length ?? 0,
                          crossAxisCount: 2,
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 10,
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.all(12),
                          shrinkWrap: true,
                          builder: (context, index) {
                            final datass =
                                homeprovider.quickbills?.data![index];
                            return InkWell(
                              onTap: () async {
                                if (homeprovider.data.any(
                                    (element) => element.id == datass?.id)) {
                                  homeprovider.updateQtyamt(id: datass?.id);
                                } else {
                                  homeprovider.addtolist(
                                      name: datass?.name,
                                      qty: 1,
                                      rs: datass?.rate,
                                      basefare: datass?.rate,
                                      id: datass?.id);
                                }
                              },
                              child: Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                    color:
                                        const Color.fromRGBO(244, 155, 54, 1),
                                    borderRadius: BorderRadius.circular(10.r)),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            "${homeprovider.quickbills?.data![index].name}",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 13.sp),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Text(
                                          "₹ ${homeprovider.quickbills?.data![index].rate}",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 15.sp,
                                              fontWeight: FontWeight.w500),
                                        ),
                                      ],
                                    ),
                                  ],
                                ).symmetricPadding(
                                    vertical: 10.h, horizontal: 10.w),
                              ),
                            );
                          },
                        ),
                      ),
                    ).horizontalPadding(8.w),
                    homeprovider.data.isEmpty
                        ? const SizedBox()
                        : Expanded(
                            child: SizedBox(
                              // height: 300.h,
                              child: RefreshIndicator(
                                onRefresh: () async {
                                  await homeprovider.getquickbill();
                                },
                                child: SingleChildScrollView(
                                  child: Column(
                                    children: [
                                      SizedBox(
                                        height: 47.h,
                                        child: PunnyamTextField(
                                            hintText: "Name",

                                            // height: 40.h,
                                            textEditingController:
                                                nameController,
                                            inputFormatter: [
                                              FilteringTextInputFormatter.allow(
                                                  RegExp("[a-z A-Z]"))
                                            ],
                                            keyboardType: TextInputType.name,
                                            hintStyle: TextStyle(
                                              fontSize: 13.5.sp,
                                              fontWeight: FontWeight.normal,
                                              color: Colors.grey.shade600,
                                            ),
                                            onChanged: (value) {
                                              if (_nameError != null &&
                                                  value.trim().isNotEmpty) {
                                                setState(
                                                    () => _nameError = null);
                                              }
                                              billingProvider
                                                  .updateBillingFormState();
                                            }),
                                      ),
                                      _errorText(_nameError),
                                      10.verticalSpace,
                                      CustomDropDownSearch(
                                        labelText: 'Select Star',
                                        isShowSearch: true,
                                        selected: _selectedStar,
                                        onChanged: (value) {
                                          FocusScope.of(context).unfocus();
                                          setState(() {
                                            _selectedStar = value?.toString();
                                            _starError = null;
                                          });
                                          billingProvider
                                            ..getStarIdFromName(value)
                                            ..updateBillingFormState();
                                        },
                                        items: List.generate(
                                            billingProvider.starsList.length,
                                            (index) =>
                                                billingProvider
                                                    .starsList[index].nameEng ??
                                                ''),
                                      ),
                                      _errorText(_starError),
                                      10.verticalSpace,
                                      ListView.separated(
                                        separatorBuilder: (context, index) =>
                                            7.verticalSpace,
                                        shrinkWrap: true,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        itemCount: homeprovider.data.length,
                                        itemBuilder: (context, index) => Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            SizedBox(
                                              width: 200.w,
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Expanded(
                                                    child: SizedBox(
                                                        // width: 100.w,
                                                        child: Text(
                                                      homeprovider
                                                          .data[index].name,
                                                      style: TextStyle(
                                                          fontSize: 13.sp,
                                                          fontWeight:
                                                              FontWeight.w500),
                                                      maxLines: 3,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    )),
                                                  ),
                                                  5.horizontalSpace,
                                                  SizedBox(
                                                    width: 70.w,
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        InkWell(
                                                          onTap: () async {
                                                            await homeprovider
                                                                .removeQtyamt(
                                                                    id: homeprovider
                                                                        .data[
                                                                            index]
                                                                        .id);
                                                          },
                                                          child: CircleAvatar(
                                                            backgroundColor:
                                                                const Color
                                                                    .fromRGBO(
                                                                    244,
                                                                    155,
                                                                    54,
                                                                    1),
                                                            radius: 11.r,
                                                            child: Center(
                                                              child: Icon(
                                                                Icons.remove,
                                                                color: Colors
                                                                    .white,
                                                                size: 13.sp,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        Text(
                                                            "${homeprovider.data[index].qty}"),
                                                        InkWell(
                                                          onTap: () async {
                                                            await homeprovider
                                                                .updateQtyamt(
                                                                    id: homeprovider
                                                                        .data[
                                                                            index]
                                                                        .id);
                                                          },
                                                          child: CircleAvatar(
                                                            backgroundColor:
                                                                const Color
                                                                    .fromRGBO(
                                                                    244,
                                                                    155,
                                                                    54,
                                                                    1),
                                                            radius: 11.r,
                                                            child: Center(
                                                              child: Icon(
                                                                color: Colors
                                                                    .white,
                                                                Icons.add,
                                                                size: 13.sp,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Row(
                                              children: [
                                                SizedBox(
                                                  width: 75.w,
                                                  child: Text(
                                                    "₹ ${homeprovider.data[index].rs}",
                                                    textAlign: TextAlign.end,
                                                  ),
                                                ),
                                                Padding(
                                                  padding: EdgeInsets.all(10.w),
                                                  child: InkWell(
                                                    onTap: () {
                                                      homeprovider.removelist(
                                                          id: homeprovider
                                                              .data[index].id);
                                                    },
                                                    child: const Icon(
                                                      Icons.delete,
                                                      color: Colors.red,
                                                    ),
                                                  ),
                                                )
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      15.verticalSpace,
                                    ],
                                  ).horizontalPadding(12.w),
                                ),
                              ),
                            ),
                          ),
                    homeprovider.data.isEmpty
                        ? const SizedBox()
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              InkWell(
                                onTap: _paying ? null : _onPay,
                                child: Container(
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(10.r),
                                            color: Colors.green),
                                        child: Row(
                                          children: [
                                            if (_paying) ...[
                                              SizedBox(
                                                height: 16.h,
                                                width: 16.h,
                                                child:
                                                    const CircularProgressIndicator(
                                                        strokeWidth: 2,
                                                        color: Colors.white),
                                              ),
                                              8.horizontalSpace,
                                            ],
                                            Text(
                                              "Pay  ",
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 17.sp),
                                            ),
                                            Text(
                                              "₹ ${homeprovider.getTotalAmount()}",
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 17.sp,
                                                  fontWeight: FontWeight.w600),
                                            )
                                          ],
                                        ).symmetricPadding(
                                            vertical: 7.h, horizontal: 15.w))
                                    .horizontalPadding(15.w),
                              )
                            ],
                          ).bottomPadding(10.h),
                  ],
                ),
              ),
            ),
          )),
    );
  }

  /// Same flow as Save Bill on the billing screen:
  /// payment mode -> (Card: Payswiff sale | QR: Payswiff dynamic QR)
  /// -> save quick bill -> print (Payswiff POS printer, else Sunmi).
  Future<void> _onPay() async {
    if (_paying) return;
    final bill = context.read<BillingProvider>();
    final home = context.read<HomeProvider>();
    if (home.data.isEmpty) {
      Helpers.successToast('Please add at least one pooja');
      return;
    }
    FocusScope.of(context).unfocus();
    if (!_validate()) return;

    final total = home.getTotalAmount();
    final amt = total.toString();

    if (bill.paymentModeDataList.isEmpty) {
      await bill.getPaymentModes(context);
      if (!mounted) return;
    }

    // 1. Payment mode (list from the API)
    final choice =
        await showPaymentModeDialog(context, bill, amount: amt);
    if (choice == null || !mounted) return; // cancelled
    bill.selectPaymentMode(choice.mode);

    setState(() => _paying = true);
    String? txnId;
    CardPaymentResult? card;
    try {
      final customerName =
          nameController.text.trim().isEmpty ? 'Customer' : nameController.text.trim();
      final ref =
          'PNQB${AppConfig.counterID ?? 0}${DateTime.now().millisecondsSinceEpoch}';
      final isCard = isCardMode(choice.mode);
      final isQr = isQrMode(choice.mode);

      // 2. Card / QR -> take the payment through Payswiff first
      if (isCard || isQr) {
        if (!await AposPrinter.isPosDevice() ||
            !await AposPayment.ensureActivated()) {
          Helpers.successToast(
              '${isCard ? 'Card' : 'QR'} payment works only on the activated POS machine');
          return;
        }
        if (!await CommonFunctions.checkInternetConnection(
            enableToast: false)) {
          Helpers.successToast('${isCard ? 'Card' : 'QR'} payment needs internet');
          return;
        }
      }

      if (isCard) {
        card = await AposPayment.startSale(
            amount: total, merchantRefNo: ref, name: customerName);
        if (!card.isApproved) {
          Helpers.successToast(card.responseMessage ?? 'Payment ${card.status}');
          return; // bill is NOT saved
        }
        txnId = card.referenceNumber;
      } else if (isQr) {
        if (!mounted) return;
        final qr =
            await showQrPaymentDialog(context, amount: total, orderRefNo: ref);
        if (!qr.isApproved) {
          Helpers.successToast(qr.responseMessage ?? 'Payment ${qr.status}');
          return; // bill is NOT saved
        }
        txnId = qr.transactionRefNo ?? qr.orderId ?? ref;
      }

      // 3. Save the quick bill
      final now = DateTime.now();
      final poojalist = home.data
          .map((item) => {
                "name": customerName,
                "star_id": (bill.starId ?? '').isEmpty ? '28' : bill.starId,
                "pooja": item.name,
                "pooja_id": item.id.toString(),
                "qty": item.qty.toString(),
                "date": "${now.year}-${now.month}-${now.day}",
                "rate": item.rs,
                "is_scheduled": "0"
              })
          .toList();

      bill.savequickbills = null; // never print a previous bill by mistake
      await bill.savequickbill(
          amt: amt,
          modeid: choice.mode.id,
          poojalist: poojalist,
          transactionid: txnId);

      if (bill.savequickbills?.status != true) {
        Helpers.successToast(txnId != null
            ? 'Payment received (Ref $txnId), but the bill was not saved. Please note the Ref No.'
            : bill.savequickbills?.message ?? 'Oops...! Something went wrong');
        return;
      }

      // 4. Print
      if (await AposPrinter.isPosDevice()) {
        await _aposPrint(bill, card);
      } else {
        if (!bill.isConnected) await bill.checkPrinter();
        if (bill.isConnected) {
          await posPrinter(bill);
        } else {
          Helpers.successToast("Printer is not connected");
        }
      }

      Helpers.successToast("${bill.savequickbills?.message ?? 'Bill saved'}");
      home.data.clear();
      nameController.clear();
      _selectedStar = null;
      bill.updateStarId('');
      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (e) {
      debugPrint('quick bill pay error: $e');
      Helpers.successToast(txnId != null
          ? 'Payment received (Ref $txnId), but the bill was not saved. Please note the Ref No.'
          : 'Something went wrong. Please try again.');
    } finally {
      if (mounted) setState(() => _paying = false);
    }
  }

  /// Payswiff POS (N86) printer - same receipt layout as the billing screen.
  Future<void> _aposPrint(BillingProvider p, CardPaymentResult? card) async {
    final res = p.savequickbills;
    final temple = res?.temple;
    final summary = res?.summary;
    final now = DateTime.now();
    final billDate = DateTime.tryParse("${summary?.billDate}") ?? now;
    final today = DateFormat('dd/MM/yyyy').format(billDate);

    final items = (res?.details ?? []).map((d) {
      final qty = int.tryParse(d.qty ?? '') ?? 1;
      final rate = double.tryParse(d.rate ?? '') ?? 0;
      return {
        'itemName': d.pooja ?? '',
        'qty': qty,
        'amount': rate,
        'itemTotal': double.tryParse(d.amount ?? '') ?? qty * rate,
      };
    }).toList();

    final cardLines = card == null
        ? ''
        : "\nCard: ${card.cardBrand ?? ''} ${card.cardNumber ?? ''}"
            "\nRef No: ${card.referenceNumber ?? ''}"
            "\nRRN: ${card.rrn ?? ''}  Auth: ${card.authCode ?? ''}"
            "\nMID: ${card.mid ?? ''}  TID: ${card.tid ?? ''}";

    try {
      await AposPrinter.printReceipt({
        'header': temple?.nameMal ?? temple?.name ?? '',
        'address':
            "${temple?.addressLine1 ?? ''}\n${temple?.addressLine2 ?? ''}",
        'contactNo': temple?.phone ?? '',
        'billNo': "${summary?.id ?? ''}",
        'billTime': today,
        'printTime':
            "${DateFormat('dd/MM/yyyy').format(now)} ${now.hour}:${now.minute.toString().padLeft(2, '0')}",
        'itemModelList': items,
        'totalItems': items.length,
        'totalAmount': double.tryParse("${summary?.total}") ?? 0,
        'itemsAmount': double.tryParse("${summary?.total}") ?? 0,
        'footer': "Name: ${summary?.name ?? 'Customer'}"
            "\nMode: ${summary?.mode ?? ''}$cardLines"
            "\nBook Online ${temple?.website ?? ''}",
      }, logo: p.imageData);
      Helpers.successToast('Bill Saved & Printed Successfully');
    } on PlatformException catch (e) {
      Helpers.successToast(e.message ?? 'Print failed');
    }
  }

  posPrinter(BillingProvider previewBillProvider) async {
    DateTime time = DateTime.parse(
        "${previewBillProvider.savequickbills?.summary?.billDate}");
    // String? today = "${time.day}/${time.month}/${time.year} ";
    String? today = DateFormat('dd/MM/yyyy').format(time);

    if (previewBillProvider.isConnected) {

      await SunmiPrinter.initPrinter();
      SunmiStyle(fontSize: 26, bold: true);
      await SunmiPrinter.setAlignment(align: SunmiPrintAlign.CENTER);
      await SunmiPrinter.lineWrap(1);
      previewBillProvider.savequickbills?.billImage == null ||
              previewBillProvider.savequickbills?.billImage == ''
          ? null
          : await SunmiPrinter.printImage(
              image: previewBillProvider.imageData!,
              align: SunmiPrintAlign.CENTER);
      previewBillProvider.savequickbills?.billImage == null ||
              previewBillProvider.savequickbills?.billImage == ''
          ? null
          : await SunmiPrinter.lineWrap(2);
      await SunmiPrinter.printText(
          content: "${previewBillProvider.savequickbills?.temple?.nameMal}",
          style: SunmiStyle(
              fontSize: 28,
              isUnderLine: false,
              bold: true,
              align: SunmiPrintAlign.CENTER));
      await SunmiPrinter.lineWrap(1);
      await SunmiPrinter.printText(
          content:
              "${previewBillProvider.savequickbills?.temple?.addressLine1}\n",
          style: SunmiStyle(
              fontSize: 24,
              isUnderLine: false,
              bold: true,
              align: SunmiPrintAlign.CENTER));
      await SunmiPrinter.printText(
          content:
              "${previewBillProvider.savequickbills?.temple?.addressLine2}\n",
          style: SunmiStyle(
              fontSize: 24,
              isUnderLine: false,
              bold: true,
              align: SunmiPrintAlign.CENTER));
      await SunmiPrinter.printText(
          content: "${previewBillProvider.savequickbills?.temple?.phone}\n",
          style: SunmiStyle(
              fontSize: 25,
              isUnderLine: false,
              bold: true,
              align: SunmiPrintAlign.CENTER));

      await SunmiPrinter.printTable(
        // style: SunmiStyle(fontSize: 25),
        cols: [
          ColumnMaker(
              text:
                  "Bill No:${previewBillProvider.savequickbills?.summary?.id}",
              align: SunmiPrintAlign.LEFT,
              width: 9),
          ColumnMaker(text: today, align: SunmiPrintAlign.RIGHT)
        ],
      );
      await SunmiPrinter.lineWrap(1);
      await SunmiPrinter.printText(
          content: "${previewBillProvider.savequickbills?.summary?.name}\n",
          style: SunmiStyle(
              fontSize: 26,
              isUnderLine: false,
              bold: false,
              align: SunmiPrintAlign.LEFT));
      await SunmiPrinter.lineWrap(1);
      int? lenn = previewBillProvider.savequickbills?.details?.length;
      final data = previewBillProvider.savequickbills?.details;
      // List<Details>? data = previewBillProvider.saveBillResponse?.details;
      for (int i = 0; i < lenn!; i++) {
        await SunmiPrinter.printText(
            content:
                "${i + 1}) ${previewBillProvider.savequickbills?.details![i].pooja}  ${data![i].qty}x${data[i].rate}\n",
            style: SunmiStyle(
                fontSize: 26,
                isUnderLine: false,
                bold: false,
                align: SunmiPrintAlign.LEFT));

        // await SunmiPrinter.printText(
        //     content:
        //         "${previewBillProvider.person[i].name} ${data[i].starMal}\n",
        //     style: SunmiStyle(
        //         fontSize: 26,
        //         isUnderLine: false,
        //         bold: false,
        //         align: SunmiPrintAlign.LEFT));
        // await SunmiPrinter.printText(
        //     content: "${data[i].poojaMal} ${data[i].qty}x${data[i].rate}\n",
        //     style: SunmiStyle(
        //         fontSize: 26,
        //         isUnderLine: false,
        //         bold: false,
        //         align: SunmiPrintAlign.LEFT));
        // for (int n = 0; n < datass.length; n += 2) {
        //   if (n + 1 < datass.length) {
        //     await SunmiPrinter.printText(
        //         content: "${datass[n]}, ${datass[n + 1]}",
        //         style: SunmiStyle(
        //             fontSize: 26,
        //             isUnderLine: false,
        //             bold: false,
        //             align: SunmiPrintAlign.LEFT));
        //   } else {
        //     if (datass.length > 1) {
        //       await SunmiPrinter.printText(
        //           content: ",\n${datass[n]}\n",
        //           style: SunmiStyle(
        //               fontSize: 26,
        //               isUnderLine: false,
        //               bold: false,
        //               align: SunmiPrintAlign.LEFT));
        //     } else {
        //       await SunmiPrinter.printText(
        //           content: "${datass[n]}\n",
        //           style: SunmiStyle(
        //               fontSize: 26,
        //               isUnderLine: false,
        //               bold: false,
        //               align: SunmiPrintAlign.LEFT));
        //     }
        // }
      }
      // data[i].address == null
      //     ? ''
      //     : await SunmiPrinter.printText(
      //         content: "${data[i].address}\n",
      //         style: SunmiStyle(
      //             fontSize: 26,
      //             isUnderLine: false,
      //             bold: false,
      //             align: SunmiPrintAlign.LEFT));

      await SunmiPrinter.lineWrap(1);
      await SunmiPrinter.printTable(
        // style: SunmiStyle(fontSize: 27, bold: true),
        cols: [
          ColumnMaker(
            text: "Mode: ${previewBillProvider.savequickbills?.summary?.mode}",
            align: SunmiPrintAlign.LEFT,
          ),
          ColumnMaker(
            text:
                "Total: ${previewBillProvider.savequickbills?.summary?.total}",
            align: SunmiPrintAlign.RIGHT,
          ),
        ],
      );
      await SunmiPrinter.lineWrap(1);
      await SunmiPrinter.printText(
          content:
              "Book Online ${previewBillProvider.savequickbills?.temple?.website} \n",
          style: SunmiStyle(
              fontSize: 24,
              isUnderLine: false,
              bold: true,
              align: SunmiPrintAlign.CENTER));
      await SunmiPrinter.lineWrap(1);
      await SunmiPrinter.feedPaper();
      await SunmiPrinter.cutPaper().then((value) {
        Helpers.successToast('Bill Saved & Printed Successfully');
      });
    }
  }
}

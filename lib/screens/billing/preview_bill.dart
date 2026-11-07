import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:punnyam/common/common_functions.dart';
import 'package:punnyam/providers/billing_provider.dart';
import 'package:punnyam/screens/billing/widgets/preview_bill_btn.dart';
import 'package:punnyam/screens/billing/widgets/preview_bill_tile.dart';
import 'package:punnyam/services/helpers.dart';
import '../../services/provider_helper_class.dart';

class PreviewBillScreen extends StatefulWidget {
  const PreviewBillScreen({Key? key}) : super(key: key);

  @override
  State<PreviewBillScreen> createState() => _PreviewBillScreenState();
}

class _PreviewBillScreenState extends State<PreviewBillScreen> {
  final TextEditingController trans = TextEditingController();
  IconData? share;
  @override
  void initState() {
    share = const IconData(0xe593, fontFamily: 'MaterialIcons');
    CommonFunctions.afterInit(() => context.read<BillingProvider>()
      ..getPaymentModes(context,
          onFailure: () => Helpers.successToast(
              'Error occurred while fetching payment modes ....!'))
      ..updatePreviewBillingFormValidated());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvoked: (didPop) {
        context.read<BillingProvider>().updateBillingFormState();
      },
      child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            // actions: [
            //   Consumer<BillingProvider>(
            //     builder: (context, billingProvider, child) {
            //       if (billingProvider.btnLoader) {
            //         return Container(
            //           alignment: Alignment.center,
            //           margin: EdgeInsets.symmetric(horizontal: 20.w),
            //           child: CircularProgressIndicator(
            //             strokeWidth: 2.r,
            //           ),
            //         );
            //       } else {
            //         return InkWell(
            //           onTap: billingProvider.paidAmountErrorMessage == null &&
            //                   billingProvider.paidAmountController.text
            //                       .trim()
            //                       .isNotEmpty
            //               ? () {
            //                   billingProvider.saveBill(
            //                       enableLoaderState: true,
            //                       onSuccess: () {
            //                         billingProvider.updateTemple(context
            //                             .read<BillingProvider>()
            //                             .saveBillResponse
            //                             ?.temple);
            //                         billingProvider.updateSummary(context
            //                             .read<BillingProvider>()
            //                             .saveBillResponse
            //                             ?.summary);
            //                       });
            //                 }
            //               : null,
            //           child: Padding(
            //             padding: EdgeInsets.symmetric(horizontal: 20.w),
            //             child: Icon(
            //               share,
            //               color:
            //                   billingProvider.paidAmountErrorMessage == null &&
            //                           billingProvider.paidAmountController.text
            //                               .trim()
            //                               .isNotEmpty
            //                       ? Colors.black
            //                       : Colors.black.withOpacity(.5),
            //             ),
            //           ),
            //         );
            //       }
            //     },
            //   )
            // ],
            leading: Center(
              child: InkWell(
                onTap: (() {
                  context.read<BillingProvider>().updateBillingFormState();
                  Navigator.pop(context);
                }),
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
              "Preview BIll",
              style: TextStyle(color: Colors.black),
            ),
          ),
          body: Consumer<BillingProvider>(
            builder: (context, previewBillProvider, child) {
              return _switchView(previewBillProvider);
            },
          )),
    );
  }

  _switchView(BillingProvider previewBillProvider) {
    Widget child = const SizedBox.shrink();
    switch (previewBillProvider.loaderState) {
      case LoaderState.initial:
        break;
      case LoaderState.loaded:
        child = Stack(children: [
          PreviewBillTile(
            previewBillProvider: previewBillProvider,
            trans: trans,
          ),
          PreviewBillButton(
              previewBillProvider: previewBillProvider,
              buildContext: context,
              trans: trans)
        ]);
        break;
      case LoaderState.loading:
        child = const LinearProgressIndicator();
        break;
      case LoaderState.error:
        break;
      case LoaderState.networkErr:
        break;
      case LoaderState.noData:
        child = const Center(
          child: Text('No Preview Bill Found !'),
        );
        break;
    }
    return child;
  }
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:punnyam/common/color_palette.dart';
import 'package:punnyam/providers/billing_provider.dart';
import 'package:punnyam/providers/home_provider.dart';
import 'package:punnyam/screens/login/login.dart';
import 'package:punnyam/services/apos_payment.dart';
import 'package:punnyam/services/app_config.dart';
import 'package:punnyam/services/helpers.dart';
import 'package:punnyam/services/offline_sync_service.dart';
import 'package:punnyam/services/shared_preference_helper.dart';
import '../home/home.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    checkLogged();
    super.initState();
  }

  checkLogged() async {
    await SharedPreferenceHelper.getToken();
    Future.delayed(const Duration(seconds: 2), () => navToScreen());
  }



  navToScreen() async {
    final home = context.read<HomeProvider>();
    final billingProvider = context.read<BillingProvider>();
    if ((AppConfig.accessToken ?? '').isNotEmpty) {
      OfflineSyncService.instance.onOnline(); // sync queued bills + refresh cache
      await billingProvider.getversion(context);
      await home.getquickbill();
      await billingProvider.getStars();
      await billingProvider.getgothra();
      await billingProvider.getrashi();

      if (!mounted) return;
      billingProvider.getPaymentModes(context,
          onFailure: () => Helpers.successToast(
              'Error occurred while fetching payment modes ....!'));

      // Payswiff: activate SDK once + load MID/TID
      await AposPayment.ensureActivated();
      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const Home()),
          (route) => false);
    } else {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const Login()),
          (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          toolbarHeight: 0,
          elevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: ColorPalette.orange,
            statusBarIconBrightness: Brightness.dark,
            statusBarBrightness: Brightness.light,
          )),
      body: Container(
        height: double.maxFinite,
        width: double.maxFinite,
        decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
              ColorPalette.orange,
              ColorPalette.primaryColor,
            ])),
        child: Center(
            child: Image.asset(
          'assets/image/logo.png',
          width: 300.w,
          height: 300.w,
          fit: BoxFit.fill,
        )),
      ),
    );
  }
}

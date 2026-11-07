import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:punnyam/common/color_palette.dart';
import 'package:punnyam/screens/splash/splash_screen.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:punnyam/services/multi_provider_list.dart';
import 'package:punnyam/services/offline_sync_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  OfflineSyncService.instance.init();
  runApp(MultiProvider(
      providers: MultiProviderList.providerList, child: const Punnyam()));
}

class Punnyam extends StatelessWidget {
  const Punnyam({super.key});
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: Size(MediaQuery.of(context).size.width,
          MediaQuery.of(context).size.height),
      builder: (context, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Punnyam temple suite',
          theme: ThemeData(
            primarySwatch: ColorPalette.materialTheme,
            brightness: Brightness.light,
            scaffoldBackgroundColor: Colors.white,
          ),
          home: const SplashScreen(),
        );
      },
    );
  }
}

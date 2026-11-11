import 'dart:async';
import 'dart:developer';
// import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:permission_handler/permission_handler.dart';
// import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:punnyam/common/color_palette.dart';
import 'package:punnyam/common/common_button.dart';
import 'package:punnyam/common/common_functions.dart';
import 'package:punnyam/common/extension.dart';
import 'package:punnyam/common/select_card.dart';
import 'package:punnyam/providers/billing_provider.dart';
import 'package:punnyam/providers/home_provider.dart';
import 'package:punnyam/screens/home/quick_bill.dart';
// import 'package:punnyam/screens/home/quick_bill.dart';
import 'package:punnyam/screens/login/login.dart';
import 'package:punnyam/services/app_config.dart';
import 'package:punnyam/services/helpers.dart';
import 'package:punnyam/services/provider_helper_class.dart';
import 'package:punnyam/services/shared_preference_helper.dart';
import 'package:punnyam/widgets/print_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class Home extends StatefulWidget {
  const Home({super.key});
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<String> titleCards = [
    "Billing",
    "Bill List",
    'Pooja Summary',
    'Counter Wise Summary',
  ];
  // BlueThermalPrinter printer = BlueThermalPrinter.instance;
  // List<BluetoothDevice> devices = [];
  // BluetoothDevice? selectedDevice;

  final _drawerController = ZoomDrawerController();
  @override
  void initState() {
    // devices.clear();
    // WidgetsBinding.instance.addPostFrameCallback((_) => _getDevices());
    final home = context.read<BillingProvider>();
    home.version?.data![0].androidVersion != AppConfig.version
        ? null
        : getCounterID();
    _init();
    super.initState();
  }

  String status = 'Starting...';

  Future<void> _init() async {
    // 1. Request permissions
    setState(() => status = 'Requesting permissions...');
    await [
      Permission.bluetooth,
      Permission.bluetoothConnect,
      Permission.bluetoothScan,
      Permission.locationWhenInUse,
    ].request();

    // 2. Auto-connect to InnerPrinter
    setState(() => status = 'Connecting to InnerPrinter...');
    final connected = await PrinterService.autoConnect();

    setState(
      () => status = connected
          ? '✅ Printer connected!'
          : '⚠️ InnerPrinter not found.\nMake sure it is paired in Bluetooth settings.',
    );
  }

  Future<Uint8List> assetImageToUint8List(String assetPath) async {
    ByteData data = await rootBundle.load(assetPath);
    return data.buffer.asUint8List();
  }

  // Future<void> _getDevices() async {
  //   bool? connect = await printer.isConnected;
  //   if (connect == true) {
  //     await printer.disconnect();
  //   }

  //   List<BluetoothDevice> devicesList = await printer.getBondedDevices();

  //   setState(() {
  //     devices = devicesList;
  //   });
  //   await _connectToPrinter();
  //   bool? conect = await printer.isConnected;
  //   if (conect == true) {
  //     Helpers.successToast("Bluetooth device connected successfully");
  //   } else {
  //     Helpers.successToast("Please check printer is available");
  //   }
  // }

  // Future<void> _connectToPrinter() async {
  //   selectedDevice = devices.firstWhere(
  //     (device) => device.name == 'CN811-UB',
  //     orElse: () => BluetoothDevice('not found', ''),
  //   );
  //   if (selectedDevice?.name == 'CN811-UB') {
  //     await printer.connect(selectedDevice!);

  //     Helpers.successToast("Bluetooth device connected successfully");
  //   }
  // }
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Consumer<BillingProvider>(
      builder: (context, home, child) => Scaffold(
        bottomSheet: home.version?.data![0].androidVersion != AppConfig.version
            ? BottomSheet(
                onClosing: () {},
                builder: (BuildContext context) {
                  return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                              color: Colors.grey,
                              blurRadius: 20.r,
                              offset: const Offset(0, 5))
                        ],
                      ),
                      height: 320.h,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            children: [
                              Row(
                                children: [
                                  SizedBox(
                                      height: 25.h,
                                      width: 25.w,
                                      child: SvgPicture.asset(
                                        "assets/image/google_play.svg",
                                        fit: BoxFit.contain,
                                      )),
                                  8.horizontalSpace,
                                  Text(
                                    "Google Play",
                                    style: TextStyle(
                                        color: Colors.blueGrey,
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                              25.verticalSpace,
                              Row(
                                children: [
                                  Text(
                                    "Update available",
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 17.sp,
                                        fontWeight: FontWeight.w700),
                                  ),
                                ],
                              ),
                              15.verticalSpace,
                              Row(
                                children: [
                                  Text(
                                    "To use this app, download the latest version",
                                    style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 11.sp,
                                        fontWeight: FontWeight.w400),
                                  ),
                                ],
                              ),
                              10.verticalSpace,
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    height: 50.h,
                                    width: 55.w,
                                    decoration: BoxDecoration(
                                      image: const DecorationImage(
                                          image: AssetImage(
                                              "assets/image/icon.png"),
                                          fit: BoxFit.cover),
                                      color: HexColor("#791AB1"),
                                    ),
                                  ),
                                  15.horizontalSpace,
                                  Column(
                                    children: [
                                      Text(
                                        "PUNNYAM",
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.w600),
                                      ),
                                    ],
                                  )
                                ],
                              )
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              CommonButton(
                                onPressed: () async {
                                  await launchUrl(Uri.parse(
                                      "https://play.google.com/store/apps/details?id=com.punnyam.staff"));
                                },
                                width: 150.w,
                                title: "Update",
                              ),
                            ],
                          )
                        ],
                      ).horizontalPadding(25.w).verticalPadding(30.h));
                },
              )
            : null,
        resizeToAvoidBottomInset: false,
        key: scaffoldKey,
        appBar: AppBar(
            toolbarHeight: 0,
            elevation: 0,
            systemOverlayStyle: SystemUiOverlayStyle(
              statusBarColor: ColorPalette.orange,
              statusBarIconBrightness: Brightness.dark,
              statusBarBrightness: Brightness.light,
            )),
        backgroundColor: ColorPalette.orange,
        body: Consumer<BillingProvider>(builder: (context, provider, _) {
          return IgnorePointer(
            ignoring:
                provider.version?.data![0].androidVersion == AppConfig.version
                    ? false
                    : true,
            child: RefreshIndicator(
              onRefresh: () async {},
              child: ZoomDrawer(
                controller: _drawerController,
                style: DrawerStyle.defaultStyle,
                menuScreen: Container(
                  width: double.maxFinite,
                  color: ColorPalette.orange,
                  child: ListView(
                    padding: const EdgeInsets.all(0),
                    children: [
                      DrawerHeader(
                        decoration: BoxDecoration(
                          color: ColorPalette.orange,
                        ), //BoxDecoration
                        child: UserAccountsDrawerHeader(
                          decoration: BoxDecoration(color: ColorPalette.orange),
                          accountName: Text(
                            "User",
                            style: TextStyle(fontSize: 18.sp),
                          ),
                          accountEmail: const Text("online"),
                          currentAccountPictureSize: const Size.square(50),
                          currentAccountPicture: const CircleAvatar(
                              // backgroundColor: Color.fromARGB(255, 165, 255, 137),
                              backgroundColor: Colors.white,
                              child: Icon(Icons.person)
                              // Text(
                              //   "A",
                              //   style:
                              //       TextStyle(fontSize: 30.0, color: ColorPalette.orange),
                              // ), //Text
                              ), //circleAvatar
                        ), //UserAccountDrawerHeader
                      ), //DrawerHeader

                      ListTile(
                        leading: const Icon(Icons.logout, color: Colors.white),
                        title: const Text(
                          'Logout',
                          style: TextStyle(color: Colors.white),
                        ),
                        onTap: () async {
                          final model = context.read<BillingProvider>();
                          // final prefs = await SharedPreferences.getInstance();
                          // prefs.clear();
                          await SharedPreferenceHelper.clearWholeData();
                          await model.logoutclear();

                          CommonFunctions.afterInit(() =>
                              Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const Login()),
                                  (route) => false));
                        },
                      ),
                    ],
                  ),
                ),
                mainScreen:
                    Consumer<HomeProvider>(builder: (context, provider, _) {
                  return Container(
                    color: Colors.white,
                    child: Column(
                      children: [
                        // TextButton(
                        //   child: Text("Select Counter"),
                        //   onPressed: () async {
                        //     await printer.printCustom(
                        //         "________________________________________", 1, 1);
                        //     await printer.printCustom(
                        //         "========================================", 1, 1);
                        //   },
                        // ),

                        Stack(
                          children: [
                            Image.asset(
                              'assets/image/dashboard_bg.png',
                              width: double.maxFinite,
                              fit: BoxFit.contain,
                            ),
                            Positioned(
                              top: 45.h,
                              left: 20.w,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  InkWell(
                                    onTap: provider.loaderState ==
                                            LoaderState.loading
                                        ? null
                                        : () {
                                            _drawerController.open!();
                                          },
                                    child: SizedBox(
                                        height: 30.w,
                                        width: 30.w,
                                        child: Center(
                                            child: Image.asset(
                                                'assets/image/menu.png'))),
                                  ),
                                  SizedBox(
                                    height: 10.h,
                                  ),
                                  Text(
                                    'Dashboard',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 21.sp),
                                  ),
                                  Text(
                                    'Online Pooja Booking',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 14.sp),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                        // 5.verticalSpace,
                        provider.loaderState == LoaderState.loading
                            ? const Center(child: CircularProgressIndicator())
                            : Expanded(
                                child: Column(
                                  children: [
                                    Expanded(
                                      child: SizedBox(
                                        // color: Colors.red,
                                        height:
                                            MediaQuery.of(context).size.height *
                                                .48,
                                        child: GridView.count(
                                            physics:
                                                const BouncingScrollPhysics(),
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 20.w),
                                            crossAxisCount: 2,
                                            crossAxisSpacing: 5.w,
                                            mainAxisSpacing: 5.w,
                                            children: List.generate(
                                                titleCards.length, (index) {
                                              return Center(
                                                child: SelectCard(
                                                  title: titleCards[index],
                                                  onTap: () {
                                                    provider.navigationSwitch(
                                                      context,
                                                      index,
                                                    );
                                                  },
                                                ),
                                              );
                                            })),
                                      ),
                                    ),
                                    //8.verticalSpace,
                                    InkWell(
                                      onTap: () {
                                        final home = context.read<HomeProvider>();
                                        home.data.clear();
                                        Navigator.of(context).push(MaterialPageRoute(
                                          builder: (context) =>
                                              const QuickBillScreen(),
                                        ));
                                      },
                                      child: Container(
                                        height: 65.h,
                                        width:
                                            MediaQuery.of(context).size.width / 1.18,
                                        decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(25.r),
                                            gradient: LinearGradient(colors: [
                                              ColorPalette.primaryColor,
                                              ColorPalette.orange
                                            ])),
                                        child: Center(
                                            child: Text(
                                          "Quick Bill",
                                          style: TextStyle(
                                              color: Colors.white, fontSize: 18.sp),
                                        )),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                      ],
                    ),
                  );
                }),
                borderRadius: 24.0,
                showShadow: true,
                angle: -12.0,
                drawerShadowsBackgroundColor: Colors.grey.shade300,
                slideWidth: MediaQuery.of(context).size.width * .65,
                openCurve: Curves.fastOutSlowIn,
                closeCurve: Curves.bounceIn,
              ),
            ),
          );
        }),
      ),
    );
  }

  String? _chosenValue;
  String? selectedCounterID;
  void _showCounters() {
    Future.microtask(
      () {
        context.read<HomeProvider>().getCounter().then((value) {
          showDialog<bool>(
            barrierDismissible: false,
            context: context,
            builder: (BuildContext context) {
              return Consumer<BillingProvider>(builder: (context, provider, _) {
                return IgnorePointer(
                  ignoring: provider.version?.data![0].androidVersion ==
                          AppConfig.version
                      ? false
                      : true,
                  child: StatefulBuilder(
                    builder: (BuildContext context, StateSetter setState) {
                      return PopScope(
                        canPop: false,
                        child: Consumer<HomeProvider>(
                            builder: (context, provider, _) {
                          return AlertDialog(
                            title: const Text("Choose Counter"),
                            content: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  const Text("Please select a counter."),
                                  SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: DropdownButton<String>(
                                        hint: const Text('Select your option'),
                                        value: _chosenValue,
                                        underline: Container(),
                                        items: provider.counterName
                                            .map((String value) {
                                          return DropdownMenuItem<String>(
                                            value: value,
                                            child: Text(
                                              value,
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.w500),
                                            ),
                                          );
                                        }).toList(),
                                        onChanged: (value) async {
                                          final SharedPreferences prefs =
                                              await SharedPreferences
                                                  .getInstance();

                                          setState(() {
                                            _chosenValue = value;
                                            for (int i = 0;
                                                i < provider.counterName.length;
                                                i++) {
                                              if (provider.counterName[i] ==
                                                  _chosenValue) {
                                                selectedCounterID =
                                                    provider.counterId[i];
                                                log(selectedCounterID
                                                    .toString());
                                                prefs.setString(
                                                    "counterid",
                                                    selectedCounterID
                                                        .toString());
                                              }
                                            }
                                          });
                                        },
                                      )),
                                ]),
                            actions: <Widget>[
                              TextButton(
                                child: const Text("SAVE"),
                                onPressed: () async {
                                  final home = context.read<HomeProvider>();
                                  final billingProvider =
                                      context.read<BillingProvider>();

                                  if ((selectedCounterID != null)) {
                                    await SharedPreferenceHelper.saveCounterID(
                                            selectedCounterID ?? "")
                                        .then((value) async {
                                      await home.getquickbill();
                                      await billingProvider.getStars();
                                      await billingProvider.getgothra();
                                      await billingProvider.getrashi();

                                      billingProvider.getPaymentModes(context,
                                          onFailure: () => Helpers.successToast(
                                              'Error occurred while fetching payment modes ....!'));

                                      Navigator.of(context).pop();
                                    });
                                  } else {
                                    Helpers.successToast(
                                        "Should Select Counter");
                                  }
                                },
                              ),
                            ],
                          );
                        }),
                      );
                    },
                  ),
                );
              });
            },
          );
        });
      },
    );
  }

  getCounterID() async {
    String id = await SharedPreferenceHelper.getCounterID();
    if (id == '') {
      _showCounters();
    }
  }
}

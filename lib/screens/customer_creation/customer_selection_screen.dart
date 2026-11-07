import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:punnyam/providers/create_cutomer_provider.dart';
import 'package:punnyam/screens/customer_creation/widgets/add_customer_tile.dart';
import 'package:punnyam/screens/customer_creation/widgets/search_result_tile.dart';
import 'package:punnyam/screens/customer_creation/widgets/search_tile.dart';
import 'package:punnyam/screens/customer_creation/widgets/walk_in_customer_tile.dart';
import 'package:punnyam/screens/home/home.dart';

class CustomerSelectionScreen extends StatefulWidget {
  const CustomerSelectionScreen({Key? key}) : super(key: key);
  @override
  State<CustomerSelectionScreen> createState() =>
      _CustomerSelectionScreenState();
}

class _CustomerSelectionScreenState extends State<CustomerSelectionScreen> {
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
          "Choose Customer",
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
      body: Consumer<CreateCustomerProvider>(
        builder: (context, createCustomerProvider, child) {
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Column(
              children: [
                Align(
                    alignment: Alignment.topRight,
                    child: AddCustomerTile(
                        createCustomerProvider: createCustomerProvider)),
                const WalkingCustomerTile(),
                20.verticalSpace,
                SearchTile(createCustomerProvider: createCustomerProvider),
                createCustomerProvider.btnLoader
                    ? Padding(
                        padding: EdgeInsets.symmetric(vertical: 40.h),
                        child: const CircularProgressIndicator(),
                      )
                    : SearchResultTile(
                        createCustomerProvider: createCustomerProvider)
              ],
            ),
          );
        },
      ),
    );
  }
}

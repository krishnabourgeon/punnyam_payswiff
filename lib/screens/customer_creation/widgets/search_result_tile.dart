import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:punnyam/providers/create_cutomer_provider.dart';
import 'package:punnyam/screens/billing/billing.dart';
import 'package:punnyam/services/app_config.dart';
import '../../../providers/billing_provider.dart';

class SearchResultTile extends StatelessWidget {
  const SearchResultTile({Key? key, required this.createCustomerProvider})
      : super(key: key);
  final CreateCustomerProvider createCustomerProvider;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onVerticalDragCancel: () => FocusScope.of(context).unfocus(),
      child: Container(
        height: 500.h,
        margin: EdgeInsets.symmetric(horizontal: 10.w),
        color: Colors.white,
        child: ListView.builder(
          itemCount: createCustomerProvider.userList.length,
          shrinkWrap: true,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(createCustomerProvider.userList[index].name ?? ''),
              onTap: () {
                AppConfig.customerId =
                    createCustomerProvider.userList[index].id ?? 0;
                AppConfig.customerName =
                    createCustomerProvider.userList[index].name ?? '';
                AppConfig.customerNumber =
                    createCustomerProvider.userList[index].mobile ?? '';
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const Billing(),
                    )).then((value) {
                  context.read<BillingProvider>()
                    ..clearValues()
                    ..clearPaymentValues()
                    ..poojaDetailsList.clear()
                    ..nameController.clear();
                  AppConfig.customerName = null;
                });
              },
            );
          },
        ),
      ),
    );
  }
}

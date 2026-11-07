import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:punnyam/providers/billing_provider.dart';
import 'package:punnyam/screens/billing/billing.dart';
import 'package:punnyam/services/app_config.dart';

class WalkingCustomerTile extends StatelessWidget {
  const WalkingCustomerTile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        AppConfig.customerName = null;
        AppConfig.customerNumber = null;
        AppConfig.customerId = 1;
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const Billing(),
            )).then((value) => context.read<BillingProvider>()
          ..clearValues()
          ..getPoojas()
          ..nameController.clear()
          ..clearPaymentValues()
          ..poojaDetailsList.clear());
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 25.h),
        height: 100.h,
        width: double.maxFinite,
        alignment: Alignment.center,
        decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(20.r)),
        child: Text(
          'Walk In Customer',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24.sp),
        ),
      ),
    );
  }
}

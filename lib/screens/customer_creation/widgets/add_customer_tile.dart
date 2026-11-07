import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:punnyam/common/common_button.dart';
import 'package:punnyam/providers/create_cutomer_provider.dart';

import '../customer_creation_screen.dart';

class AddCustomerTile extends StatelessWidget {
  const AddCustomerTile({Key? key, required this.createCustomerProvider})
      : super(key: key);
  final CreateCustomerProvider createCustomerProvider;
  @override
  Widget build(BuildContext context) {
    return CommonButton(
      width: 130.w,
      height: 35.h,
      title: 'Add Customer',
      onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const CustomerCreationScreen(),
          )).then((value) => createCustomerProvider.clearValues()),
    );
  }
}

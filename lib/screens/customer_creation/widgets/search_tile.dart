import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:punnyam/providers/create_cutomer_provider.dart';

import '../../../widgets/punnyam_textfiled.dart';

class SearchTile extends StatelessWidget {
  const SearchTile({Key? key, required this.createCustomerProvider})
      : super(key: key);
  final CreateCustomerProvider createCustomerProvider;
  @override
  Widget build(BuildContext context) {
    return PunnyamTextField(
      hintText: "Search Customer By Mobile No.",
      keyboardType: TextInputType.number,
      textEditingController: createCustomerProvider.searchController,
      onChanged: (value) => createCustomerProvider.searchCustomer(),
    );
  }
}

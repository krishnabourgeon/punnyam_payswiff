import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:punnyam/models/create_customer_body.dart';
import 'package:punnyam/providers/create_cutomer_provider.dart';
import 'package:punnyam/services/helpers.dart';
import 'package:punnyam/services/validation_helper.dart';
import 'package:punnyam/widgets/punnyam_textfiled.dart';

import '../../common/common_button.dart';
import '../../common/custom_drop_down_search.dart';
import '../../services/provider_helper_class.dart';
import '../register/register_screen.dart';

class CustomerCreationScreen extends StatefulWidget {
  const CustomerCreationScreen({Key? key}) : super(key: key);
  @override
  State<CustomerCreationScreen> createState() => _CustomerCreationScreenState();
}

class _CustomerCreationScreenState extends State<CustomerCreationScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        title: const Text(
          "Create Customer",
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: Consumer<CreateCustomerProvider>(
        builder: (context, createCustomerProvider, child) {
          return SingleChildScrollView(
            reverse: true,
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                40.verticalSpace,
                PunnyamTextField(
                  hintText: 'Name',
                  textEditingController: createCustomerProvider.nameController,
                  inputFormatter: [
                    FilteringTextInputFormatter.allow(RegExp("[a-zA-Z]"))
                  ],
                  keyboardType: TextInputType.name,
                  textInputAction: TextInputAction.next,
                  onChanged: (value) {
                    createCustomerProvider.updateValidationMessage(
                        validationTypes: CreateCustomerValidationTypes.name,
                        validationMessage:
                            ValidationHelperClass.validateName(value.trim()) ??
                                '');
                  },
                ),
                if (createCustomerProvider.nameErrorMessage != null)
                  ValidationWidget(
                      validationMessage:
                          createCustomerProvider.nameErrorMessage ?? ''),
                10.verticalSpace,
                PunnyamTextField(
                  hintText: 'Mobile Number',
                  maxLength: 10,
                  textEditingController:
                      createCustomerProvider.mobileController,
                  inputFormatter: [FilteringTextInputFormatter.digitsOnly],
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    createCustomerProvider.updateValidationMessage(
                        validationTypes:
                            CreateCustomerValidationTypes.mobileNumber,
                        validationMessage:
                            ValidationHelperClass.validateMobileNumber(
                                    value.trim()) ??
                                '');
                  },
                ),
                if (createCustomerProvider.mobileErrorMessage != null)
                  ValidationWidget(
                      validationMessage:
                          createCustomerProvider.mobileErrorMessage ?? ''),
                10.verticalSpace,
                PunnyamTextField(
                  hintText: 'Email',
                  textEditingController: createCustomerProvider.emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  onChanged: (value) {
                    createCustomerProvider.updateValidationMessage(
                        validationTypes: CreateCustomerValidationTypes.email,
                        validationMessage:
                            ValidationHelperClass.validateEmail(value.trim()) ??
                                '');
                  },
                ),
                if (createCustomerProvider.emailErrorMessage != null)
                  ValidationWidget(
                      validationMessage:
                          createCustomerProvider.emailErrorMessage ?? ''),
                10.verticalSpace,
                PunnyamTextField(
                  hintText: 'House Name',
                  textEditingController:
                      createCustomerProvider.houseNameController,
                  textInputAction: TextInputAction.next,
                  onChanged: (value) {
                    createCustomerProvider.updateValidationMessage(
                        validationTypes:
                            CreateCustomerValidationTypes.houseName,
                        validationMessage:
                            ValidationHelperClass.validateName(value.trim()) ??
                                '');
                  },
                ),
                if (createCustomerProvider.houseNameErrorMessage != null)
                  ValidationWidget(
                      validationMessage:
                          createCustomerProvider.houseNameErrorMessage ?? ''),
                10.verticalSpace,
                PunnyamTextField(
                  hintText: 'Street',
                  textEditingController:
                      createCustomerProvider.streetController,
                  textInputAction: TextInputAction.next,
                  onChanged: (value) {
                    createCustomerProvider.updateValidationMessage(
                        validationTypes: CreateCustomerValidationTypes.street,
                        validationMessage:
                            ValidationHelperClass.validateName(value.trim()) ??
                                '');
                  },
                ),
                if (createCustomerProvider.streetErrorMessage != null)
                  ValidationWidget(
                      validationMessage:
                          createCustomerProvider.streetErrorMessage ?? ''),
                10.verticalSpace,
                PunnyamTextField(
                  hintText: 'Post',
                  textEditingController: createCustomerProvider.postController,
                  textInputAction: TextInputAction.next,
                  onChanged: (value) {
                    createCustomerProvider.updateValidationMessage(
                        validationTypes: CreateCustomerValidationTypes.post,
                        validationMessage:
                            ValidationHelperClass.validateName(value.trim()) ??
                                '');
                  },
                ),
                if (createCustomerProvider.postErrorMessage != null)
                  ValidationWidget(
                      validationMessage:
                          createCustomerProvider.postErrorMessage ?? ''),
                10.verticalSpace,
                CustomDropDownSearch(
                  labelText: 'Select District',
                  isShowSearch: true,
                  labelColor: Colors.black,
                  onChanged: (value) =>
                      createCustomerProvider.updateDistrictName(value),
                  items: List.generate(
                      createCustomerProvider.districtsList.length,
                      (index) => createCustomerProvider.districtsList[index]),
                ),
                10.verticalSpace,
                const PunnyamTextField(
                  hintText: 'Kerala',
                  isEnabled: false,
                ),
                10.verticalSpace,
                PunnyamTextField(
                  hintText: 'Pin Code',
                  maxLength: 6,
                  textEditingController:
                      createCustomerProvider.pinCodeController,
                  inputFormatter: [FilteringTextInputFormatter.digitsOnly],
                  textInputAction: TextInputAction.done,
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    createCustomerProvider.updateValidationMessage(
                        validationTypes: CreateCustomerValidationTypes.pinCode,
                        validationMessage:
                            ValidationHelperClass.validatePinCode(
                                    value.trim()) ??
                                '');
                  },
                ),
                if (createCustomerProvider.pinCodeErrorMessage != null)
                  ValidationWidget(
                      validationMessage:
                          createCustomerProvider.pinCodeErrorMessage ?? ''),
                50.verticalSpace,
                CommonButton(
                    title: 'Create Customer',
                    isLoading: createCustomerProvider.loaderState ==
                        LoaderState.loading,
                    onPressed: createCustomerProvider.isCreateFormValidated
                        ? () {
                            FocusScope.of(context).unfocus();
                            createCustomerFunction(createCustomerProvider);
                          }
                        : null),
                Padding(
                    padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).viewInsets.bottom))
              ],
            ),
          );
        },
      ),
    );
  }

  createCustomerFunction(CreateCustomerProvider createCustomerProvider) {
    CreateCustomer createCustomer = CreateCustomer(
        name: createCustomerProvider.nameController.text.trim(),
        mobileNumber: createCustomerProvider.mobileController.text.trim(),
        email: createCustomerProvider.emailController.text.trim(),
        houseName: createCustomerProvider.houseNameController.text.trim(),
        street: createCustomerProvider.streetController.text.trim(),
        post: createCustomerProvider.postController.text.trim(),
        district: createCustomerProvider.districtName,
        pinCode: createCustomerProvider.pinCodeController.text.trim(),
        state: 'Kerala');
    createCustomerProvider.createCustomer(createCustomer,
        onSuccess: () {
          Helpers.successToast('Customer created successfully');
          Navigator.pop(context);
        },
        onFailure: () => Helpers.successToast(
            'Mobile number already exists. Please try another one.'));
  }
}

import 'package:punnyam/services/offline_sync_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:punnyam/common/common_functions.dart';
import 'package:punnyam/providers/auth_provider.dart';
import 'package:punnyam/providers/billing_provider.dart';
import 'package:punnyam/providers/home_provider.dart';
import 'package:punnyam/services/helpers.dart';
import 'package:punnyam/services/provider_helper_class.dart';
import '../../common/common_button.dart';
import '../../services/validation_helper.dart';
import '../../widgets/punnyam_textfiled.dart';
import '../home/home.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);
  @override
  RegisterScreenState createState() => RegisterScreenState();
}

class RegisterScreenState extends State<RegisterScreen> {
  @override
  void initState() {
    CommonFunctions.afterInit(() => context.read<AuthProvider>().clearValues());
    super.initState();
  }

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
          "Register",
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: SingleChildScrollView(
        reverse: true,
        child: Consumer<AuthProvider>(
          builder: (context, authProvider, child) {
            return Container(
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  20.verticalSpace,
                  PunnyamTextField(
                    hintText: "Name",
                    textEditingController: authProvider.nameController,
                    inputFormatter: [
                      FilteringTextInputFormatter.allow(RegExp("[a-zA-Z]"))
                    ],
                    keyboardType: TextInputType.name,
                    onChanged: (value) {
                      authProvider.updateValidationMessages(
                          validationType: ValidationTypes.name,
                          validationMessage: ValidationHelperClass.validateName(
                                  value.trim()) ??
                              '');
                    },
                  ),
                  if (authProvider.nameValidationMessage != null)
                    ValidationWidget(
                        validationMessage:
                            authProvider.nameValidationMessage ?? ''),
                  10.verticalSpace,
                  PunnyamTextField(
                    textEditingController: authProvider.emailController,
                    hintText: "Email",
                    onChanged: (value) {
                      authProvider.updateValidationMessages(
                          validationType: ValidationTypes.email,
                          validationMessage:
                              ValidationHelperClass.validateEmail(
                                      value.trim()) ??
                                  '');
                    },
                  ),
                  if (authProvider.emailValidationMessage != null)
                    ValidationWidget(
                        validationMessage:
                            authProvider.emailValidationMessage ?? ''),
                  10.verticalSpace,
                  PunnyamTextField(
                    textEditingController: authProvider.punnyamCodeController,
                    hintText: "Punnyam Code",
                    maxLength: 3,
                    onChanged: (value) {
                      authProvider.updateValidationMessages(
                          validationType: ValidationTypes.punnyamCode,
                          validationMessage:
                              ValidationHelperClass.validatePunnyamCode(
                                      value.trim()) ??
                                  '');
                    },
                  ),
                  if (authProvider.punnyamCodeValidationMessage != null)
                    ValidationWidget(
                        validationMessage:
                            authProvider.punnyamCodeValidationMessage ?? ''),
                  10.verticalSpace,
                  PunnyamTextField(
                    textEditingController: authProvider.passwordController,
                    hintText: "Password",
                    makePasswordField: true,
                    onChanged: (value) {
                      authProvider.updateValidationMessages(
                          validationType: ValidationTypes.password,
                          validationMessage:
                              ValidationHelperClass.validatePassword(
                                      value.trim()) ??
                                  '');
                    },
                  ),
                  if (authProvider.passwordValidationMessage != null)
                    ValidationWidget(
                        validationMessage:
                            authProvider.passwordValidationMessage ?? ''),
                  10.verticalSpace,
                  PunnyamTextField(
                    textEditingController:
                        authProvider.confirmPasswordController,
                    hintText: "Confirm Password",
                    makePasswordField: true,
                    textInputAction: TextInputAction.done,
                    onChanged: (value) {
                      if (value.isNotEmpty &&
                          authProvider.passwordController.text != value) {
                        authProvider.updateValidationMessages(
                            validationType: ValidationTypes.confirmPassword,
                            validationMessage:
                                'Confirm password should be same');
                      } else {
                        authProvider.updateValidationMessages(
                            validationType: ValidationTypes.confirmPassword,
                            validationMessage: '');
                      }
                    },
                  ),
                  if (authProvider.confirmPasswordValidationMessage != null)
                    ValidationWidget(
                        validationMessage:
                            authProvider.confirmPasswordValidationMessage ??
                                ''),
                  40.verticalSpace,
                  CommonButton(
                    isLoading: authProvider.loaderState == LoaderState.loading,
                    title: "Register",
                    onPressed: authProvider.isRegisterFormValidated
                        ? () {
                            FocusScope.of(context).unfocus();
                            authProvider.register(
                                onSuccess: () async {
                                  final home = context.read<HomeProvider>();
                                  final billingProvider =
                                      context.read<BillingProvider>();
                                  await home.getquickbill();
                                  await billingProvider.getStars();
                                  await billingProvider.getversion(context);

                                  billingProvider.getPaymentModes(context,
                                      onFailure: () => Helpers.successToast(
                                          'Error occurred while fetching payment modes ....!'));
                                  OfflineSyncService.instance.onOnline();
                                  await home.getCounter();

                                  Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const Home(),
                                      ),
                                      (route) => false);
                                },
                                onFailure: () => Helpers.successToast(
                                    authProvider.errorToast ?? ''));
                          }
                        : null,
                  ),
                  Padding(
                      padding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).viewInsets.bottom))
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class ValidationWidget extends StatelessWidget {
  const ValidationWidget(
      {Key? key, required this.validationMessage, this.textStyle})
      : super(key: key);
  final String validationMessage;
  final TextStyle? textStyle;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      child: Text(
        validationMessage,
        style: textStyle ?? const TextStyle(color: Colors.red),
      ),
    );
  }
}

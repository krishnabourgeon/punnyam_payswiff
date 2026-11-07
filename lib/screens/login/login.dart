import 'package:punnyam/services/offline_sync_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:punnyam/common/color_palette.dart';
import 'package:punnyam/common/common_button.dart';
import 'package:punnyam/providers/auth_provider.dart';
import 'package:punnyam/providers/billing_provider.dart';
import 'package:punnyam/providers/home_provider.dart';
import 'package:punnyam/screens/home/home.dart';
import 'package:punnyam/screens/register/register_screen.dart';
import 'package:punnyam/services/apos_payment.dart';
import 'package:punnyam/services/helpers.dart';
import 'package:punnyam/services/provider_helper_class.dart';
import 'package:punnyam/services/validation_helper.dart';
import 'package:punnyam/widgets/punnyam_textfiled.dart';

class Login extends StatefulWidget {
  const Login({super.key});
  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
          toolbarHeight: 0,
          elevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: ColorPalette.orange,
            statusBarIconBrightness: Brightness.dark,
            statusBarBrightness: Brightness.light,
          )),
      body: SingleChildScrollView(
        child: Consumer<AuthProvider>(
          builder: (context, authProvider, child) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SafeArea(
                  child: SizedBox(
                    width: double.maxFinite,
                    child: Image.asset(
                      "assets/image/login_image.png",
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 25.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 30.h,
                      ),
                      PunnyamTextField(
                        contentpadding: EdgeInsets.symmetric(vertical: 15.h),
                        hintText: "Email",
                        textEditingController:
                            authProvider.loginUsernameController,
                        prefixIcon: Icons.person,
                        onChanged: (value) {
                          authProvider.updateValidationMessages(
                              validationType: ValidationTypes.userName,
                              validationMessage:
                                  ValidationHelperClass.validateEmail(
                                          value.trim()) ??
                                      '');
                        },
                      ),
                      if (authProvider.userNameValidationMessage != null)
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 10.w, vertical: 5.h),
                          child: Text(
                            authProvider.userNameValidationMessage ?? '',
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      SizedBox(
                        height: 15.h,
                      ),
                      PunnyamTextField(
                        contentpadding: EdgeInsets.symmetric(vertical: 15.h),
                        hintText: "Password",
                        textEditingController:
                            authProvider.loginPasswordController,
                        prefixIcon: Icons.lock,
                        onChanged: (value) =>
                            authProvider.updateLoginFormState(),
                        makePasswordField: true,
                        textInputAction: TextInputAction.done,
                      ),
                      SizedBox(
                        height: 10.h,
                      ),
                      Row(
                        children: [
                          Checkbox(
                            value: authProvider.isRememberCredentials,
                            onChanged: (value) {
                              authProvider
                                  .updateRememberMeValue(value ?? false);
                            },
                          ),
                          Text("Remember me",
                              style: TextStyle(color: Colors.grey.shade700)),
                        ],
                      ),
                      SizedBox(
                        height: 20.h,
                      ),
                      CommonButton(
                          title: 'Login',
                          isLoading:
                              authProvider.loaderState == LoaderState.loading,
                          onPressed: authProvider.isLoginFormValidated
                              ? () {
                                  FocusScope.of(context).unfocus();
                                  authProvider.login(
                                      onSuccess: () async {
                                        final home =
                                            context.read<HomeProvider>();
                                        final billingProvider =
                                            context.read<BillingProvider>();
                                        await home.getquickbill();
                                        await billingProvider.getStars();
                                        await billingProvider
                                            .getversion(context);

                                        billingProvider.getPaymentModes(context,
                                            onFailure: () => Helpers.successToast(
                                                'Error occurred while fetching payment modes ....!'));

                                        OfflineSyncService.instance.onOnline();
                                        // Payswiff: activate SDK once + load MID/TID
                                        await AposPayment.ensureActivated();
                                        if (!context.mounted) return;
                                        Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  const Home(),
                                            )).then((value) async {
                                          await home.getCounter();

                                          authProvider.clearValues();
                                        });
                                      },
                                      onFailure: () => Helpers.successToast(
                                          authProvider.errorToast ?? ''));
                                }
                              : null),
                      SizedBox(
                        height: 60.h,
                      ),
                      Center(
                        child: RichText(
                          text: TextSpan(
                            text: 'Not a member ? ',
                            style: TextStyle(color: Colors.grey.shade700),
                            children: <WidgetSpan>[
                              WidgetSpan(
                                  child: InkWell(
                                onTap: () {
                                  FocusScope.of(context).unfocus();
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const RegisterScreen()));
                                },
                                child: Text('Sign up now',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: ColorPalette.primaryColor)),
                              ))
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                    padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).viewInsets.bottom))
              ],
            );
          },
        ),
      ),
    );
  }
}

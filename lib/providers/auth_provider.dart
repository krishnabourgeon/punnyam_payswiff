import 'package:flutter/cupertino.dart';
import 'package:punnyam/models/login_response_model.dart';
import 'package:punnyam/models/register_body.dart';
import 'package:punnyam/services/provider_helper_class.dart';
import 'package:punnyam/services/shared_preference_helper.dart';
import 'package:punnyam/services/validation_helper.dart';

class AuthProvider extends ChangeNotifier with ProviderHelperClass {
  TextEditingController loginUsernameController = TextEditingController();
  TextEditingController loginPasswordController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController punnyamCodeController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  String? errorToast;
  String? userNameValidationMessage;
  String? nameValidationMessage;
  String? emailValidationMessage;
  String? punnyamCodeValidationMessage;
  String? passwordValidationMessage;
  String? confirmPasswordValidationMessage;
  bool isLoginFormValidated = false;
  bool isRegisterFormValidated = false;
  bool isRememberCredentials = true;
  Future<void> login({Function? onSuccess, Function? onFailure}) async {
    updateLoadState(LoaderState.loading);
    var res = await serviceConfig.login(
        email: loginUsernameController.text,
        password: loginPasswordController.text);
    if (res.isValue) {
      LoginResponseModel loginResponseModel = res.asValue!.value;
      if (isRememberCredentials) {
        await SharedPreferenceHelper.saveToken(loginResponseModel.token ?? '');

        //  await SharedPreferenceHelper.savesetting(loginResponseModel. ?? '');
      }
      if (onSuccess != null) onSuccess();
      updateLoadState(LoaderState.loaded);
    } else {
      errorToast = 'Login failed';
      if (onFailure != null) onFailure();
      updateLoadState(LoaderState.loaded);
    }
    notifyListeners();
  }

  Future<void> register({Function? onSuccess, Function? onFailure}) async {
    updateLoadState(LoaderState.loading);
    RegisterBody registerBody = RegisterBody(
        password: passwordController.text,
        email: emailController.text,
        confirmPassword: confirmPasswordController.text,
        name: nameController.text,
        punnyamCode: punnyamCodeController.text);
    var res = await serviceConfig.register(registerBody);
    if (res.isValue) {
      LoginResponseModel loginResponseModel = res.asValue!.value;
      await SharedPreferenceHelper.saveToken(loginResponseModel.token ?? '');
      if (onSuccess != null) onSuccess();
      updateLoadState(LoaderState.loaded);
    } else {
      errorToast = 'Registration failed';
      if (onFailure != null) onFailure();
      updateLoadState(LoaderState.loaded);
    }
    notifyListeners();
  }

  updateValidationMessages(
      {required ValidationTypes validationType,
      required String validationMessage}) {
    switch (validationType) {
      case ValidationTypes.name:
        if (validationMessage.isNotEmpty) {
          nameValidationMessage = validationMessage;
        } else {
          nameValidationMessage = null;
        }

        break;

      case ValidationTypes.email:
        if (validationMessage.isNotEmpty) {
          emailValidationMessage = validationMessage;
        } else {
          emailValidationMessage = null;
        }
        break;
      case ValidationTypes.punnyamCode:
        if (validationMessage.isNotEmpty) {
          punnyamCodeValidationMessage = validationMessage;
        } else {
          punnyamCodeValidationMessage = null;
        }
        break;
      case ValidationTypes.password:
        if (validationMessage.isNotEmpty) {
          passwordValidationMessage = validationMessage;
        } else {
          passwordValidationMessage = null;
        }
        break;
      case ValidationTypes.confirmPassword:
        if (validationMessage.isNotEmpty) {
          confirmPasswordValidationMessage = validationMessage;
        } else {
          confirmPasswordValidationMessage = null;
        }
        break;
      case ValidationTypes.userName:
        if (validationMessage.isNotEmpty) {
          userNameValidationMessage = validationMessage;
        } else {
          userNameValidationMessage = null;
        }
        break;
    }
    updateLoginFormState();
    updateRegisterFormState();
    notifyListeners();
  }

  updateLoginFormState() {
    if (loginUsernameController.text.isNotEmpty &&
        loginPasswordController.text.isNotEmpty &&
        userNameValidationMessage == null) {
      isLoginFormValidated = true;
    } else {
      isLoginFormValidated = false;
    }
    debugPrint('is login form validated $isLoginFormValidated');
    notifyListeners();
  }

  updateRegisterFormState() {
    if (nameController.text.isNotEmpty &&
        emailController.text.isNotEmpty &&
        punnyamCodeController.text.isNotEmpty &&
        passwordController.text.isNotEmpty &&
        confirmPasswordController.text.isNotEmpty &&
        nameValidationMessage == null &&
        emailValidationMessage == null &&
        punnyamCodeValidationMessage == null &&
        passwordValidationMessage == null &&
        confirmPasswordValidationMessage == null) {
      isRegisterFormValidated = true;
    } else {
      isRegisterFormValidated = false;
    }
    notifyListeners();
  }

  updateRememberMeValue(bool value) {
    isRememberCredentials = value;
    notifyListeners();
  }

  clearValues() {
    nameController.clear();
    emailController.clear();
    punnyamCodeController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
    loginUsernameController.clear();
    loginPasswordController.clear();
    nameValidationMessage = null;
    emailValidationMessage = null;
    punnyamCodeValidationMessage = null;
    passwordValidationMessage = null;
    confirmPasswordValidationMessage = null;
    userNameValidationMessage = null;
    notifyListeners();
  }

  @override
  void updateLoadState(LoaderState state) {
    loaderState = state;
    notifyListeners();
  }
}

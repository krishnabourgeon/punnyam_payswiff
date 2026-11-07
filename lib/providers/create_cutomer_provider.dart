import 'package:flutter/cupertino.dart';
import 'package:punnyam/models/create_customer_body.dart';
import 'package:punnyam/models/search_response_model.dart';
import 'package:punnyam/services/provider_helper_class.dart';
import 'package:punnyam/services/validation_helper.dart';

class CreateCustomerProvider extends ChangeNotifier with ProviderHelperClass {
  TextEditingController searchController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController mobileController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController houseNameController = TextEditingController();
  TextEditingController streetController = TextEditingController();
  TextEditingController pinCodeController = TextEditingController();
  TextEditingController postController = TextEditingController();

  String? districtName;
  String? nameErrorMessage;
  String? mobileErrorMessage;
  String? emailErrorMessage;
  String? houseNameErrorMessage;
  String? streetErrorMessage;
  String? postErrorMessage;
  String? pinCodeErrorMessage;
  String? message;

  bool isCreateFormValidated = false;
  SearchResponse? searchResponse;
  List<SearchResponseData> userList = [];
  List<String> districtsList = [
    'Alappuzha',
    'Ernakulam',
    'Idukki',
    'Kannur',
    'Kasaragod',
    'Kollam',
    'Kottayam',
    'Kozhikode',
    'Malappuram',
    'Palakkad',
    'Pathanamthitta',
    'Thiruvananthapuram',
    'Thrissur',
    'Wayanad'
  ];
  Future<void> searchCustomer() async {
    updateBtnLoader(true);
    try {
      var res =
          await serviceConfig.searchCustomer(searchController.text.trim());
      if (res.isValue) {
        searchResponse = res.asValue!.value;
        updateUserList(searchResponse);
        updateBtnLoader(false);
      } else {
        updateBtnLoader(false);
      }
    } catch (e) {
      debugPrint('exception in search: $e');
      updateLoadState(LoaderState.loaded);
    }
  }

  Future<void> createCustomer(CreateCustomer createCustomer,
      {Function? onSuccess, Function? onFailure}) async {
    updateLoadState(LoaderState.loading);
    try {
      var res = await serviceConfig.createCustomer(createCustomer);
      if (res.isValue) {
        message = 'Customer created successfully';
        updateLoadState(LoaderState.loaded);
        if (onSuccess != null) onSuccess();
      } else {
        message = 'Mobile number already exists. Please try another one.';
        updateLoadState(LoaderState.loaded);
        if (onFailure != null) onFailure();
      }
    } catch (e) {
      debugPrint('exception in search: $e');
      updateLoadState(LoaderState.loaded);
    }
    notifyListeners();
  }

  updateUserList(SearchResponse? searchResponse) {
    userList = searchResponse?.data ?? [];
    notifyListeners();
  }

  updateDistrictName(String name) {
    districtName = name;
    notifyListeners();
  }

  updateValidationMessage(
      {required CreateCustomerValidationTypes validationTypes,
      required String validationMessage}) {
    switch (validationTypes) {
      case CreateCustomerValidationTypes.name:
        if (validationMessage.isNotEmpty) {
          nameErrorMessage = validationMessage;
        } else {
          nameErrorMessage = null;
        }
        break;
      case CreateCustomerValidationTypes.email:
        if (validationMessage.isNotEmpty) {
          emailErrorMessage = validationMessage;
        } else {
          emailErrorMessage = null;
        }
        break;
      case CreateCustomerValidationTypes.mobileNumber:
        if (validationMessage.isNotEmpty) {
          mobileErrorMessage = validationMessage;
        } else {
          mobileErrorMessage = null;
        }
        break;
      case CreateCustomerValidationTypes.houseName:
        if (validationMessage.isNotEmpty) {
          houseNameErrorMessage = validationMessage;
        } else {
          houseNameErrorMessage = null;
        }
        break;
      case CreateCustomerValidationTypes.street:
        if (validationMessage.isNotEmpty) {
          streetErrorMessage = validationMessage;
        } else {
          streetErrorMessage = null;
        }
        break;
      case CreateCustomerValidationTypes.post:
        if (validationMessage.isNotEmpty) {
          postErrorMessage = validationMessage;
        } else {
          postErrorMessage = null;
        }
        break;
      case CreateCustomerValidationTypes.pinCode:
        if (validationMessage.isNotEmpty) {
          pinCodeErrorMessage = validationMessage;
        } else {
          pinCodeErrorMessage = null;
        }
        break;
    }
    updateCreateCustomerFormState();
    notifyListeners();
  }

  updateCreateCustomerFormState() {
    if (nameController.text.isNotEmpty &&
        mobileController.text.isNotEmpty &&
        houseNameController.text.isNotEmpty &&
        streetController.text.isNotEmpty &&
        postController.text.isNotEmpty &&
        pinCodeController.text.isNotEmpty &&
        nameErrorMessage == null &&
        mobileErrorMessage == null &&
        emailErrorMessage == null &&
        houseNameErrorMessage == null &&
        streetErrorMessage == null &&
        postErrorMessage == null &&
        pinCodeErrorMessage == null &&
        districtName != null) {
      isCreateFormValidated = true;
    } else {
      isCreateFormValidated = false;
    }
    notifyListeners();
  }

  clearValues() {
    userList.clear();
    nameController.clear();
    mobileController.clear();
    emailController.clear();
    houseNameController.clear();
    streetController.clear();
    postController.clear();
    pinCodeController.clear();
    searchController.clear();
    nameErrorMessage = null;
    mobileErrorMessage = null;
    emailErrorMessage = null;
    houseNameErrorMessage = null;
    streetErrorMessage = null;
    postErrorMessage = null;
    pinCodeErrorMessage = null;
    districtName = null;
    notifyListeners();
  }

  @override
  void updateLoadState(LoaderState state) {
    loaderState = state;
    notifyListeners();
  }

  @override
  void updateBtnLoader(bool value) {
    btnLoader = value;
    notifyListeners();
  }
}

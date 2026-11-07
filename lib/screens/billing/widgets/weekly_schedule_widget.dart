import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:punnyam/providers/billing_provider.dart';
import '../../../common/custom_drop_down_search.dart';
import '../../../common/date_picker.dart';
import '../../../services/provider_helper_class.dart';
import '../../../services/validation_helper.dart';
import '../../../widgets/punnyam_textfiled.dart';
import 'loading_dropdown.dart';

class WeeklyScheduleWidget extends StatelessWidget {
  const WeeklyScheduleWidget({Key? key, required this.billingProvider})
      : super(key: key);
  final BillingProvider billingProvider;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        billingProvider.loaderState == LoaderState.loading
            ? const LoadingDropDown(
                title: 'Week Days',
              )
            : CustomDropDownSearch(
                labelText: 'Week Days',
                onChanged: (value) => billingProvider
                  ..updateWeekDays(value)
                  ..updateBillingFormState(),
                items: List.generate(billingProvider.weekDayList.length,
                    (index) => billingProvider.weekDayList[index]),
              ),
        10.verticalSpace,
        PunnyamDatePicker(
          title: billingProvider.fromDate?.split('-').reversed.join('-'),
          onChanged: (date) {
            debugPrint('date $date');
            billingProvider
              ..updateFromDate(date)
              ..updateBillingFormState();
          },
        ),
        10.verticalSpace,
        PunnyamTextField(
          hintText: "Weeks",
          inputFormatter: [FilteringTextInputFormatter.digitsOnly],
          textInputAction: TextInputAction.next,
          keyboardType: TextInputType.number,
          textEditingController: billingProvider.noOfWeeksController,
          hintStyle: TextStyle(
            fontSize: 14.sp,
            color: Colors.grey.shade600,
          ),
          onChanged: (value) {
            billingProvider.updateValidationMessage(
                validationTypes: ValidationTypes.qty,
                validationMessage:
                    ValidationHelperClass.validateQty(value.trim()) ?? '');
            billingProvider.updateBillingFormState();
          },
        ),
        10.verticalSpace,
        billingProvider.loaderState == LoaderState.loading
            ? const LoadingDropDown(
                title: 'Prasadam',
              )
            : CustomDropDownSearch(
                labelText: 'Prasadam',
                maxHeight: 100.h,
                onChanged: (value) => billingProvider
                  ..updateIsPrasadhamIncluded(value)
                  ..updateBillingFormState(),
                items: List.generate(billingProvider.prasadamList.length,
                    (index) => billingProvider.prasadamList[index]),
              ),
      ],
    );
  }
}

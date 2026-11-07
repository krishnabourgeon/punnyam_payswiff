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

class MonthlyScheduleWidget extends StatelessWidget {
  const MonthlyScheduleWidget({Key? key, required this.billingProvider})
      : super(key: key);
  final BillingProvider billingProvider;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PunnyamDatePicker(
          title: billingProvider.fromDate?.split('-').reversed.join('-'),
          onChanged: (date) {
            debugPrint('date $date');
            billingProvider
              ..updateFromDate(date)
              ..updateBillingFormState();
            // debugPrint(DateFormat.yMMMMd().format(DateTime.now()));
          },
        ),
        10.verticalSpace,
        PunnyamTextField(
          hintText: "Months",
          inputFormatter: [FilteringTextInputFormatter.digitsOnly],
          textInputAction: TextInputAction.next,
          keyboardType: TextInputType.number,
          textEditingController: billingProvider.noOfMonthsController,
          hintStyle: TextStyle(
            fontSize: 14.sp,
            // fontWeight: FontWeight.bold,
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

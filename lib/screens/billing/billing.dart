import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:punnyam/common/common_button.dart';
import 'package:punnyam/common/common_functions.dart';
import 'package:punnyam/providers/billing_provider.dart';
import 'package:punnyam/screens/billing/widgets/daily_schedule_widget.dart';
import 'package:punnyam/screens/billing/widgets/loading_dropdown.dart';
import 'package:punnyam/screens/billing/widgets/monthly_schedule_widget.dart';
import 'package:punnyam/screens/billing/widgets/normal_billing_widget.dart';
import 'package:punnyam/screens/billing/widgets/other_schedule_widget.dart';
import 'package:punnyam/screens/billing/widgets/weekly_schedule_widget.dart';
import 'package:punnyam/services/provider_helper_class.dart';
import 'package:punnyam/widgets/punnyam_switch.dart';
import 'package:punnyam/widgets/stack_loader.dart';
import '../../common/custom_drop_down_search.dart';

class Billing extends StatefulWidget {
  const Billing({super.key});
  @override
  State<Billing> createState() => _BillingState();
}

class _BillingState extends State<Billing> {
  final DateFormat formatter = DateFormat('dd-MM-yyyy');
  DateTime selectedDate = DateTime.now();
  @override
  void initState() {
    CommonFunctions.afterInit(() {
      context.read<BillingProvider>().getInitialDataList();
    });
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
          "Billing",
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: Consumer<BillingProvider>(builder: (__, billingProvider, _) {
        return StackLoader(
          inAsyncCall:
              billingProvider.loaderState == LoaderState.loading ? true : false,
          child: SingleChildScrollView(
            reverse: true,
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                children: [
                  NormalBillingWidget(billingProvider: billingProvider),
                  if (billingProvider.deityname != "DONATION") ...[
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 5.w),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Do you want to schedule?",
                            style: TextStyle(color: Colors.black),
                          ),
                          PunnyamSwitch(
                            isOn: billingProvider.isScheduled,
                            onTap: (value) => billingProvider
                              ..updateSwitch(value)
                              ..updateBillingFormState(),
                          ),
                        ],
                      ),
                    ),
                    if (billingProvider.isScheduled)
                      Column(
                        children: [
                          10.verticalSpace,
                          billingProvider.loaderState == LoaderState.loading
                              ? const LoadingDropDown(
                                  title: 'Schedule Type',
                                )
                              : CustomDropDownSearch(
                                  labelText: 'Schedule Type',
                                  maxHeight: 220.h,
                                  onChanged: (value) => billingProvider
                                    ..updateSheduleType(value)
                                    ..updateBillingFormState(),
                                  items: List.generate(
                                      billingProvider.scheduleTypesList.length,
                                      (index) =>
                                          billingProvider
                                              .scheduleTypesList[index]
                                          ),
                                ),
                          10.verticalSpace,
                          if (billingProvider.scheduleTypes == "Daily")
                            DailyScheduleWidget(billingProvider: billingProvider),
                          if (billingProvider.scheduleTypes == "Weekly")
                            WeeklyScheduleWidget(
                                billingProvider: billingProvider),
                          if (billingProvider.scheduleTypes == "Monthly")
                            MonthlyScheduleWidget(
                                billingProvider: billingProvider),
                          if (billingProvider.scheduleTypes == "Other")
                            OtherScheduleWidget(billingProvider: billingProvider),
                          20.verticalSpace,
                        ],
                      ),
                  ],
                  CommonButton(
                    title: "Save and Add Next",
                    onPressed: billingProvider.isBillingFormValidated
                        ? () async {
                            FocusScope.of(context).unfocus();
                            BillingProvider.address = false;
                            await billingProvider.saveAndNextFunction();
                            // billingProvider.getStarIdFromName('Nodata');
                          }
                        : null,
                  ),
                  10.verticalSpace,
                  CommonButton(
                      title: "Save and Preview",
                      colors: [
                        billingProvider.poojaDetailsList.isEmpty
                            ? billingProvider.isBillingFormValidated
                                ? Colors.green
                                : Colors.green.withOpacity(.5)
                            : Colors.green,
                        billingProvider.poojaDetailsList.isEmpty
                            ? billingProvider.isBillingFormValidated
                                ? Colors.greenAccent
                                : Colors.greenAccent.withOpacity(.5)
                            : Colors.greenAccent
                      ],
                      onPressed: billingProvider.poojaDetailsList.isEmpty
                          ? billingProvider.isBillingFormValidated
                              ? () {
                                  BillingProvider.address = false;
                                  billingProvider
                                      .saveAndPreviewFunction(context);
                                }
                              : null
                          : () =>
                              billingProvider.navigateToPreviewBill(context)),
                  30.verticalSpace,
                  Padding(
                      padding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).viewInsets.bottom))
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}

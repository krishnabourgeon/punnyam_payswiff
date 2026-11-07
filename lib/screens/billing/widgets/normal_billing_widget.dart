import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:punnyam/common/custom_drop_down_search.dart';
import 'package:punnyam/common/date_picker.dart';
import 'package:punnyam/providers/billing_provider.dart';
import 'package:punnyam/screens/billing/widgets/loading_dropdown.dart';
import 'package:punnyam/services/provider_helper_class.dart';
import 'package:punnyam/services/validation_helper.dart';
import '../../../models/dieties_response_model.dart';
import '../../../widgets/punnyam_textfiled.dart';
import '../../register/register_screen.dart';

class NormalBillingWidget extends StatefulWidget {
  const NormalBillingWidget({Key? key, required this.billingProvider})
      : super(key: key);
  final BillingProvider billingProvider;
  @override
  State<NormalBillingWidget> createState() => _NormalBillingWidgetState();
}

class _NormalBillingWidgetState extends State<NormalBillingWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SizedBox(
        height: 20.h,
      ),
      widget.billingProvider.loaderState == LoaderState.loading
          ? const LoadingDropDown(
              title: 'Select Deity',
            )
          : Selector<BillingProvider, List<DeitiesData>>(
              selector: (context, billingProvider) =>
                  billingProvider.deitiesList,
              builder: (context, value, child) {
                debugPrint('value ${value.length}');
                return CustomDropDownSearch(
                  labelText: 'Select Deity',
                  selected: widget.billingProvider.deityname,
                  isShowSearch: true,
                  onChanged: (value) => widget.billingProvider
                    ..poojaName = null
                    ..poojaId = ''
                    ..getDeityIdFromName(value)
                    ..getPoojas(isEnableBtnLoader: true)
                    // ..ayyapanpooja(value)
                    ..updateBillingFormState(),
                  items: List.generate(value.length, (index) {
                    return value[index].name ?? '';
                  }),
                );
              }),
      10.verticalSpace,
      widget.billingProvider.btnLoader
          ? Container(
              height: 45.h,
              width: double.maxFinite,
              padding: EdgeInsets.symmetric(horizontal: 15.w),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(40.r),
                color: Colors.grey.shade200,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Select Pooja',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                    ),
                  ),
                  SizedBox(
                    height: 15.h,
                    width: 15.w,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.r,
                    ),
                  ),
                ],
              ),
            )
          : CustomDropDownSearch(
              labelText: 'Select Pooja',
              selected: widget.billingProvider.poojaName,
              isShowSearch: true,
              onChanged: (value) => widget.billingProvider
                ..getPoojaIdFromName(value)
                ..updateBillingFormState(),
              items: List.generate(
                  widget.billingProvider.poojaDataList.length,
                  (index) =>
                      widget.billingProvider.poojaDataList[index].name ?? ''),
            ),
      10.verticalSpace,
      PunnyamTextField(
          hintText: "Customer",
          height: 45.h,
          textEditingController: widget.billingProvider.nameController,
          inputFormatter: [
            FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')),
          ],
          keyboardType: TextInputType.name,
          hintStyle: TextStyle(
            fontSize: 13.5.sp,
            fontWeight: FontWeight.normal,
            color: Colors.black,
          ),
          onChanged: (value) {
            widget.billingProvider.updateBillingFormState();
          }
          // => widget.billingProvider.updateValidationMessage(
          //     validationTypes: ValidationTypes.name,
          //     validationMessage:
          //         ValidationHelperClass.validateName(value.trim()) ?? ''),
          ),
      if (widget.billingProvider.nameErrorMessage != null)
        ValidationWidget(
            validationMessage: widget.billingProvider.nameErrorMessage ?? ''),
      10.verticalSpace,
      widget.billingProvider.loaderState == LoaderState.loading
          ? const LoadingDropDown(
              title: 'Select Star',
            )
          : CustomDropDownSearch(
              labelText: widget.billingProvider.starName,
              isShowSearch: true,
              onChanged: (value) {
                widget.billingProvider
                  ..getStarIdFromName(value)
                  ..updateBillingFormState();
              },
              items: List.generate(
                  widget.billingProvider.starsList.length,
                  (index) =>
                      widget.billingProvider.starsList[index].nameEng ?? ''),
            ),
      10.verticalSpace,
      widget.billingProvider.poojacountrow == 2
          ? Column(children: [
              PunnyamTextField(
                  hintText: "Customer",
                  height: 45.h,
                  textEditingController: widget.billingProvider.nameController2,
                  inputFormatter: [
                    FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')),
                  ],
                  keyboardType: TextInputType.name,
                  hintStyle: TextStyle(
                    fontSize: 13.5.sp,
                    fontWeight: FontWeight.normal,
                    color: Colors.black,
                  ),
                  onChanged: (value) {
                    widget.billingProvider.updateBillingFormState();
                  }),
              if (widget.billingProvider.nameErrorMessage != null)
                ValidationWidget(
                    validationMessage:
                        widget.billingProvider.nameErrorMessage ?? ''),
              10.verticalSpace,
              widget.billingProvider.loaderState == LoaderState.loading
                  ? const LoadingDropDown(
                      title: 'Select Star',
                    )
                  : CustomDropDownSearch(
                      labelText: widget.billingProvider.starName,
                      // labelColor: Colors.black,
                      isShowSearch: true,
                      onChanged: (value) {
                        widget.billingProvider
                          ..getStarIdFromName1(value)
                          ..updateBillingFormState();
                      },
                      items: List.generate(
                          widget.billingProvider.starsList.length,
                          (index) =>
                              widget.billingProvider.starsList[index].nameEng ??
                              ''),
                    ),
              10.verticalSpace,
            ])
          : const SizedBox(),
      // Row(
      //   children: [
      //     widget.billingProvider.loaderState == LoaderState.loading
      //         ? const Expanded(
      //             child: LoadingDropDown(
      //               title: 'Select Gothra',
      //             ),
      //           )
      //         : Expanded(
      //             child: CustomDropDownSearch(
      //               labelText: 'Select Gothra',
      //               // labelColor: Colors.black,
      //               isShowSearch: true,
      //               onChanged: (value) {
      //                 widget.billingProvider
      //                   ..getgothraIdFromName(value)
      //                   ..updateBillingFormState();
      //               },
      //               items: List.generate(
      //                   widget.billingProvider.gothraResponse?.data?.length ??
      //                       0,
      //                   (index) =>
      //                       widget.billingProvider.gothraResponse?.data![index]
      //                           .nameEng ??
      //                       ''),
      //             ),
      //           ),
      //     10.horizontalSpace,
      //     widget.billingProvider.loaderState == LoaderState.loading
      //         ? const Expanded(
      //             child: LoadingDropDown(
      //               title: 'Select Rashi',
      //             ),
      //           )
      //         : Expanded(
      //             child: CustomDropDownSearch(
      //               labelText: 'Select Rashi',
      //               // labelColor: Colors.black,
      //               isShowSearch: true,
      //               onChanged: (value) {
      //                 widget.billingProvider
      //                   ..getrashiIdFromName(value)
      //                   ..updateBillingFormState();
      //               },
      //               items: List.generate(
      //                   widget.billingProvider.rashiResponse?.data?.length ?? 0,
      //                   (index) =>
      //                       widget.billingProvider.rashiResponse?.data![index]
      //                           .nameEng ??
      //                       ''),
      //             ),
      //           ),
      //   ],
      // ),
      // 10.verticalSpace,
      !widget.billingProvider.isScheduled
          ? PunnyamDatePicker(
              title: widget.billingProvider.fromDate
                  ?.split('-')
                  .reversed
                  .join('-'),
              isFromDate: false,
              onChanged: (date) {
                debugPrint('date $date');
                widget.billingProvider
                  ..updateFromDate(date)
                  ..updateBillingFormState();
                // debugPrint(DateFormat.yMMMMd().format(DateTime.now()));
              },
            )
          : const SizedBox.shrink(),
      !widget.billingProvider.isScheduled ? 10.verticalSpace : 0.verticalSpace,
      Row(
        children: [
          Flexible(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PunnyamTextField(
                hintText: "Qty",
                height: 45.h,
                inputFormatter: [FilteringTextInputFormatter.digitsOnly],
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.number,
                isEnabled: BillingProvider.ratefield == true ? false : true,
                textEditingController: widget.billingProvider.qtyController,
                hintStyle: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey.shade600,
                ),
                onChanged: (value) {
                  widget.billingProvider.updateValidationMessage(
                      validationTypes: ValidationTypes.qty,
                      validationMessage:
                          ValidationHelperClass.validateQty(value.trim()) ??
                              '');
                  widget.billingProvider
                    ..updateRate()
                    ..updateBillingFormState();
                },
              ),
            ],
          )),
          10.horizontalSpace,
          Flexible(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PunnyamTextField(
                hintText: "Rate/Amount",
                height: 45.h,
                textEditingController: widget.billingProvider.rateController,
                textInputAction: TextInputAction.done,
                keyboardType: TextInputType.number,
                isEnabled: BillingProvider.ratefield == true ? true : false,
                hintStyle: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey.shade600,
                ),
                onChanged: (value) => widget.billingProvider
                    .updateValidationMessage(
                        validationTypes: ValidationTypes.rate,
                        validationMessage:
                            ValidationHelperClass.validateRate(value.trim()) ??
                                ''),
              ),
            ],
          )),
        ],
      ),
      10.verticalSpace,
      BillingProvider.address
          ? const SizedBox()
          : Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                InkWell(
                  onTap: () {
                    setState(() {
                      BillingProvider.address = true;
                    });
                  },
                  child: Container(
                    height: 40.h,
                    width: 100.w,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.grey),
                    child: const Center(child: Text("Add address")),
                  ),
                ),
              ],
            ),
      BillingProvider.address
          ? PunnyamTextField(
              hintText: "Address",
              height: 45.h,
              textEditingController: widget.billingProvider.addressController,
              keyboardType: TextInputType.text,
              hintStyle: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey.shade600,
              ),
              // onChanged: (value) => widget.billingProvider
              //     .updateValidationMessage(
              //         validationTypes: ValidationTypes.name,
              //         validationMessage:
              //             ValidationHelperClass.validateName(value.trim()) ??
              //                 ''),
            )
          : const SizedBox(),
    ]);
  }
}

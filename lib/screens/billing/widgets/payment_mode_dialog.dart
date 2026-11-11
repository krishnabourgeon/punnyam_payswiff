import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:punnyam/models/payment_mode_response.dart';
import 'package:punnyam/providers/billing_provider.dart';
import 'package:punnyam/services/helpers.dart';

/// What the user picked in the payment-mode popup.
class PaymentChoice {
  final PaymentModeDataList mode;

  /// Only filled for QR Code (typed by staff). Null for other modes.
  final String? transactionId;

  PaymentChoice(this.mode, this.transactionId);
}

/// "Card" in the payment-modes API -> Payswiff card payment
bool isCardMode(PaymentModeDataList m) =>
    (m.name ?? '').trim().toLowerCase() == 'card';

/// "QR Code" in the payment-modes API -> staff enters UPI transaction id
bool isQrMode(PaymentModeDataList m) =>
    (m.name ?? '').toLowerCase().contains('qr');

IconData _iconFor(PaymentModeDataList m) {
  final name = (m.name ?? '').toLowerCase();
  if (isCardMode(m)) return Icons.credit_card;
  if (isQrMode(m)) return Icons.qr_code_2;
  if (name.contains('cash')) return Icons.payments_outlined;
  if (name.contains('neft') || name.contains('bank')) {
    return Icons.account_balance_outlined;
  }
  return Icons.account_balance_wallet_outlined;
}

/// Shows the payment-mode popup when Save Bill is tapped.
/// Returns the selected mode, or null if the user cancels.
Future<PaymentChoice?> showPaymentModeDialog(
    BuildContext context, BillingProvider provider,
    {String? amount}) async {
  // Quick Bill passes its own total; normal billing uses the paid amount field
  final shownAmount = amount ?? provider.paidAmountController.text.trim();
  // All modes come from the payment-modes API (or SQLite when offline).
  final modes = provider.paymentModeDataList;

  if (modes.isEmpty) {
    Helpers.successToast('Payment modes not loaded. Please try again.');
    return null;
  }

  // Pre-select the last used mode, else the first one in the list
  PaymentModeDataList selected = modes.firstWhere(
    (m) => m.id == provider.paymentModeId,
    orElse: () => modes.first,
  );

  // final transCtrl = TextEditingController();

  return showDialog<PaymentChoice>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setState) {
        // final needsTxnId = isQrMode(selected);
        const needsTxnId = false;

        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          title: const Text('Select Payment Mode'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Amount: ₹ $shownAmount',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10.h),

                // One row per payment mode from the API
                ...modes.map((m) {
                  final isSelected = m.id == selected.id;
                  return Card(
                    elevation: 0,
                    margin: EdgeInsets.symmetric(vertical: 4.h),
                    color: isSelected ? Colors.orange.shade50 : Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                      side: BorderSide(
                        color: isSelected
                            ? Colors.orange
                            : Colors.grey.shade300,
                      ),
                    ),
                    child: ListTile(
                      leading: Icon(
                        _iconFor(m),
                        color: isSelected ? Colors.orange : Colors.grey,
                      ),
                      title: Text(
                        m.name ?? '',
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      trailing: Icon(
                        isSelected
                            ? Icons.radio_button_checked
                            : Icons.radio_button_off,
                        color: isSelected ? Colors.orange : Colors.grey,
                      ),
                      onTap: () => setState(() => selected = m),
                    ),
                  );
                }),

                // QR Code -> staff types the UPI transaction id
                // if (needsTxnId) ...[
                //   SizedBox(height: 12.h),
                //   TextField(
                //     controller: transCtrl,
                //     autofocus: true,
                //     textInputAction: TextInputAction.done,
                //     decoration: InputDecoration(
                //       labelText: 'Transaction Id',
                //       border: OutlineInputBorder(
                //         borderRadius: BorderRadius.circular(10.r),
                //       ),
                //     ),
                //   ),
                // ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                // if (needsTxnId && transCtrl.text.trim().isEmpty) {
                //   Helpers.successToast('Please enter Transaction Id');
                //   return;
                // }
                Navigator.pop(
                  ctx,
                  PaymentChoice(
                    selected,
                    null, // QR txn id now comes from the Payswiff QR result
                  ),
                );
              },
              child: Text(isCardMode(selected)
                  ? 'Pay by Card'
                  : isQrMode(selected)
                      ? 'Show QR'
                      : 'Save Bill'),
            ),
          ],
        );
      },
    ),
  );
}
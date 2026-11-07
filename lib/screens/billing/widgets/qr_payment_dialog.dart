import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:punnyam/models/qr_payment_result.dart';
import 'package:punnyam/services/apos_payment.dart';

/// Shows a Payswiff dynamic QR and waits for the customer to pay.
/// Always returns a result (never null).
Future<QrPaymentResult> showQrPaymentDialog(
  BuildContext context, {
  required double amount,
  required String orderRefNo,
}) async {
  final res = await showDialog<QrPaymentResult>(
    context: context,
    barrierDismissible: false,
    builder: (_) => _QrPaymentDialog(amount: amount, orderRefNo: orderRefNo),
  );
  return res ?? QrPaymentResult.of('cancelled', 'QR cancelled');
}

class _QrPaymentDialog extends StatefulWidget {
  final double amount;
  final String orderRefNo;
  const _QrPaymentDialog({required this.amount, required this.orderRefNo});

  @override
  State<_QrPaymentDialog> createState() => _QrPaymentDialogState();
}

class _QrPaymentDialogState extends State<_QrPaymentDialog> {
  static const _defaultTimeout = 300; // seconds, if the SDK sends no timer

  QrInfo? _qr;
  String? _error;
  int _secondsLeft = _defaultTimeout;
  Timer? _timer;
  StreamSubscription<QrPaymentResult>? _sub;
  bool _closed = false;

  @override
  void initState() {
    super.initState();
    _sub = AposPayment.qrStatus.listen(_close);
    _generate();
  }

  Future<void> _generate() async {
    _timer?.cancel();
    setState(() {
      _qr = null;
      _error = null;
    });
    try {
      final qr = await AposPayment.generateQr(
          amount: widget.amount, orderRefNo: widget.orderRefNo);
      if (!mounted || _closed) return;
      setState(() {
        _qr = qr;
        _secondsLeft = (qr.timerSeconds ?? 0) > 0
            ? qr.timerSeconds!
            : _defaultTimeout;
      });
      _startTimer();
    } on PlatformException catch (e) {
      if (mounted && !_closed) {
        setState(() => _error = e.message ?? 'Could not create QR');
      }
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      if (_secondsLeft <= 1) {
        AposPayment.cancelQr();
        _close(QrPaymentResult.of('expired', 'QR expired'));
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  void _close(QrPaymentResult r) {
    if (_closed || !mounted) return;
    _closed = true;
    _timer?.cancel();
    Navigator.pop(context, r);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _sub?.cancel();
    super.dispose();
  }

  String get _mmss {
    final m = (_secondsLeft ~/ 60).toString().padLeft(2, '0');
    final s = (_secondsLeft % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: const Text('Scan to Pay'),
        content: SizedBox(
          width: 280.w,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('₹ ${widget.amount.toStringAsFixed(2)}',
                  style:
                      TextStyle(fontSize: 22.sp, fontWeight: FontWeight.bold)),
              SizedBox(height: 12.h),
              if (_error != null) ...[
                Icon(Icons.error_outline, color: Colors.red, size: 48.r),
                SizedBox(height: 8.h),
                Text(_error!, textAlign: TextAlign.center),
              ] else if (_qr == null) ...[
                SizedBox(height: 40.h),
                const CircularProgressIndicator(),
                SizedBox(height: 12.h),
                const Text('Generating QR...'),
                SizedBox(height: 40.h),
              ] else ...[
                Image.memory(base64Decode(_qr!.qrImage),
                    width: 240.w, height: 240.w, gaplessPlayback: true),
                if (_qr!.vpa != null) ...[
                  SizedBox(height: 6.h),
                  Text(_qr!.vpa!, style: TextStyle(fontSize: 13.sp)),
                ],
                SizedBox(height: 10.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                        width: 16.r,
                        height: 16.r,
                        child:
                            const CircularProgressIndicator(strokeWidth: 2)),
                    SizedBox(width: 8.w),
                    Text('Waiting for payment  $_mmss'),
                  ],
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              AposPayment.cancelQr();
              _close(QrPaymentResult.of('cancelled', 'QR cancelled'));
            },
            child: const Text('Cancel'),
          ),
          if (_error != null)
            ElevatedButton(onPressed: _generate, child: const Text('Retry')),
        ],
      ),
    );
  }
}

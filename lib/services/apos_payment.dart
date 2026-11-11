import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:punnyam/models/card_payment_result.dart';
import 'package:punnyam/models/qr_payment_result.dart';
import 'package:punnyam/services/apos_printer.dart';
import 'package:punnyam/services/app_config.dart';

class AposPayment {
  static const _channel = MethodChannel('punnyam/apos_payment');

  static final _qrStatus = StreamController<QrPaymentResult>.broadcast();
  static bool _listening = false;

  static Future<bool> isActivated() async {
    try {
      return await _channel.invokeMethod<bool>('isActivated') ?? false;
    } catch (_) {
      return false;
    }
  }

  static Future<String> activate(
          {required String merchantKey, required String partnerKey}) async =>
      await _channel.invokeMethod<String>('activate', {
        'merchantKey': merchantKey,
        'partnerKey': partnerKey,
      }) ??
      'Activated';

  static Future<Map<String, dynamic>> getMerchantConfig(
      {required String apiKey, required String secureKey}) async {
    final res = await _channel.invokeMethod('getMerchantConfig', {
      'apiKey': apiKey,
      'secureKey': secureKey,
    });
    return Map<String, dynamic>.from(res as Map);
  }

  /// Opens the Payswiff card screen. Never throws.
  static Future<CardPaymentResult> startSale({
    required double amount,
    required String merchantRefNo,
    String? mobile,
    String? name,
  }) async {
    try {
      final res = await _channel.invokeMethod('startSale', {
        'amount': amount.toStringAsFixed(2), // confirm format with Payswiff
        'merchantRefNo': merchantRefNo,
        'orderRefNo': merchantRefNo,
        'mobile': mobile ?? '',
        'name': name ?? 'Customer',
      });
      return CardPaymentResult.fromMap(res as Map);
    } on PlatformException catch (e) {
      return CardPaymentResult.error(e.message ?? 'Payment error');
    }
  }


   static Stream<QrPaymentResult> get qrStatus {
    if (!_listening) {
      _listening = true;
      _channel.setMethodCallHandler((call) async {
        if (call.method == 'onQrStatus') {
          _qrStatus.add(QrPaymentResult.fromMap(call.arguments as Map));
        }
      });
    }
    return _qrStatus.stream;
  }

  /// Generates a dynamic QR and starts status polling. Throws PlatformException.
  static Future<QrInfo> generateQr({
    required double amount,
    required String orderRefNo,
  }) async {
    qrStatus; // make sure the listener is attached before polling starts
    final res = await _channel.invokeMethod('generateQr', {
      'amount': amount.toStringAsFixed(2),
      'orderRefNo': orderRefNo,
      'merchantRefNo': AppConfig.psMid ?? '', // confirm with Payswiff
    });
    return QrInfo.fromMap(res as Map);
  }

  /// Stops polling. Safe to call any time.
  static Future<void> cancelQr() async {
    try {
      await _channel.invokeMethod('cancelQr');
    } catch (_) {}
  }

  static Future<CardPaymentResult> voidTxn(String referenceNumber) async {
    try {
      final res = await _channel
          .invokeMethod('voidTxn', {'referenceNumber': referenceNumber});
      return CardPaymentResult.fromMap(res as Map);
    } on PlatformException catch (e) {
      return CardPaymentResult(status: 'failed', responseMessage: e.message);
    }
  }


  /// Call after login / auto-login. Activates the SDK once and loads MID/TID.
  static Future<bool> ensureActivated() async {
    if (!await AposPrinter.isPosDevice()) return false;
    try {
      if (!await isActivated()) {
        final msg = await activate(
            merchantKey: AppConfig.psMerchantKey,
            partnerKey: AppConfig.psPartnerKey);
        debugPrint('Payswiff activation: $msg');
        AppConfig.psTid = null; // reload MID/TID for the newly activated environment
      }
    } on PlatformException catch (e) {
      debugPrint('Payswiff activation failed: ${e.message}');
      return false;
    }

    // Not critical - don't block payments if this fails
    if (AppConfig.psTid == null) {
      try {
        final cfg = await getMerchantConfig(
            apiKey: AppConfig.psMerchantApiKey,
            secureKey: AppConfig.psSecureKey);
        AppConfig.psMid = cfg['mid'] ?? AppConfig.psMid; // keep default MID
        AppConfig.psTid = cfg['tid'];
        AppConfig.psSerialNo = cfg['serialNumber'];
      } catch (e) {
        debugPrint('Merchant config failed: $e');
      }
    }

    await Permission.location.request(); // SDK sends location with each sale
    return true;
  }
}
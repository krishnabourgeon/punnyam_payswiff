import 'dart:convert';
import 'package:flutter/services.dart';

class AposPrinter {
  static const _channel = MethodChannel('punnyam/apos_printer');

  /// True only on the Payswiff POS terminal (N86).
  /// Never throws: any channel error means "not a POS device".
  static Future<bool> isPosDevice() async {
    try {
      return await _channel.invokeMethod<bool>('isPosDevice') ?? false;
    } catch (_) {
      return false;
    }
  }

  /// [receipt] keys must match PrintModel fields (header, footer, businessName,
  /// address, billNo, billTime, itemModelList, totalAmount, ...).
  static Future<void> printReceipt(Map<String, dynamic> receipt, {Uint8List? logo}) =>
    _channel.invokeMethod('printReceipt', {
      'json': jsonEncode(receipt),
      if (logo != null) 'logo': base64Encode(logo),
    });
}
import 'dart:async';
import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:punnyam/services/app_config.dart';
import 'package:punnyam/services/app_exceptions.dart';
import 'package:punnyam/services/database_helper.dart';
import 'package:punnyam/services/helpers.dart';
import 'package:punnyam/services/service_config.dart';

/// Uploads bills that were saved to SQLite while offline (see
/// `BillingProvider._saveBillOffline`) as soon as the connection is back.
class OfflineSyncService {
  OfflineSyncService._();
  static final OfflineSyncService instance = OfflineSyncService._();

  final DatabaseHelper _db = DatabaseHelper.instance;
  final ServiceConfig _api = ServiceConfig();

  /// Number of bills waiting to be synced (for a badge in the UI, if wanted).
  final ValueNotifier<int> pendingCount = ValueNotifier<int>(0);

  StreamSubscription<List<ConnectivityResult>>? _subscription;
  bool _syncing = false;

  Future<void> init() async {
    await refreshPendingCount();
    _subscription ??= Connectivity().onConnectivityChanged.listen((results) {
      if (results.any((r) => r != ConnectivityResult.none)) {
        onOnline();
      }
    });
    onOnline();
  }

  /// Called whenever the device (may have) come online.
  Future<void> onOnline() async {
    if ((AppConfig.accessToken ?? '').isEmpty) return;
    await syncPendingBills();
  }

  Future<void> refreshPendingCount() async {
    pendingCount.value = await _db.pendingBillCount();
  }

  /// Stores a bill body (`SaveBillBody.toJson()`) for later upload.
  Future<int> queueBill(Map<String, dynamic> billBody) async {
    final id = await _db.insertPendingBill(jsonEncode(billBody));
    await refreshPendingCount();
    return id;
  }

  Future<void> syncPendingBills() async {
    if (_syncing) return;
    _syncing = true;
    int synced = 0;
    try {
      final rows = await _db.getPendingBills();
      for (final row in rows) {
        final id = row['id'] as int;
        try {
          final payload =
              jsonDecode(row['payload'] as String) as Map<String, dynamic>;
          final res = await _api.syncOfflineBill(payload);
          if (res.isValue) {
            await _db.deletePendingBill(id);
            synced++;
          } else {
            await _db.markPendingBillFailed(id, '${res.asError!.error}');
          }
        } on NoInternetException {
          break; // still offline – keep everything queued, retry later
        } catch (e) {
          debugPrint('sync of pending bill $id failed: $e');
          await _db.markPendingBillFailed(id, '$e');
        }
      }
    } finally {
      _syncing = false;
      await refreshPendingCount();
    }
    if (synced > 0) {
      Helpers.successToast('$synced offline bill(s) synced');
    }
  }
}

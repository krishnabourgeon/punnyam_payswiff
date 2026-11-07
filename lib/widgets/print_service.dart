import 'package:permission_handler/permission_handler.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';

class PrinterService {
  static const String _targetPrinterName = 'InnerPrinter';
  static bool isConnected = false;

  static Future<bool> autoConnect() async {
    try {
      // ✅ Must request this on Android 12+
      final btPermission = await Permission.bluetoothConnect.request();
      final scanPermission = await Permission.bluetoothScan.request();

      if (!btPermission.isGranted || !scanPermission.isGranted) {
        print('Bluetooth permissions denied');
        return false;
      }

      List<BluetoothInfo> devices =
          await PrintBluetoothThermal.pairedBluetooths;

      final printer = devices.firstWhere(
        (d) => d.name == _targetPrinterName,
        orElse: () => throw Exception('InnerPrinter not found'),
      );

      await PrintBluetoothThermal.disconnect;
      await Future.delayed(const Duration(milliseconds: 500));

      final result = await PrintBluetoothThermal.connect(
        macPrinterAddress: printer.macAdress,
      );

      isConnected = result;
      print("connected....$isConnected");
      return result;
    } catch (e) {
      isConnected = false;
      print('Auto-connect error: $e');
      return false;
    }
  }

  /// Check connection and reconnect if dropped
  static Future<bool> ensureConnected() async {
    final connected = await PrintBluetoothThermal.connectionStatus;
    if (!connected) {
      return await autoConnect();
    }
    isConnected = true;
    return true;
  }
}

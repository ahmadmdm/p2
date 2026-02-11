import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'settings_controller.g.dart';

const _defaultApiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://localhost:3000',
);

@riverpod
class SettingsController extends _$SettingsController {
  @override
  Future<Map<String, dynamic>> build() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'printerIp': prefs.getString('printerIp') ?? '',
      'printerPort': prefs.getInt('printerPort') ?? 9100,
      'paperSize': prefs.getString('paperSize') ?? '80mm', // 80mm or 58mm
      'printerRetryCount': prefs.getInt('printerRetryCount') ?? 1,
      'printerTimeoutMs': prefs.getInt('printerTimeoutMs') ?? 5000,
      'receiptCopies': prefs.getInt('receiptCopies') ?? 1,
      'autoPrintReceipt': prefs.getBool('autoPrintReceipt') ?? true,
      'autoPrintKitchen': prefs.getBool('autoPrintKitchen') ?? true,
      'baseUrl': prefs.getString('baseUrl') ?? _defaultApiBaseUrl,
    };
  }

  Future<void> updateSettings({
    String? printerIp,
    int? printerPort,
    String? paperSize,
    int? printerRetryCount,
    int? printerTimeoutMs,
    int? receiptCopies,
    bool? autoPrintReceipt,
    bool? autoPrintKitchen,
    String? baseUrl,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final current = state.value ?? {};

    if (printerIp != null) await prefs.setString('printerIp', printerIp);
    if (printerPort != null) await prefs.setInt('printerPort', printerPort);
    if (paperSize != null) await prefs.setString('paperSize', paperSize);
    if (printerRetryCount != null) {
      await prefs.setInt('printerRetryCount', printerRetryCount);
    }
    if (printerTimeoutMs != null) {
      await prefs.setInt('printerTimeoutMs', printerTimeoutMs);
    }
    if (receiptCopies != null) {
      await prefs.setInt('receiptCopies', receiptCopies);
    }
    if (autoPrintReceipt != null) {
      await prefs.setBool('autoPrintReceipt', autoPrintReceipt);
    }
    if (autoPrintKitchen != null) {
      await prefs.setBool('autoPrintKitchen', autoPrintKitchen);
    }
    if (baseUrl != null) await prefs.setString('baseUrl', baseUrl);

    state = AsyncValue.data({
      'printerIp': printerIp ?? current['printerIp'],
      'printerPort': printerPort ?? current['printerPort'],
      'paperSize': paperSize ?? current['paperSize'],
      'printerRetryCount': printerRetryCount ?? current['printerRetryCount'],
      'printerTimeoutMs': printerTimeoutMs ?? current['printerTimeoutMs'],
      'receiptCopies': receiptCopies ?? current['receiptCopies'],
      'autoPrintReceipt': autoPrintReceipt ?? current['autoPrintReceipt'],
      'autoPrintKitchen': autoPrintKitchen ?? current['autoPrintKitchen'],
      'baseUrl': baseUrl ?? current['baseUrl'],
    });
  }

  Future<void> updatePrinterSettings(
    String ip,
    int port,
    String paperSize, {
    int? printerRetryCount,
    int? printerTimeoutMs,
    int? receiptCopies,
    bool? autoPrintReceipt,
    bool? autoPrintKitchen,
  }) async {
    await updateSettings(
      printerIp: ip,
      printerPort: port,
      paperSize: paperSize,
      printerRetryCount: printerRetryCount,
      printerTimeoutMs: printerTimeoutMs,
      receiptCopies: receiptCopies,
      autoPrintReceipt: autoPrintReceipt,
      autoPrintKitchen: autoPrintKitchen,
    );
  }
}

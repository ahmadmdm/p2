import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/config/api_config.dart';

part 'settings_controller.g.dart';

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
      'baseUrl': prefs.getString('baseUrl') ?? defaultApiBaseUrl(),
      'currencyCode': prefs.getString('currencyCode') ?? 'USD',
      'currencySymbol': prefs.getString('currencySymbol') ?? '\$',
      'currencyDecimals': prefs.getInt('currencyDecimals') ?? 2,
      'defaultDeliveryProvider':
          prefs.getString('defaultDeliveryProvider') ?? 'internal',
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
    String? currencyCode,
    String? currencySymbol,
    int? currencyDecimals,
    String? defaultDeliveryProvider,
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
    if (baseUrl != null) {
      await prefs.setString('baseUrl', baseUrl);
    }
    if (currencyCode != null) {
      await prefs.setString('currencyCode', currencyCode);
    }
    if (currencySymbol != null) {
      await prefs.setString('currencySymbol', currencySymbol);
    }
    if (currencyDecimals != null) {
      await prefs.setInt('currencyDecimals', currencyDecimals);
    }
    if (defaultDeliveryProvider != null) {
      await prefs.setString('defaultDeliveryProvider', defaultDeliveryProvider);
    }

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
      'currencyCode': currencyCode ?? current['currencyCode'],
      'currencySymbol': currencySymbol ?? current['currencySymbol'],
      'currencyDecimals': currencyDecimals ?? current['currencyDecimals'],
      'defaultDeliveryProvider':
          defaultDeliveryProvider ?? current['defaultDeliveryProvider'],
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

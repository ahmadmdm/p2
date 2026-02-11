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
      'printerIp': prefs.getString('printerIp') ?? '192.168.1.200',
      'printerPort': prefs.getInt('printerPort') ?? 9100,
      'paperSize': prefs.getString('paperSize') ?? '80mm', // 80mm or 58mm
      'baseUrl': prefs.getString('baseUrl') ?? _defaultApiBaseUrl,
    };
  }

  Future<void> updateSettings({
    String? printerIp,
    int? printerPort,
    String? paperSize,
    String? baseUrl,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final current = state.value ?? {};

    if (printerIp != null) await prefs.setString('printerIp', printerIp);
    if (printerPort != null) await prefs.setInt('printerPort', printerPort);
    if (paperSize != null) await prefs.setString('paperSize', paperSize);
    if (baseUrl != null) await prefs.setString('baseUrl', baseUrl);

    state = AsyncValue.data({
      'printerIp': printerIp ?? current['printerIp'],
      'printerPort': printerPort ?? current['printerPort'],
      'paperSize': paperSize ?? current['paperSize'],
      'baseUrl': baseUrl ?? current['baseUrl'],
    });
  }

  Future<void> updatePrinterSettings(
      String ip, int port, String paperSize) async {
    await updateSettings(
        printerIp: ip, printerPort: port, paperSize: paperSize);
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_mobile/l10n/app_localizations.dart';
import '../../../core/services/printing_service.dart';
import 'settings_controller.dart';
import '../../../core/services/sync_service.dart';
import '../../../core/providers/locale_provider.dart';
import '../users/users_screen.dart';
import '../auth/auth_controller.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _ipController = TextEditingController();
  final _portController = TextEditingController();
  final _retryController = TextEditingController();
  final _timeoutController = TextEditingController();
  final _copiesController = TextEditingController();
  final _baseUrlController = TextEditingController();
  String _paperSize = '80mm';
  bool _autoPrintReceipt = true;
  bool _autoPrintKitchen = true;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    final settings = ref.read(settingsControllerProvider).value;
    if (settings != null) {
      _ipController.text = settings['printerIp'];
      _portController.text = settings['printerPort'].toString();
      _paperSize = settings['paperSize'];
      _baseUrlController.text = settings['baseUrl'] ?? '';
    }
  }

  @override
  void dispose() {
    _ipController.dispose();
    _portController.dispose();
    _retryController.dispose();
    _timeoutController.dispose();
    _copiesController.dispose();
    _baseUrlController.dispose();
    super.dispose();
  }

  void _hydrateSettings(Map<String, dynamic> settings) {
    if (_initialized) return;

    _ipController.text = (settings['printerIp'] ?? '').toString();
    _portController.text = (settings['printerPort'] ?? 9100).toString();
    _paperSize = (settings['paperSize'] ?? '80mm').toString();
    _retryController.text = (settings['printerRetryCount'] ?? 1).toString();
    _timeoutController.text = (settings['printerTimeoutMs'] ?? 5000).toString();
    _copiesController.text = (settings['receiptCopies'] ?? 1).toString();
    _autoPrintReceipt = settings['autoPrintReceipt'] as bool? ?? true;
    _autoPrintKitchen = settings['autoPrintKitchen'] as bool? ?? true;
    _baseUrlController.text = (settings['baseUrl'] ?? '').toString();
    _initialized = true;
  }

  bool _isValidIpv4OrHost(String input) {
    final value = input.trim();
    if (value.isEmpty) return false;

    final ipv4 = RegExp(
      r'^((25[0-5]|2[0-4][0-9]|[01]?[0-9]?[0-9])\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9]?[0-9])$',
    );
    final host = RegExp(r'^[a-zA-Z0-9][a-zA-Z0-9.-]*[a-zA-Z0-9]$');
    return ipv4.hasMatch(value) || host.hasMatch(value);
  }

  bool _isValidBaseUrl(String input) {
    final value = input.trim();
    if (value.isEmpty) return false;
    final uri = Uri.tryParse(value);
    return uri != null &&
        (uri.scheme == 'http' || uri.scheme == 'https') &&
        uri.host.isNotEmpty;
  }

  Future<void> _saveSettings() async {
    if (!_formKey.currentState!.validate()) return;

    final ip = _ipController.text.trim();
    final port = int.tryParse(_portController.text) ?? 0;
    final retryCount = int.tryParse(_retryController.text) ?? 1;
    final timeoutMs = int.tryParse(_timeoutController.text) ?? 5000;
    final copies = int.tryParse(_copiesController.text) ?? 1;
    final baseUrl = _baseUrlController.text.trim();

    if (port <= 0 || port > 65535) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Printer port must be between 1 and 65535.')),
      );
      return;
    }
    if (retryCount < 1 || retryCount > 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Retry count must be between 1 and 5.')),
      );
      return;
    }
    if (timeoutMs < 1000 || timeoutMs > 30000) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Timeout must be between 1000 and 30000 ms.')),
      );
      return;
    }
    if (copies < 1 || copies > 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Receipt copies must be between 1 and 3.')),
      );
      return;
    }

    if ((_autoPrintReceipt || _autoPrintKitchen) && !_isValidIpv4OrHost(ip)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid printer IP/host.')),
      );
      return;
    }

    if (!_isValidBaseUrl(baseUrl)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid API base URL.')),
      );
      return;
    }

    await ref.read(settingsControllerProvider.notifier).updateSettings(
          printerIp: ip,
          printerPort: port,
          paperSize: _paperSize,
          printerRetryCount: retryCount,
          printerTimeoutMs: timeoutMs,
          receiptCopies: copies,
          autoPrintReceipt: _autoPrintReceipt,
          autoPrintKitchen: _autoPrintKitchen,
          baseUrl: baseUrl,
        );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)!.success)),
    );
  }

  Future<void> _testPrinterConnection() async {
    final ip = _ipController.text.trim();
    final port = int.tryParse(_portController.text) ?? 0;
    final timeoutMs = int.tryParse(_timeoutController.text) ?? 5000;

    if (!_isValidIpv4OrHost(ip) || port <= 0 || port > 65535) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid printer IP/port.')),
      );
      return;
    }

    final isReachable = await ref
        .read(printingServiceProvider)
        .testPrinter(ip, port, timeoutMs: timeoutMs);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isReachable
              ? 'Printer connection succeeded.'
              : 'Printer is unreachable. Check IP/port/network.',
        ),
      ),
    );
  }

  Future<void> _printTestReceipt() async {
    final ip = _ipController.text.trim();
    final port = int.tryParse(_portController.text) ?? 0;
    final timeoutMs = int.tryParse(_timeoutController.text) ?? 5000;
    final retryCount = int.tryParse(_retryController.text) ?? 1;

    if (!_isValidIpv4OrHost(ip) || port <= 0 || port > 65535) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid printer IP/port.')),
      );
      return;
    }

    try {
      await ref.read(printingServiceProvider).printTestReceipt(
            ip: ip,
            port: port,
            paperSize: _paperSize,
            timeoutMs: timeoutMs,
            retryCount: retryCount,
          );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Test receipt sent to printer.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Print test failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(settingsControllerProvider);

    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.settings)),
      body: settingsAsync.when(
        data: (settings) {
          _hydrateSettings(settings);

          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(AppLocalizations.of(context)!.general,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                Consumer(
                  builder: (context, ref, child) {
                    final locale = ref.watch(localeControllerProvider).value;
                    final isArabic = locale?.languageCode == 'ar';
                    return ListTile(
                      title: Text(AppLocalizations.of(context)!.language),
                      subtitle: Text(isArabic
                          ? AppLocalizations.of(context)!.arabic
                          : AppLocalizations.of(context)!.english),
                      trailing: Switch(
                        value: isArabic,
                        onChanged: (val) {
                          ref
                              .read(localeControllerProvider.notifier)
                              .toggleLocale();
                        },
                      ),
                    );
                  },
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _baseUrlController,
                  decoration: const InputDecoration(
                    labelText: 'API Base URL',
                    hintText: 'http://localhost:3000',
                  ),
                ),
                const Divider(height: 40),
                Text(AppLocalizations.of(context)!.printerSettings,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('Auto-print receipt after checkout'),
                  value: _autoPrintReceipt,
                  onChanged: (val) {
                    setState(() => _autoPrintReceipt = val);
                  },
                ),
                SwitchListTile(
                  title: const Text('Auto-print kitchen tickets'),
                  value: _autoPrintKitchen,
                  onChanged: (val) {
                    setState(() => _autoPrintKitchen = val);
                  },
                ),
                TextFormField(
                  controller: _ipController,
                  decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.printerIp),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _portController,
                  decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.printerPort),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _paperSize,
                  decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.paperSize),
                  items: const [
                    DropdownMenuItem(
                        value: '80mm', child: Text('80mm (Standard)')),
                    DropdownMenuItem(
                        value: '58mm', child: Text('58mm (Small)')),
                  ],
                  onChanged: (val) {
                    if (val != null) setState(() => _paperSize = val);
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _copiesController,
                        decoration: const InputDecoration(
                          labelText: 'Receipt Copies',
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _retryController,
                        decoration: const InputDecoration(
                          labelText: 'Retry Count',
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _timeoutController,
                  decoration: const InputDecoration(
                    labelText: 'Printer Timeout (ms)',
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    OutlinedButton.icon(
                      icon: const Icon(Icons.wifi_tethering),
                      label: const Text('Test Connection'),
                      onPressed: _testPrinterConnection,
                    ),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.receipt_long),
                      label: const Text('Print Test Receipt'),
                      onPressed: _printTestReceipt,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _saveSettings,
                  child: Text(AppLocalizations.of(context)!.saveSettings),
                ),
                const Divider(height: 40),
                Text(AppLocalizations.of(context)!.dataSync,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  icon: const Icon(Icons.sync),
                  label: Text(AppLocalizations.of(context)!.syncNow),
                  onPressed: () async {
                    await ref.read(syncServiceProvider).syncAll();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content:
                              Text(AppLocalizations.of(context)!.success)));
                    }
                  },
                ),
                const Divider(height: 40),
                if (ref.watch(authControllerProvider).value?.role ==
                    'admin') ...[
                  Text(AppLocalizations.of(context)!.administration,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  ListTile(
                    leading: const Icon(Icons.people),
                    title: Text(AppLocalizations.of(context)!.staffManagement),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const UsersScreen()),
                      );
                    },
                  ),
                ],
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) =>
            Center(child: Text('${AppLocalizations.of(context)!.error}: $e')),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_mobile/l10n/app_localizations.dart';
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
  final _ipController = TextEditingController();
  final _portController = TextEditingController();
  final _baseUrlController = TextEditingController();
  String _paperSize = '80mm';

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
    _baseUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(settingsControllerProvider);

    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.settings)),
      body: settingsAsync.when(
        data: (settings) {
          if (_baseUrlController.text.isEmpty) {
            _baseUrlController.text = settings['baseUrl'] ?? '';
          }
          return ListView(
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
              TextField(
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
              TextField(
                controller: _ipController,
                decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.printerIp),
              ),
              const SizedBox(height: 16),
              TextField(
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
                  DropdownMenuItem(value: '58mm', child: Text('58mm (Small)')),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _paperSize = val);
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  final port = int.tryParse(_portController.text) ?? 9100;
                  ref.read(settingsControllerProvider.notifier).updateSettings(
                        printerIp: _ipController.text,
                        printerPort: port,
                        paperSize: _paperSize,
                        baseUrl: _baseUrlController.text.trim(),
                      );
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(AppLocalizations.of(context)!.success)));
                },
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
                        content: Text(AppLocalizations.of(context)!.success)));
                  }
                },
              ),
              const Divider(height: 40),
              if (ref.watch(authControllerProvider).value?.role == 'admin') ...[
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
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) =>
            Center(child: Text('${AppLocalizations.of(context)!.error}: $e')),
      ),
    );
  }
}

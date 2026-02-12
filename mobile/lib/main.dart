import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:pos_mobile/l10n/app_localizations.dart';
import 'presentation/features/auth/login_screen.dart';
import 'core/services/sync_service.dart';
import 'core/services/kitchen_socket_service.dart';
import 'core/providers/locale_provider.dart';
import 'theme/pos_theme.dart';

void main() {
  runApp(
    const ProviderScope(
      child: POSApp(),
    ),
  );
}

class POSApp extends ConsumerWidget {
  const POSApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Initialize services
    ref.watch(syncServiceProvider);
    ref.watch(kitchenSocketServiceProvider);

    final localeAsync = ref.watch(localeControllerProvider);

    return MaterialApp(
      title: 'POS System',
      theme: POSTheme.light(),
      locale: localeAsync.value ?? const Locale('en'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const LoginScreen(),
    );
  }
}


import 'dart:ui';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'locale_provider.g.dart';

@Riverpod(keepAlive: true)
class LocaleController extends _$LocaleController {
  @override
  FutureOr<Locale> build() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString('languageCode');
    if (languageCode != null) {
      return Locale(languageCode);
    }
    return const Locale('en'); // Default
  }

  Future<void> setLocale(Locale locale) async {
    state = AsyncValue.data(locale);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('languageCode', locale.languageCode);
  }

  Future<void> toggleLocale() async {
    final current = state.value ?? const Locale('en');
    if (current.languageCode == 'en') {
      await setLocale(const Locale('ar'));
    } else {
      await setLocale(const Locale('en'));
    }
  }
}

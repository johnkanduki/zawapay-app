import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../countries/country.dart';

/// Choices made on the first screen: the user's country and the app language.
///
/// Kept in memory for now. Saving them on the phone (so the first screen is
/// shown only once, even after the app is closed) needs a storage package.
class AppSettings extends ChangeNotifier {
  Country? _country;
  Locale? _locale;
  bool _setupDone = false;
  ThemeMode _themeMode = ThemeMode.system;

  Country? get country => _country;

  /// Null means "follow the phone language".
  Locale? get locale => _locale;

  /// True once the user has confirmed country and language.
  bool get setupDone => _setupDone;

  void setCountry(Country country) {
    _country = country;
    notifyListeners();
  }

  void setLocale(Locale locale) {
    _locale = locale;
    notifyListeners();
    _storage
        .write(key: _localeKey, value: locale.languageCode)
        .catchError((_) {});
  }

  static const _localeKey = 'zawapay.language';

  /// Light, dark, or (by default, for every new account) the phone's own
  /// setting.
  ThemeMode get themeMode => _themeMode;

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
    // Kept on the phone: the app opens in the same mode next time.
    _storage.write(key: _themeKey, value: mode.name).catchError((_) {});
  }

  static const _themeKey = 'zawapay.theme_mode';
  static const _storage = FlutterSecureStorage();

  /// At start-up: the Appearance chosen last time (Automatic by default).
  Future<void> load() async {
    try {
      final saved = await _storage.read(key: _themeKey);
      _themeMode = ThemeMode.values.firstWhere(
        (m) => m.name == saved,
        orElse: () => ThemeMode.system,
      );
    } catch (_) {
      _themeMode = ThemeMode.system;
    }
    try {
      final lang = await _storage.read(key: _localeKey);
      if (lang == 'fr' || lang == 'en') _locale = Locale(lang!);
    } catch (_) {
      // Keeps the phone's language.
    }
  }

  void completeSetup() {
    _setupDone = true;
    notifyListeners();
  }
}

/// Gives every screen access to [AppSettings].
class AppSettingsScope extends InheritedNotifier<AppSettings> {
  const AppSettingsScope({
    super.key,
    required AppSettings settings,
    required super.child,
  }) : super(notifier: settings);

  /// Same as [of], but null when there is no scope (previews, tests).
  static AppSettings? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppSettingsScope>()?.notifier;

  static AppSettings of(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<AppSettingsScope>();
    assert(scope != null, 'AppSettingsScope is missing above this widget.');
    return scope!.notifier!;
  }
}

import 'package:flutter/widgets.dart';

import '../countries/country.dart';

/// Choices made on the first screen: the user's country and the app language.
///
/// Kept in memory for now. Saving them on the phone (so the first screen is
/// shown only once, even after the app is closed) needs a storage package.
class AppSettings extends ChangeNotifier {
  Country? _country;
  Locale? _locale;
  bool _setupDone = false;

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

  static AppSettings of(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<AppSettingsScope>();
    assert(scope != null, 'AppSettingsScope is missing above this widget.');
    return scope!.notifier!;
  }
}

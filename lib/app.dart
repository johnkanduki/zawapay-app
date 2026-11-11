import 'package:flutter/material.dart';

import 'core/account/zawapay_account.dart';
import 'core/settings/app_settings.dart';
import 'core/widgets/keyboard_dismisser.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/open_home.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/welcome/welcome_screen.dart';
import 'l10n/app_localizations.dart';

class ZawapayApp extends StatefulWidget {
  const ZawapayApp({super.key, this.signedIn, this.settings});

  /// Loaded at start-up (Appearance kept from last time).
  final AppSettings? settings;

  /// The member saved at the last sign-in, if any.
  final SignedIn? signedIn;

  @override
  State<ZawapayApp> createState() => _ZawapayAppState();
}

class _ZawapayAppState extends State<ZawapayApp> {
  late final _settings = widget.settings ?? AppSettings();

  @override
  void dispose() {
    _settings.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppSettingsScope(
      settings: _settings,
      child: ListenableBuilder(
        listenable: _settings,
        builder: (context, _) => MaterialApp(
          onGenerateTitle: (context) => AppLocalizations.of(context).appName,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: _settings.themeMode,
          locale: _settings.locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          // Tapping an empty area anywhere closes the keyboard, on every
          // page, sheet and dialog (they all live under this builder).
          builder: (context, child) => KeyboardDismisser(child: child!),
          // Signed in: the home page. Otherwise country and language are
          // asked only the first time.
          home: widget.signedIn != null
              ? homeFor(widget.signedIn!)
              : _settings.setupDone
              ? const OnboardingScreen()
              : const WelcomeScreen(),
        ),
      ),
    );
  }
}

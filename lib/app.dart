import 'package:flutter/material.dart';

import 'core/settings/app_settings.dart';
import 'core/theme/app_theme.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/welcome/welcome_screen.dart';
import 'l10n/app_localizations.dart';

class ZawapayApp extends StatefulWidget {
  const ZawapayApp({super.key});

  @override
  State<ZawapayApp> createState() => _ZawapayAppState();
}

class _ZawapayAppState extends State<ZawapayApp> {
  final _settings = AppSettings();

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
          locale: _settings.locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          // Tapping an empty area anywhere closes the keyboard.
          builder: (context, child) => GestureDetector(
            onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
            behavior: HitTestBehavior.translucent,
            child: child,
          ),
          // Country and language are asked only the first time.
          home: _settings.setupDone
              ? const OnboardingScreen()
              : const WelcomeScreen(),
        ),
      ),
    );
  }
}

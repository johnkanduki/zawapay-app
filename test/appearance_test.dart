import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zawapay_app/core/settings/app_settings.dart';
import 'package:zawapay_app/features/settings/appearance_sheet.dart';
import 'package:zawapay_app/l10n/app_localizations.dart';

void main() {
  testWidgets('Automatic by default; Light and Dark can be chosen', (
    tester,
  ) async {
    final settings = AppSettings();
    expect(settings.themeMode, ThemeMode.system);

    await tester.pumpWidget(
      AppSettingsScope(
        settings: settings,
        child: ListenableBuilder(
          listenable: settings,
          builder: (context, _) => MaterialApp(
            locale: const Locale('fr'),
            themeMode: settings.themeMode,
            theme: ThemeData.light(),
            darkTheme: ThemeData.dark(),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Builder(
              builder: (context) => Scaffold(
                body: TextButton(
                  onPressed: () => showAppearanceSheet(context),
                  child: const Text('open'),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.text('Automatique'), findsOneWidget);
    expect(find.text('Suit le réglage de votre téléphone'), findsOneWidget);

    await tester.tap(find.text('Sombre'));
    await tester.pumpAndSettle();
    expect(settings.themeMode, ThemeMode.dark);

    await tester.tap(find.text('Clair'));
    await tester.pumpAndSettle();
    expect(settings.themeMode, ThemeMode.light);
  });
}

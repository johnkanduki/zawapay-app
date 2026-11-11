import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zawapay_app/core/settings/app_settings.dart';
import 'package:zawapay_app/features/settings/settings_sheet.dart';
import 'package:zawapay_app/l10n/app_localizations.dart';

void main() {
  testWidgets('Language: Français first, English below; About page', (
    tester,
  ) async {
    FlutterSecureStorage.setMockInitialValues({});
    tester.view.physicalSize = const Size(1206, 2622);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    final settings = AppSettings();

    await tester.pumpWidget(
      AppSettingsScope(
        settings: settings,
        child: ListenableBuilder(
          listenable: settings,
          builder: (context, _) => MaterialApp(
            locale: settings.locale ?? const Locale('fr'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Builder(
              builder: (context) => Scaffold(
                body: Column(
                  children: [
                    TextButton(
                      onPressed: () => showLanguageSheet(context),
                      child: const Text('Langue'),
                    ),
                    TextButton(
                      onPressed: () => showAboutSheet(context),
                      child: const Text('Infos'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Langue'));
    await tester.pumpAndSettle();
    final fr = tester.getTopLeft(find.text('Français')).dy;
    final en = tester.getTopLeft(find.text('English')).dy;
    expect(fr < en, isTrue);
    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();
    expect(settings.locale, const Locale('en'));
    expect(find.text('Choose your language'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Infos'));
    await tester.pumpAndSettle();
    expect(find.text('About'), findsOneWidget);
    expect(find.text('Privacy policy'), findsOneWidget);
    expect(find.text('Terms of use'), findsOneWidget);
    expect(find.text('Delete account'), findsOneWidget);
    expect(find.text(appVersion), findsOneWidget);
  });
}

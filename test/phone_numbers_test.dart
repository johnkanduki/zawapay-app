import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zawapay_app/core/settings/app_settings.dart';
import 'package:zawapay_app/core/widgets/app_checkbox.dart';
import 'package:zawapay_app/features/settings/phone_numbers_screen.dart';
import 'package:zawapay_app/l10n/app_localizations.dart';

void main() {
  Widget app(Widget page) => AppSettingsScope(
    settings: AppSettings(),
    child: MaterialApp(
      locale: const Locale('fr'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      // Opened from a parent page, so "back" can be checked.
      home: Builder(
        builder: (context) => Scaffold(
          body: TextButton(
            onPressed: () =>
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (_) => page)),
            child: const Text('Réglages'),
          ),
        ),
      ),
    ),
  );

  bool ticked(WidgetTester tester) =>
      tester.widget<AppCheckbox>(find.byType(AppCheckbox)).value;

  testWidgets('Same page as sign-up, filled; box ticked when same number', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1206, 2622);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      app(
        const PhoneNumbersScreen(
          paymentPhone: '+243812345678',
          receivePhone: '+243812345678',
        ),
      ),
    );
    await tester.tap(find.text('Réglages'));
    await tester.pumpAndSettle();

    expect(find.text('Votre numéro'), findsOneWidget);
    expect(find.text('812345678'), findsOneWidget);
    expect(ticked(tester), isTrue);
    expect(find.text('Enregistrer'), findsOneWidget);

    // Unticked: a second field for the withdrawal number.
    await tester.tap(find.byType(AppCheckbox));
    await tester.pumpAndSettle();
    expect(find.byType(TextField), findsNWidgets(2));

    // Back returns to Settings, never a black screen.
    // (Swipe back on iPhone, back button on Android.)
    final NavigatorState nav = tester.state(find.byType(Navigator));
    await nav.maybePop();
    await tester.pumpAndSettle();
    expect(find.text('Réglages'), findsOneWidget);
  });

  testWidgets('Different withdrawal number: box unticked, both filled', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1206, 2622);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      app(
        const PhoneNumbersScreen(
          paymentPhone: '+243812345678',
          receivePhone: '+243899999999',
        ),
      ),
    );
    await tester.tap(find.text('Réglages'));
    await tester.pumpAndSettle();
    expect(ticked(tester), isFalse);
    expect(find.text('812345678'), findsOneWidget);
    expect(find.text('899999999'), findsOneWidget);
  });
}

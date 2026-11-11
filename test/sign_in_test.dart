import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zawapay_app/features/auth/screens/sign_in_screen.dart';
import 'package:zawapay_app/l10n/app_localizations.dart';

void main() {
  testWidgets('Sign in with an e-mail or an @username', (tester) async {
    tester.view.physicalSize = const Size(1206, 2622);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('fr'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const SignInScreen(),
      ),
    );

    expect(find.text('E-mail ou identifiant'), findsOneWidget);
    expect(find.text('E-mail ou @identifiant'), findsOneWidget);
    bool enabled() =>
        tester
            .widget<FilledButton>(
              find.widgetWithText(FilledButton, 'Se connecter'),
            )
            .onPressed !=
        null;
    expect(enabled(), isFalse);

    // An @username works as well as an e-mail.
    await tester.enterText(find.byType(TextField).first, '@johnkanduki');
    await tester.enterText(find.byType(TextField).last, 'Zawapay2026!');
    await tester.pump();
    expect(enabled(), isTrue);
  });
}

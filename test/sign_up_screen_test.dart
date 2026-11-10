import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zawapay_app/core/settings/app_settings.dart';
import 'package:zawapay_app/core/widgets/app_checkbox.dart';
import 'package:zawapay_app/features/auth/screens/sign_up_screen.dart';
import 'package:zawapay_app/l10n/app_localizations.dart';

void main() {
  testWidgets('Continue stays grey until every required point is filled', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1170, 4000);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      AppSettingsScope(
        settings: AppSettings(),
        child: MaterialApp(
          locale: const Locale('fr'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const SignUpScreen(),
        ),
      ),
    );

    final continueButton = find.widgetWithText(FilledButton, 'Continuer');
    bool enabled() =>
        tester.widget<FilledButton>(continueButton).onPressed != null;
    Finder field(String hint) => find.widgetWithText(TextField, hint);

    expect(enabled(), isFalse);

    await tester.enterText(field('Prénom'), 'Jean');
    await tester.enterText(field('Nom'), 'Kabila');
    await tester.pump();
    expect(enabled(), isFalse);

    // An email without a domain is not accepted.
    await tester.enterText(field('Entrez votre email'), 'jean@mail');
    await tester.pump();
    expect(enabled(), isFalse);
    await tester.enterText(field('Entrez votre email'), 'jean@mail.com');
    await tester.pump();
    expect(enabled(), isFalse);

    // Sponsor typed but not confirmed: still grey.
    await tester.enterText(field('identifiant parrain ou marraine'), 'zawapay');
    await tester.pumpAndSettle();
    expect(enabled(), isFalse);
    await tester.tap(find.text('Confirmer'));
    await tester.pumpAndSettle();
    expect(enabled(), isFalse);

    // Password missing a symbol: 4 rules out of 5 is not enough.
    await tester.enterText(field('8 caractères minimum'), 'Zawapay2026');
    await tester.pumpAndSettle();
    expect(find.text('Des symboles (@, #, ! …)'), findsOneWidget);
    expect(enabled(), isFalse);
    await tester.enterText(field('8 caractères minimum'), 'Zawapay2026!');
    await tester.pumpAndSettle();
    expect(enabled(), isFalse);

    // Terms ticked: everything is filled, Continue becomes red.
    await tester.tap(
      find
          .descendant(
            of: find.byType(AppCheckbox),
            matching: find.byType(GestureDetector),
          )
          .first,
    );
    await tester.pump();
    expect(enabled(), isTrue);

    // Emptying one field greys it again.
    await tester.enterText(field('Prénom'), ' ');
    await tester.pump();
    expect(enabled(), isFalse);
  });
}

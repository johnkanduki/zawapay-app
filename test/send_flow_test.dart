import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zawapay_app/core/countries/country.dart';
import 'package:zawapay_app/features/send/recipient.dart';
import 'package:zawapay_app/features/send/send_amount_screen.dart';
import 'package:zawapay_app/features/send/send_recipient_screen.dart';
import 'package:zawapay_app/l10n/app_localizations.dart';

void main() {
  final congo = supportedCountries.first;

  Widget app(Widget home) => MaterialApp(
    locale: const Locale('fr'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: home,
  );

  test('The fee is added on top of what the recipient receives', () {
    expect(feeFor(100, 0.06), closeTo(6, 0.001));
  });

  testWidgets('Send by username or by number, amount, then the receipt', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1206, 2622);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      app(
        SendRecipientScreen(
          senderCountry: congo,
          recents: demoRecipients.take(3).toList(),
        ),
      ),
    );
    expect(find.text('Envoyer de l’argent'), findsOneWidget);
    expect(find.text('Récents (3)'), findsOneWidget);

    // By username: no suggestion while typing, the account once exact.
    await tester.enterText(find.byType(TextField), 'ami');
    await tester.pumpAndSettle();
    expect(find.text('Amina Diallo'), findsNothing);
    await tester.enterText(find.byType(TextField), 'amina');
    await tester.pumpAndSettle();
    expect(find.text('Amina Diallo'), findsOneWidget);

    // By number: the "@" and the name show for a known number.
    await tester.tap(find.text('Numéro'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '0975 135 801');
    await tester.pumpAndSettle();
    expect(find.text('Zawapay App'), findsOneWidget);
    await tester.enterText(find.byType(TextField), '999999999');
    await tester.pumpAndSettle();
    expect(find.text('Aucun compte avec ce numéro.'), findsOneWidget);

    // Pick the first recent: amount page.
    await tester.tap(find.text('@zawapay').last);
    await tester.pumpAndSettle();
    expect(find.text('Il reçoit'), findsOneWidget);
    FilledButton pay() =>
        tester.widget<FilledButton>(find.widgetWithText(FilledButton, 'Payer'));
    expect(pay().onPressed, isNull);

    // Type what the person receives: the fee goes on top, the total is in
    // the "Pay" button.
    await tester.enterText(find.byType(TextField).first, '100');
    await tester.pump();
    expect(find.text('6,00 USD'), findsOneWidget);
    expect(find.text('Payer 106,00 USD'), findsOneWidget);

    // Changing the currency starts the amount again from 0.
    await tester.tap(find.text('CDF'));
    await tester.pump();
    expect(find.text('Payer'), findsOneWidget);
    expect(pay().onPressed, isNull);
    await tester.enterText(find.byType(TextField).first, '100');
    await tester.pump();
    expect(find.text('Payer 106,00 CDF'), findsOneWidget);

    await tester.tap(find.byType(FilledButton));
    // The payment step keeps spinning: wait a fixed time instead of settling.
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Envoi en cours'), findsOneWidget);
    expect(find.text('100,00 CDF'), findsWidgets);
    expect(find.text('Paiement Mobile Money'), findsOneWidget);
    expect(find.text('Retour à l’accueil'), findsOneWidget);
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zawapay_app/core/account/destinations.dart';
import 'package:zawapay_app/core/countries/country.dart';
import 'package:zawapay_app/features/send/recipient.dart';
import 'package:zawapay_app/features/send/send_amount_screen.dart';
import 'package:zawapay_app/features/send/send_recipient_screen.dart';
import 'package:zawapay_app/features/send/send_success_screen.dart';
import 'package:zawapay_app/l10n/app_localizations.dart';

import 'test_data.dart';

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
          recents: testAccounts.take(3).toList(),
        ),
      ),
    );
    expect(find.text('Envoyer de l’argent'), findsOneWidget);
    expect(find.text('Récents (3)'), findsOneWidget);

    // By username: no suggestion while typing, the account once exact.
    await tester.enterText(find.byType(TextField), 'ami');
    await tester.pumpAndSettle();
    expect(find.text('Amina Diallo'), findsNothing);
    // Amina is in Senegal: not opened in the admin dashboard yet.
    await tester.enterText(find.byType(TextField), 'amina');
    await tester.pumpAndSettle();
    expect(find.text('Amina Diallo'), findsNothing);
    expect(
      find.text('L’envoi vers ce pays n’est pas encore disponible.'),
      findsOneWidget,
    );
    // Once Senegal is open, her card shows.
    destinations.value = const [
      Destination(
        country: 'SN',
        currency: 'XOF',
        clientRate: 590,
        feePercent: 3.38,
        minFeeUsd: 0.5,
        min: 100,
        max: 2000000,
      ),
    ];
    addTearDown(() => destinations.value = const []);
    await tester.pumpAndSettle();
    expect(find.text('Amina Diallo'), findsOneWidget);

    // By number: NO account is looked up, the money goes straight to the
    // typed number (even an unknown one).
    await tester.tap(find.text('Numéro'));
    await tester.pumpAndSettle();
    expect(find.text('Numéro Mobile Money'), findsOneWidget);
    await tester.enterText(find.byType(TextField), '0975 13');
    await tester.pumpAndSettle();
    expect(find.text('Confirmer'), findsNothing);
    await tester.enterText(find.byType(TextField), '0850 000 099');
    await tester.pumpAndSettle();
    expect(find.text('+243 850 000 099'), findsOneWidget);
    expect(
      find.text('L’argent arrive directement sur ce numéro.'),
      findsOneWidget,
    );
    expect(find.text('Zawapay App'), findsNothing);
    await tester.tap(find.text('Confirmer'));
    await tester.pumpAndSettle();
    expect(find.text('Il reçoit'), findsOneWidget);
    expect(find.text('+243 850 000 099'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.arrow_back_rounded));
    await tester.pumpAndSettle();
    expect(find.text('Envoyer de l’argent'), findsOneWidget);

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
    // Just "Frais", without "Payés par vous".
    expect(find.text('Frais'), findsOneWidget);
    expect(find.text('Payés par vous'), findsNothing);
    expect(find.text('Payer 106,00 USD'), findsOneWidget);

    // Changing the currency starts the amount again from 0.
    await tester.tap(find.text('CDF'));
    await tester.pump();
    expect(find.text('Payer'), findsOneWidget);
    expect(pay().onPressed, isNull);
    await tester.enterText(find.byType(TextField).first, '100');
    await tester.pump();
    expect(find.text('Payer 106,00 CDF'), findsOneWidget);

    // "Pay" now asks the real server (no fake receipt any more): without a
    // server here, the page stays and shows the error at the top.
    await tester.tap(find.byType(FilledButton));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Envoi en cours'), findsNothing);
    expect(find.text('Il reçoit'), findsOneWidget);
    await tester.pump(const Duration(seconds: 4));
  });

  testWidgets('The sent page shows the receipt and the three steps', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1206, 2622);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      app(
        SendSuccessScreen(
          recipient: testAccounts.first,
          paid: 107,
          received: 100,
          fee: 7,
          currency: 'USD',
          reference: 'ZP-ABCDEF12',
        ),
      ),
    );
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Envoi en cours'), findsOneWidget);
    expect(find.text('ZP-ABCDEF12'), findsOneWidget);
    expect(find.text('Paiement Mobile Money'), findsOneWidget);
    expect(find.text('Retour à l’accueil'), findsOneWidget);
  });

  testWidgets(
    'Abroad: "Il reçoit 400 000 UGX", the button shows what to pay in dollars',
    (tester) async {
      tester.view.physicalSize = const Size(1206, 2622);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      destinations.value = const [
        Destination(
          country: 'UG',
          currency: 'UGX',
          clientRate: 4003.19,
          feePercent: 3.38,
          minFeeUsd: 0.5,
          min: 500,
          max: 5000000,
        ),
      ];
      addTearDown(() => destinations.value = const []);

      await tester.pumpWidget(
        app(
          SendAmountScreen(
            recipient: Recipient.number('UG', '771234567'),
            senderCountry: congo,
          ),
        ),
      );
      // No USD / CDF choice: the recipient gets UGX, the rate is shown.
      expect(find.text('CDF'), findsNothing);
      expect(find.text('UGX'), findsOneWidget);
      expect(find.text('1 USD = 4 003 UGX'), findsOneWidget);

      await tester.enterText(find.byType(TextField).first, '400000');
      await tester.pump();
      expect(find.text('3,38 \$'), findsOneWidget);
      expect(find.text('Payer 103,31 \$'), findsOneWidget);

      // Outside the limits: the button waits, the limits are shown.
      await tester.enterText(find.byType(TextField).first, '100');
      await tester.pump();
      expect(find.textContaining('Entre 500 et'), findsOneWidget);
      expect(
        tester
            .widget<FilledButton>(find.widgetWithText(FilledButton, 'Payer'))
            .onPressed,
        isNull,
      );
    },
  );
}

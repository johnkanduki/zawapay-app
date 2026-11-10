import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zawapay_app/core/countries/country.dart';
import 'package:zawapay_app/features/scan/my_qr_screen.dart';
import 'package:zawapay_app/features/send/recipient.dart';
import 'package:zawapay_app/features/send/send_amount_screen.dart';
import 'package:zawapay_app/l10n/app_localizations.dart';

void main() {
  final congo = supportedCountries.first;
  const me = Recipient(
    username: 'johnkanduki',
    fullName: 'John Kanduki',
    countryCode: 'CD',
    phone: '',
  );

  Widget app(Widget home) => MaterialApp(
    locale: const Locale('fr'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: home,
  );

  void bigScreen(WidgetTester tester) {
    tester.view.physicalSize = const Size(1206, 2622);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
  }

  testWidgets('Request money: amount shown under the code, then removed', (
    tester,
  ) async {
    bigScreen(tester);
    await tester.pumpWidget(app(const Scaffold(body: MyQrView(me: me))));
    await tester.tap(find.text('Demander de l’argent'));
    await tester.pumpAndSettle();
    expect(find.text('Supprimer le montant'), findsNothing);
    await tester.enterText(find.byType(TextField), '100');
    await tester.pump();
    await tester.tap(find.text('Demander le montant'));
    await tester.pumpAndSettle();
    expect(find.text('100 USD demandé'), findsOneWidget);

    await tester.tap(find.text('Modifier la demande'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Supprimer le montant'));
    await tester.pumpAndSettle();
    expect(find.text('100 USD demandé'), findsNothing);
    expect(find.text('Demander de l’argent'), findsOneWidget);
  });

  testWidgets('A requested amount is locked; no balance → Mobile Money', (
    tester,
  ) async {
    bigScreen(tester);
    await tester.pumpWidget(
      app(
        SendAmountScreen(
          recipient: demoRecipients.first,
          senderCountry: congo,
          initialAmount: 100,
          initialCurrency: 'USD',
          balances: const {'USD': 50},
        ),
      ),
    );
    expect(find.text('Montant demandé'), findsOneWidget);
    expect(find.byIcon(Icons.lock_rounded), findsOneWidget);
    // No currency switch, and the amount cannot be typed over.
    expect(find.text('CDF'), findsNothing);
    final field = tester.widget<TextField>(find.byType(TextField).first);
    expect(field.readOnly, isTrue);
    expect(find.text('Solde insuffisant'), findsOneWidget);
    expect(find.text('Payer 106,00 USD'), findsOneWidget);
  });

  testWidgets('Enough balance: the Zawapay balance can be chosen', (
    tester,
  ) async {
    bigScreen(tester);
    await tester.pumpWidget(
      app(
        SendAmountScreen(
          recipient: demoRecipients.first,
          senderCountry: congo,
          initialAmount: 100,
          initialCurrency: 'USD',
          balances: const {'USD': 500},
        ),
      ),
    );
    expect(find.text('Solde insuffisant'), findsNothing);
    expect(find.text('500,00 USD'), findsOneWidget);
    await tester.tap(find.text('Solde Zawapay'));
    await tester.pump();
    await tester.tap(find.text('Payer 106,00 USD'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Payé avec votre solde Zawapay'), findsOneWidget);
  });
}

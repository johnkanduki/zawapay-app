import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zawapay_app/core/countries/country.dart';
import 'package:zawapay_app/features/withdraw/withdraw_screen.dart';
import 'package:zawapay_app/l10n/app_localizations.dart';

void main() {
  testWidgets('Withdraw: minimum, balance, all, PIN, then in progress', (
    tester,
  ) async {
    FlutterSecureStorage.setMockInitialValues({});
    // The server: 1 USD = 2 299 CDF for the member (week's rate minus 3 %).
    final created = <String>[];
    final before = withdrawalApi;
    withdrawalApi = WithdrawalApi(
      quote: (amount, currency) async => {
        'receive': '${(double.parse(amount) * 2299).floor()}',
        'receiveCurrency': currency,
      },
      create: (amount, currency) async {
        created.add('$amount $currency');
        return {
          'receive': currency == 'CDF'
              ? '${(double.parse(amount) * 2299).floor()}'
              : amount,
          'receiveCurrency': currency,
        };
      },
    );
    addTearDown(() => withdrawalApi = before);
    tester.view.physicalSize = const Size(1206, 2622);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    // Opened from a parent page, so "back" can be checked.
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('fr'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: TextButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => WithdrawScreen(
                      country: supportedCountries.first,
                      phone: '+243812345678',
                      balances: const {'USD': 50, 'CDF': 0},
                    ),
                  ),
                ),
                child: const Text('Accueil'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Accueil'));
    await tester.pumpAndSettle();

    expect(find.text('Retirer de l’argent'), findsOneWidget);
    expect(find.text('+243812345678'), findsOneWidget);
    expect(find.text('Gratuit'), findsOneWidget);
    FilledButton button() =>
        tester.widget<FilledButton>(find.byType(FilledButton));

    final amount = find.byType(TextField);
    await tester.enterText(amount, '0.5');
    await tester.pump();
    expect(find.text('Minimum 1,00 USD'), findsOneWidget);
    expect(button().onPressed, isNull);

    await tester.enterText(amount, '80');
    await tester.pump();
    expect(find.text('Solde insuffisant'), findsOneWidget);
    expect(button().onPressed, isNull);

    await tester.tap(find.text('Tout retirer'));
    await tester.pump();
    expect(find.text('Retirer 50,00 USD'), findsOneWidget);

    // One balance in dollars; the member chooses to RECEIVE in CDF: the
    // server says how many francs arrive (week's rate).
    await tester.tap(find.text('CDF'));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump();
    expect(
      find.textContaining(RegExp(r'^Vous recevez 114\s950 CDF')),
      findsOneWidget,
    );
    // The button shows what arrives, in francs.
    expect(
      find.textContaining(RegExp(r'^Retirer 114\s950 CDF')),
      findsOneWidget,
    );
    // Too much: the francs still show, the button stays off.
    await tester.enterText(amount, '80');
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump();
    expect(
      find.textContaining(RegExp(r'^Vous recevez 183\s920 CDF')),
      findsOneWidget,
    );
    expect(find.text('Solde insuffisant'), findsOneWidget);
    expect(button().onPressed, isNull);
    await tester.tap(find.text('Tout retirer'));
    await tester.pump(const Duration(milliseconds: 400));
    // Back to receiving dollars (the switch, not the amount's "USD").
    await tester.tap(find.text('USD').first);
    await tester.pump(const Duration(milliseconds: 400));

    await tester.enterText(amount, '20');
    await tester.pump(const Duration(milliseconds: 400));
    await tester.tap(find.text('Retirer 20,00 USD'));
    await tester.pumpAndSettle();

    // First withdrawal: the PIN is created, typed twice.
    expect(find.text('Créez votre code PIN'), findsOneWidget);
    await tester.enterText(find.byType(TextField).last, '1234');
    await tester.pumpAndSettle();
    expect(find.text('Confirmez votre code PIN'), findsOneWidget);
    await tester.enterText(find.byType(TextField).last, '1234');
    // The "in progress" step keeps moving: wait, without "settle".
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('Retrait en cours'), findsOneWidget);
    expect(find.text('Envoyé à Mobile Money'), findsOneWidget);
    expect(created, ['20.00 USD']);

    // Back from "in progress" goes home, never to a black screen.
    final NavigatorState nav = tester.state(find.byType(Navigator));
    await nav.maybePop();
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Accueil'), findsOneWidget);

    // Next time: the PIN is only typed, and a wrong one is refused.
    await tester.tap(find.text('Accueil'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '5');
    await tester.pump(const Duration(milliseconds: 400));
    await tester.tap(find.text('Retirer 5,00 USD'));
    await tester.pumpAndSettle();
    expect(find.text('Entrez votre code PIN'), findsOneWidget);
    await tester.enterText(find.byType(TextField).last, '9999');
    await tester.pumpAndSettle();
    expect(find.text('Code PIN incorrect.'), findsOneWidget);
    await tester.enterText(find.byType(TextField).last, '1234');
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Retrait en cours'), findsOneWidget);
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zawapay_app/core/account/app_rules.dart';
import 'package:zawapay_app/core/account/withdraw_pin.dart';
import 'package:zawapay_app/core/countries/country.dart';
import 'package:zawapay_app/features/send/recipient.dart';
import 'package:zawapay_app/features/send/send_amount_screen.dart';
import 'package:zawapay_app/features/send/send_success_screen.dart';
import 'package:zawapay_app/l10n/app_localizations.dart';

import 'fake_pin.dart';

/// "Solde Zawapay": the PIN first, then the server is asked to pay with the
/// commissions (it gives no commission on such a transfer).
void main() {
  testWidgets('Pay with the Zawapay balance: PIN, then sent', (tester) async {
    FlutterSecureStorage.setMockInitialValues({});
    tester.view.physicalSize = const Size(1206, 2622);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    final before = (withdrawPin, createTransferCall);
    addTearDown(() {
      withdrawPin = before.$1;
      createTransferCall = before.$2;
      appRules.value = const AppRules();
    });
    withdrawPin = FakePin('2580');
    appRules.value = const AppRules(serviceFeeRate: 0.06);
    final sent = <Map<String, Object?>>[];
    createTransferCall = ({
      required recipient,
      required currency,
      required amount,
      note,
      balancePin,
    }) async {
      sent.add({'amount': amount, 'currency': currency, 'pin': balancePin});
      return {
        'id': 't1', 'reference': 'ZP-1', 'paid': '10.60', 'received': '10.00',
        'fee': '0.60', 'currency': 'USD', 'status': 'paying_out',
      };
    };
    const grace = Recipient(
      username: 'gracembuyi',
      fullName: 'Grace Mbuyi',
      countryCode: 'CD',
      phone: '812345678',
      certified: true,
    );

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('fr'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: SendAmountScreen(
          recipient: grace,
          senderCountry: supportedCountries.firstWhere((c) => c.isoCode == 'CD'),
          balances: const {'USD': 50},
        ),
      ),
    );
    await tester.enterText(find.byType(TextField).first, '10');
    await tester.pump();
    await tester.tap(find.text('Solde Zawapay'));
    await tester.pump();
    await tester.tap(find.textContaining('Payer'));
    await tester.pumpAndSettle();
    // The PIN sheet, then the server call with the PIN.
    await tester.enterText(find.byType(TextField).last, '2580');
    // The receipt keeps following the transfer: no settling, a few frames.
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    expect(sent, [
      {'amount': '10', 'currency': 'USD', 'pin': '2580'},
    ]);
    expect(find.byType(SendSuccessScreen), findsOneWidget);
    expect(
      tester.widget<SendSuccessScreen>(find.byType(SendSuccessScreen)).fromBalance,
      isTrue,
    );
    // Leave the receipt (it stops following the transfer).
    await tester.pumpWidget(const SizedBox());
  });
}

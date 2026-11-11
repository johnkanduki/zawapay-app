import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zawapay_app/features/scan/zawapay_qr.dart';
import 'package:zawapay_app/features/scan/my_qr_screen.dart';
import 'package:zawapay_app/features/send/recipient.dart';
import 'package:zawapay_app/l10n/app_localizations.dart';
import 'package:zawapay_app/features/scan/pay_qr.dart';

void main() {
  test('Only Zawapay codes of known accounts are accepted', () {
    expect(PayQr.forUsername('zawapay'), 'zawapay://pay/zawapay');
    expect(PayQr.recipientOf('zawapay://pay/zawapay')?.fullName, 'Zawapay App');
    expect(PayQr.recipientOf('ZAWAPAY://pay/@Amina')?.username, 'amina');
    expect(PayQr.recipientOf('zawapay://pay/unknown'), isNull);
    expect(PayQr.recipientOf('https://example.com'), isNull);
    expect(PayQr.recipientOf(null), isNull);
  });

  test('Any valid Zawapay code is read, even for an account not in demo', () {
    final request = PayQr.parse('zawapay://pay/johnkanduki');
    expect(request?.username, 'johnkanduki');
    expect(PayQr.parse('https://wa.me/123'), isNull);
    const someone = Recipient(
      username: 'johnkanduki',
      fullName: '',
      countryCode: 'CD',
      phone: '',
    );
    expect(someone.details, '');
    expect(someone.initials, 'J');
  });

  test('A code can carry the amount asked for', () {
    final text = PayQr.forUsername('zawapay', amount: 10, currency: 'USD');
    expect(text, 'zawapay://pay/zawapay?amount=10&currency=USD');
    final request = PayQr.parse(text)!;
    expect(request.username, 'zawapay');
    expect(request.amount, 10);
    expect(request.currency, 'USD');
    expect(PayQr.recipientOf(text)?.fullName, 'Zawapay App');
  });

  testWidgets('"My QR code" shows a code with the user\'s "@"', (tester) async {
    tester.view.physicalSize = const Size(1206, 2622);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    const me = Recipient(
      username: 'johnkanduki',
      fullName: 'John Kanduki',
      countryCode: 'CD',
      phone: '',
    );
    await tester.pumpWidget(
      const MaterialApp(
        locale: Locale('fr'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: MyQrScreen(me: me),
      ),
    );
    expect(find.text('@johnkanduki'), findsOneWidget);
    expect(find.byType(ZawapayQr), findsOneWidget);
    expect(PayQr.usernameOf(PayQr.forUsername(me.username)), 'johnkanduki');
    expect(find.text('Partager le code QR'), findsOneWidget);
  });
}

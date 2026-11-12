import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zawapay_app/core/account/zawapay_account.dart';
import 'package:zawapay_app/features/settings/devices_screen.dart';
import 'package:zawapay_app/features/settings/notifications_screen.dart';
import 'package:zawapay_app/features/settings/phone_code_sheet.dart';
import 'package:zawapay_app/features/withdraw/pin_sheet.dart';
import 'package:zawapay_app/l10n/app_localizations.dart';

import 'fake_pin.dart';

Widget _app(Widget home) => MaterialApp(
  locale: const Locale('fr'),
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: home,
);

void main() {
  testWidgets('Code PIN: created, changed, forgotten (all by the server)', (
    tester,
  ) async {
    final pins = FakePin();
    bool? result;
    await tester.pumpWidget(
      _app(
        Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () async =>
                  result = await changeWithdrawPin(context, pins: pins),
              child: const Text('PIN'),
            ),
          ),
        ),
      ),
    );
    // No PIN yet: created, typed twice.
    await tester.tap(find.text('PIN'));
    await tester.pumpAndSettle();
    expect(find.text('Créez votre code PIN'), findsOneWidget);
    await tester.enterText(find.byType(TextField).last, '2580');
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).last, '2580');
    await tester.pumpAndSettle();
    expect(result, isTrue);
    expect(pins.pin, '2580');

    // Change: the current one (checked by the server), then the new twice.
    await tester.tap(find.text('PIN'));
    await tester.pumpAndSettle();
    expect(find.text('Votre code PIN actuel'), findsOneWidget);
    await tester.enterText(find.byType(TextField).last, '0000');
    await tester.pumpAndSettle();
    expect(find.text('Code PIN incorrect.'), findsOneWidget);
    await tester.enterText(find.byType(TextField).last, '2580');
    await tester.pumpAndSettle();
    expect(find.text('Nouveau code PIN'), findsOneWidget);
    await tester.enterText(find.byType(TextField).last, '5791');
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).last, '5791');
    await tester.pumpAndSettle();
    expect(pins.pin, '5791');

    // Forgotten: a code by e-mail, then a new PIN.
    await tester.tap(find.text('PIN'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Code PIN oublié ?'));
    await tester.pumpAndSettle();
    expect(find.text('Code reçu par e-mail'), findsOneWidget);
    await tester.enterText(find.byType(TextField).last, '123456');
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).last, '8642');
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).last, '8642');
    await tester.pump();
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
    expect(pins.pin, '8642');
  });

  testWidgets('Connected devices: this phone, and another one to sign out', (
    tester,
  ) async {
    final signedOut = <String>[];
    final beforeLoad = loadDevices;
    final beforeOut = signOutDevice;
    var list = [
      {
        'id': 'a',
        'name': 'iPhone · iOS 27.0.1',
        'since': '2026-11-10T10:00:00Z',
        'current': true,
      },
      {
        'id': 'b',
        'name': 'Android · Android 14',
        'since': '2026-11-01T10:00:00Z',
        'current': false,
      },
    ];
    loadDevices = () async => list;
    signOutDevice = (id) async {
      signedOut.add(id);
      list = list.where((d) => d['id'] != id).toList();
    };
    addTearDown(() {
      loadDevices = beforeLoad;
      signOutDevice = beforeOut;
    });

    await tester.pumpWidget(_app(const DevicesScreen()));
    await tester.pumpAndSettle();
    expect(find.text('Appareils connectés'), findsOneWidget);
    expect(find.text('Cet appareil'), findsOneWidget);
    expect(find.text('Android · Android 14'), findsOneWidget);

    await tester.tap(find.text('Déconnecter'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Déconnecter').last);
    await tester.pump();
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
    expect(signedOut, ['b']);
    expect(find.text('Android · Android 14'), findsNothing);
    expect(find.text('Aucun autre appareil.'), findsOneWidget);
  });

  testWidgets('Notifications: three switches, saved on the server', (
    tester,
  ) async {
    final saved = <Map<String, bool>>[];
    final beforeLoad = loadNotificationPrefs;
    final beforeSave = saveNotificationPrefs;
    loadNotificationPrefs = () async => {
      'transfers': true,
      'commissions': true,
      'news': false,
    };
    saveNotificationPrefs = (p) async {
      saved.add(p);
      return p;
    };
    addTearDown(() {
      loadNotificationPrefs = beforeLoad;
      saveNotificationPrefs = beforeSave;
    });

    await tester.pumpWidget(_app(const NotificationsScreen()));
    await tester.pumpAndSettle();
    expect(find.text('Envois et réceptions'), findsOneWidget);
    expect(find.text('Commissions et retraits'), findsOneWidget);
    expect(find.text('Nouveautés'), findsOneWidget);
    final switches = find.byType(Switch);
    expect(tester.widget<Switch>(switches.at(2)).value, isFalse);

    await tester.tap(switches.at(1));
    await tester.pumpAndSettle();
    expect(saved, [
      {'commissions': false},
    ]);
    expect(tester.widget<Switch>(switches.at(1)).value, isFalse);
  });

  testWidgets(
    'New number: a code sent to it must be typed (WhatsApp, then SMS)',
    (tester) async {
      final checked = <String>[];
      final beforeSend = sendPhoneCode;
      final beforeCheck = checkPhoneCode;
      final channels = <String>[];
      sendPhoneCode = (phone, channel) async {
        channels.add(channel);
        return true;
      };
      checkPhoneCode = (phone, code) async {
        checked.add('$phone $code');
        if (code != '654321') {
          throw const AccountException(
            'Code incorrect. Réessayez.',
            status: 400,
          );
        }
      };
      addTearDown(() {
        sendPhoneCode = beforeSend;
        checkPhoneCode = beforeCheck;
      });
      bool? proved;
      await tester.pumpWidget(
        _app(
          Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () async =>
                    proved = await verifyNewPhone(context, '+256771234567'),
                child: const Text('Vérifier'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Vérifier'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('Code de vérification'), findsOneWidget);
      // The number is masked; first sent by WhatsApp.
      expect(find.textContaining('+256******567'), findsOneWidget);
      expect(channels, ['whatsapp']);
      expect(find.textContaining('Renvoyer par SMS dans'), findsOneWidget);
      await tester.pump(const Duration(seconds: 46));
      await tester.tap(find.text('Renvoyer par SMS'));
      await tester.pump();
      expect(channels, ['whatsapp', 'sms']);
      expect(find.textContaining('Renvoyer par SMS dans'), findsOneWidget);
      await tester.pump(const Duration(seconds: 5));
      await tester.enterText(find.byType(TextField).last, '111111');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('Code incorrect. Réessayez.'), findsOneWidget);
      await tester.enterText(find.byType(TextField).last, '654321');
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      expect(proved, isTrue);
      expect(checked.last, '+256771234567 654321');
    },
  );
}

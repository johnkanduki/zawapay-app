import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zawapay_app/core/account/withdraw_pin.dart';
import 'package:zawapay_app/features/settings/devices_screen.dart';
import 'package:zawapay_app/features/settings/notifications_screen.dart';
import 'package:zawapay_app/features/withdraw/pin_sheet.dart';
import 'package:zawapay_app/l10n/app_localizations.dart';

Widget _app(Widget home) => MaterialApp(
  locale: const Locale('fr'),
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: home,
);

void main() {
  testWidgets('Code PIN: created, then changed (the current one first)', (
    tester,
  ) async {
    FlutterSecureStorage.setMockInitialValues({});
    final pins = WithdrawPin(key: 'test.pin');
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
    await tester.enterText(find.byType(TextField).last, '1234');
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).last, '1234');
    await tester.pumpAndSettle();
    expect(result, isTrue);
    expect(await pins.check('1234'), isTrue);

    // Change: the current PIN, then the new one twice.
    await tester.tap(find.text('PIN'));
    await tester.pumpAndSettle();
    expect(find.text('Entrez votre code PIN'), findsOneWidget);
    await tester.enterText(find.byType(TextField).last, '1234');
    await tester.pumpAndSettle();
    expect(find.text('Créez votre code PIN'), findsOneWidget);
    await tester.enterText(find.byType(TextField).last, '5678');
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).last, '5678');
    await tester.pumpAndSettle();
    expect(await pins.check('5678'), isTrue);
    expect(await pins.check('1234'), isFalse);
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
}

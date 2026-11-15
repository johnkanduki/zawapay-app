import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zawapay_app/core/account/zawapay_account.dart';
import 'package:zawapay_app/core/account/withdraw_pin.dart';
import 'package:zawapay_app/features/onboarding/onboarding_screen.dart';
import 'package:zawapay_app/features/settings/delete_account.dart';
import 'package:zawapay_app/features/settings/settings_sheet.dart';
import 'package:zawapay_app/l10n/app_localizations.dart';

import 'fake_pin.dart';

/// Settings → About → "Supprimer le compte": explanation, PIN, server.
void main() {
  Future<void> openAbout(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1206, 2622);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('fr'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: TextButton(
                onPressed: () => showAboutSheet(context),
                child: const Text('Infos'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Infos'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Supprimer le compte'));
    await tester.pumpAndSettle();
  }

  setUp(() => FlutterSecureStorage.setMockInitialValues({}));

  void keepGlobals() {
    final pins = withdrawPin;
    final call = deleteMyAccount;
    addTearDown(() {
      withdrawPin = pins;
      deleteMyAccount = call;
    });
  }

  testWidgets('Confirmed with the PIN: deleted, back to the first page', (
    tester,
  ) async {
    keepGlobals();
    withdrawPin = FakePin('1234');
    final sent = <String>[];
    deleteMyAccount = (pin) async => sent.add(pin);

    await openAbout(tester);
    expect(find.text('Supprimer votre compte ?'), findsOneWidget);
    expect(find.textContaining('Vos filleuls passeront sous votre parrain'), findsOneWidget);
    await tester.tap(find.text('Supprimer mon compte'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).last, '1234');
    for (var i = 0; i < 8; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    expect(sent, ['1234']);
    expect(find.byType(OnboardingScreen), findsOneWidget);
    expect(find.text('Votre compte Zawapay App a été supprimé.'), findsOneWidget);
    await tester.pumpAndSettle(const Duration(seconds: 5));
  });

  testWidgets('Cancel: nothing is deleted', (tester) async {
    keepGlobals();
    withdrawPin = FakePin('1234');
    var called = false;
    deleteMyAccount = (_) async => called = true;

    await openAbout(tester);
    await tester.tap(find.text('Annuler'));
    await tester.pumpAndSettle();
    expect(called, isFalse);
    expect(find.byType(OnboardingScreen), findsNothing);
  });

  testWidgets('Commissions left: the server message is shown', (tester) async {
    keepGlobals();
    withdrawPin = FakePin('1234');
    deleteMyAccount = (_) async => throw const AccountException(
      'Il vous reste 12.40 \$ de commissions. Retirez-les d’abord, puis supprimez votre compte.',
      status: 409,
    );

    await openAbout(tester);
    await tester.tap(find.text('Supprimer mon compte'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).last, '1234');
    await tester.pumpAndSettle();
    expect(find.textContaining('Retirez-les d’abord'), findsOneWidget);
    expect(find.byType(OnboardingScreen), findsNothing);
    await tester.pumpAndSettle(const Duration(seconds: 5));
  });
}

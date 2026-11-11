import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zawapay_app/features/settings/sign_out_dialog.dart';
import 'package:zawapay_app/l10n/app_localizations.dart';

void main() {
  testWidgets('Sign out asks first: Cancel keeps, Sign out confirms', (
    tester,
  ) async {
    bool? answer;
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('fr'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () async => answer = await confirmSignOut(context),
              child: const Text('Déconnexion'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Déconnexion'));
    await tester.pumpAndSettle();
    expect(find.text('Se déconnecter de Zawapay App ?'), findsOneWidget);
    await tester.tap(find.text('Annuler'));
    await tester.pumpAndSettle();
    expect(answer, isFalse);
    expect(find.text('Se déconnecter de Zawapay App ?'), findsNothing);

    await tester.tap(find.text('Déconnexion'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Se déconnecter'));
    await tester.pumpAndSettle();
    expect(answer, isTrue);
  });
}

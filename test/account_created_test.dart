import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zawapay_app/features/auth/screens/account_created_screen.dart';
import 'package:zawapay_app/features/auth/screens/sign_in_screen.dart';
import 'package:zawapay_app/features/onboarding/onboarding_screen.dart';
import 'package:zawapay_app/l10n/app_localizations.dart';

void main() {
  testWidgets('Account created: the person signs in by themself', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('fr'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const AccountCreatedScreen(),
      ),
    );
    expect(find.text('Compte créé !'), findsOneWidget);
    expect(
      find.textContaining('Connectez-vous pour commencer'),
      findsOneWidget,
    );
    await tester.tap(find.text('Se connecter'));
    await tester.pumpAndSettle();
    expect(find.byType(SignInScreen), findsOneWidget);
    // Back from the sign-in page: the first page, never black.
    tester.state<NavigatorState>(find.byType(Navigator)).pop();
    await tester.pumpAndSettle();
    expect(find.byType(OnboardingScreen), findsOneWidget);
    expect(find.byType(AccountCreatedScreen), findsNothing);
  });
}

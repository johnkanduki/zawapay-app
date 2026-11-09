import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zawapay_app/app.dart';
import 'package:zawapay_app/features/auth/widgets/password_strength.dart';

void main() {
  testWidgets('First screen: pick country and language, then sign-in choice', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    tester.platformDispatcher.localesTestValue = const [Locale('fr')];

    await tester.pumpWidget(const ZawapayApp());
    await tester.pumpAndSettle();
    expect(find.text('Bienvenue'), findsOneWidget);

    // Switching to English translates the page at once.
    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();
    expect(find.text('Welcome'), findsOneWidget);

    // Continue stays disabled until a country is chosen.
    await tester.tap(find.text('Choose your country'));
    await tester.pumpAndSettle();

    // A country that is not available shows the "coming soon" message.
    await tester.enterText(find.byType(TextField), 'France');
    await tester.pump();
    expect(find.text('Not in this country yet'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'ken');
    await tester.pump();
    await tester.tap(find.text('Kenya'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(find.text('Sign in'), findsOneWidget);
    expect(find.text('Create an account'), findsOneWidget);
  });

  test('Password strength levels', () {
    expect(PasswordRules('abc12').level, 1);
    expect(PasswordRules('Abcdefgh12').level, 2);
    expect(PasswordRules('Abcdefgh12!').level, 3);
  });
}

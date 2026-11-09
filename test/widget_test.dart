import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zawapay_app/app.dart';
import 'package:zawapay_app/features/auth/widgets/password_strength.dart';

void main() {
  testWidgets('Onboarding shows both entry buttons in French', (tester) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    tester.platformDispatcher.localesTestValue = const [Locale('fr')];
    await tester.pumpWidget(const ZawapayApp());
    await tester.pumpAndSettle();
    expect(find.text('Se connecter'), findsOneWidget);
    expect(find.text('Créer un compte'), findsOneWidget);
  });

  test('Password strength levels', () {
    expect(PasswordRules('abc12').level, 1);
    expect(PasswordRules('Abcdefgh12').level, 2);
    expect(PasswordRules('Abcdefgh12!').level, 3);
  });
}

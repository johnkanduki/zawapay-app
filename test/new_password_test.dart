import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:zawapay_app/core/account/zawapay_account.dart';
import 'package:zawapay_app/features/auth/screens/new_password_screen.dart';
import 'package:zawapay_app/features/home/home_screen.dart';
import 'package:zawapay_app/l10n/app_localizations.dart';

/// "Mot de passe oublié" → new password → "Enregistrer": the home page opens
/// (no endless spinner).
void main() {
  final calls = <String>[];

  setUpAll(() {
    FlutterSecureStorage.setMockInitialValues({});
    final server = MockClient((request) async {
      calls.add('${request.method} ${request.url.path}');
      Map<String, dynamic> answer = {};
      switch (request.url.path) {
        case '/v1/auth/email/reset/complete':
          answer = {
            'accessToken': 'a',
            'refreshToken': 'r',
            'accessTokenExpiresIn': 900,
            'isNewUser': false,
            'user': {'firstName': 'John', 'lastName': 'Kanduki', 'email': 'j@example.com'},
          };
        case '/v1/zawapay/me':
          answer = {
            'member': {'handle': 'johnkanduki', 'name': 'John Kanduki', 'country': 'CD'},
          };
      }
      return http.Response(jsonEncode(answer), 200, headers: {'content-type': 'application/json'});
    });
    // The account is created here, with the fake server.
    http.runWithClient(() => zawapayAccount, () => server);
  });

  testWidgets('Enregistrer opens the home page', (tester) async {
    tester.view.physicalSize = const Size(1206, 2622);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('fr'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const NewPasswordScreen(resetTicket: 'ticket'),
      ),
    );
    await tester.enterText(find.byType(TextField).first, 'Zawapay2026!');
    await tester.enterText(find.byType(TextField).last, 'Zawapay2026!');
    await tester.pump();
    await tester.tap(find.text('Enregistrer'));
    for (var i = 0; i < 20; i++) {
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(calls, containsAllInOrder(['POST /v1/auth/email/reset/complete', 'GET /v1/zawapay/me']));
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.byType(NewPasswordScreen), findsNothing);
  });
}

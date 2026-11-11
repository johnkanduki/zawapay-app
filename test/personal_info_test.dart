import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zawapay_app/core/account/zawapay_account.dart';
import 'package:zawapay_app/features/settings/personal_info_sheet.dart';
import 'package:zawapay_app/l10n/app_localizations.dart';

void main() {
  testWidgets('Personal info: filled, @ locked, Save only after a change', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1206, 2622);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    zawapayAccount.current.value = const SignedIn(
      member: ZawapayMember(
        handle: 'johnkanduki',
        name: 'John Kanduki',
        country: 'CD',
      ),
      firstName: 'John',
      lastName: 'Kanduki',
      email: 'john@exemple.test',
    );
    addTearDown(() => zawapayAccount.current.value = null);

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('fr'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => showPersonalInfoSheet(context),
              child: const Text('Modifier'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Modifier'));
    await tester.pumpAndSettle();

    expect(find.text('John'), findsOneWidget);
    expect(find.text('Kanduki'), findsOneWidget);
    expect(find.text('john@exemple.test'), findsOneWidget);
    // The @ is shown, never in a field that can be typed in.
    expect(find.text('@johnkanduki'), findsOneWidget);
    expect(find.text('Ne change jamais'), findsOneWidget);
    expect(find.widgetWithText(TextField, '@johnkanduki'), findsNothing);

    bool canSave() =>
        tester
            .widget<FilledButton>(
              find.widgetWithText(FilledButton, 'Enregistrer'),
            )
            .onPressed !=
        null;
    expect(canSave(), isFalse);
    await tester.enterText(find.widgetWithText(TextField, 'John'), 'Johnny');
    await tester.pump();
    expect(canSave(), isTrue);
    expect(find.text('Johnny Kanduki'), findsOneWidget);
  });
}

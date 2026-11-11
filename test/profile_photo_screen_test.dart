import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zawapay_app/features/auth/screens/profile_photo_screen.dart';
import 'package:zawapay_app/l10n/app_localizations.dart';

void main() {
  testWidgets('Finish stays grey until a photo is taken', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('fr'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: ProfilePhotoScreen(onFinished: (_, _) async {}),
      ),
    );

    expect(find.text('Votre photo de profil'), findsOneWidget);
    expect(find.text('Touchez le cercle'), findsWidgets);
    final finish = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Terminer'),
    );
    expect(finish.onPressed, isNull);
  });
}

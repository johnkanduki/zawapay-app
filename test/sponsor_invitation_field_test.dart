import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zawapay_app/features/auth/widgets/sponsor_invitation_field.dart';
import 'package:zawapay_app/l10n/app_localizations.dart';

void main() {
  testWidgets('Sponsor appears only when the username is exact, then confirm', (
    tester,
  ) async {
    Sponsor? confirmed;
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('fr'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: SponsorInvitationField(onConfirmed: (s) => confirmed = s),
        ),
      ),
    );

    // "@" is always there; typing "@" or spaces is refused.
    expect(find.text('@'), findsOneWidget);
    await tester.enterText(find.byType(TextField), '@Ami na');
    await tester.pump();
    expect(find.text('amina'), findsOneWidget);

    // Partial name: no suggestion, no sponsor.
    await tester.enterText(find.byType(TextField), 'ami');
    await tester.pumpAndSettle();
    expect(find.text('Est-ce bien votre parrain ou marraine ?'), findsNothing);

    // Exact name: photo (initials), country and Confirm button.
    await tester.enterText(find.byType(TextField), 'amina');
    await tester.pumpAndSettle();
    expect(find.text('AD'), findsOneWidget);
    expect(find.text('Amina Diallo'), findsOneWidget);
    expect(find.text('Sénégal'), findsOneWidget);

    await tester.tap(find.text('Confirmer'));
    await tester.pumpAndSettle();
    expect(confirmed?.username, 'amina');
    expect(find.text('Invitation confirmée : Amina Diallo'), findsOneWidget);

    await tester.tap(find.text('Modifier'));
    await tester.pumpAndSettle();
    expect(confirmed, isNull);
    expect(find.text('Confirmer'), findsOneWidget);
  });
}

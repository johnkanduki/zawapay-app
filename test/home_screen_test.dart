import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zawapay_app/core/widgets/verified_badge.dart';
import 'package:zawapay_app/features/home/home_screen.dart';
import 'package:zawapay_app/l10n/app_localizations.dart';

void main() {
  testWidgets('Home shows the greeting, Transfer and the activity list', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1206, 2622);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('fr'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const HomeScreen(firstName: 'John', lastName: 'Kanduki'),
      ),
    );

    expect(find.text('John Kanduki'), findsOneWidget);
    expect(find.text('@johnkanduki'), findsOneWidget);
    expect(usernameFromName('Hélène Mbuyi-Ngoy'), 'helenembuyingoy');
    expect(find.text('J'), findsOneWidget);
    expect(find.text('Envoyer'), findsOneWidget);
    expect(find.text('Historique'), findsOneWidget);
    expect(find.text('Échoué'), findsOneWidget);
    expect(find.text('il y a 1 jour'), findsOneWidget);
    expect(find.text('il y a 2 mois'), findsOneWidget);

    // "Masquer" folds the list, "Afficher" opens it again.
    await tester.tap(find.text('Masquer'));
    await tester.pumpAndSettle();
    expect(find.text('Échoué'), findsNothing);
    await tester.tap(find.text('Afficher'));
    await tester.pumpAndSettle();
    expect(find.text('Échoué'), findsOneWidget);
  });

  Widget app(Widget home) => MaterialApp(
    locale: const Locale('fr'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: home,
  );

  testWidgets('Not certified: tapping the profile opens the KYC page', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1206, 2622);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      app(
        const HomeScreen(firstName: 'John', lastName: 'Kanduki', transfers: []),
      ),
    );
    expect(find.byType(VerifiedBadge), findsNothing);

    await tester.tap(find.text('@johnkanduki'));
    await tester.pumpAndSettle();
    expect(find.text('Certifiez votre identifiant'), findsOneWidget);
    expect(find.text('Commencer la vérification'), findsOneWidget);
  });

  testWidgets('Certified: blue badge, the profile does not open the KYC page', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1206, 2622);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      app(
        const HomeScreen(
          firstName: 'John',
          lastName: 'Kanduki',
          certified: true,
          transfers: [],
        ),
      ),
    );
    expect(find.byType(VerifiedBadge), findsOneWidget);

    // Certified: the profile leads to Settings, not to the KYC page.
    await tester.tap(find.text('John Kanduki'));
    await tester.pumpAndSettle();
    expect(find.text('Certifiez votre identifiant'), findsNothing);
    expect(find.text('Paramètres'), findsOneWidget);
    expect(find.text('Identifiant certifié'), findsOneWidget);

    // "Invite friends" explains the 3 levels above and 3 below.
    await tester.tap(find.text('Inviter des amis'));
    await tester.pumpAndSettle();
    expect(find.text('Invitez, gagnez ensemble'), findsOneWidget);
    expect(find.text('@johnkanduki'), findsOneWidget);
    expect(find.text('Vous'), findsOneWidget);
  });

  testWidgets('Settings tab from the bottom bar, not certified', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1206, 2622);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      app(const HomeScreen(firstName: 'John', lastName: 'Kanduki')),
    );
    await tester.tap(find.byIcon(Icons.settings_rounded));
    await tester.pumpAndSettle();
    expect(find.text('Identifiant non certifié'), findsOneWidget);
    await tester.tap(find.text('Certifier'));
    await tester.pumpAndSettle();
    expect(find.text('Certifiez votre identifiant'), findsOneWidget);
  });

  testWidgets('Pulling the page down and releasing refreshes it', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1206, 2622);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    var refreshed = 0;
    await tester.pumpWidget(
      app(
        HomeScreen(
          firstName: 'John',
          lastName: 'Kanduki',
          onRefresh: () async => refreshed++,
        ),
      ),
    );

    // A small pull does nothing.
    await tester.drag(find.text('Envoyer'), const Offset(0, 40));
    await tester.pumpAndSettle();
    expect(refreshed, 0);

    // A long pull, then release: refresh.
    final header = tester.getTopLeft(find.text('John Kanduki')).dy;
    final gesture = await tester.startGesture(
      tester.getCenter(find.text('Envoyer')),
    );
    await gesture.moveBy(const Offset(0, 100));
    await gesture.moveBy(const Offset(0, 100));
    await tester.pump();
    // The header comes down with the page.
    expect(
      tester.getTopLeft(find.text('John Kanduki')).dy,
      greaterThan(header),
    );
    await gesture.up();
    await tester.pumpAndSettle();
    expect(refreshed, 1);
    // Back in place once released.
    expect(tester.getTopLeft(find.text('John Kanduki')).dy, header);
  });

  testWidgets('Balance: two currencies for RD Congo, one elsewhere, can hide', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1206, 2622);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      app(
        const HomeScreen(
          firstName: 'John',
          lastName: 'Kanduki',
          countryCode: 'CD',
          balances: {'USD': 88.75},
        ),
      ),
    );
    expect(find.text('Solde'), findsNothing);
    expect(find.text('Scanner pour payer'), findsOneWidget);
    expect(find.text('Zawapay'), findsOneWidget);
    expect(find.textContaining('USD', findRichText: true), findsOneWidget);
    expect(find.textContaining('CDF', findRichText: true), findsOneWidget);
    expect(find.textContaining('88,75', findRichText: true), findsOneWidget);
    expect(find.text('Envoyer'), findsOneWidget);
    expect(find.text('Retirer'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.visibility_off_rounded));
    await tester.pump();
    expect(find.textContaining('88,75', findRichText: true), findsNothing);

    await tester.pumpWidget(
      app(const HomeScreen(firstName: 'Amani', countryCode: 'KE')),
    );
    await tester.pump();
    expect(find.textContaining('KES', findRichText: true), findsOneWidget);
    expect(find.textContaining('USD', findRichText: true), findsNothing);
  });

  testWidgets('History rows show the "@" and open the detail of each status', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1206, 2622);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      app(const HomeScreen(firstName: 'John', countryCode: 'CD')),
    );
    expect(find.text('@zawapay'), findsNWidgets(2));
    expect(find.text('@mireille.k'), findsOneWidget);

    // Successful.
    await tester.tap(find.text('Réussi'));
    await tester.pumpAndSettle();
    expect(find.text('Reçu et confirmé par @zawapay'), findsOneWidget);
    expect(find.text('Contacter le support'), findsOneWidget);
    expect(find.text('Réessayer'), findsNothing);
    await tester.tap(find.byIcon(Icons.arrow_back_rounded));
    await tester.pumpAndSettle();

    // Failed: the reason in red and "Try again".
    await tester.tap(find.text('Échoué'));
    await tester.pumpAndSettle();
    expect(find.textContaining('code PIN incorrect'), findsOneWidget);
    expect(find.text('Réessayer'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.arrow_back_rounded));
    await tester.pumpAndSettle();

    // Received and still pending (the step spins: no settle).
    await tester.tap(find.text('En cours'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Expéditeur'.toUpperCase()), findsOneWidget);
    expect(find.text('Confirmez la réception de cet argent'), findsOneWidget);
  });

  testWidgets('The middle tab shows the user\'s own QR code', (tester) async {
    tester.view.physicalSize = const Size(1206, 2622);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      app(const HomeScreen(firstName: 'John', lastName: 'Kanduki')),
    );
    await tester.tap(find.byIcon(Icons.qr_code_scanner_rounded));
    await tester.pumpAndSettle();
    expect(find.text('Scanner pour payer'), findsOneWidget);
    expect(find.text('Demander de l’argent'), findsOneWidget);
    expect(find.text('Partager le code QR'), findsOneWidget);
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zawapay_app/features/history/history_filter.dart';
import 'package:zawapay_app/features/history/history_screen.dart';
import 'package:zawapay_app/features/history/transfer.dart';
import 'package:zawapay_app/features/home/home_screen.dart';
import 'package:zawapay_app/l10n/app_localizations.dart';

import 'test_data.dart';

void main() {
  Widget app(Widget home) => MaterialApp(
    locale: const Locale('fr'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: home,
  );

  test('Filters keep only the matching transfers', () {
    final all = testTransfers;
    expect(const HistoryFilter().apply(all).length, all.length);
    final failed = const HistoryFilter(status: TransferStatus.failed);
    expect(failed.apply(all).length, 2);
    expect(failed.activeCount, 1);
    const received = HistoryFilter(type: FilterType.received);
    expect(received.apply(all).every((t) => !t.outgoing), isTrue);
    const week = HistoryFilter(period: FilterPeriod.days7);
    expect(week.apply(all).length, 1);
  });

  testWidgets('"See all the history" opens History; Filters narrow it', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1206, 2622);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      app(HomeScreen(firstName: 'John', transfers: testTransfers)),
    );
    // Only the 3 latest on the home page.
    expect(find.text('@zawapay'), findsNWidgets(2));
    await tester.tap(find.text('VOIR TOUT L’HISTORIQUE'));
    await tester.pumpAndSettle();
    expect(find.byType(HistoryScreen), findsOneWidget);
    expect(find.text('@kofi.mensah'), findsOneWidget);

    await tester.tap(find.text('Filtres'));
    await tester.pumpAndSettle();
    expect(find.text('Tout le monde'), findsOneWidget);
    expect(find.text('Voir 6 résultats'), findsOneWidget);

    await tester.tap(find.text('Statut'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Échoué').last);
    await tester.pumpAndSettle();
    expect(find.text('Voir 2 résultats'), findsOneWidget);

    await tester.tap(find.text('Voir 2 résultats'));
    await tester.pumpAndSettle();
    expect(find.text('2 résultats'), findsOneWidget);
    expect(find.text('Réussi'), findsNothing);

    await tester.tap(find.text('Effacer'));
    await tester.pumpAndSettle();
    expect(find.text('Réussi'), findsWidgets);
  });
}

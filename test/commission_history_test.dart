import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zawapay_app/features/commissions/commission_history_screen.dart';
import 'package:zawapay_app/l10n/app_localizations.dart';

void main() {
  testWidgets('Commissions history: where every dollar comes from', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1206, 2622);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    final before = loadCommissionHistory;
    loadCommissionHistory = () async => {
      'available': '2.50',
      'pending': '0.32',
      'earned': '4.00',
      'withdrawn': '1.50',
      'items': [
        {
          'kind': 'commission',
          'amount': '0.78',
          'status': 'available',
          'createdAt': '2026-11-12T10:00:00Z',
          'commission': {
            'level': 'up1',
            'percent': 30,
            'sharedWith': 1,
            'pool': '2.60',
            'sender': 'amina',
            'reference': 'ZP-1234ABCD',
            'paid': '106.50',
            'paidCurrency': 'USD',
            'received': '100.00',
            'receivedCurrency': 'USD',
          },
        },
        {
          'kind': 'withdrawal',
          'amount': '-1.50',
          'status': 'available',
          'createdAt': '2026-11-11T10:00:00Z',
          'withdrawal': {
            'reference': 'ZR-1',
            'receive': '3448',
            'currency': 'CDF',
            'phone': '+243812345678',
            'status': 'SUCCESS',
          },
        },
      ],
    };
    addTearDown(() => loadCommissionHistory = before);

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('fr'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const CommissionHistoryScreen(username: 'johnkanduki'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Historique des commissions'), findsOneWidget);
    expect(find.text('2,50 USD'), findsOneWidget);
    // A commission: who sent, how much, the real %, plus.
    expect(find.text('@amina a envoyé 106,50 USD'), findsOneWidget);
    expect(find.textContaining('Votre invité (niveau 1)'), findsOneWidget);
    expect(find.textContaining('30 %'), findsOneWidget);
    expect(find.text('+0,78 USD'), findsOneWidget);
    // A withdrawal: minus, and the francs received.
    expect(find.text('−1,50 USD'), findsOneWidget);
    expect(find.textContaining('3 448 CDF'), findsOneWidget);
    // Tap a commission: its reference.
    await tester.tap(find.text('@amina a envoyé 106,50 USD'));
    await tester.pump();
    expect(find.text('ZP-1234ABCD'), findsOneWidget);
  });
}

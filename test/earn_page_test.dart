import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zawapay_app/features/invite/invite_screen.dart';
import 'package:zawapay_app/l10n/app_localizations.dart';

void main() {
  testWidgets('Gagner ensemble: the real numbers from the server', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1206, 2622);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    final before = loadEarnPage;
    loadEarnPage = () async => {
      'title': {'fr': 'Invitez vos proches, gagnez à chaque envoi'},
      'subtitle': {'fr': 'Chaque envoi de votre équipe vous rapporte.'},
      'example': {
        'sendAmountUsd': 100,
        'sendsPerWeek': 2,
        'directFriends': 5,
        'eachInvites': 5,
      },
      'rules': {
        'feePercent': 6.5,
        'poolPercent': 10,
        'up': [30, 20, 10],
        'down': [20, 12, 8],
        'withdrawMinimumUsd': 1,
        'withdrawFeePercent': 0,
      },
      'perSend': {
        'fee': 6.5,
        'pool': 0.65,
        'gen1': 0.2,
        'gen2': 0.13,
        'gen3': 0.07,
        'sponsor': 0.13,
        'above': [
          {'level': 1, 'percent': 20, 'perSend': 0.13, 'each': 0.03},
          {'level': 2, 'percent': 12, 'perSend': 0.08, 'each': 0.0},
          {'level': 3, 'percent': 8, 'perSend': 0.05, 'each': 0.0},
        ],
      },
      'where': {
        'received': 100,
        'paid': 106.5,
        'fee': 6.5,
        'toNetwork': 0.65,
        'toZawapay': 5.85,
      },
      'oneFriend': {'once': 0.2, 'week': 0.39, 'month': 1.69, 'year': 20.28},
      'team': {
        'levels': [
          {
            'level': 1,
            'people': 5,
            'percent': 30,
            'perSend': 0.2,
            'perMonth': 8.45,
          },
          {
            'level': 2,
            'people': 25,
            'percent': 20,
            'perSend': 0.13,
            'perMonth': 28.17,
          },
          {
            'level': 3,
            'people': 125,
            'percent': 10,
            'perSend': 0.07,
            'perMonth': 70.42,
          },
        ],
        'people': 155,
        'week': 24.7,
        'month': 107.04,
        'year': 1284.48,
      },
    };
    addTearDown(() => loadEarnPage = before);

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('fr'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const InviteScreen(username: 'johnkanduki'),
      ),
    );
    await tester.pumpAndSettle();

    // The title from the admin, the team example in big.
    expect(
      find.text('Invitez vos proches, gagnez à chaque envoi'),
      findsOneWidget,
    );
    expect(find.text('107,04 \$ par mois'), findsWidgets);
    expect(find.text('@johnkanduki'), findsOneWidget);
    // The 6 levels (3 above too) and where the money goes come first.
    await tester.scrollUntilVisible(
      find.text('Votre parrain ou marraine'),
      300,
    );
    expect(find.text('Le parrain de votre parrain'), findsOneWidget);
    await tester.scrollUntilVisible(find.textContaining('toujours 100 %'), 300);
    await tester.scrollUntilVisible(find.text('5,85 \$'), 300);
    // Then the real percentages and what you get.
    await tester.scrollUntilVisible(find.text('vous recevez 0,20 \$'), 300);
    expect(find.text('30 %'), findsWidgets);
    await tester.scrollUntilVisible(
      find.text('Vous gagnez aussi grâce aux personnes au-dessus de vous'),
      300,
    );
    // Examples down the long page.
    await tester.scrollUntilVisible(find.text('20,28 \$ par an'), 300);
    expect(find.text('20,28 \$ par an'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Le retrait est gratuit.'), 300);
    expect(find.text('Le retrait est gratuit.'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Partager mon invitation'), 300);
  });
}

// Draws the App Store / Play Store screens with the real widgets and demo
// numbers (no server, no money). Run:
//   flutter test tool/store_screens_test.dart --dart-define=OUT=<folder> --dart-define=PHOTO=<png>
// Each PNG is 1320 x 2868 (iPhone 6.9"): 440 x 956 points at 3x.
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zawapay_app/core/account/app_rules.dart';
import 'package:zawapay_app/core/account/destinations.dart';
import 'package:zawapay_app/core/countries/country.dart';
import 'package:zawapay_app/core/theme/app_theme.dart';
import 'package:zawapay_app/features/commissions/commission_history_screen.dart';
import 'package:zawapay_app/features/history/transfer.dart';
import 'package:zawapay_app/features/home/home_screen.dart';
import 'package:zawapay_app/features/invite/invite_screen.dart';
import 'package:zawapay_app/features/scan/my_qr_screen.dart';
import 'package:zawapay_app/features/send/recipient.dart';
import 'package:zawapay_app/features/send/send_amount_screen.dart';
import 'package:zawapay_app/features/send/send_recipient_screen.dart';
import 'package:zawapay_app/l10n/app_localizations.dart';

const _out = String.fromEnvironment('OUT');
const _photo = String.fromEnvironment('PHOTO');
// Screen in pixels and pixel ratio: iPhone 6.9" by default, iPad 13" with
// --dart-define=W=2064 --dart-define=H=2752 --dart-define=DPR=2 --dart-define=TOP=48 --dart-define=BOTTOM=40.
const _w = int.fromEnvironment('W', defaultValue: 1320);
const _h = int.fromEnvironment('H', defaultValue: 2868);
final _dpr = double.parse(const String.fromEnvironment('DPR', defaultValue: '3'));
const _top = int.fromEnvironment('TOP', defaultValue: 186);
const _bottom = int.fromEnvironment('BOTTOM', defaultValue: 102);
final _shot = GlobalKey();

Future<void> _fonts() async {
  final inter = FontLoader('PlusJakartaSans');
  for (final w in ['Regular', 'Medium', 'SemiBold', 'Bold', 'ExtraBold']) {
    inter.addFont(rootBundle.load('assets/fonts/PlusJakartaSans-$w.ttf'));
  }
  await inter.load();
  final root = Platform.environment['FLUTTER_ROOT'] ?? '/Users/kanduki/development/flutter';
  final icons = FontLoader('MaterialIcons')
    ..addFont(
      File('$root/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf')
          .readAsBytes()
          .then((b) => ByteData.view(b.buffer)),
    );
  await icons.load();
}

Future<void> _show(WidgetTester tester, Widget home) async {
  tester.view.physicalSize = Size(_w.toDouble(), _h.toDouble());
  tester.view.devicePixelRatio = _dpr;
  tester.view.padding = FakeViewPadding(top: _top.toDouble(), bottom: _bottom.toDouble());
  tester.view.viewPadding = FakeViewPadding(top: _top.toDouble(), bottom: _bottom.toDouble());
  await tester.pumpWidget(
    RepaintBoundary(
      key: _shot,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        locale: const Locale('fr'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: home,
      ),
    ),
  );
  await _settle(tester);
}

/// Lets images, SVG flags and fake server answers arrive.
Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 6; i++) {
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 150)));
    await tester.pump(const Duration(milliseconds: 400));
  }
}

Future<void> _save(WidgetTester tester, String name) async {
  await tester.runAsync(() async {
    final boundary = _shot.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: _dpr);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    File('$_out/$name.png')
      ..createSync(recursive: true)
      ..writeAsBytesSync(bytes!.buffer.asUint8List());
  });
}

DateTime _ago(int minutes) => DateTime.now().subtract(Duration(minutes: minutes));

void main() {
  final congo = supportedCountries.firstWhere((c) => c.isoCode == 'CD');
  const grace = Recipient(
    username: 'gracembuyi',
    fullName: 'Grace Mbuyi',
    countryCode: 'CD',
    phone: '812345678',
    certified: true,
  );
  const kofi = Recipient(username: 'kofi', fullName: 'Kofi Mensah', countryCode: 'CI', phone: '0701020304', certified: true);
  const amina = Recipient(username: 'amina', fullName: 'Amina Diallo', countryCode: 'SN', phone: '771234567', certified: true);
  const david = Recipient(username: 'david.k', fullName: 'David Kasongo', countryCode: 'CD', phone: '991234567');
  const me = Recipient(username: 'johnkanduki', fullName: 'John Kanduki', countryCode: 'CD', phone: '975135458', certified: true);

  setUpAll(() async {
    await _fonts();
    knownAccounts
      ..clear()
      ..addAll([grace, kofi, amina, david]);
    destinations.value = const [
      Destination(country: 'CD', currency: 'USD', min: 1, max: 5000),
    ];
  });

  testWidgets('1 Accueil', (tester) async {
    Transfer t(String id, Recipient r, double v, int min, {bool out = true}) => Transfer(
      id: id, reference: 'ZP-$id', other: r, outgoing: out, received: v,
      fee: v * 0.065, currency: 'USD', status: TransferStatus.success,
      sentAt: _ago(min), paidAt: _ago(min - 1), confirmedAt: _ago(min - 2),
    );
    await _show(
      tester,
      HomeScreen(
        firstName: 'John',
        lastName: 'Kanduki',
        username: 'johnkanduki',
        photoPath: _photo.isEmpty ? null : _photo,
        certified: true,
        countryCode: 'CD',
        balances: const {'USD': 1248.75},
        transfers: [
          t('A1', grace, 150, 25),
          t('A2', kofi, 80, 180, out: false),
          t('A3', amina, 200, 60 * 26),
        ],
      ),
    );
    await _save(tester, '1-accueil');
  });

  testWidgets('2 Six niveaux', (tester) async {
    loadEarnPage = () async => {
      'title': {'fr': 'Invitez vos proches, gagnez à chaque envoi'},
      'subtitle': {'fr': 'Chaque fois que quelqu’un de votre équipe envoie de l’argent à sa famille, vous recevez une part. Automatiquement, à vie.'},
      'example': {'sendAmountUsd': 100, 'sendsPerWeek': 2, 'directFriends': 5, 'eachInvites': 5},
      'rules': {'feePercent': 6.5, 'poolPercent': 40, 'up': [30, 20, 10], 'down': [20, 12, 8], 'withdrawMinimumUsd': 1, 'withdrawFeePercent': 0},
      'perSend': {
        'fee': 6.5, 'pool': 2.6, 'gen1': 0.78, 'gen2': 0.52, 'gen3': 0.26, 'sponsor': 0.52,
        'above': [
          {'level': 1, 'percent': 20, 'perSend': 0.52, 'each': 0.52},
          {'level': 2, 'percent': 12, 'perSend': 0.31, 'each': 0.31},
          {'level': 3, 'percent': 8, 'perSend': 0.21, 'each': 0.21},
        ],
      },
      'where': {'received': 100, 'paid': 106.5, 'fee': 6.5, 'toNetwork': 2.6, 'toZawapay': 3.9},
      'oneFriend': {'once': 0.78, 'week': 1.56, 'month': 6.76, 'year': 81.12},
      'team': {
        'levels': [
          {'level': 1, 'people': 5, 'percent': 30, 'perSend': 0.78, 'perMonth': 33.8},
          {'level': 2, 'people': 25, 'percent': 20, 'perSend': 0.52, 'perMonth': 112.67},
          {'level': 3, 'people': 125, 'percent': 10, 'perSend': 0.26, 'perMonth': 281.67},
        ],
        'people': 155, 'week': 98.8, 'month': 428.14, 'year': 5137.68,
      },
    };
    await _show(tester, const InviteScreen(username: 'johnkanduki'));
    final title = find.text('Les 6 niveaux qui vous rapportent');
    await tester.scrollUntilVisible(title, 400, scrollable: find.byType(Scrollable).first);
    await tester.pump();
    final y = tester.getTopLeft(title).dy;
    await tester.drag(find.byType(Scrollable).first, Offset(0, -(y - (_top / _dpr + 50))));
    await _settle(tester);
    await _save(tester, '2-six-niveaux');
  });

  testWidgets('3 Envoyer', (tester) async {
    await _show(tester, SendRecipientScreen(senderCountry: congo, recents: const [grace, kofi, amina]));
    await tester.enterText(find.byType(TextField).first, 'gracembuyi');
    await _settle(tester);
    FocusManager.instance.primaryFocus?.unfocus();
    await _settle(tester);
    await _save(tester, '3-envoyer');
  });

  testWidgets('4 Mon code QR', (tester) async {
    await _show(
      tester,
      MyQrScreen(
        me: Recipient(
          username: me.username,
          fullName: me.fullName,
          countryCode: me.countryCode,
          phone: me.phone,
          certified: true,
          photoFile: _photo.isEmpty ? null : _photo,
        ),
      ),
    );
    await _save(tester, '4-mon-code-qr');
  });

  testWidgets('5 Il recoit', (tester) async {
    fetchQuote = ({required recipient, required currency, required amount}) async => Quote(
      currency: 'USD', fee: 6.5, paid: 106.5, destCurrency: 'USD',
      destAmount: double.tryParse(amount) ?? 100, rate: 1,
    );
    appRules.value = const AppRules(serviceFeeRate: 0.065);
    await _show(tester, SendAmountScreen(recipient: grace, senderCountry: congo, balances: const {'USD': 1248.75}));
    await tester.enterText(find.byType(TextField).first, '100');
    await _settle(tester);
    FocusManager.instance.primaryFocus?.unfocus();
    await _settle(tester);
    await _save(tester, '5-il-recoit');
  });

  testWidgets('6 Commissions', (tester) async {
    Map<String, dynamic> c(String amount, String level, int percent, String sender, int daysAgo, String paid) => {
      'kind': 'commission', 'amount': amount, 'status': 'available',
      'createdAt': DateTime.now().subtract(Duration(days: daysAgo, hours: 2)).toUtc().toIso8601String(),
      'commission': {
        'level': level, 'percent': percent, 'sharedWith': 1, 'pool': '2.60', 'sender': sender,
        'reference': 'ZP-${sender.hashCode.toRadixString(16).toUpperCase().padLeft(8, '0').substring(0, 8)}',
        'paid': paid, 'paidCurrency': 'USD', 'received': '100.00', 'receivedCurrency': 'USD',
      },
    };
    loadCommissionHistory = () async => {
      'available': '186.40',
      'pending': '3.12',
      'earned': '312.75',
      'withdrawn': '126.35',
      'items': [
        c('0.78', 'down1', 30, 'gracembuyi', 0, '106.50'),
        c('0.52', 'down2', 20, 'kofi', 0, '106.50'),
        c('0.52', 'up1', 20, 'amina', 1, '106.50'),
        c('0.26', 'down3', 10, 'david.k', 1, '106.50'),
        c('0.31', 'up2', 12, 'mireille.k', 2, '106.50'),
        c('0.78', 'down1', 30, 'patrick.m', 3, '106.50'),
      ],
    };
    await _show(tester, const CommissionHistoryScreen(username: 'johnkanduki'));
    await _save(tester, '6-commissions');
  });
}

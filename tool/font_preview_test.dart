// Font preview (never shipped): the home page and the send page drawn with
// another font and a smaller text size, to compare. Run:
//   flutter test tool/font_preview_test.dart --dart-define=OUT=<folder>
//     --dart-define=FONTDIR=<folder> --dart-define=FONT=Manrope --dart-define=SCALE=0.9
// FONT empty: the current Inter. The candidate is loaded under the name
// "Inter", so every screen uses it without any change in the app.
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zawapay_app/core/account/app_rules.dart';
import 'package:zawapay_app/core/countries/country.dart';
import 'package:zawapay_app/core/theme/app_theme.dart';
import 'package:zawapay_app/features/history/transfer.dart';
import 'package:zawapay_app/features/home/home_screen.dart';
import 'package:zawapay_app/features/send/recipient.dart';
import 'package:zawapay_app/features/send/send_amount_screen.dart';
import 'package:zawapay_app/core/account/destinations.dart';
import 'package:zawapay_app/l10n/app_localizations.dart';

const _out = String.fromEnvironment('OUT');
const _dir = String.fromEnvironment('FONTDIR');
const _font = String.fromEnvironment('FONT');
final _scale = double.parse(const String.fromEnvironment('SCALE', defaultValue: '1'));
final _shot = GlobalKey();

Future<void> _fonts() async {
  final family = FontLoader('Inter');
  if (_font.isEmpty) {
    for (final w in ['Regular', 'Medium', 'SemiBold', 'Bold']) {
      family.addFont(rootBundle.load('assets/fonts/Inter-$w.ttf'));
    }
  } else {
    for (final w in [400, 500, 600, 700, 800]) {
      family.addFont(File('$_dir/$_font-$w.ttf').readAsBytes().then((b) => ByteData.view(b.buffer)));
    }
  }
  await family.load();
  final root = Platform.environment['FLUTTER_ROOT'] ?? '/Users/kanduki/development/flutter';
  final icons = FontLoader('MaterialIcons')
    ..addFont(File('$root/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf')
        .readAsBytes()
        .then((b) => ByteData.view(b.buffer)));
  await icons.load();
}

Future<void> _show(WidgetTester tester, Widget home) async {
  tester.view.physicalSize = const Size(1206, 2622);
  tester.view.devicePixelRatio = 3;
  tester.view.padding = const FakeViewPadding(top: 186, bottom: 102);
  tester.view.viewPadding = const FakeViewPadding(top: 186, bottom: 102);
  await tester.pumpWidget(
    RepaintBoundary(
      key: _shot,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        locale: const Locale('fr'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(_scale)),
          child: child!,
        ),
        home: home,
      ),
    ),
  );
  for (var i = 0; i < 6; i++) {
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 150)));
    await tester.pump(const Duration(milliseconds: 400));
  }
}

Future<void> _save(WidgetTester tester, String name) async {
  await tester.runAsync(() async {
    final b = _shot.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final img = await b.toImage(pixelRatio: 3);
    final bytes = await img.toByteData(format: ui.ImageByteFormat.png);
    File('$_out/$name.png')
      ..createSync(recursive: true)
      ..writeAsBytesSync(bytes!.buffer.asUint8List());
  });
}

void main() {
  const grace = Recipient(username: 'gracembuyi', fullName: 'Grace Mbuyi', countryCode: 'CD', phone: '812345678', certified: true);
  const kofi = Recipient(username: 'kofi', fullName: 'Kofi Mensah', countryCode: 'CI', phone: '0701020304', certified: true);
  setUpAll(_fonts);

  testWidgets('home', (tester) async {
    DateTime ago(int m) => DateTime.now().subtract(Duration(minutes: m));
    Transfer t(String id, Recipient r, double v, int m, {bool out = true}) => Transfer(
      id: id, reference: 'ZP-$id', other: r, outgoing: out, received: v, fee: v * 0.065, currency: 'USD',
      status: TransferStatus.success, sentAt: ago(m), paidAt: ago(m - 1), confirmedAt: ago(m - 2));
    await _show(tester, HomeScreen(
      firstName: 'John', lastName: 'Kanduki', username: 'johnkanduki', certified: true, countryCode: 'CD',
      balances: const {'USD': 1248.75},
      transfers: [t('A1', grace, 150, 25), t('A2', kofi, 80, 180, out: false)],
    ));
    await _save(tester, 'home');
  });

  testWidgets('send', (tester) async {
    final congo = supportedCountries.firstWhere((c) => c.isoCode == 'CD');
    fetchQuote = ({required recipient, required currency, required amount}) async => Quote(
      currency: 'USD', fee: 6.5, paid: 106.5, destCurrency: 'USD', destAmount: double.tryParse(amount) ?? 100, rate: 1);
    appRules.value = const AppRules(serviceFeeRate: 0.065);
    await _show(tester, SendAmountScreen(recipient: grace, senderCountry: congo, balances: const {'USD': 1248.75}));
    await tester.enterText(find.byType(TextField).first, '100');
    FocusManager.instance.primaryFocus?.unfocus();
    for (var i = 0; i < 4; i++) {
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 150)));
      await tester.pump(const Duration(milliseconds: 400));
    }
    await _save(tester, 'send');
  });
}

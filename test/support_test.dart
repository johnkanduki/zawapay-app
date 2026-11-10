import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zawapay_app/core/widgets/top_notice.dart';
import 'package:zawapay_app/features/history/transfer.dart';
import 'package:zawapay_app/features/history/transfer_detail_screen.dart';
import 'package:zawapay_app/l10n/app_localizations.dart';

void main() {
  Widget app(Widget home) => MaterialApp(
    locale: const Locale('fr'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: home,
  );

  testWidgets('"Contact support" opens Contact us with Sapotti recommended', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1206, 2622);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      app(TransferDetailScreen(transfer: demoTransfers.first)),
    );
    final help = find.text('Contacter le support');
    await tester.ensureVisible(help);
    await tester.pumpAndSettle();
    await tester.tap(help);
    await tester.pumpAndSettle();

    expect(find.text('Nous contacter'), findsOneWidget);
    expect(find.text('Sapotti'), findsOneWidget);
    expect(find.text('Recommandé'), findsOneWidget);
    expect(find.text('E-mail'), findsOneWidget);
    expect(
      find.text('Nous répondons généralement en moins d’une heure'),
      findsOneWidget,
    );
    expect(find.text('WhatsApp'), findsNothing);
  });

  testWidgets('Messages come down from the top, then leave', (tester) async {
    await tester.pumpWidget(
      app(
        Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: TextButton(
                onPressed: () => showTopNotice(context, 'Copié'),
                child: const Text('go'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('go'));
    await tester.pumpAndSettle();
    final notice = tester.getRect(find.text('Copié'));
    // In the top part of the screen, never at the bottom.
    expect(notice.top, lessThan(200));

    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
    expect(find.text('Copié'), findsNothing);
  });
}

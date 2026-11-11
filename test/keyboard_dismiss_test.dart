import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zawapay_app/core/widgets/keyboard_dismisser.dart';

void main() {
  testWidgets('A tap anywhere outside a field closes the keyboard', (
    tester,
  ) async {
    const field = Key('field');
    const sheetField = Key('sheetField');
    final node = FocusNode();
    final sheetNode = FocusNode();
    addTearDown(node.dispose);
    addTearDown(sheetNode.dispose);
    var cardTaps = 0;

    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => KeyboardDismisser(child: child!),
        home: Builder(
          builder: (context) => Scaffold(
            body: ListView(
              children: [
                TextField(key: field, focusNode: node),
                // A card that handles taps itself (used to swallow them).
                InkWell(
                  onTap: () => cardTaps++,
                  child: const SizedBox(height: 200, child: Text('Carte')),
                ),
                const SizedBox(height: 1500),
                TextButton(
                  onPressed: () => showModalBottomSheet<void>(
                    context: context,
                    builder: (_) => Padding(
                      padding: const EdgeInsets.all(40),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextField(key: sheetField, focusNode: sheetNode),
                          const SizedBox(height: 120, child: Text('Vide')),
                        ],
                      ),
                    ),
                  ),
                  child: const Text('Feuille'),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    // Tap on the field: typing.
    await tester.tap(find.byKey(field));
    await tester.pump();
    expect(node.hasFocus, isTrue);

    // Tap on the field again: still typing.
    await tester.tap(find.byKey(field));
    await tester.pump();
    expect(node.hasFocus, isTrue);

    // Tap on a card that handles taps: the card works AND the keyboard goes.
    await tester.tap(find.text('Carte'));
    await tester.pump();
    expect(cardTaps, 1);
    expect(node.hasFocus, isFalse);

    // Scrolling the list does not close the keyboard.
    await tester.tap(find.byKey(field));
    await tester.pump();
    await tester.drag(find.byType(ListView), const Offset(0, -30));
    await tester.pump();
    expect(node.hasFocus, isTrue);

    // In a bottom sheet too.
    await tester.dragUntilVisible(
      find.text('Feuille'),
      find.byType(ListView),
      const Offset(0, -300),
    );
    await tester.tap(find.text('Feuille'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(sheetField));
    await tester.pump();
    expect(sheetNode.hasFocus, isTrue);
    await tester.tap(find.text('Vide'));
    await tester.pump();
    expect(sheetNode.hasFocus, isFalse);
  });
}

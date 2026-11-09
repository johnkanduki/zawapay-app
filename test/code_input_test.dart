import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zawapay_app/core/widgets/code_input.dart';

void main() {
  testWidgets('Tapping the boxes focuses the field and digits are kept', (
    tester,
  ) async {
    String value = '';
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(24),
            child: CodeInput(
              length: 4,
              obscure: true,
              onChanged: (v) => value = v,
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byType(CodeInput));
    await tester.pump();
    final field = tester.widget<TextField>(find.byType(TextField));
    expect(field.focusNode!.hasFocus, isTrue);

    await tester.enterText(find.byType(TextField), '12a345');
    await tester.pump();
    expect(value, '1234');
  });
}

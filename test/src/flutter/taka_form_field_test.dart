import 'package:bd_taka/bd_taka.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _pump(WidgetTester tester, Widget field) => tester.pumpWidget(
      MaterialApp(home: Scaffold(body: Form(child: field))),
    );

String _text(WidgetTester tester) =>
    tester.widget<TextField>(find.byType(TextField)).controller!.text;

void main() {
  group('TakaFormField', () {
    testWidgets('formats typed digits and reports a Taka', (tester) async {
      Taka? reported;
      await _pump(tester, TakaFormField(onChanged: (t) => reported = t));

      await tester.enterText(find.byType(TextField), '1234567.5');
      expect(_text(tester), '12,34,567.5');
      expect(reported, Taka.fromPaisa(123456750));

      await tester.enterText(find.byType(TextField), '');
      expect(reported, isNull);
    });

    testWidgets('accepts Bengali digits', (tester) async {
      Taka? reported;
      await _pump(
        tester,
        TakaFormField(bengaliDigits: true, onChanged: (t) => reported = t),
      );

      await tester.enterText(find.byType(TextField), '১২৩৪৫');
      expect(_text(tester), '১২,৩৪৫');
      expect(reported, Taka(12345));
    });

    testWidgets('keeps the previous text when an edit is rejected', (
      tester,
    ) async {
      await _pump(tester, const TakaFormField());

      await tester.enterText(find.byType(TextField), '12.34');
      await tester.enterText(find.byType(TextField), '12.345');
      expect(_text(tester), '12.34');
    });

    testWidgets('shows a ৳ prefix unless told not to', (tester) async {
      await _pump(tester, const TakaFormField());
      expect(find.text('৳ '), findsOneWidget);

      await _pump(tester, const TakaFormField(showSymbol: false));
      expect(find.text('৳ '), findsNothing);
    });

    testWidgets('keeps a prefix from the decoration', (tester) async {
      await _pump(
        tester,
        const TakaFormField(
          decoration: InputDecoration(prefixText: 'BDT '),
        ),
      );
      expect(find.text('BDT '), findsOneWidget);
      expect(find.text('৳ '), findsNothing);
    });

    testWidgets('shows an initial value', (tester) async {
      await _pump(
        tester,
        TakaFormField(initialValue: Taka.fromPaisa(123450)),
      );
      expect(_text(tester), '1,234.50');

      await _pump(
        tester,
        TakaFormField(
          key: UniqueKey(),
          initialValue: Taka(1234567),
          bengaliDigits: true,
        ),
      );
      expect(_text(tester), '১২,৩৪,৫৬৭');
    });

    testWidgets('validates and saves the parsed amount', (tester) async {
      final formKey = GlobalKey<FormState>();
      Taka? saved;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(
              key: formKey,
              child: TakaFormField(
                validator: (amount) =>
                    amount == null || amount.isZero ? 'Enter an amount' : null,
                onSaved: (amount) => saved = amount,
              ),
            ),
          ),
        ),
      );

      expect(formKey.currentState!.validate(), isFalse);
      await tester.pump();
      expect(find.text('Enter an amount'), findsOneWidget);

      await tester.enterText(find.byType(TextField), '250');
      expect(formKey.currentState!.validate(), isTrue);
      formKey.currentState!.save();
      expect(saved, Taka(250));
    });

    testWidgets('uses a decimal keyboard, signed only for negatives', (
      tester,
    ) async {
      await _pump(tester, const TakaFormField());
      expect(
        tester.widget<TextField>(find.byType(TextField)).keyboardType,
        const TextInputType.numberWithOptions(decimal: true),
      );

      await _pump(tester, const TakaFormField(allowNegative: true));
      expect(
        tester.widget<TextField>(find.byType(TextField)).keyboardType,
        const TextInputType.numberWithOptions(decimal: true, signed: true),
      );
    });

    testWidgets('works with a controller', (tester) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);
      await _pump(tester, TakaFormField(controller: controller));

      await tester.enterText(find.byType(TextField), '100000');
      expect(controller.text, '1,00,000');
    });

    test('rejects both a controller and an initial value', () {
      expect(
        () => TakaFormField(
          controller: TextEditingController(),
          initialValue: Taka.zero,
        ),
        throwsAssertionError,
      );
    });
  });
}

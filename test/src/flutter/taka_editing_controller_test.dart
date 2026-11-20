import 'package:bd_taka/bd_taka.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// Pumps a bare [EditableText], the widget every text field builds on, so the
/// test needs neither Material nor Cupertino.
Future<void> _pumpField(
  WidgetTester tester,
  TakaEditingController controller,
) async {
  final focusNode = FocusNode();
  addTearDown(focusNode.dispose);
  await tester.pumpWidget(
    MediaQuery(
      data: const MediaQueryData(),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: EditableText(
          controller: controller,
          focusNode: focusNode,
          inputFormatters: [controller.formatter],
          style: const TextStyle(fontSize: 14),
          cursorColor: const Color(0xFF000000),
          backgroundCursorColor: const Color(0xFF888888),
        ),
      ),
    ),
  );
}

void main() {
  group('TakaEditingController', () {
    test('starts empty without an amount', () {
      final controller = TakaEditingController();
      addTearDown(controller.dispose);
      expect(controller.text, '');
      expect(controller.taka, isNull);
    });

    test('shows an initial amount', () {
      final whole = TakaEditingController(taka: Taka(1250));
      final withPaisa = TakaEditingController(taka: Taka.fromPaisa(99950));
      final bengali = TakaEditingController(
        taka: Taka(1234567),
        bengaliDigits: true,
      );
      addTearDown(whole.dispose);
      addTearDown(withPaisa.dispose);
      addTearDown(bengali.dispose);

      expect(whole.text, '1,250');
      expect(withPaisa.text, '999.50');
      expect(bengali.text, '১২,৩৪,৫৬৭');
      expect(bengali.taka, Taka(1234567));
    });

    test('sets the amount with the cursor at the end', () {
      final controller = TakaEditingController();
      addTearDown(controller.dispose);

      controller.taka = Taka(100000);
      expect(controller.text, '1,00,000');
      expect(controller.selection, const TextSelection.collapsed(offset: 8));
      expect(controller.taka, Taka(100000));

      controller.taka = null;
      expect(controller.text, '');
      expect(controller.taka, isNull);
    });

    test('reads in-progress text', () {
      final controller = TakaEditingController();
      addTearDown(controller.dispose);
      controller.text = '12.';
      expect(controller.taka, Taka(12));
      controller.text = '-';
      expect(controller.taka, isNull);
    });

    test('gives a formatter with the same options', () {
      final controller = TakaEditingController(
        grouping: Grouping.international,
        bengaliDigits: true,
        allowNegative: true,
      );
      addTearDown(controller.dispose);
      final formatter = controller.formatter;
      expect(formatter.grouping, Grouping.international);
      expect(formatter.bengaliDigits, isTrue);
      expect(formatter.allowNegative, isTrue);
    });

    testWidgets('formats typed text in a field', (tester) async {
      final controller = TakaEditingController();
      addTearDown(controller.dispose);
      await _pumpField(tester, controller);

      await tester.enterText(find.byType(EditableText), '1234567.5');
      expect(controller.text, '12,34,567.5');
      expect(controller.taka, Taka.fromPaisa(123456750));
    });

    testWidgets('accepts Bengali digits in a field', (tester) async {
      final controller = TakaEditingController(bengaliDigits: true);
      addTearDown(controller.dispose);
      await _pumpField(tester, controller);

      await tester.enterText(find.byType(EditableText), '১২৩৪৫');
      expect(controller.text, '১২,৩৪৫');
      expect(controller.taka, Taka(12345));
    });

    testWidgets('keeps the previous text when an edit is rejected', (
      tester,
    ) async {
      final controller = TakaEditingController();
      addTearDown(controller.dispose);
      await _pumpField(tester, controller);

      await tester.enterText(find.byType(EditableText), '12.34');
      await tester.enterText(find.byType(EditableText), '12.345');
      expect(controller.text, '12.34');
      expect(controller.taka, Taka.fromPaisa(1234));
    });
  });
}

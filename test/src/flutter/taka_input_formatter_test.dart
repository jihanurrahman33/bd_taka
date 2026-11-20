import 'package:bd_taka/bd_taka.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

TextEditingValue _value(String text, [int? cursor]) => TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: cursor ?? text.length),
    );

void main() {
  group('TakaInputFormatter', () {
    const formatter = TakaInputFormatter();

    test('groups the text and keeps the cursor after the same digit', () {
      final result = formatter.formatEditUpdate(
        _value('1,234'),
        _value('1,2345'),
      );
      expect(result.text, '12,345');
      expect(result.selection, const TextSelection.collapsed(offset: 6));
    });

    test('keeps the cursor in place for an edit in the middle', () {
      // "12,34,567" with 9 typed after "12,".
      final result = formatter.formatEditUpdate(
        _value('12,34,567', 3),
        _value('12,934,567', 4),
      );
      expect(result.text, '1,29,34,567');
      expect(result.selection.baseOffset, 4);
    });

    test('keeps the old value when an edit is rejected', () {
      final old = _value('12.34');
      expect(formatter.formatEditUpdate(old, _value('12.345')), old);
      expect(formatter.formatEditUpdate(old, _value('12.3.4')), old);
    });

    test('deletes the digit before a comma on backspace', () {
      final result = formatter.formatEditUpdate(
        _value('1,234', 2),
        _value('1234', 1),
      );
      expect(result.text, '234');
      expect(result.selection.baseOffset, 0);
    });

    test('leaves composing text alone', () {
      const composing = TextEditingValue(
        text: '12৩',
        selection: TextSelection.collapsed(offset: 3),
        composing: TextRange(start: 2, end: 3),
      );
      expect(formatter.formatEditUpdate(_value('12'), composing), composing);
    });

    test('treats an invalid selection as a cursor at the end', () {
      final result = formatter.formatEditUpdate(
        _value(''),
        const TextEditingValue(text: '1234'),
      );
      expect(result.text, '1,234');
      expect(result.selection.baseOffset, 5);
    });

    test('honours its options', () {
      const custom = TakaInputFormatter(
        grouping: Grouping.international,
        bengaliDigits: true,
        allowNegative: true,
      );
      expect(
        custom.formatEditUpdate(_value(''), _value('-1234567')).text,
        '-১,২৩৪,৫৬৭',
      );
      expect(
        formatter.formatEditUpdate(_value(''), _value('-12')).text,
        '12',
      );
    });

    test('tryParse reads formatted and in-progress text', () {
      expect(
        TakaInputFormatter.tryParse('12,34,567.5'),
        Taka.fromPaisa(123456750),
      );
      expect(TakaInputFormatter.tryParse('১২.'), Taka(12));
      expect(TakaInputFormatter.tryParse(''), isNull);
      expect(TakaInputFormatter.tryParse('-'), isNull);
    });
  });
}

import 'package:bd_taka/bd_taka.dart';
import 'package:bd_taka/src/input_editing.dart';
import 'package:flutter_test/flutter_test.dart';

/// Splits text written with a `|` for the cursor, such as `12|34`.
(String, int) _split(String marked) {
  final cursor = marked.indexOf('|');
  expect(cursor, isNot(-1), reason: 'No cursor in "$marked"');
  return (marked.replaceFirst('|', ''), cursor);
}

/// Reformats [marked] and returns the result with a `|` for the cursor, or
/// `null` when the edit is rejected.
String? _reformat(
  String marked, {
  Grouping grouping = Grouping.southAsian,
  bool bengaliDigits = false,
  bool allowNegative = false,
}) {
  final (text, cursor) = _split(marked);
  return reformatTakaInput(
    text,
    cursor,
    grouping: grouping,
    bengaliDigits: bengaliDigits,
    allowNegative: allowNegative,
  )?.toString();
}

/// Applies an edit from [before] to [after], both written with a `|`.
String? _edit(String before, String after) {
  final (oldText, oldCursor) = _split(before);
  final (newText, newCursor) = _split(after);
  return editTakaInput(
    oldText: oldText,
    oldCursor: oldCursor,
    newText: newText,
    newCursor: newCursor,
    grouping: Grouping.southAsian,
    bengaliDigits: false,
    allowNegative: false,
  )?.toString();
}

void main() {
  group('reformatTakaInput groups as you type', () {
    const cases = {
      '|': '|',
      '1|': '1|',
      '123|': '123|',
      '1234|': '1,234|',
      '12345|': '12,345|',
      '123456|': '1,23,456|',
      '1234567|': '12,34,567|',
      '12345678|': '1,23,45,678|',
    };
    for (final MapEntry(key: input, value: expected) in cases.entries) {
      test('$input -> $expected', () => expect(_reformat(input), expected));
    }

    test('uses international grouping when asked', () {
      expect(
        _reformat('1234567|', grouping: Grouping.international),
        '1,234,567|',
      );
      expect(_reformat('1234567|', grouping: Grouping.none), '1234567|');
    });
  });

  group('reformatTakaInput keeps the cursor after the same digit', () {
    test('in the middle of the number', () {
      expect(_reformat('12|34567'), '12|,34,567');
      expect(_reformat('1|234567'), '1|2,34,567');
    });

    test('after typing a digit in the middle', () {
      // "12,34,567" with 9 typed after "12,".
      expect(_reformat('12,9|34,567'), '1,29|,34,567');
    });

    test('after deleting a digit in the middle', () {
      // "12,34,567" with the 5 deleted.
      expect(_reformat('12,34,|67'), '1,23,4|67');
    });

    test('at the start', () {
      expect(_reformat('|1234567'), '|12,34,567');
    });
  });

  group('reformatTakaInput handles decimals', () {
    test('keeps a fraction of up to two digits as typed', () {
      expect(_reformat('1234.|'), '1,234.|');
      expect(_reformat('1234.5|'), '1,234.5|');
      expect(_reformat('1234.56|'), '1,234.56|');
    });

    test('turns a lone point into 0.', () {
      expect(_reformat('.|'), '0.|');
      expect(_reformat('.5|'), '0.5|');
      expect(_reformat('|.'), '|0.');
    });

    test('rejects a third decimal digit', () {
      expect(_reformat('1234.567|'), isNull);
      expect(_reformat('0.001|'), isNull);
    });

    test('rejects a second point', () {
      expect(_reformat('12.3.|'), isNull);
      expect(_reformat('1..|'), isNull);
    });
  });

  group('reformatTakaInput cleans the input', () {
    test('removes leading zeros but keeps one digit', () {
      expect(_reformat('007|'), '7|');
      expect(_reformat('05|'), '5|');
      expect(_reformat('0|'), '0|');
      expect(_reformat('00|'), '0|');
      expect(_reformat('0.5|'), '0.5|');
      expect(_reformat('0|07'), '|7');
    });

    test('drops letters, spaces, symbols and old separators', () {
      expect(_reformat('12a3|'), '123|');
      expect(_reformat('৳ 1250|'), '1,250|');
      expect(_reformat('1 2,3_4|'), '1,234|');
    });

    test('accepts Bengali digits and writes ASCII by default', () {
      expect(_reformat('১২৩৪|'), '1,234|');
      expect(_reformat('১2৩4|'), '1,234|');
    });

    test('writes Bengali digits when asked', () {
      expect(_reformat('1234567|', bengaliDigits: true), '১২,৩৪,৫৬৭|');
      expect(_reformat('১২৩৪.৫|', bengaliDigits: true), '১,২৩৪.৫|');
      expect(_reformat('12|34', bengaliDigits: true), '১,২|৩৪');
    });
  });

  group('reformatTakaInput handles the sign', () {
    test('drops a minus sign unless negatives are allowed', () {
      expect(_reformat('-12|'), '12|');
    });

    test('keeps a leading minus sign when allowed', () {
      expect(_reformat('-1234|', allowNegative: true), '-1,234|');
      expect(_reformat('-|', allowNegative: true), '-|');
      expect(_reformat('-|1234', allowNegative: true), '-|1,234');
      expect(_reformat('|-1234', allowNegative: true), '|-1,234');
    });

    test('ignores a minus sign after the first digit', () {
      expect(_reformat('1-2|', allowNegative: true), '12|');
    });
  });

  group('reformatTakaInput enforces the range', () {
    test('accepts the largest amount', () {
      expect(
        _reformat('90071992547409.91|'),
        '9,00,71,99,25,47,409.91|',
      );
    });

    test('rejects anything larger', () {
      expect(_reformat('90071992547409.92|'), isNull);
      expect(_reformat('900719925474099|'), isNull);
    });
  });

  group('editTakaInput', () {
    test('reformats an ordinary edit', () {
      expect(_edit('1,234|', '1,2345|'), '12,345|');
      expect(_edit('12,34,56|7', '12,34,5|7'), '1,23,45|7');
    });

    test('backspace over a comma deletes the digit before it', () {
      expect(_edit('1,|234', '1|234'), '|234');
      expect(_edit('12,34,|567', '12,34|567'), '1,23|,567');
    });

    test('forward delete over a comma deletes the digit after it', () {
      expect(_edit('1|,234', '1|234'), '1|34');
    });

    test('passes a rejected edit through as null', () {
      expect(_edit('1.23|', '1.234|'), isNull);
    });
  });

  group('paisaOfTakaInput', () {
    test('reads formatted text', () {
      expect(paisaOfTakaInput('12,34,567.5'), 123456750);
      expect(paisaOfTakaInput('১,২৩৪'), 123400);
      expect(paisaOfTakaInput('-1,234.05'), -123405);
    });

    test('accepts in-progress text', () {
      expect(paisaOfTakaInput('12.'), 1200);
      expect(paisaOfTakaInput('0.'), 0);
    });

    test('returns null when there is no amount', () {
      expect(paisaOfTakaInput(''), isNull);
      expect(paisaOfTakaInput('-'), isNull);
      expect(paisaOfTakaInput('abc'), isNull);
    });

    test('reads back everything reformatTakaInput writes', () {
      for (final raw in ['1', '1234567', '1234.5', '-98765.43', '০.৫']) {
        for (final bengaliDigits in [false, true]) {
          final edit = reformatTakaInput(
            raw,
            raw.length,
            grouping: Grouping.southAsian,
            bengaliDigits: bengaliDigits,
            allowNegative: true,
          )!;
          expect(paisaOfTakaInput(edit.text), isNotNull, reason: edit.text);
        }
      }
    });
  });
}

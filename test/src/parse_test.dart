import 'package:bd_taka/src/parse.dart';
import 'package:test/test.dart';

void main() {
  group('parsePaisa accepts', () {
    const valid = {
      // Plain, grouped and fractional digits.
      '0': 0,
      '5': 500,
      '1250': 125000,
      '1,250': 125000,
      '12,34,567': 123456700, // South Asian grouping
      '1,234,567': 123456700, // international grouping
      '12,34,567.50': 123456750,
      '1,234,567.50': 123456750,
      // A single fraction digit is tenths of a taka.
      '1.5': 150,
      '0.5': 50,
      '1.05': 105,
      '0.05': 5,
      '0.00': 0,
      // Markers, ignoring case.
      '৳1250': 125000,
      '৳ 1250': 125000,
      'Tk 1250': 125000,
      'tk.1250': 125000,
      'Tk. 1,250.00': 125000,
      'BDT 1,250.00': 125000,
      'bdt1250': 125000,
      // Signs.
      '-125.50': -12550,
      '-৳125.50': -12550,
      '-Tk 125.50': -12550,
      '-0': 0,
      // Bengali digits.
      '১,২৫০.৫০': 125050,
      '৳১২,৩৪,৫৬৭.৫০': 123456750,
      '-৳১২৫.৫০': -12550,
      // Surrounding whitespace is ignored.
      '  1250  ': 125000,
      '\t৳12.50\n': 1250,
      // The largest amount.
      '90071992547409.91': 9007199254740991,
      '-90071992547409.91': -9007199254740991,
    };
    for (final MapEntry(key: input, value: paisa) in valid.entries) {
      test(input.trim().isEmpty ? 'whitespace' : "'$input'", () {
        final result = parsePaisa(input);
        expect(result.error, isNull);
        expect(result.paisa, paisa);
      });
    }
  });

  group('parsePaisa rejects', () {
    const invalid = [
      '', // empty
      '   ',
      '-',
      '৳',
      'Tk',
      'abc',
      'NaN',
      'Infinity',
      // Too many decimals would lose paisa.
      '1.234',
      '১.২৩৪',
      // Missing digits around the point.
      '1.',
      '.5',
      '.',
      // Exponents and signs we do not accept.
      '1e3',
      '+5',
      '--5',
      '- 5',
      '৳-5', // the sign comes before the marker
      // Misplaced grouping.
      '1,25,0',
      '12,3456',
      '1,2,3',
      '1,2345',
      ',123',
      '123,',
      '12,34', // no valid grouping ends in two digits
      '1,00',
      '12,34,567,890',
      '1,234,56',
      '1,,234',
      // Other separators.
      '1 000',
      '1_000',
      '12 50',
      // Surrounding text.
      '5 Tk',
      '১২৫ টাকা',
      'Tkt5',
      'about 5',
      // Leading zeros.
      '007',
      '00.50',
      '01,234',
      // Mixed digit scripts.
      '১২3',
      '1২',
      // Out of range.
      '90071992547409.92',
      '-90071992547409.92',
      '99999999999999999999',
    ];
    for (final input in invalid) {
      test("'$input'", () {
        final result = parsePaisa(input);
        expect(result.paisa, isNull);
        expect(result.error, isNotNull);
      });
    }

    test('explains why', () {
      expect(parsePaisa('').error, contains('empty'));
      expect(parsePaisa('১২3').error, contains('mixes'));
      expect(parsePaisa('007').error, contains('leading zeros'));
      expect(parsePaisa('99999999999999999999').error, contains('larger'));
      expect(parsePaisa('1.234').error, contains('at most two decimals'));
    });
  });
}

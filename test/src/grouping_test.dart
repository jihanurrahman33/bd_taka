import 'package:bd_taka/src/grouping.dart';
import 'package:test/test.dart';

void main() {
  group('applyGrouping southAsian', () {
    const cases = {
      '0': '0',
      '5': '5',
      '99': '99',
      '999': '999',
      '1000': '1,000',
      '12345': '12,345',
      '99999': '99,999',
      '100000': '1,00,000', // one lakh
      '1234567': '12,34,567',
      '9999999': '99,99,999',
      '10000000': '1,00,00,000', // one crore
      '123456789': '12,34,56,789',
      '1234567890': '1,23,45,67,890',
      '9007199254740991': '9,00,71,99,25,47,40,991', // Taka.maxPaisa
    };
    for (final MapEntry(key: digits, value: expected) in cases.entries) {
      test('$digits -> $expected', () {
        expect(applyGrouping(digits, Grouping.southAsian), expected);
      });
    }
  });

  group('applyGrouping international', () {
    const cases = {
      '0': '0',
      '999': '999',
      '1000': '1,000',
      '100000': '100,000',
      '1234567': '1,234,567',
      '1234567890': '1,234,567,890',
    };
    for (final MapEntry(key: digits, value: expected) in cases.entries) {
      test('$digits -> $expected', () {
        expect(applyGrouping(digits, Grouping.international), expected);
      });
    }
  });

  test('applyGrouping none leaves digits alone', () {
    expect(applyGrouping('1234567', Grouping.none), '1234567');
  });
}

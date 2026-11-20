import 'package:bd_taka/src/digits.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('toBengaliDigits', () {
    test('converts every digit', () {
      expect(toBengaliDigits('0123456789'), '০১২৩৪৫৬৭৮৯');
    });

    test('leaves separators and other characters alone', () {
      expect(toBengaliDigits('12,34,567.50'), '১২,৩৪,৫৬৭.৫০');
      expect(toBengaliDigits('-৳ 5 Tk'), '-৳ ৫ Tk');
    });

    test('leaves existing Bengali digits and an empty string alone', () {
      expect(toBengaliDigits('১২৩'), '১২৩');
      expect(toBengaliDigits(''), '');
    });
  });

  group('fromBengaliDigits', () {
    test('converts every digit', () {
      expect(fromBengaliDigits('০১২৩৪৫৬৭৮৯'), '0123456789');
    });

    test('leaves separators and other characters alone', () {
      expect(fromBengaliDigits('১২,৩৪,৫৬৭.৫০'), '12,34,567.50');
      expect(fromBengaliDigits('-৳ ৫ Tk'), '-৳ 5 Tk');
    });

    test('is the inverse of toBengaliDigits', () {
      const text = '-12,34,567.50 and 0987';
      expect(fromBengaliDigits(toBengaliDigits(text)), text);
    });
  });

  group('digit detection', () {
    test('finds Bengali digits', () {
      expect(hasBengaliDigit('৳১২'), isTrue);
      expect(hasBengaliDigit('12'), isFalse);
      expect(hasBengaliDigit(''), isFalse);
    });

    test('finds ASCII digits', () {
      expect(hasAsciiDigit('৳12'), isTrue);
      expect(hasAsciiDigit('১২'), isFalse);
      expect(hasAsciiDigit(''), isFalse);
    });
  });
}

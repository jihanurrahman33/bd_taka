import 'package:bd_taka/src/digits.dart';
import 'package:test/test.dart';

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
}

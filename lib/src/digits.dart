/// The first Bengali digit, `০` (U+09E6).
const int _bengaliZero = 0x09E6;

/// Replaces every ASCII digit in [text] with its Bengali digit, leaving all
/// other characters unchanged.
///
/// `toBengaliDigits('12,34.50')` is `'১২,৩৪.৫০'`.
String toBengaliDigits(String text) {
  final buffer = StringBuffer();
  for (final unit in text.codeUnits) {
    final isAsciiDigit = unit >= 0x30 && unit <= 0x39;
    buffer.writeCharCode(isAsciiDigit ? _bengaliZero + (unit - 0x30) : unit);
  }
  return buffer.toString();
}

/// Replaces every Bengali digit in [text] with its ASCII digit, leaving all
/// other characters unchanged.
///
/// `fromBengaliDigits('১২,৩৪.৫০')` is `'12,34.50'`.
String fromBengaliDigits(String text) {
  final buffer = StringBuffer();
  for (final unit in text.codeUnits) {
    final isBengaliDigit = unit >= _bengaliZero && unit <= _bengaliZero + 9;
    buffer.writeCharCode(isBengaliDigit ? 0x30 + (unit - _bengaliZero) : unit);
  }
  return buffer.toString();
}

/// Whether [text] contains at least one Bengali digit.
bool hasBengaliDigit(String text) =>
    text.codeUnits.any((u) => u >= _bengaliZero && u <= _bengaliZero + 9);

/// Whether [text] contains at least one ASCII digit.
bool hasAsciiDigit(String text) =>
    text.codeUnits.any((u) => u >= 0x30 && u <= 0x39);

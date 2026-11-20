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

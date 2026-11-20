import 'digits.dart';

/// The largest number of paisa an amount can hold. Mirrors `Taka.maxPaisa`.
const int _maxPaisa = 9007199254740991;

/// An optional currency marker before the digits: `৳`, `Tk`, `Tk.` or `BDT`.
final RegExp _symbol = RegExp(r'^(৳|tk\.?|bdt)\s*', caseSensitive: false);

/// The digits of an amount, ASCII only, in one of three accepted layouts:
///
/// - plain digits (`1234567`),
/// - South Asian grouping (`12,34,567`),
/// - international grouping (`1,234,567`),
///
/// followed by an optional fraction of one or two digits.
final RegExp _amount = RegExp(
  r'^(\d+|\d{1,2}(?:,\d{2})*,\d{3}|\d{1,3}(?:,\d{3})+)(?:\.(\d{1,2}))?$',
);

/// The outcome of [parsePaisa]: either [paisa] or an [error] message.
typedef ParseResult = ({int? paisa, String? error});

ParseResult _fail(String message) => (paisa: null, error: message);

/// Parses [source] strictly into a whole number of paisa.
///
/// Accepts an optional leading `-`, an optional currency marker (`৳`, `Tk`,
/// `Tk.`, `BDT`, ignoring case), then ASCII or Bengali digits (not both) with
/// plain, South Asian or international grouping and an optional fraction of
/// one or two digits. A single fraction digit counts as tenths of a taka, so
/// `1.5` is 150 paisa.
///
/// Anything else is rejected instead of guessed: more than two decimals
/// (which would lose paisa), misplaced commas, leading zeros, exponents,
/// extra text, an empty string, and amounts outside the range of an amount.
ParseResult parsePaisa(String source) {
  var text = source.trim();
  if (text.isEmpty) return _fail('The amount is empty.');

  var negative = false;
  if (text.startsWith('-')) {
    negative = true;
    text = text.substring(1);
  }

  text = text.replaceFirst(_symbol, '');

  final bengali = hasBengaliDigit(text);
  if (bengali && hasAsciiDigit(text)) {
    return _fail('The amount mixes Bengali and ASCII digits.');
  }
  if (bengali) text = fromBengaliDigits(text);

  final match = _amount.firstMatch(text);
  if (match == null) {
    return _fail(
      'Not a valid taka amount. Expected digits with optional grouping and at '
      'most two decimals, such as 1250, 12,34,567.50 or ৳১২৫.৫০.',
    );
  }

  final whole = match.group(1)!.replaceAll(',', '');
  if (whole.length > 1 && whole.startsWith('0')) {
    return _fail('The amount has leading zeros.');
  }

  // A single fraction digit is tenths of a taka: ".5" is 50 paisa.
  final fraction = (match.group(2) ?? '').padRight(2, '0');
  final paisa =
      BigInt.parse(whole) * BigInt.from(100) + BigInt.parse('0$fraction');

  if (paisa > BigInt.from(_maxPaisa)) {
    return _fail('The amount is larger than the largest supported amount.');
  }
  return (paisa: negative ? -paisa.toInt() : paisa.toInt(), error: null);
}

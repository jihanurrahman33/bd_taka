const List<String> _ones = [
  'Zero',
  'One',
  'Two',
  'Three',
  'Four',
  'Five',
  'Six',
  'Seven',
  'Eight',
  'Nine',
  'Ten',
  'Eleven',
  'Twelve',
  'Thirteen',
  'Fourteen',
  'Fifteen',
  'Sixteen',
  'Seventeen',
  'Eighteen',
  'Nineteen',
];

const List<String> _tens = [
  '',
  '',
  'Twenty',
  'Thirty',
  'Forty',
  'Fifty',
  'Sixty',
  'Seventy',
  'Eighty',
  'Ninety',
];

/// Spells 0 to 99, hyphenating compounds: `Twenty-Five`.
String _below100(int n) {
  if (n < 20) return _ones[n];
  final tens = _tens[n ~/ 10];
  final ones = n % 10;
  return ones == 0 ? tens : '$tens-${_ones[ones]}';
}

/// Spells the non-negative whole number [n] with the South Asian scale:
/// thousand, lakh (100,000) and crore (10,000,000).
///
/// Above 99 crore the crore count is spelled the same way, so 100 crore is
/// `One Hundred Crore`. When [useAnd] is true, `and` comes before the last
/// two digits of any number above 100: `One Hundred and Five`.
String englishNumber(int n, {bool useAnd = true}) {
  assert(n >= 0, 'n must not be negative');
  if (n == 0) return _ones[0];

  final words = <String>[];

  final crore = n ~/ 10000000;
  if (crore > 0) words.add('${englishNumber(crore, useAnd: useAnd)} Crore');

  var rest = n % 10000000;
  final lakh = rest ~/ 100000;
  if (lakh > 0) words.add('${_below100(lakh)} Lakh');

  rest %= 100000;
  final thousand = rest ~/ 1000;
  if (thousand > 0) words.add('${_below100(thousand)} Thousand');

  rest %= 1000;
  final hundred = rest ~/ 100;
  if (hundred > 0) words.add('${_ones[hundred]} Hundred');

  final below = rest % 100;
  if (below > 0) {
    final connector = useAnd && words.isNotEmpty ? 'and ' : '';
    words.add('$connector${_below100(below)}');
  }

  return words.join(' ');
}

/// Spells [paisa], a signed whole number of paisa, as an amount of taka in
/// English.
///
/// Zero is `Zero Taka`, an amount below one taka is spelled in paisa alone,
/// and a negative amount starts with `Minus`. `Taka` and `Paisa` stay
/// singular, as currency names do. When [only] is true, `Only` closes the
/// text, as on a cheque.
String englishAmount(int paisa, {required bool only, required bool useAnd}) {
  final magnitude = paisa.abs();
  final whole = magnitude ~/ 100;
  final fraction = magnitude % 100;

  final parts = <String>[];
  if (whole > 0 || fraction == 0) {
    parts.add('${englishNumber(whole, useAnd: useAnd)} Taka');
  }
  if (fraction > 0) {
    final connector = whole > 0 ? 'and ' : '';
    parts.add('$connector${_below100(fraction)} Paisa');
  }

  final text = parts.join(' ');
  final signed = paisa < 0 ? 'Minus $text' : text;
  return only ? '$signed Only' : signed;
}

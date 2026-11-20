/// The Bangla words for 0 to 99, by number.
///
/// Every number below 100 has its own word and many are not built from
/// smaller parts (37 is সাঁইত্রিশ, 52 is বায়ান্ন), so they are listed in full.
/// The rows are the tens: 0x, 1x, 2x and so on.
const List<String> _below100 = [
  // 0x
  'শূন্য', 'এক', 'দুই', 'তিন', 'চার', 'পাঁচ', 'ছয়', 'সাত', 'আট', 'নয়', //
  // 1x
  'দশ', 'এগারো', 'বারো', 'তেরো', 'চৌদ্দ', 'পনেরো', 'ষোলো', 'সতেরো', //
  'আঠারো', 'উনিশ',
  // 2x
  'বিশ', 'একুশ', 'বাইশ', 'তেইশ', 'চব্বিশ', 'পঁচিশ', 'ছাব্বিশ', 'সাতাশ', //
  'আটাশ', 'ঊনত্রিশ',
  // 3x
  'ত্রিশ', 'একত্রিশ', 'বত্রিশ', 'তেত্রিশ', 'চৌত্রিশ', 'পঁয়ত্রিশ', 'ছত্রিশ', //
  'সাঁইত্রিশ', 'আটত্রিশ', 'ঊনচল্লিশ',
  // 4x
  'চল্লিশ', 'একচল্লিশ', 'বিয়াল্লিশ', 'তেতাল্লিশ', 'চুয়াল্লিশ', //
  'পঁয়তাল্লিশ', 'ছেচল্লিশ', 'সাতচল্লিশ', 'আটচল্লিশ', 'ঊনপঞ্চাশ',
  // 5x
  'পঞ্চাশ', 'একান্ন', 'বায়ান্ন', 'তিপ্পান্ন', 'চুয়ান্ন', 'পঞ্চান্ন', //
  'ছাপ্পান্ন', 'সাতান্ন', 'আটান্ন', 'ঊনষাট',
  // 6x
  'ষাট', 'একষট্টি', 'বাষট্টি', 'তেষট্টি', 'চৌষট্টি', 'পঁয়ষট্টি', 'ছেষট্টি', //
  'সাতষট্টি', 'আটষট্টি', 'ঊনসত্তর',
  // 7x
  'সত্তর', 'একাত্তর', 'বাহাত্তর', 'তিয়াত্তর', 'চুয়াত্তর', 'পঁচাত্তর', //
  'ছিয়াত্তর', 'সাতাত্তর', 'আটাত্তর', 'ঊনআশি',
  // 8x
  'আশি', 'একাশি', 'বিরাশি', 'তিরাশি', 'চুরাশি', 'পঁচাশি', 'ছিয়াশি', //
  'সাতাশি', 'আটাশি', 'ঊননব্বই',
  // 9x
  'নব্বই', 'একানব্বই', 'বিরানব্বই', 'তিরানব্বই', 'চুরানব্বই', 'পঁচানব্বই', //
  'ছিয়ানব্বই', 'সাতানব্বই', 'আটানব্বই', 'নিরানব্বই',
];

/// Spells the non-negative whole number [n] in Bangla with the South Asian
/// scale: হাজার (thousand), লক্ষ (lakh, 100,000) and কোটি (crore, 10,000,000).
///
/// Hundreds are written as the digit word plus শো (`পাঁচশো`). Above 99 crore
/// the crore count is spelled the same way, so 100 crore is `একশো কোটি`.
String banglaNumber(int n) {
  assert(n >= 0, 'n must not be negative');
  if (n == 0) return _below100[0];

  final words = <String>[];

  final crore = n ~/ 10000000;
  if (crore > 0) words.add('${banglaNumber(crore)} কোটি');

  var rest = n % 10000000;
  final lakh = rest ~/ 100000;
  if (lakh > 0) words.add('${_below100[lakh]} লক্ষ');

  rest %= 100000;
  final thousand = rest ~/ 1000;
  if (thousand > 0) words.add('${_below100[thousand]} হাজার');

  rest %= 1000;
  final hundred = rest ~/ 100;
  if (hundred > 0) words.add('${_below100[hundred]}শো');

  final below = rest % 100;
  if (below > 0) words.add(_below100[below]);

  return words.join(' ');
}

/// Spells [paisa], a signed whole number of paisa, as an amount of taka in
/// Bangla.
///
/// Zero is `শূন্য টাকা`, an amount below one taka is spelled in পয়সা alone,
/// and a negative amount starts with `ঋণাত্মক`. When [only] is true, `মাত্র`
/// closes the text, as on a cheque.
String banglaAmount(int paisa, {required bool only}) {
  final magnitude = paisa.abs();
  final whole = magnitude ~/ 100;
  final fraction = magnitude % 100;

  final parts = <String>[];
  if (whole > 0 || fraction == 0) {
    parts.add('${banglaNumber(whole)} টাকা');
  }
  if (fraction > 0) {
    parts.add('${_below100[fraction]} পয়সা');
  }

  final text = parts.join(' ');
  final signed = paisa < 0 ? 'ঋণাত্মক $text' : text;
  return only ? '$signed মাত্র' : signed;
}

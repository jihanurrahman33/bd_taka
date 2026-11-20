import 'dart:math';

import 'package:bd_taka/src/words_bn.dart';
import 'package:flutter_test/flutter_test.dart';

/// The table approved for 0 to 99, in the same grid it was reviewed in: rows
/// are the tens, columns are the ones. It is typed out here on purpose, so an
/// accidental edit to a word in the library fails a test.
const List<List<String>> _approved = [
  ['শূন্য', 'এক', 'দুই', 'তিন', 'চার', 'পাঁচ', 'ছয়', 'সাত', 'আট', 'নয়'],
  [
    'দশ', 'এগারো', 'বারো', 'তেরো', 'চৌদ্দ',
    'পনেরো', 'ষোলো', 'সতেরো', 'আঠারো', 'উনিশ', //
  ],
  [
    'বিশ', 'একুশ', 'বাইশ', 'তেইশ', 'চব্বিশ',
    'পঁচিশ', 'ছাব্বিশ', 'সাতাশ', 'আটাশ', 'ঊনত্রিশ', //
  ],
  [
    'ত্রিশ', 'একত্রিশ', 'বত্রিশ', 'তেত্রিশ', 'চৌত্রিশ',
    'পঁয়ত্রিশ', 'ছত্রিশ', 'সাঁইত্রিশ', 'আটত্রিশ', 'ঊনচল্লিশ', //
  ],
  [
    'চল্লিশ', 'একচল্লিশ', 'বিয়াল্লিশ', 'তেতাল্লিশ', 'চুয়াল্লিশ',
    'পঁয়তাল্লিশ', 'ছেচল্লিশ', 'সাতচল্লিশ', 'আটচল্লিশ', 'ঊনপঞ্চাশ', //
  ],
  [
    'পঞ্চাশ', 'একান্ন', 'বায়ান্ন', 'তিপ্পান্ন', 'চুয়ান্ন',
    'পঞ্চান্ন', 'ছাপ্পান্ন', 'সাতান্ন', 'আটান্ন', 'ঊনষাট', //
  ],
  [
    'ষাট', 'একষট্টি', 'বাষট্টি', 'তেষট্টি', 'চৌষট্টি',
    'পঁয়ষট্টি', 'ছেষট্টি', 'সাতষট্টি', 'আটষট্টি', 'ঊনসত্তর', //
  ],
  [
    'সত্তর', 'একাত্তর', 'বাহাত্তর', 'তিয়াত্তর', 'চুয়াত্তর',
    'পঁচাত্তর', 'ছিয়াত্তর', 'সাতাত্তর', 'আটাত্তর', 'ঊনআশি', //
  ],
  [
    'আশি', 'একাশি', 'বিরাশি', 'তিরাশি', 'চুরাশি',
    'পঁচাশি', 'ছিয়াশি', 'সাতাশি', 'আটাশি', 'ঊননব্বই', //
  ],
  [
    'নব্বই', 'একানব্বই', 'বিরানব্বই', 'তিরানব্বই', 'চুরানব্বই',
    'পঁচানব্বই', 'ছিয়ানব্বই', 'সাতানব্বই', 'আটানব্বই', 'নিরানব্বই', //
  ],
];

final List<String> _table = [for (final row in _approved) ...row];

void main() {
  group('banglaNumber', () {
    test('the approved table has exactly 100 distinct words', () {
      expect(_approved.length, 10);
      expect(_approved.every((row) => row.length == 10), isTrue);
      expect(_table.toSet().length, 100);
    });

    test('spells every number from 0 to 99 as approved', () {
      for (var i = 0; i < 100; i++) {
        expect(banglaNumber(i), _table[i], reason: '$i');
      }
    });

    const cases = {
      100: 'একশো',
      101: 'একশো এক',
      125: 'একশো পঁচিশ',
      200: 'দুইশো',
      500: 'পাঁচশো',
      999: 'নয়শো নিরানব্বই',
      1000: 'এক হাজার',
      1050: 'এক হাজার পঞ্চাশ',
      1250: 'এক হাজার দুইশো পঞ্চাশ',
      99999: 'নিরানব্বই হাজার নয়শো নিরানব্বই',
      100000: 'এক লক্ষ',
      1234567: 'বারো লক্ষ চৌত্রিশ হাজার পাঁচশো সাতষট্টি',
      10000000: 'এক কোটি',
      123456789: 'বারো কোটি চৌত্রিশ লক্ষ ছাপ্পান্ন হাজার সাতশো ঊননব্বই',
      // From 100 crore the crore count is spelled the same way.
      1000000000: 'একশো কোটি',
      1050000000: 'একশো পাঁচ কোটি',
      // 9007199 crore and 2547409.
      90071992547409: 'নব্বই লক্ষ সাত হাজার একশো নিরানব্বই কোটি '
          'পঁচিশ লক্ষ সাতচল্লিশ হাজার চারশো নয়',
    };
    for (final MapEntry(key: n, value: words) in cases.entries) {
      test('$n', () => expect(banglaNumber(n), words));
    }

    test('is tidy: single spaces and only known words', () {
      final vocabulary = {
        ..._table,
        for (var d = 1; d <= 9; d++) '${_table[d]}শো',
        'হাজার',
        'লক্ষ',
        'কোটি',
      };
      for (var n = 0; n <= 20000; n++) {
        final words = banglaNumber(n);
        expect(words, words.trim(), reason: '$n');
        expect(words, isNot(contains('  ')), reason: '$n');
        for (final token in words.split(' ')) {
          expect(vocabulary, contains(token), reason: '$n: $words');
        }
      }
    });

    test('reads back as the same number (independent reference parser)', () {
      for (var n = 0; n <= 250000; n++) {
        expect(_wordsToInt(banglaNumber(n)), n, reason: '$n');
      }
      final random = Random(7);
      for (var i = 0; i < 3000; i++) {
        // Below 9.0e13, the number of whole taka in the largest amount.
        final n = random.nextInt(0x7fffffff) * random.nextInt(40000);
        expect(_wordsToInt(banglaNumber(n)), n, reason: '$n');
      }
    });
  });

  group('banglaAmount', () {
    String amount(int paisa, {bool only = true}) =>
        banglaAmount(paisa, only: only);

    test('spells whole taka', () {
      expect(amount(100), 'এক টাকা মাত্র');
      expect(amount(12500), 'একশো পঁচিশ টাকা মাত্র');
      expect(amount(100000), 'এক হাজার টাকা মাত্র');
    });

    test('adds পয়সা after the taka', () {
      expect(amount(12550), 'একশো পঁচিশ টাকা পঞ্চাশ পয়সা মাত্র');
      expect(amount(10001), 'একশো টাকা এক পয়সা মাত্র');
    });

    test('spells an amount below one taka in পয়সা alone', () {
      expect(amount(50), 'পঞ্চাশ পয়সা মাত্র');
      expect(amount(1), 'এক পয়সা মাত্র');
      expect(amount(37), 'সাঁইত্রিশ পয়সা মাত্র');
    });

    test('spells zero', () => expect(amount(0), 'শূন্য টাকা মাত্র'));

    test('puts ঋণাত্মক first for negative amounts', () {
      expect(amount(-500), 'ঋণাত্মক পাঁচ টাকা মাত্র');
      expect(amount(-5), 'ঋণাত্মক পাঁচ পয়সা মাত্র');
      expect(
        amount(-12550),
        'ঋণাত্মক একশো পঁচিশ টাকা পঞ্চাশ পয়সা মাত্র',
      );
    });

    test('can leave out মাত্র', () {
      expect(
        amount(12550, only: false),
        'একশো পঁচিশ টাকা পঞ্চাশ পয়সা',
      );
      expect(amount(0, only: false), 'শূন্য টাকা');
    });

    test('spells the largest amount', () {
      expect(
        amount(9007199254740991),
        'নব্বই লক্ষ সাত হাজার একশো নিরানব্বই কোটি '
        'পঁচিশ লক্ষ সাতচল্লিশ হাজার চারশো নয় টাকা '
        'একানব্বই পয়সা মাত্র',
      );
    });
  });
}

/// A deliberately independent reference: turns the words back into a number,
/// using the approved table, so the tests do not just repeat the library's
/// own logic.
int _wordsToInt(String words) {
  const hundred = 'শো';
  final small = {for (var i = 0; i < 100; i++) _table[i]: i};
  const scale = {'হাজার': 1000, 'লক্ষ': 100000};

  var total = 0;
  var current = 0;
  for (final token in words.split(' ')) {
    if (small.containsKey(token)) {
      current += small[token]!;
    } else if (token.endsWith(hundred) &&
        small.containsKey(token.substring(0, token.length - hundred.length))) {
      final digit = small[token.substring(0, token.length - hundred.length)]!;
      current += digit * 100;
    } else if (scale.containsKey(token)) {
      total += current * scale[token]!;
      current = 0;
    } else if (token == 'কোটি') {
      // Everything spelled so far is the crore count.
      total = (total + current) * 10000000;
      current = 0;
    } else {
      fail('Unknown token "$token" in "$words"');
    }
  }
  return total + current;
}

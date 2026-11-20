import 'dart:math';

import 'package:bd_taka/src/words_en.dart';
import 'package:test/test.dart';

void main() {
  group('englishNumber', () {
    test('spells 0 to 19', () {
      const expected = [
        'Zero', 'One', 'Two', 'Three', 'Four', 'Five', 'Six', 'Seven',
        'Eight', 'Nine', 'Ten', 'Eleven', 'Twelve', 'Thirteen', 'Fourteen',
        'Fifteen', 'Sixteen', 'Seventeen', 'Eighteen', 'Nineteen', //
      ];
      for (var i = 0; i < expected.length; i++) {
        expect(englishNumber(i), expected[i], reason: '$i');
      }
    });

    test('spells the tens and hyphenates compounds', () {
      const tens = {
        20: 'Twenty',
        30: 'Thirty',
        40: 'Forty',
        50: 'Fifty',
        60: 'Sixty',
        70: 'Seventy',
        80: 'Eighty',
        90: 'Ninety',
      };
      for (final MapEntry(key: n, value: word) in tens.entries) {
        expect(englishNumber(n), word);
        expect(englishNumber(n + 7), '$word-Seven');
      }
      expect(englishNumber(99), 'Ninety-Nine');
      expect(englishNumber(21), 'Twenty-One');
    });

    const cases = {
      100: 'One Hundred',
      101: 'One Hundred and One',
      125: 'One Hundred and Twenty-Five',
      999: 'Nine Hundred and Ninety-Nine',
      1000: 'One Thousand',
      1005: 'One Thousand and Five',
      1050: 'One Thousand and Fifty',
      1250: 'One Thousand Two Hundred and Fifty',
      10000: 'Ten Thousand',
      99999: 'Ninety-Nine Thousand Nine Hundred and Ninety-Nine',
      100000: 'One Lakh',
      100001: 'One Lakh and One',
      120500: 'One Lakh Twenty Thousand Five Hundred',
      123456: 'One Lakh Twenty-Three Thousand Four Hundred and Fifty-Six',
      10000000: 'One Crore',
      10000001: 'One Crore and One',
      123456789:
          'Twelve Crore Thirty-Four Lakh Fifty-Six Thousand Seven Hundred '
              'and Eighty-Nine',
      999999999: 'Ninety-Nine Crore Ninety-Nine Lakh Ninety-Nine Thousand '
          'Nine Hundred and Ninety-Nine',
      // From 100 crore the crore count is spelled the same way.
      1000000000: 'One Hundred Crore',
      1050000000: 'One Hundred and Five Crore',
      // 9007199 crore and 2547409.
      90071992547409:
          'Ninety Lakh Seven Thousand One Hundred and Ninety-Nine Crore '
              'Twenty-Five Lakh Forty-Seven Thousand Four Hundred and Nine',
    };
    for (final MapEntry(key: n, value: words) in cases.entries) {
      test('$n', () => expect(englishNumber(n), words));
    }

    test('can leave out "and"', () {
      expect(englishNumber(101, useAnd: false), 'One Hundred One');
      expect(englishNumber(1005, useAnd: false), 'One Thousand Five');
      expect(
        englishNumber(1050000000, useAnd: false),
        'One Hundred Five Crore',
      );
      expect(englishNumber(100, useAnd: false), 'One Hundred');
    });

    test('is tidy: single spaces and only known words', () {
      const vocabulary = {
        'Zero', 'One', 'Two', 'Three', 'Four', 'Five', 'Six', 'Seven',
        'Eight', 'Nine', 'Ten', 'Eleven', 'Twelve', 'Thirteen', 'Fourteen',
        'Fifteen', 'Sixteen', 'Seventeen', 'Eighteen', 'Nineteen', 'Twenty',
        'Thirty', 'Forty', 'Fifty', 'Sixty', 'Seventy', 'Eighty', 'Ninety',
        'Hundred', 'Thousand', 'Lakh', 'Crore', 'and', //
      };
      for (var n = 0; n <= 20000; n++) {
        final words = englishNumber(n);
        expect(words, words.trim(), reason: '$n');
        expect(words, isNot(contains('  ')), reason: '$n');
        for (final token in words.split(RegExp('[ -]'))) {
          expect(vocabulary, contains(token), reason: '$n: $words');
        }
      }
    });

    test('reads back as the same number (independent reference parser)', () {
      for (var n = 0; n <= 250000; n++) {
        expect(_wordsToInt(englishNumber(n)), n, reason: '$n');
        expect(_wordsToInt(englishNumber(n, useAnd: false)), n, reason: '$n');
      }
      final random = Random(7);
      for (var i = 0; i < 3000; i++) {
        // Below 9.0e13, the number of whole taka in the largest amount.
        final n = random.nextInt(0x7fffffff) * random.nextInt(40000);
        expect(_wordsToInt(englishNumber(n)), n, reason: '$n');
      }
    });
  });

  group('englishAmount', () {
    String amount(int paisa, {bool only = true, bool useAnd = true}) =>
        englishAmount(paisa, only: only, useAnd: useAnd);

    test('spells whole taka', () {
      expect(amount(100), 'One Taka Only');
      expect(amount(12500), 'One Hundred and Twenty-Five Taka Only');
    });

    test('adds paisa after the taka', () {
      expect(
        amount(12550),
        'One Hundred and Twenty-Five Taka and Fifty Paisa Only',
      );
      expect(amount(10001), 'One Hundred Taka and One Paisa Only');
    });

    test('spells an amount below one taka in paisa alone', () {
      expect(amount(50), 'Fifty Paisa Only');
      expect(amount(1), 'One Paisa Only');
      expect(amount(99), 'Ninety-Nine Paisa Only');
    });

    test('spells zero', () => expect(amount(0), 'Zero Taka Only'));

    test('puts Minus first for negative amounts', () {
      expect(amount(-500), 'Minus Five Taka Only');
      expect(amount(-5), 'Minus Five Paisa Only');
      expect(
        amount(-12550),
        'Minus One Hundred and Twenty-Five Taka and Fifty Paisa Only',
      );
    });

    test('can leave out Only', () {
      expect(
        amount(12550, only: false),
        'One Hundred and Twenty-Five Taka and Fifty Paisa',
      );
      expect(amount(0, only: false), 'Zero Taka');
    });

    test('can leave out and', () {
      expect(
        amount(12550, useAnd: false),
        'One Hundred Twenty-Five Taka and Fifty Paisa Only',
      );
    });

    test('spells the largest amount', () {
      expect(
        amount(9007199254740991),
        'Ninety Lakh Seven Thousand One Hundred and Ninety-Nine Crore '
        'Twenty-Five Lakh Forty-Seven Thousand Four Hundred and Nine Taka '
        'and Ninety-One Paisa Only',
      );
    });
  });
}

/// A deliberately independent reference: turns the words back into a number,
/// so the tests do not just repeat the implementation's own logic.
int _wordsToInt(String words) {
  const small = {
    'Zero': 0, 'One': 1, 'Two': 2, 'Three': 3, 'Four': 4, 'Five': 5,
    'Six': 6, 'Seven': 7, 'Eight': 8, 'Nine': 9, 'Ten': 10, 'Eleven': 11,
    'Twelve': 12, 'Thirteen': 13, 'Fourteen': 14, 'Fifteen': 15,
    'Sixteen': 16, 'Seventeen': 17, 'Eighteen': 18, 'Nineteen': 19,
    'Twenty': 20, 'Thirty': 30, 'Forty': 40, 'Fifty': 50, 'Sixty': 60,
    'Seventy': 70, 'Eighty': 80, 'Ninety': 90, //
  };
  const scale = {'Thousand': 1000, 'Lakh': 100000};

  var total = 0;
  var current = 0;
  for (final token in words.split(RegExp('[ -]'))) {
    if (token == 'and') continue;
    if (small.containsKey(token)) {
      current += small[token]!;
    } else if (token == 'Hundred') {
      current *= 100;
    } else if (scale.containsKey(token)) {
      total += current * scale[token]!;
      current = 0;
    } else if (token == 'Crore') {
      // Everything spelled so far is the crore count.
      total = (total + current) * 10000000;
      current = 0;
    } else {
      fail('Unknown token "$token" in "$words"');
    }
  }
  return total + current;
}

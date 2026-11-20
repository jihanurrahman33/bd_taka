import 'dart:math';

import 'package:bd_taka/bd_taka.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('construction', () {
    test('Taka() takes whole taka', () {
      expect(Taka(1250).paisa, 125000);
      expect(Taka(-3).paisa, -300);
      expect(Taka(0), Taka.zero);
    });

    test('fromPaisa() takes paisa', () {
      expect(Taka.fromPaisa(1).paisa, 1);
      expect(Taka.fromPaisa(-99).paisa, -99);
    });

    test('accepts the limits of the range', () {
      expect(Taka.fromPaisa(Taka.maxPaisa).paisa, Taka.maxPaisa);
      expect(Taka.fromPaisa(-Taka.maxPaisa).paisa, -Taka.maxPaisa);
    });

    test('rejects amounts outside the range', () {
      expect(() => Taka.fromPaisa(Taka.maxPaisa + 1), throwsRangeError);
      expect(() => Taka.fromPaisa(-Taka.maxPaisa - 1), throwsRangeError);
      expect(() => Taka(Taka.maxPaisa), throwsRangeError);
    });
  });

  group('accessors', () {
    test('split a positive amount into taka and paisa', () {
      final amount = Taka.fromPaisa(12550);
      expect(amount.taka, 125);
      expect(amount.paisaPart, 50);
      expect(amount.isNegative, isFalse);
      expect(amount.isZero, isFalse);
    });

    test('split a negative amount, truncating toward zero', () {
      final amount = Taka.fromPaisa(-12550);
      expect(amount.taka, -125);
      expect(amount.paisaPart, 50);
      expect(amount.isNegative, isTrue);
    });

    test('handle amounts below one taka', () {
      expect(Taka.fromPaisa(5).taka, 0);
      expect(Taka.fromPaisa(-5).taka, 0);
      expect(Taka.fromPaisa(-5).paisaPart, 5);
    });

    test('zero is zero', () {
      expect(Taka.zero.isZero, isTrue);
      expect(Taka.zero.isNegative, isFalse);
    });

    test('abs() returns the magnitude', () {
      expect(Taka(-5).abs(), Taka(5));
      expect(Taka(5).abs(), Taka(5));
      expect(Taka.zero.abs(), Taka.zero);
    });
  });

  group('arithmetic', () {
    test('adds exactly, unlike double', () {
      // 0.1 + 0.2 == 0.30000000000000004 as a double.
      expect(Taka.fromPaisa(10) + Taka.fromPaisa(20), Taka.fromPaisa(30));
    });

    test('subtracts and negates', () {
      expect(Taka(10) - Taka(3), Taka(7));
      expect(Taka(3) - Taka(10), Taka(-7));
      expect(-Taka(5), Taka(-5));
      expect(-Taka.zero, Taka.zero);
    });

    test('multiplies by a whole factor', () {
      expect(Taka.fromPaisa(1050) * 3, Taka.fromPaisa(3150));
      expect(Taka(5) * -2, Taka(-10));
      expect(Taka(5) * 0, Taka.zero);
    });

    test('throws a RangeError instead of overflowing', () {
      final big = Taka.fromPaisa(Taka.maxPaisa);
      expect(() => big + Taka.fromPaisa(1), throwsRangeError);
      expect(() => -big - Taka.fromPaisa(1), throwsRangeError);
      expect(() => big * 2, throwsRangeError);
      // 2^40 * 2^40 would silently wrap in 64-bit arithmetic.
      expect(
        () => Taka.fromPaisa(1099511627776) * 1099511627776,
        throwsRangeError,
      );
    });
  });

  group('comparison', () {
    test('orders amounts', () {
      expect(Taka(1) < Taka(2), isTrue);
      expect(Taka(2) <= Taka(2), isTrue);
      expect(Taka(3) > Taka(2), isTrue);
      expect(Taka(2) >= Taka(2), isTrue);
      expect(Taka(2) < Taka(2), isFalse);
      expect(Taka(-1) < Taka.zero, isTrue);
    });

    test('equal amounts are equal and share a hash code', () {
      expect(Taka.fromPaisa(100), Taka(1));
      expect(Taka.fromPaisa(100).hashCode, Taka(1).hashCode);
      expect(Taka(1), isNot(Taka(2)));
    });

    test('sorts with compareTo', () {
      final amounts = [Taka(3), Taka(-1), Taka.zero, Taka(2)];
      amounts.sort();
      expect(amounts, [Taka(-1), Taka.zero, Taka(2), Taka(3)]);
    });
  });

  group('ratio', () {
    test('computes a percentage exactly', () {
      expect(Taka(1250).ratio(15, 100), Taka.fromPaisa(18750));
      expect(Taka(1250) + Taka(1250).ratio(15, 100), Taka.fromPaisa(143750));
    });

    test('rounds half to even by default', () {
      // 25 paisa / 10 = 2.5 and 35 paisa / 10 = 3.5.
      expect(Taka.fromPaisa(25).ratio(1, 10), Taka.fromPaisa(2));
      expect(Taka.fromPaisa(35).ratio(1, 10), Taka.fromPaisa(4));
    });

    // Rows: paisa, then the expected result for each mode, for ratio(1, 10).
    const table = {
      // exact tie, 2.5
      25: {
        RoundingMode.down: 2,
        RoundingMode.up: 3,
        RoundingMode.floor: 2,
        RoundingMode.ceil: 3,
        RoundingMode.halfUp: 3,
        RoundingMode.halfDown: 2,
        RoundingMode.halfEven: 2,
      },
      // exact tie, -2.5
      -25: {
        RoundingMode.down: -2,
        RoundingMode.up: -3,
        RoundingMode.floor: -3,
        RoundingMode.ceil: -2,
        RoundingMode.halfUp: -3,
        RoundingMode.halfDown: -2,
        RoundingMode.halfEven: -2,
      },
      // exact tie, 3.5
      35: {
        RoundingMode.down: 3,
        RoundingMode.up: 4,
        RoundingMode.floor: 3,
        RoundingMode.ceil: 4,
        RoundingMode.halfUp: 4,
        RoundingMode.halfDown: 3,
        RoundingMode.halfEven: 4,
      },
      // below the tie, 2.4
      24: {
        RoundingMode.down: 2,
        RoundingMode.up: 3,
        RoundingMode.floor: 2,
        RoundingMode.ceil: 3,
        RoundingMode.halfUp: 2,
        RoundingMode.halfDown: 2,
        RoundingMode.halfEven: 2,
      },
      // above the tie, 2.6
      26: {
        RoundingMode.down: 2,
        RoundingMode.up: 3,
        RoundingMode.floor: 2,
        RoundingMode.ceil: 3,
        RoundingMode.halfUp: 3,
        RoundingMode.halfDown: 3,
        RoundingMode.halfEven: 3,
      },
      // above the tie, negative, -2.6
      -26: {
        RoundingMode.down: -2,
        RoundingMode.up: -3,
        RoundingMode.floor: -3,
        RoundingMode.ceil: -2,
        RoundingMode.halfUp: -3,
        RoundingMode.halfDown: -3,
        RoundingMode.halfEven: -3,
      },
    };

    for (final MapEntry(key: paisa, value: expected) in table.entries) {
      for (final MapEntry(key: mode, value: result) in expected.entries) {
        test('$mode rounds ${paisa / 10} paisa to $result', () {
          expect(
            Taka.fromPaisa(paisa).ratio(1, 10, rounding: mode),
            Taka.fromPaisa(result),
          );
        });
      }
    }

    test('leaves exact results alone in every mode', () {
      for (final mode in RoundingMode.values) {
        expect(
          Taka.fromPaisa(300).ratio(1, 3, rounding: mode),
          Taka.fromPaisa(100),
        );
      }
    });

    test('accepts a negative denominator', () {
      expect(Taka(10).ratio(1, -2), Taka(-5));
      expect(Taka(10).ratio(-1, -2), Taka(5));
    });

    test('rejects a zero denominator', () {
      expect(() => Taka(1).ratio(1, 0), throwsArgumentError);
    });

    test('does not overflow in the intermediate product', () {
      final big = Taka.fromPaisa(Taka.maxPaisa);
      expect(big.ratio(Taka.maxPaisa, Taka.maxPaisa), big);
    });

    test('throws a RangeError when the result is out of range', () {
      expect(() => Taka.fromPaisa(Taka.maxPaisa).ratio(2, 1), throwsRangeError);
    });
  });

  group('split', () {
    test('gives leftover paisa to the first shares', () {
      expect(Taka(100).split(3), [
        Taka.fromPaisa(3334),
        Taka.fromPaisa(3333),
        Taka.fromPaisa(3333),
      ]);
    });

    test('with one part returns the amount', () {
      expect(Taka(7).split(1), [Taka(7)]);
    });

    test('handles fewer paisa than parts', () {
      expect(Taka.fromPaisa(2).split(5), [
        Taka.fromPaisa(1),
        Taka.fromPaisa(1),
        Taka.zero,
        Taka.zero,
        Taka.zero,
      ]);
    });

    test('splits a negative amount symmetrically', () {
      expect(Taka(-100).split(3), [
        Taka.fromPaisa(-3334),
        Taka.fromPaisa(-3333),
        Taka.fromPaisa(-3333),
      ]);
    });

    test('splits zero into zeros', () {
      expect(Taka.zero.split(3), [Taka.zero, Taka.zero, Taka.zero]);
    });

    test('never creates or loses money', () {
      for (final paisa in [0, 1, 2, 99, 100, 101, 9999, 123457, -7, -100003]) {
        for (var parts = 1; parts <= 13; parts++) {
          final shares = Taka.fromPaisa(paisa).split(parts);
          final sum = shares.fold<int>(0, (a, s) => a + s.paisa);
          final lowest =
              shares.map((s) => s.paisa).reduce((a, b) => a < b ? a : b);
          final highest =
              shares.map((s) => s.paisa).reduce((a, b) => a > b ? a : b);
          expect(shares.length, parts);
          expect(sum, paisa, reason: '$paisa paisa into $parts');
          expect(highest - lowest, lessThanOrEqualTo(1));
        }
      }
    });

    test('rejects a non-positive number of parts', () {
      expect(() => Taka(1).split(0), throwsArgumentError);
      expect(() => Taka(1).split(-2), throwsArgumentError);
    });
  });

  group('allocate', () {
    test('matches split for equal ratios', () {
      expect(Taka(100).allocate([1, 1, 1]), Taka(100).split(3));
    });

    test('allocates in proportion', () {
      expect(Taka(100).allocate([70, 30]), [Taka(70), Taka(30)]);
    });

    test('gives leftover paisa to the first shares', () {
      // 1.00 split 1:2 is 0.333... and 0.666..., so 0.34 and 0.66.
      expect(Taka(1).allocate([1, 2]), [
        Taka.fromPaisa(34),
        Taka.fromPaisa(66),
      ]);
    });

    test('skips zero ratios, which receive nothing', () {
      expect(Taka.fromPaisa(10).allocate([0, 1, 1]), [
        Taka.zero,
        Taka.fromPaisa(5),
        Taka.fromPaisa(5),
      ]);
      expect(Taka.fromPaisa(1).allocate([0, 1]), [
        Taka.zero,
        Taka.fromPaisa(1),
      ]);
    });

    test('allocates a negative amount symmetrically', () {
      expect(Taka(-100).allocate([70, 30]), [Taka(-70), Taka(-30)]);
    });

    test('never creates or loses money', () {
      const ratioSets = [
        [1],
        [1, 1],
        [3, 7],
        [1, 2, 3],
        [5, 0, 2, 9],
        [100, 1, 1],
      ];
      for (final paisa in [0, 1, 7, 99, 100, 12345, -12345]) {
        for (final ratios in ratioSets) {
          final shares = Taka.fromPaisa(paisa).allocate(ratios);
          final sum = shares.fold<int>(0, (a, s) => a + s.paisa);
          expect(shares.length, ratios.length);
          expect(sum, paisa, reason: '$paisa paisa by $ratios');
        }
      }
    });

    test('rejects invalid ratios', () {
      expect(() => Taka(1).allocate([]), throwsArgumentError);
      expect(() => Taka(1).allocate([1, -1]), throwsArgumentError);
      expect(() => Taka(1).allocate([0, 0]), throwsArgumentError);
    });
  });

  group('toString', () {
    test('prints plain decimal text with two decimals', () {
      expect(Taka.zero.toString(), '0.00');
      expect(Taka.fromPaisa(5).toString(), '0.05');
      expect(Taka.fromPaisa(1250).toString(), '12.50');
      expect(Taka(1234567).toString(), '1234567.00');
    });

    test('keeps the sign for negative amounts below one taka', () {
      expect(Taka.fromPaisa(-5).toString(), '-0.05');
      expect(Taka.fromPaisa(-12550).toString(), '-125.50');
    });
  });

  group('format', () {
    final amount = Taka.fromPaisa(123456750); // 12,34,567.50

    test('defaults to the symbol with lakh and crore grouping', () {
      expect(amount.format(), '৳12,34,567.50');
    });

    test('groups lakh and crore correctly', () {
      expect(Taka(999).format(), '৳999.00');
      expect(Taka(1000).format(), '৳1,000.00');
      expect(Taka(100000).format(), '৳1,00,000.00'); // one lakh
      expect(Taka(10000000).format(), '৳1,00,00,000.00'); // one crore
      expect(Taka(123456789).format(), '৳12,34,56,789.00');
    });

    test('writes Bengali digits', () {
      expect(amount.format(bengaliDigits: true), '৳১২,৩৪,৫৬৭.৫০');
    });

    test('supports international and no grouping', () {
      expect(
        amount.format(grouping: Grouping.international),
        '৳1,234,567.50',
      );
      expect(amount.format(grouping: Grouping.none), '৳1234567.50');
    });

    test('can leave out the symbol', () {
      expect(amount.format(symbol: false), '12,34,567.50');
    });

    test('always shows two decimals for paisa', () {
      expect(Taka.zero.format(), '৳0.00');
      expect(Taka.fromPaisa(5).format(), '৳0.05');
      expect(Taka.fromPaisa(90).format(), '৳0.90');
    });

    test('omitZeroPaisa hides decimals only for whole taka', () {
      expect(Taka(1250).format(omitZeroPaisa: true), '৳1,250');
      expect(Taka.zero.format(omitZeroPaisa: true), '৳0');
      expect(Taka.fromPaisa(125050).format(omitZeroPaisa: true), '৳1,250.50');
      expect(Taka.fromPaisa(5).format(omitZeroPaisa: true), '৳0.05');
    });

    test('puts the minus sign before the symbol', () {
      expect(Taka.fromPaisa(-12550).format(), '-৳125.50');
      expect(Taka.fromPaisa(-5).format(), '-৳0.05');
      expect(Taka.fromPaisa(-12550).format(symbol: false), '-125.50');
      expect(
        Taka.fromPaisa(-12550).format(bengaliDigits: true),
        '-৳১২৫.৫০',
      );
    });

    test('formats the largest and smallest amounts', () {
      expect(
        Taka.fromPaisa(Taka.maxPaisa).format(symbol: false),
        '9,00,71,99,25,47,409.91',
      );
      expect(
        Taka.fromPaisa(-Taka.maxPaisa).format(symbol: false),
        '-9,00,71,99,25,47,409.91',
      );
    });
  });

  group('toEnglishWords', () {
    test('spells taka and paisa as on a cheque', () {
      expect(
        Taka.fromPaisa(12550).toEnglishWords(),
        'One Hundred and Twenty-Five Taka and Fifty Paisa Only',
      );
      expect(
        Taka(123456).toEnglishWords(),
        'One Lakh Twenty-Three Thousand Four Hundred and Fifty-Six Taka Only',
      );
    });

    test('handles zero, paisa alone and negatives', () {
      expect(Taka.zero.toEnglishWords(), 'Zero Taka Only');
      expect(Taka.fromPaisa(50).toEnglishWords(), 'Fifty Paisa Only');
      expect(Taka(-5).toEnglishWords(), 'Minus Five Taka Only');
    });

    test('supports leaving out Only and and', () {
      final amount = Taka.fromPaisa(10500);
      expect(amount.toEnglishWords(), 'One Hundred and Five Taka Only');
      expect(amount.toEnglishWords(only: false), 'One Hundred and Five Taka');
      expect(
        amount.toEnglishWords(useAnd: false),
        'One Hundred Five Taka Only',
      );
    });

    test('spells every sample amount without throwing', () {
      for (final paisa in _samplePaisa) {
        final words = Taka.fromPaisa(paisa).toEnglishWords();
        expect(words, endsWith(' Only'));
        expect(words, isNot(contains('  ')));
      }
    });
  });

  group('toBanglaWords', () {
    test('spells taka and পয়সা as on a cheque', () {
      expect(
        Taka.fromPaisa(12550).toBanglaWords(),
        'একশো পঁচিশ টাকা পঞ্চাশ পয়সা মাত্র',
      );
      expect(
        Taka(1234567).toBanglaWords(),
        'বারো লক্ষ চৌত্রিশ হাজার পাঁচশো সাতষট্টি টাকা মাত্র',
      );
    });

    test('handles zero, পয়সা alone and negatives', () {
      expect(Taka.zero.toBanglaWords(), 'শূন্য টাকা মাত্র');
      expect(Taka.fromPaisa(50).toBanglaWords(), 'পঞ্চাশ পয়সা মাত্র');
      expect(Taka(-5).toBanglaWords(), 'ঋণাত্মক পাঁচ টাকা মাত্র');
    });

    test('supports leaving out মাত্র', () {
      expect(Taka(100).toBanglaWords(only: false), 'একশো টাকা');
    });

    test('spells every sample amount without throwing', () {
      for (final paisa in _samplePaisa) {
        final words = Taka.fromPaisa(paisa).toBanglaWords();
        expect(words, endsWith(' মাত্র'));
        expect(words, isNot(contains('  ')));
      }
    });
  });

  group('parse', () {
    test('parses text into an amount', () {
      expect(Taka.parse('1250'), Taka(1250));
      expect(Taka.parse('৳12,34,567.5'), Taka.fromPaisa(123456750));
      expect(Taka.parse('-৳১২৫.৫০'), Taka.fromPaisa(-12550));
      expect(Taka.parse('1.5'), Taka.fromPaisa(150));
    });

    test('throws a FormatException for invalid text', () {
      expect(() => Taka.parse('1.234'), throwsFormatException);
      expect(() => Taka.parse(''), throwsFormatException);
      expect(() => Taka.parse('1,25,0'), throwsFormatException);
      expect(() => Taka.parse('99999999999999999999'), throwsFormatException);
    });

    test('keeps the source and a reason in the exception', () {
      try {
        Taka.parse('1.234');
        fail('Expected a FormatException.');
      } on FormatException catch (e) {
        expect(e.source, '1.234');
        expect(e.message, contains('at most two decimals'));
      }
    });

    test('tryParse returns null instead of throwing', () {
      expect(Taka.tryParse('1250'), Taka(1250));
      expect(Taka.tryParse('1.234'), isNull);
      expect(Taka.tryParse(''), isNull);
      expect(Taka.tryParse('99999999999999999999'), isNull);
    });

    test('reads back what toString writes', () {
      for (final paisa in _samplePaisa) {
        final amount = Taka.fromPaisa(paisa);
        expect(Taka.parse(amount.toString()), amount, reason: '$paisa');
      }
    });

    test('reads back what format writes, for every option', () {
      for (final paisa in _samplePaisa) {
        final amount = Taka.fromPaisa(paisa);
        for (final symbol in [true, false]) {
          for (final bengaliDigits in [true, false]) {
            for (final omitZeroPaisa in [true, false]) {
              for (final grouping in Grouping.values) {
                final text = amount.format(
                  symbol: symbol,
                  bengaliDigits: bengaliDigits,
                  grouping: grouping,
                  omitZeroPaisa: omitZeroPaisa,
                );
                expect(
                  Taka.parse(text),
                  amount,
                  reason: '$paisa as "$text" '
                      '(symbol: $symbol, bengaliDigits: $bengaliDigits, '
                      'grouping: $grouping, omitZeroPaisa: $omitZeroPaisa)',
                );
              }
            }
          }
        }
      }
    });
  });
}

/// Amounts that exercise every grouping boundary, both signs and the limits,
/// plus a few hundred pseudo-random values from a fixed seed.
final List<int> _samplePaisa = () {
  final random = Random(42);
  return [
    0,
    1,
    5,
    50,
    99,
    100,
    101,
    99999,
    100000,
    12345,
    10000000,
    123456750,
    1000000000,
    Taka.maxPaisa,
    -1,
    -5,
    -12550,
    -123456750,
    -Taka.maxPaisa,
    // The product stays below 2^53, so it is exact under dart2js too.
    for (var i = 0; i < 300; i++)
      (random.nextBool() ? 1 : -1) *
          random.nextInt(0x7fffffff) *
          random.nextInt(4000000),
  ];
}();

# ৳ bd_taka

[![pub package](https://img.shields.io/pub/v/bd_taka.svg)](https://pub.dev/packages/bd_taka)
[![CI](https://github.com/jihanurrahman33/bd_taka/actions/workflows/ci.yml/badge.svg)](https://github.com/jihanurrahman33/bd_taka/actions/workflows/ci.yml)
[![license: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

Money-safe Bangladeshi taka for Dart. An exact integer-paisa `Taka` type with
arithmetic, fair splitting, lakh/crore formatting, strict parsing and amount in
words, in English and Bangla. Pure Dart, zero dependencies, works in Flutter,
server, CLI and the web.

## Why

A `double` cannot hold most amounts of money exactly:

```dart
print(0.1 + 0.2); // 0.30000000000000004
```

`Taka` stores whole paisa as an `int`, so sums are exact, and a bill split three
ways never gains or loses a paisa.

## Features

- 💰 Exact `Taka` value type: add, subtract, multiply, compare, sort
- 📐 `ratio(15, 100)` for tax and discounts, with seven explicit rounding modes
- ➗ `split(3)` and `allocate([70, 30])` always add up to the original amount
- 🔢 Lakh and crore grouping (`12,34,567.50`), optional ৳ and Bengali digits
- 🧾 Strict `parse` and `tryParse` that accept what `format` writes, in either digit system
- ✍️ Amount in words for cheques and invoices: English and Bangla
- 🌐 Exact on the web too: amounts are limited to ±(2⁵³ − 1) paisa, about ৳90 trillion

## Install

```yaml
dependencies:
  bd_taka: ^0.1.0
```

## Usage

```dart
import 'package:bd_taka/bd_taka.dart';
```

### Arithmetic

```dart
Taka.fromPaisa(10) + Taka.fromPaisa(20); // 0.30, exactly

final price = Taka(1250);
final vat = price.ratio(15, 100);        // 187.50
price + vat;                             // 1437.50
```

`Taka(int)` takes whole taka and `Taka.fromPaisa(int)` takes paisa. Operations
that would leave the supported range throw a `RangeError` instead of wrapping.

### Rounding

`ratio(numerator, denominator, {rounding})` multiplies by an exact fraction and
rounds the result to a whole paisa. The default is half to even, which avoids a
systematic bias when many amounts are rounded.

| `RoundingMode` | 2.5 | −2.5 | 2.4 | 2.6 |
|---|---|---|---|---|
| `down` (toward zero) | 2 | −2 | 2 | 2 |
| `up` (away from zero) | 3 | −3 | 3 | 3 |
| `floor` | 2 | −3 | 2 | 2 |
| `ceil` | 3 | −2 | 3 | 3 |
| `halfUp` | 3 | −3 | 2 | 3 |
| `halfDown` | 2 | −2 | 2 | 3 |
| `halfEven` | 2 | −2 | 2 | 3 |

### Splitting

```dart
Taka(100).split(3);            // [33.34, 33.33, 33.33]
Taka(100).allocate([70, 30]);  // [70.00, 30.00]
```

Leftover paisa go one each to the first shares, so the parts always add up to
exactly the original.

### Formatting

```dart
final amount = Taka.fromPaisa(123456750);

amount.format();                                         // ৳12,34,567.50
amount.format(bengaliDigits: true);                      // ৳১২,৩৪,৫৬৭.৫০
amount.format(grouping: Grouping.international, symbol: false); // 1,234,567.50
Taka(1250).format(omitZeroPaisa: true);                  // ৳1,250
```

`omitZeroPaisa` only hides `.00`. An amount with paisa always shows both
decimals, so nothing is silently dropped. `toString()` is a separate, stable,
machine-readable form such as `1234567.50`.

### Parsing

```dart
Taka.parse('৳12,34,567.5');  // 1234567.50
Taka.parse('-৳১২৫.৫০');      // -125.50
Taka.tryParse('1.234');      // null: a third decimal would lose paisa
```

`parse` accepts an optional `-`, an optional marker (`৳`, `Tk`, `Tk.` or `BDT`),
ASCII or Bengali digits (not mixed), no grouping, lakh/crore grouping or
international grouping, and one or two decimals. A single decimal digit counts
as tenths, so `1.5` is `1.50`. Everything else is rejected rather than
guessed: extra decimals, misplaced commas, leading zeros, exponents, stray
text and out-of-range amounts. `parse` throws a `FormatException` with a
reason, and `tryParse` returns `null`.

### Amount in words

```dart
Taka.fromPaisa(12550).toEnglishWords();
// One Hundred and Twenty-Five Taka and Fifty Paisa Only

Taka.fromPaisa(12550).toBanglaWords();
// একশো পঁচিশ টাকা পঞ্চাশ পয়সা মাত্র

Taka(1234567).toBanglaWords();
// বারো লক্ষ চৌত্রিশ হাজার পাঁচশো সাতষট্টি টাকা মাত্র
```

Both use the South Asian scale (thousand, lakh, crore). From 100 crore upward
the crore count is spelled the same way, so 100 crore is `One Hundred Crore` and
`একশো কোটি`. Pass `only: false` to leave out the closing "Only" or মাত্র, and
`useAnd: false` for `One Hundred Five` in English.

Some Bangla numbers have more than one accepted spelling. This package uses
সাঁইত্রিশ (37), বায়ান্ন (52), তিপ্পান্ন (53), ছাপ্পান্ন (56), ঊন- for 29,
39 … 89, and hundreds written with শো. If your house style differs, or you
spot a mistake, please open an issue.

## Related packages

Other packages cover parts of this on pub.dev, for example
[`bangla_format`](https://pub.dev/packages/bangla_format) (Bangla digits, dates
and taka formatting) and
[`bangla_number_to_words`](https://pub.dev/packages/bangla_number_to_words)
(numbers and currency in Bangla words). `bd_taka` is aimed at the money itself:
an exact value type, safe splitting and rounding, lakh/crore formatting and
strict parsing. It takes a whole number of paisa, not a `double`.

## Contributing

Issues and PRs are welcome, see [CONTRIBUTING.md](CONTRIBUTING.md).

## License

MIT, see [LICENSE](LICENSE).

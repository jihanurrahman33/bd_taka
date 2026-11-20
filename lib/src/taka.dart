import 'rounding_mode.dart';

/// An exact amount of Bangladeshi taka (৳), stored as a whole number of paisa.
///
/// One taka is 100 paisa. Because the amount is an integer, arithmetic never
/// suffers from the rounding error of `double`: `0.1 + 0.2` is not `0.3` as a
/// double, but `Taka.fromPaisa(10) + Taka.fromPaisa(20)` is exactly
/// `Taka.fromPaisa(30)`.
///
/// ```dart
/// final price = Taka(1250);
/// final vat = price.ratio(15, 100);
/// print(price + vat); // 1437.50
/// ```
///
/// ## Range
///
/// Amounts are limited to ±[maxPaisa] (about ৳90 trillion). The limit keeps
/// every value exactly representable when Dart is compiled to JavaScript,
/// where an `int` is a double with 53 bits of precision. Operations that would
/// leave the range throw a [RangeError] instead of silently wrapping.
final class Taka implements Comparable<Taka> {
  /// The largest number of paisa a [Taka] can hold, 2^53 - 1.
  static const int maxPaisa = 9007199254740991;

  /// An amount of zero.
  static const Taka zero = Taka._(0);

  /// The amount in paisa. Negative for amounts that are owed or deducted.
  final int paisa;

  const Taka._(this.paisa);

  /// Creates an amount from a whole number of [taka].
  ///
  /// Throws a [RangeError] if the amount is outside ±[maxPaisa] paisa.
  factory Taka(int taka) => _fromBig(BigInt.from(taka) * _hundred);

  /// Creates an amount from a whole number of [paisa].
  ///
  /// Throws a [RangeError] if [paisa] is outside ±[maxPaisa].
  factory Taka.fromPaisa(int paisa) {
    RangeError.checkValueInInterval(paisa, -maxPaisa, maxPaisa, 'paisa');
    return Taka._(paisa);
  }

  static final BigInt _hundred = BigInt.from(100);
  static final BigInt _max = BigInt.from(maxPaisa);

  static Taka _fromBig(BigInt paisa) {
    if (paisa.abs() > _max) {
      throw RangeError(
        'The amount is outside ±$maxPaisa paisa, the range of Taka.',
      );
    }
    return Taka._(paisa.toInt());
  }

  /// The whole taka of this amount, truncated toward zero.
  ///
  /// The `taka` of `Taka.fromPaisa(12550)` is `125`, and of
  /// `Taka.fromPaisa(-12550)` is `-125`.
  int get taka => paisa ~/ 100;

  /// The paisa left over after the whole taka, from 0 to 99, ignoring the sign.
  ///
  /// The `paisaPart` of both `Taka.fromPaisa(12550)` and
  /// `Taka.fromPaisa(-12550)` is `50`.
  int get paisaPart => paisa.abs() % 100;

  /// Whether the amount is below zero.
  bool get isNegative => paisa < 0;

  /// Whether the amount is exactly zero.
  bool get isZero => paisa == 0;

  /// The absolute value of this amount.
  Taka abs() => isNegative ? Taka._(-paisa) : this;

  /// Adds [other] to this amount.
  ///
  /// Throws a [RangeError] if the result is outside the range of [Taka].
  Taka operator +(Taka other) => Taka.fromPaisa(paisa + other.paisa);

  /// Subtracts [other] from this amount.
  ///
  /// Throws a [RangeError] if the result is outside the range of [Taka].
  Taka operator -(Taka other) => Taka.fromPaisa(paisa - other.paisa);

  /// The negation of this amount.
  Taka operator -() => Taka._(-paisa);

  /// Multiplies this amount by a whole [factor].
  ///
  /// Use [ratio] for fractional factors such as a tax rate.
  ///
  /// Throws a [RangeError] if the result is outside the range of [Taka].
  Taka operator *(int factor) =>
      _fromBig(BigInt.from(paisa) * BigInt.from(factor));

  /// Whether this amount is less than [other].
  bool operator <(Taka other) => paisa < other.paisa;

  /// Whether this amount is less than or equal to [other].
  bool operator <=(Taka other) => paisa <= other.paisa;

  /// Whether this amount is greater than [other].
  bool operator >(Taka other) => paisa > other.paisa;

  /// Whether this amount is greater than or equal to [other].
  bool operator >=(Taka other) => paisa >= other.paisa;

  /// Multiplies this amount by the exact fraction [numerator] / [denominator]
  /// and rounds the result to a whole paisa using [rounding].
  ///
  /// The calculation is done with integers, so there is no floating-point
  /// error. A 15% VAT is `ratio(15, 100)`, and a third is `ratio(1, 3)`.
  ///
  /// Rounds half to even by default, which avoids a systematic bias when many
  /// amounts are rounded. Pass [RoundingMode.halfUp] for the "round 0.5 up"
  /// convention.
  ///
  /// Throws an [ArgumentError] if [denominator] is zero, and a [RangeError] if
  /// the result is outside the range of [Taka].
  Taka ratio(
    int numerator,
    int denominator, {
    RoundingMode rounding = RoundingMode.halfEven,
  }) {
    if (denominator == 0) {
      throw ArgumentError.value(denominator, 'denominator', 'Must not be zero');
    }
    var n = BigInt.from(paisa) * BigInt.from(numerator);
    var d = BigInt.from(denominator);
    if (d.isNegative) {
      n = -n;
      d = -d;
    }
    return _fromBig(divideRounded(n, d, rounding));
  }

  /// Splits this amount into [parts] shares that differ by at most one paisa
  /// and add up to exactly this amount.
  ///
  /// The leftover paisa go one each to the first shares, so
  /// `Taka(100).split(3)` is `33.34`, `33.33`, `33.33`. Dividing a bill this
  /// way never creates or loses money.
  ///
  /// Throws an [ArgumentError] if [parts] is not positive.
  List<Taka> split(int parts) {
    if (parts <= 0) {
      throw ArgumentError.value(parts, 'parts', 'Must be positive');
    }
    final base = paisa ~/ parts;
    final leftover = paisa.remainder(parts).abs();
    final step = isNegative ? -1 : 1;
    return [
      for (var i = 0; i < parts; i++) Taka._(base + (i < leftover ? step : 0)),
    ];
  }

  /// Splits this amount in proportion to [ratios] and adds up to exactly this
  /// amount.
  ///
  /// Each share is rounded down to a whole paisa, and the leftover paisa go
  /// one each to the first shares. `Taka(100).allocate([1, 1, 1])` therefore
  /// matches `Taka(100).split(3)`, and `Taka(100).allocate([70, 30])` is
  /// `70.00` and `30.00`.
  ///
  /// Throws an [ArgumentError] if [ratios] is empty, contains a negative
  /// value, or adds up to zero.
  List<Taka> allocate(List<int> ratios) {
    if (ratios.isEmpty) {
      throw ArgumentError.value(ratios, 'ratios', 'Must not be empty');
    }
    if (ratios.any((r) => r < 0)) {
      throw ArgumentError.value(ratios, 'ratios', 'Must not be negative');
    }
    final total =
        ratios.fold<BigInt>(BigInt.zero, (a, r) => a + BigInt.from(r));
    if (total == BigInt.zero) {
      throw ArgumentError.value(ratios, 'ratios', 'Must not add up to zero');
    }

    final magnitude = BigInt.from(paisa).abs();
    final sign = isNegative ? -1 : 1;
    final shares = [
      for (final r in ratios) (magnitude * BigInt.from(r) ~/ total).toInt(),
    ];
    var leftover = magnitude.toInt() - shares.fold<int>(0, (a, s) => a + s);
    for (var i = 0; leftover > 0; i = (i + 1) % shares.length) {
      if (ratios[i] > 0) {
        shares[i]++;
        leftover--;
      }
    }
    return [for (final s in shares) Taka._(sign * s)];
  }

  @override
  int compareTo(Taka other) => paisa.compareTo(other.paisa);

  @override
  bool operator ==(Object other) => other is Taka && other.paisa == paisa;

  @override
  int get hashCode => paisa.hashCode;

  /// The amount as plain decimal text with exactly two decimals, such as
  /// `1250.50` or `-0.05`.
  ///
  /// This is a stable, machine-readable form, not display text.
  @override
  String toString() {
    final sign = isNegative ? '-' : '';
    final fraction = paisaPart.toString().padLeft(2, '0');
    return '$sign${paisa.abs() ~/ 100}.$fraction';
  }
}

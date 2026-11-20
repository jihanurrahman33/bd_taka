/// How a fractional paisa is rounded to a whole paisa.
///
/// Every mode is described for a value exactly halfway between two paisa
/// (a "tie") and for values that are not. For example, `2.5` and `-2.5`
/// show how each mode treats the sign.
enum RoundingMode {
  /// Rounds toward zero, discarding the fraction (`2.9` becomes `2`).
  down,

  /// Rounds away from zero whenever there is a fraction (`2.1` becomes `3`).
  up,

  /// Rounds toward negative infinity (`-2.1` becomes `-3`, `2.9` becomes `2`).
  floor,

  /// Rounds toward positive infinity (`-2.9` becomes `-2`, `2.1` becomes `3`).
  ceil,

  /// Rounds to the nearest value, and ties away from zero (`2.5` becomes `3`,
  /// `-2.5` becomes `-3`).
  halfUp,

  /// Rounds to the nearest value, and ties toward zero (`2.5` becomes `2`,
  /// `-2.5` becomes `-2`).
  halfDown,

  /// Rounds to the nearest value, and ties to the even neighbor (`2.5`
  /// becomes `2`, `3.5` becomes `4`). Also known as banker's rounding.
  halfEven,
}

/// Divides [numerator] by a positive [denominator] and rounds the quotient
/// to an integer using [mode].
BigInt divideRounded(BigInt numerator, BigInt denominator, RoundingMode mode) {
  assert(denominator > BigInt.zero, 'denominator must be positive');

  final quotient = numerator ~/ denominator; // Truncates toward zero.
  final remainder = numerator.remainder(denominator);
  if (remainder == BigInt.zero) return quotient;

  final negative = numerator.isNegative;
  final away = negative ? quotient - BigInt.one : quotient + BigInt.one;
  // Compares the doubled remainder with the denominator to find which side
  // of the halfway point the exact quotient is on.
  final side = (remainder.abs() * BigInt.two).compareTo(denominator);

  switch (mode) {
    case RoundingMode.down:
      return quotient;
    case RoundingMode.up:
      return away;
    case RoundingMode.floor:
      return negative ? away : quotient;
    case RoundingMode.ceil:
      return negative ? quotient : away;
    case RoundingMode.halfUp:
      return side >= 0 ? away : quotient;
    case RoundingMode.halfDown:
      return side > 0 ? away : quotient;
    case RoundingMode.halfEven:
      if (side > 0) return away;
      if (side < 0) return quotient;
      return quotient.isEven ? quotient : away;
  }
}

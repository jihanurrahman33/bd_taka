import 'digits.dart';
import 'grouping.dart';
import 'parse.dart';

/// The largest number of paisa an amount can hold. Mirrors `Taka.maxPaisa`.
final BigInt _maxPaisa = BigInt.from(9007199254740991);

/// The text of a taka input after an edit, and where the cursor goes.
final class TakaEdit {
  /// Creates an edit result with [text] and a [cursor] offset into it.
  const TakaEdit(this.text, this.cursor);

  /// The reformatted text, such as `12,34,567.5`.
  final String text;

  /// The cursor offset in [text], from 0 to its length.
  final int cursor;

  @override
  bool operator ==(Object other) =>
      other is TakaEdit && other.text == text && other.cursor == cursor;

  @override
  int get hashCode => Object.hash(text, cursor);

  @override
  String toString() => '${text.substring(0, cursor)}|${text.substring(cursor)}';
}

bool _isAsciiDigit(int unit) => unit >= 0x30 && unit <= 0x39;

bool _isBengaliDigit(int unit) => unit >= 0x09E6 && unit <= 0x09EF;

/// Whether [unit] is a character the user typed on purpose: a digit in either
/// script, the decimal point or the minus sign. Separators are not.
bool _isSignificant(int unit) =>
    _isAsciiDigit(unit) ||
    _isBengaliDigit(unit) ||
    unit == 0x2E ||
    unit == 0x2D;

/// Reformats [raw], the text of a taka input with the cursor at [cursor], as a
/// person types.
///
/// Digits in either script, one decimal point and, when [allowNegative] is
/// true, a leading minus sign are kept. Everything else, including the commas
/// from an earlier pass, is dropped and the whole part is grouped again with
/// [grouping]. Leading zeros are removed, and a lone decimal point becomes
/// `0.`. The fraction is kept as typed, so `12.` and `12.5` stay valid while
/// typing.
///
/// The cursor stays after the same digit it followed before, so the commas
/// that appear and disappear never make it jump.
///
/// Returns `null` when the edit must be rejected and the previous text kept:
/// a second decimal point, a third decimal digit (which would lose paisa), or
/// an amount outside the range of `Taka`.
TakaEdit? reformatTakaInput(
  String raw,
  int cursor, {
  required Grouping grouping,
  required bool bengaliDigits,
  required bool allowNegative,
}) {
  final caret = cursor.clamp(0, raw.length);

  var negative = false;
  var signBeforeCursor = false;
  var seenPoint = false;
  final kept = StringBuffer(); // ASCII digits and at most one '.'
  var keptBeforeCursor = 0;

  for (var i = 0; i < raw.length; i++) {
    final unit = raw.codeUnitAt(i);
    String char;
    if (_isAsciiDigit(unit)) {
      char = String.fromCharCode(unit);
    } else if (_isBengaliDigit(unit)) {
      char = String.fromCharCode(0x30 + unit - 0x09E6);
    } else if (unit == 0x2E) {
      if (seenPoint) return null;
      seenPoint = true;
      char = '.';
    } else if (unit == 0x2D && allowNegative && !negative && kept.isEmpty) {
      negative = true;
      signBeforeCursor = i < caret;
      continue;
    } else {
      continue;
    }
    kept.write(char);
    if (i < caret) keptBeforeCursor++;
  }

  final text = kept.toString();
  final point = text.indexOf('.');
  var whole = point < 0 ? text : text.substring(0, point);
  final fraction = point < 0 ? '' : text.substring(point + 1);
  if (fraction.length > 2) return null;

  // Leading zeros go, but a whole part keeps at least one digit.
  var zeros = 0;
  while (zeros < whole.length - 1 && whole[zeros] == '0') {
    zeros++;
  }
  if (zeros > 0) {
    whole = whole.substring(zeros);
    keptBeforeCursor -= zeros < keptBeforeCursor ? zeros : keptBeforeCursor;
  }
  // A lone point becomes "0.". The new zero sits before everything typed.
  if (whole.isEmpty && seenPoint) {
    whole = '0';
    if (keptBeforeCursor > 0) keptBeforeCursor++;
  }

  if (whole.isNotEmpty) {
    final paisa = BigInt.parse(whole) * BigInt.from(100) +
        BigInt.parse('0${fraction.padRight(2, '0')}');
    if (paisa > _maxPaisa) return null;
  }

  final sign = negative ? '-' : '';
  final body = whole.isEmpty
      ? ''
      : '${applyGrouping(whole, grouping)}${seenPoint ? '.$fraction' : ''}';
  final ascii = '$sign$body';
  final formatted = bengaliDigits ? toBengaliDigits(ascii) : ascii;

  // Put the cursor after the same number of significant characters.
  final target = keptBeforeCursor + (signBeforeCursor ? 1 : 0);
  var seen = 0;
  var position = 0;
  while (position < formatted.length && seen < target) {
    if (_isSignificant(formatted.codeUnitAt(position))) seen++;
    position++;
  }
  return TakaEdit(formatted, position);
}

/// Applies an edit from [oldText] (cursor at [oldCursor]) to [newText] (cursor
/// at [newCursor]) and reformats the result with [reformatTakaInput].
///
/// When the edit removed only a comma, the digit next to it is removed too:
/// the one before it for backspace, the one after it for forward delete.
/// Otherwise the comma would come straight back and the key would seem to do
/// nothing.
///
/// Returns `null` when the edit must be rejected and [oldText] kept.
TakaEdit? editTakaInput({
  required String oldText,
  required int oldCursor,
  required String newText,
  required int newCursor,
  required Grouping grouping,
  required bool bengaliDigits,
  required bool allowNegative,
}) {
  var text = newText;
  var cursor = newCursor;

  final removedOne = newText.length == oldText.length - 1;
  if (removedOne && cursor >= 0 && cursor < oldText.length) {
    final removedComma = oldText[cursor] == ',' &&
        oldText.substring(0, cursor) == newText.substring(0, cursor) &&
        oldText.substring(cursor + 1) == newText.substring(cursor);
    if (removedComma) {
      final backspace = oldCursor == cursor + 1;
      if (backspace && cursor > 0) {
        text = text.substring(0, cursor - 1) + text.substring(cursor);
        cursor -= 1;
      } else if (!backspace && cursor < text.length) {
        text = text.substring(0, cursor) + text.substring(cursor + 1);
      }
    }
  }

  return reformatTakaInput(
    text,
    cursor,
    grouping: grouping,
    bengaliDigits: bengaliDigits,
    allowNegative: allowNegative,
  );
}

/// Reads the amount in [text], the text of a taka input, in paisa.
///
/// Accepts the in-progress forms that [reformatTakaInput] allows while typing,
/// such as `12.` and `-`, by dropping a trailing point first. Returns `null`
/// for empty text, a lone minus sign, or text that is not an amount.
int? paisaOfTakaInput(String text) {
  var cleaned = text.trim();
  if (cleaned.endsWith('.')) cleaned = cleaned.substring(0, cleaned.length - 1);
  if (cleaned.isEmpty || cleaned == '-') return null;
  return parsePaisa(cleaned).paisa;
}

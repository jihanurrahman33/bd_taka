import 'package:flutter/services.dart';

import '../grouping.dart';
import '../input_editing.dart';
import '../taka.dart';

/// Formats a text field as a taka amount while the person types.
///
/// Digits are grouped as they are entered (`12,34,567.50` by default) and the
/// cursor stays after the digit it followed, so inserting or deleting in the
/// middle of a number works as expected. Digits typed in either script are
/// accepted. Edits that would make the text invalid, such as a second decimal
/// point, a third decimal digit or an amount outside the range of [Taka], are
/// ignored and the previous text is kept.
///
/// ```dart
/// TextField(
///   keyboardType: const TextInputType.numberWithOptions(decimal: true),
///   inputFormatters: const [TakaInputFormatter()],
///   decoration: const InputDecoration(prefixText: '৳ '),
///   onChanged: (text) => amount = TakaInputFormatter.tryParse(text),
/// )
/// ```
///
/// The formatter does not add the ৳ symbol to the text; use
/// `InputDecoration.prefixText` for that, so the symbol cannot be deleted or
/// end up in the value. `TakaEditingController` offers a matching formatter
/// and reads the field as a [Taka].
class TakaInputFormatter extends TextInputFormatter {
  /// Creates a taka input formatter.
  ///
  /// [grouping] chooses how digits are separated, [bengaliDigits] writes the
  /// text in Bengali digits, and [allowNegative] accepts a leading minus sign.
  const TakaInputFormatter({
    this.grouping = Grouping.southAsian,
    this.bengaliDigits = false,
    this.allowNegative = false,
  });

  /// How digits are separated. Defaults to the South Asian lakh and crore
  /// grouping.
  final Grouping grouping;

  /// Whether the text is written in Bengali digits (`১২,৩৪৫`).
  final bool bengaliDigits;

  /// Whether a leading minus sign is accepted.
  final bool allowNegative;

  /// Reads the amount in [text], the text of a field formatted by a
  /// [TakaInputFormatter].
  ///
  /// Accepts in-progress text such as `12.`. Returns `null` when the field is
  /// empty, holds only a minus sign, or does not contain an amount.
  static Taka? tryParse(String text) {
    final paisa = paisaOfTakaInput(text);
    return paisa == null ? null : Taka.fromPaisa(paisa);
  }

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Leave text alone while an input method is still composing a character,
    // or phonetic Bengali keyboards would break.
    if (newValue.composing.isValid && !newValue.composing.isCollapsed) {
      return newValue;
    }

    final edit = editTakaInput(
      oldText: oldValue.text,
      oldCursor: _cursorOf(oldValue),
      newText: newValue.text,
      newCursor: _cursorOf(newValue),
      grouping: grouping,
      bengaliDigits: bengaliDigits,
      allowNegative: allowNegative,
    );
    if (edit == null) return oldValue;

    return TextEditingValue(
      text: edit.text,
      selection: TextSelection.collapsed(offset: edit.cursor),
    );
  }

  /// The cursor offset of [value], or the end of the text when the selection
  /// is invalid.
  static int _cursorOf(TextEditingValue value) {
    final selection = value.selection;
    if (!selection.isValid) return value.text.length;
    return selection.extentOffset.clamp(0, value.text.length);
  }
}

import 'package:flutter/widgets.dart';

import '../grouping.dart';
import '../taka.dart';
import 'taka_input_formatter.dart';

/// A text controller for a taka input that reads and writes the amount as a
/// [Taka].
///
/// It works with any text field, Material or Cupertino. Pair it with its
/// [formatter] so the text is grouped as the person types, with the same
/// options:
///
/// ```dart
/// final controller = TakaEditingController(taka: Taka(1250));
///
/// TextField(
///   controller: controller,
///   inputFormatters: [controller.formatter],
///   keyboardType: const TextInputType.numberWithOptions(decimal: true),
///   decoration: const InputDecoration(prefixText: '৳ '),
/// );
///
/// controller.taka; // Taka(1250), or null while the field is empty
/// controller.taka = Taka.fromPaisa(99950); // shows 999.50
/// ```
class TakaEditingController extends TextEditingController {
  /// Creates a controller showing [taka], or an empty field when it is
  /// `null`.
  ///
  /// [grouping], [bengaliDigits] and [allowNegative] apply to the text this
  /// controller writes and to its [formatter].
  TakaEditingController({
    Taka? taka,
    this.grouping = Grouping.southAsian,
    this.bengaliDigits = false,
    this.allowNegative = false,
  }) : super(
          text: taka == null
              ? ''
              : _textOf(taka, grouping: grouping, bengaliDigits: bengaliDigits),
        );

  /// How digits are separated. Defaults to the lakh and crore grouping.
  final Grouping grouping;

  /// Whether the text is written in Bengali digits.
  final bool bengaliDigits;

  /// Whether negative amounts can be entered.
  final bool allowNegative;

  /// A [TakaInputFormatter] with the same options as this controller. Pass it
  /// to the field's `inputFormatters`.
  TakaInputFormatter get formatter => TakaInputFormatter(
        grouping: grouping,
        bengaliDigits: bengaliDigits,
        allowNegative: allowNegative,
      );

  /// The amount in the field, or `null` when it is empty or holds no amount.
  ///
  /// In-progress text such as `12.` reads as `12.00`.
  Taka? get taka => TakaInputFormatter.tryParse(text);

  /// Shows [value] in the field with the cursor at the end, or clears the
  /// field when [value] is `null`.
  ///
  /// Whole amounts are shown without decimals (`1,250`); amounts with paisa
  /// show both decimals (`999.50`).
  set taka(Taka? value) {
    final newText = value == null
        ? ''
        : _textOf(value, grouping: grouping, bengaliDigits: bengaliDigits);
    this.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }

  static String _textOf(
    Taka taka, {
    required Grouping grouping,
    required bool bengaliDigits,
  }) =>
      taka.format(
        symbol: false,
        bengaliDigits: bengaliDigits,
        grouping: grouping,
        omitZeroPaisa: true,
      );
}

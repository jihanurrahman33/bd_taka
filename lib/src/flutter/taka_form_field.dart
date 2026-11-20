import 'package:flutter/material.dart';

import '../grouping.dart';
import '../taka.dart';
import 'taka_input_formatter.dart';

/// A form field for entering an amount of taka, reporting it as a [Taka].
///
/// It wraps a [TextFormField] with a [TakaInputFormatter], a numeric keyboard
/// and a ৳ prefix. [onChanged] and [validator] receive the parsed amount, or
/// `null` while the field is empty, so a form never has to parse text itself.
///
/// ```dart
/// TakaFormField(
///   decoration: const InputDecoration(labelText: 'Amount'),
///   onChanged: (amount) => setState(() => _amount = amount),
///   validator: (amount) =>
///       amount == null || amount.isZero ? 'Enter an amount' : null,
/// )
/// ```
class TakaFormField extends StatelessWidget {
  /// Creates a taka form field.
  ///
  /// Pass either [controller] or [initialValue], not both.
  const TakaFormField({
    super.key,
    this.controller,
    this.initialValue,
    this.decoration = const InputDecoration(),
    this.onChanged,
    this.validator,
    this.onSaved,
    this.grouping = Grouping.southAsian,
    this.bengaliDigits = false,
    this.allowNegative = false,
    this.showSymbol = true,
    this.enabled,
    this.autofocus = false,
    this.focusNode,
    this.textInputAction,
    this.autovalidateMode,
  }) : assert(
          controller == null || initialValue == null,
          'Pass either a controller or an initialValue, not both.',
        );

  /// Controls the text of the field. Its text should be empty or already
  /// formatted.
  final TextEditingController? controller;

  /// The amount shown when the field is first built.
  final Taka? initialValue;

  /// The decoration of the field. A ৳ prefix is added unless [showSymbol] is
  /// false or the decoration already has a prefix.
  final InputDecoration decoration;

  /// Called with the parsed amount after every change, or `null` when the
  /// field holds no amount.
  final ValueChanged<Taka?>? onChanged;

  /// Validates the parsed amount, which is `null` when the field is empty.
  final FormFieldValidator<Taka?>? validator;

  /// Called with the parsed amount when the form is saved.
  final FormFieldSetter<Taka?>? onSaved;

  /// How digits are separated. Defaults to the lakh and crore grouping.
  final Grouping grouping;

  /// Whether the text is written in Bengali digits.
  final bool bengaliDigits;

  /// Whether negative amounts can be entered.
  final bool allowNegative;

  /// Whether a ৳ prefix is shown in front of the amount.
  final bool showSymbol;

  /// Whether the field accepts input. Defaults to the enclosing form's value.
  final bool? enabled;

  /// Whether the field takes focus when it is first shown.
  final bool autofocus;

  /// The focus node of the field.
  final FocusNode? focusNode;

  /// The action button shown on the keyboard.
  final TextInputAction? textInputAction;

  /// When the field validates itself.
  final AutovalidateMode? autovalidateMode;

  @override
  Widget build(BuildContext context) {
    final hasPrefix =
        decoration.prefix != null || decoration.prefixText != null;
    final amount = initialValue;

    return TextFormField(
      controller: controller,
      initialValue: amount?.format(
        symbol: false,
        bengaliDigits: bengaliDigits,
        grouping: grouping,
        omitZeroPaisa: true,
      ),
      decoration: showSymbol && !hasPrefix
          ? decoration.copyWith(prefixText: '৳ ')
          : decoration,
      keyboardType: TextInputType.numberWithOptions(
        decimal: true,
        signed: allowNegative,
      ),
      inputFormatters: [
        TakaInputFormatter(
          grouping: grouping,
          bengaliDigits: bengaliDigits,
          allowNegative: allowNegative,
        ),
      ],
      onChanged: onChanged == null
          ? null
          : (text) => onChanged!(TakaInputFormatter.tryParse(text)),
      validator: validator == null
          ? null
          : (text) => validator!(TakaInputFormatter.tryParse(text ?? '')),
      onSaved: onSaved == null
          ? null
          : (text) => onSaved!(TakaInputFormatter.tryParse(text ?? '')),
      enabled: enabled,
      autofocus: autofocus,
      focusNode: focusNode,
      textInputAction: textInputAction,
      autovalidateMode: autovalidateMode,
    );
  }
}

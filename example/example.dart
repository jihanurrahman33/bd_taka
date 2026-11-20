// ignore_for_file: avoid_print

import 'package:bd_taka/bd_taka.dart';

void main() {
  // Exact money: no floating-point surprises.
  print(0.1 + 0.2); // 0.30000000000000004
  print(Taka.fromPaisa(10) + Taka.fromPaisa(20)); // 0.30

  // A 15% VAT on ৳1,250, worked out with integers.
  final price = Taka(1250);
  final vat = price.ratio(15, 100);
  print('VAT $vat, total ${price + vat}');

  // Splitting never creates or loses a paisa.
  print(Taka(100).split(3));
  print(Taka(100).allocate([70, 30]));

  // Display text in the South Asian grouping.
  final amount = Taka.fromPaisa(123456750);
  print(amount.format());
  print(amount.format(bengaliDigits: true));
  print(amount.format(grouping: Grouping.international, symbol: false));
  print(Taka(1250).format(omitZeroPaisa: true));

  // Strict parsing of what people type, in either digit system.
  print(Taka.parse('৳12,34,567.5'));
  print(Taka.parse('-৳১২৫.৫০'));
  print(Taka.tryParse('1.234')); // null: a third decimal would lose paisa

  // Amounts in words, as on a cheque.
  print(Taka.fromPaisa(12550).toEnglishWords());
  print(Taka.fromPaisa(12550).toBanglaWords());
  print(Taka(1234567).toBanglaWords());
}

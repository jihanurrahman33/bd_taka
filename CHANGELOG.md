## 0.2.0

### Breaking changes

- `bd_taka` now depends on the Flutter SDK (Flutter 3.10.0 or later), so it can
  ship a text-field formatter. **A pure-Dart project (a server or CLI) can no
  longer resolve it: stay on `bd_taka: ^0.1.0`**, which has the same money API.
  Nothing in the `Taka` API changed.

### New

- `TakaInputFormatter`: a `TextInputFormatter` that groups an amount as it is
  typed, keeps the cursor after the digit it followed, accepts ASCII or Bengali
  digits, ignores edits that would make the text invalid, deletes the digit
  before a comma on backspace, and leaves text being composed by a phonetic
  keyboard alone. `TakaInputFormatter.tryParse` reads the amount.
- `TakaEditingController`: a `TextEditingController` with a `taka` getter and
  setter and a matching `formatter`.
- Both use only `package:flutter/services.dart` and `widgets.dart`, so they
  work with Material, Cupertino or any other text field.

## 0.1.0

First release.

- `Taka`: an exact amount stored as integer paisa, with `+`, `-`, `*`, comparison,
  `ratio` (exact fractions with seven `RoundingMode`s), `split` and `allocate`.
  Amounts are limited to ±(2^53 − 1) paisa so they are exact on the web; going
  outside the range throws a `RangeError`.
- `Taka.format`: lakh/crore, international or no grouping, optional ৳ symbol and
  Bengali digits.
- `Taka.parse` and `Taka.tryParse`: strict parsing of what `format` writes, in
  ASCII or Bengali digits.
- `Taka.toEnglishWords` and `Taka.toBanglaWords`: amount in words for cheques
  and invoices.

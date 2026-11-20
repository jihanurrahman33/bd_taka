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

/// How the digits of an amount are separated with commas.
enum Grouping {
  /// The South Asian system used in Bangladesh: the last three digits, then
  /// groups of two (`12,34,567`). Each group is named: thousand, lakh, crore.
  southAsian,

  /// Groups of three digits (`1,234,567`).
  international,

  /// No separators (`1234567`).
  none,
}

/// Inserts commas into [digits], a string of ASCII digits, following [grouping].
String applyGrouping(String digits, Grouping grouping) {
  switch (grouping) {
    case Grouping.none:
      return digits;
    case Grouping.international:
      return _group(digits, firstGroup: 3, nextGroup: 3);
    case Grouping.southAsian:
      return _group(digits, firstGroup: 3, nextGroup: 2);
  }
}

/// Groups [digits] from the right: the rightmost group has [firstGroup]
/// digits and every group to its left has [nextGroup] digits.
String _group(
  String digits, {
  required int firstGroup,
  required int nextGroup,
}) {
  if (digits.length <= firstGroup) return digits;

  final head = digits.substring(0, digits.length - firstGroup);
  final tail = digits.substring(digits.length - firstGroup);

  final groups = <String>[];
  var end = head.length;
  while (end > 0) {
    final start = end - nextGroup < 0 ? 0 : end - nextGroup;
    groups.insert(0, head.substring(start, end));
    end = start;
  }
  return '${groups.join(',')},$tail';
}

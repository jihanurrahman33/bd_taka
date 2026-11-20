# Contributing

1. Fork and create a branch.
2. Write a failing test first, then the fix or feature.
3. Run before pushing:
   ```bash
   dart format .
   dart analyze --fatal-infos
   dart test -p vm,chrome
   ```
   The web run matters: `int` behaves differently under dart2js, and this
   package promises exact amounts there too.
4. Add a `CHANGELOG.md` entry and open a PR.

## Guidelines

- **Money stays integer.** Never route an amount through `double`, not even
  temporarily. Use `BigInt` for intermediate products so nothing overflows
  before the range check.
- **Rounding is explicit.** Anything that can lose a fraction of a paisa takes
  a `RoundingMode` or rejects the input. Nothing is dropped silently.
- **Keep it strict.** `Taka.parse` rejects input it would have to guess at.
  Relaxing that needs a discussion first.
- **Bangla words.** The 0 to 99 table in `lib/src/words_bn.dart` is mirrored in
  `test/src/words_bn_test.dart` on purpose, so a word cannot change by
  accident. If you believe a word is wrong, open an issue with a source
  (a dictionary or Bangla Academy reference) before changing both files.

## Releasing (maintainer)

1. Bump `version` in `pubspec.yaml` and finalize the changelog.
2. Merge to `main`, then `git tag vX.Y.Z && git push --tags`.
3. The `publish.yml` workflow publishes to pub.dev (automated publishing must be
   enabled once in the package Admin tab, with the tag pattern `v{{version}}`).

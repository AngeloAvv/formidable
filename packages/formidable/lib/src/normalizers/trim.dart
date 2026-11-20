import 'normalizer.dart';

/// Trims whitespace around the text before validation. Text that is only
/// whitespace becomes Unset.
///
/// Trimming is opt-in: without `@Trim()` the whitespace the user typed is kept.
class Trim extends FormidableNormalizer<String> {
  const Trim();

  @override
  String normalize(String value) => value.trim();

  @override
  bool makesUnset(String normalized) => normalized.isEmpty;
}

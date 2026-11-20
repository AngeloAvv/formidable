/// A rule attached to a Field that rewrites its value before validation.
///
/// A Normalizer is a const class declared as an annotation on the Field, like
/// a Validator. It applies only when you declare it, and only when the Field
/// has a value. A Normalizer typed for a non-nullable value is skipped when the
/// chosen value is null.
abstract class FormidableNormalizer<T> {
  const FormidableNormalizer();

  /// Returns [value] rewritten, or [value] itself when nothing changes.
  T normalize(T value);

  /// Whether the Field becomes Unset when [normalized], the result of
  /// [normalize], is what the Normalizer produced. Defaults to false.
  bool makesUnset(T normalized) => false;

  /// Whether a chosen value of null is passed to [normalize].
  bool get acceptsNull => null is T;
}

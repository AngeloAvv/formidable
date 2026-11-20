import 'validation_error.dart';

/// A synchronous rule attached to a Field.
///
/// A Validator is a const class with a single [validate] method. It is
/// declared as an annotation on the Field, and the generator rebuilds that
/// annotation in the generated Form.
///
/// [validate] is called only when the Field has a value. A Validator typed for
/// a non-nullable value is skipped when the chosen value is null.
abstract class FormidableValidator<T> {
  const FormidableValidator();

  /// Returns the errors for [value], or an empty list when it is valid.
  List<FormidableValidationError> validate(T value);

  /// Whether a chosen value of null is passed to [validate].
  bool get acceptsNull => null is T;

  /// Whether a Field of value type [V] can use this Validator: [V] is [T] or a
  /// subtype of it, ignoring nullability.
  ///
  /// The generator checks this when a Validator is an annotation. A Dynamic
  /// Form has no annotations, so it asks the Validator at runtime instead.
  bool fitsValueType<V>() => <V>[] is List<T?>;
}

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
}

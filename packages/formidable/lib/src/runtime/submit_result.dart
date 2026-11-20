import '../validation/validation_error.dart';
import 'field.dart';

/// The outcome of `submit()`: valid with the Schema instance, or invalid with
/// the errors. Handle both with an exhaustive `switch`.
sealed class FormidableSubmitResult<S> {
  const FormidableSubmitResult();
}

/// Every Field is valid. [value] is the Schema instance.
final class FormidableSubmitValid<S> extends FormidableSubmitResult<S> {
  const FormidableSubmitValid(this.value);

  final S value;
}

/// At least one Field is invalid.
final class FormidableSubmitInvalid<S> extends FormidableSubmitResult<S> {
  const FormidableSubmitInvalid(this.fieldErrors);

  /// The errors of every invalid Field, addressed by its typed handle.
  final Map<FormidableField<Object?>, List<FormidableValidationError>>
  fieldErrors;
}

import '../validation/validation_error.dart';
import 'field.dart';
import 'field_array.dart';
import 'node.dart';

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
  const FormidableSubmitInvalid(
    this.fieldErrors, {
    this.arrayErrors = const {},
  });

  /// The errors of every invalid Field, addressed by its typed handle.
  final Map<FormidableField<Object?>, List<FormidableValidationError>>
  fieldErrors;

  /// The errors of the Field Arrays themselves (a minimum number of items, an
  /// empty required array), addressed by their typed handle. The errors of the
  /// items are in [fieldErrors], in tree order.
  final Map<
    FormidableFieldArray<FormidableNode, Object?>,
    List<FormidableValidationError>
  >
  arrayErrors;
}

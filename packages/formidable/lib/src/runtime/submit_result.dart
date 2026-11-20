import '../validation/validation_error.dart';
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
  const FormidableSubmitInvalid(this.errors);

  /// The errors of every invalid Field and of every Field Array that has
  /// errors of its own (a minimum number of items, an empty required array),
  /// addressed by its typed handle, in tree order. A Field Array comes before
  /// the Fields of its items.
  final Map<FormidableNode, List<FormidableValidationError>> errors;
}

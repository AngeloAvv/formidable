import 'validation_error.dart';

/// A Required Field is Unset.
final class FormidableRequiredError extends FormidableValidationError {
  const FormidableRequiredError();

  @override
  String toString() => 'This field is required.';
}

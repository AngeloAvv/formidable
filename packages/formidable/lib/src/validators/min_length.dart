import '../validation/validation_error.dart';
import '../validation/validator.dart';

/// The value is shorter than the required minimum length.
final class FormidableMinLengthError extends FormidableValidationError {
  const FormidableMinLengthError({
    required this.minLength,
    required this.actualLength,
  });

  /// The minimum length the Validator requires.
  final int minLength;

  /// The length of the rejected value.
  final int actualLength;

  @override
  List<Object?> get props => [minLength, actualLength];

  @override
  String toString() =>
      'Must be at least $minLength characters long (got $actualLength).';
}

/// The value must be at least [minLength] characters long.
class MinLength extends FormidableValidator<String> {
  const MinLength(this.minLength);

  final int minLength;

  @override
  List<FormidableValidationError> validate(String value) =>
      value.length < minLength
      ? [
          FormidableMinLengthError(
            minLength: minLength,
            actualLength: value.length,
          ),
        ]
      : const [];
}

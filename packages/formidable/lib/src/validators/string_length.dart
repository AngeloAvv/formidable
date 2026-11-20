import '../validation/validation_error.dart';
import '../validation/validator.dart';
import 'min_length.dart';

/// The value is longer than the allowed maximum length.
final class FormidableMaxLengthError extends FormidableValidationError {
  const FormidableMaxLengthError({
    required this.maxLength,
    required this.actualLength,
  });

  /// The maximum length the Validator allows.
  final int maxLength;

  /// The length of the rejected value.
  final int actualLength;

  @override
  List<Object?> get props => [maxLength, actualLength];

  @override
  String toString() =>
      'Must be at most $maxLength characters long (got $actualLength).';
}

/// The value does not have the exact required length.
final class FormidableExactLengthError extends FormidableValidationError {
  const FormidableExactLengthError({
    required this.length,
    required this.actualLength,
  });

  /// The length the Validator requires.
  final int length;

  /// The length of the rejected value.
  final int actualLength;

  @override
  List<Object?> get props => [length, actualLength];

  @override
  String toString() =>
      'Must be exactly $length characters long (got $actualLength).';
}

/// The value must be at most [maxLength] characters long.
class MaxLength extends FormidableValidator<String> {
  const MaxLength(this.maxLength);

  final int maxLength;

  @override
  List<FormidableValidationError> validate(String value) =>
      value.length > maxLength
      ? [
          FormidableMaxLengthError(
            maxLength: maxLength,
            actualLength: value.length,
          ),
        ]
      : const [];
}

/// The value must have an exact length, or a length within a range.
///
/// A range reports `FormidableMinLengthError` or `FormidableMaxLengthError`,
/// the same errors as `MinLength` and `MaxLength`.
class Length extends FormidableValidator<String> {
  /// The value must be exactly [length] characters long.
  const Length.exactly(int this.length) : min = null, max = null;

  /// The value must be between [min] and [max] characters long, both included.
  const Length.between(int this.min, int this.max) : length = null;

  final int? length;
  final int? min;
  final int? max;

  @override
  List<FormidableValidationError> validate(String value) {
    final actual = value.length;
    final length = this.length;
    if (length != null) {
      return actual == length
          ? const []
          : [FormidableExactLengthError(length: length, actualLength: actual)];
    }
    final min = this.min!;
    final max = this.max!;
    if (actual < min) {
      return [FormidableMinLengthError(minLength: min, actualLength: actual)];
    }
    if (actual > max) {
      return [FormidableMaxLengthError(maxLength: max, actualLength: actual)];
    }
    return const [];
  }
}

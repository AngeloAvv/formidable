import '../validation/validation_error.dart';
import '../validation/validator.dart';

/// The array has fewer items than the minimum.
final class FormidableMinItemsError extends FormidableValidationError {
  const FormidableMinItemsError({required this.min, required this.actual});

  /// The minimum number of items.
  final int min;

  /// The number of items there are.
  final int actual;

  @override
  List<Object?> get props => [min, actual];

  @override
  String toString() => 'Must have at least $min items (got $actual).';
}

/// The array has more items than the maximum.
final class FormidableMaxItemsError extends FormidableValidationError {
  const FormidableMaxItemsError({required this.max, required this.actual});

  /// The maximum number of items.
  final int max;

  /// The number of items there are.
  final int actual;

  @override
  List<Object?> get props => [max, actual];

  @override
  String toString() => 'Must have at most $max items (got $actual).';
}

/// A Field Array (or any list) must have at least [min] items.
class MinItems extends FormidableValidator<Iterable<Object?>> {
  const MinItems(this.min);

  final int min;

  @override
  List<FormidableValidationError> validate(Iterable<Object?> value) =>
      value.length < min
      ? [FormidableMinItemsError(min: min, actual: value.length)]
      : const [];
}

/// A Field Array (or any list) must have at most [max] items.
class MaxItems extends FormidableValidator<Iterable<Object?>> {
  const MaxItems(this.max);

  final int max;

  @override
  List<FormidableValidationError> validate(Iterable<Object?> value) =>
      value.length > max
      ? [FormidableMaxItemsError(max: max, actual: value.length)]
      : const [];
}

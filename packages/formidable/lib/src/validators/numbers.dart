import '../validation/validation_error.dart';
import '../validation/validator.dart';

// Number Validators. They are typed for `num`, so they fit `int` and `double`
// Fields. NaN never satisfies a bound, so every comparison below is written
// as "not within the bound" rather than "outside the bound".

/// The value is below the minimum of a [Min].
final class FormidableMinError extends FormidableValidationError {
  const FormidableMinError({
    required this.min,
    required this.exclusive,
    required this.actual,
  });

  /// The bound the Validator requires.
  final num min;

  /// Whether the bound itself is rejected too.
  final bool exclusive;

  /// The rejected value.
  final num actual;

  @override
  List<Object?> get props => [min, exclusive, actual];

  @override
  String toString() => exclusive
      ? 'Must be greater than $min (got $actual).'
      : 'Must be at least $min (got $actual).';
}

/// The value must be at least [min], or greater than it when [exclusive].
class Min extends FormidableValidator<num> {
  const Min(this.min, {this.exclusive = false});

  final num min;
  final bool exclusive;

  @override
  List<FormidableValidationError> validate(num value) =>
      (exclusive ? value > min : value >= min)
      ? const []
      : [FormidableMinError(min: min, exclusive: exclusive, actual: value)];
}

/// The value is above the maximum of a [Max].
final class FormidableMaxError extends FormidableValidationError {
  const FormidableMaxError({
    required this.max,
    required this.exclusive,
    required this.actual,
  });

  /// The bound the Validator requires.
  final num max;

  /// Whether the bound itself is rejected too.
  final bool exclusive;

  /// The rejected value.
  final num actual;

  @override
  List<Object?> get props => [max, exclusive, actual];

  @override
  String toString() => exclusive
      ? 'Must be less than $max (got $actual).'
      : 'Must be at most $max (got $actual).';
}

/// The value must be at most [max], or less than it when [exclusive].
class Max extends FormidableValidator<num> {
  const Max(this.max, {this.exclusive = false});

  final num max;
  final bool exclusive;

  @override
  List<FormidableValidationError> validate(num value) =>
      (exclusive ? value < max : value <= max)
      ? const []
      : [FormidableMaxError(max: max, exclusive: exclusive, actual: value)];
}

/// The value is outside the bounds of a [Range].
final class FormidableRangeError extends FormidableValidationError {
  const FormidableRangeError({
    required this.min,
    required this.max,
    required this.actual,
  });

  final num min;
  final num max;
  final num actual;

  @override
  List<Object?> get props => [min, max, actual];

  @override
  String toString() => 'Must be between $min and $max (got $actual).';
}

/// The value must be between [min] and [max], both included.
class Range extends FormidableValidator<num> {
  const Range(this.min, this.max);

  final num min;
  final num max;

  @override
  List<FormidableValidationError> validate(num value) =>
      value >= min && value <= max
      ? const []
      : [FormidableRangeError(min: min, max: max, actual: value)];
}

/// The value is not greater than zero.
final class FormidablePositiveError extends FormidableValidationError {
  const FormidablePositiveError(this.actual);

  final num actual;

  @override
  List<Object?> get props => [actual];

  @override
  String toString() => 'Must be greater than zero (got $actual).';
}

/// The value must be greater than zero.
class Positive extends FormidableValidator<num> {
  const Positive();

  @override
  List<FormidableValidationError> validate(num value) =>
      value > 0 ? const [] : [FormidablePositiveError(value)];
}

/// The value is less than zero.
final class FormidablePositiveOrZeroError extends FormidableValidationError {
  const FormidablePositiveOrZeroError(this.actual);

  final num actual;

  @override
  List<Object?> get props => [actual];

  @override
  String toString() => 'Must be zero or greater (got $actual).';
}

/// The value must be zero or greater.
class PositiveOrZero extends FormidableValidator<num> {
  const PositiveOrZero();

  @override
  List<FormidableValidationError> validate(num value) =>
      value >= 0 ? const [] : [FormidablePositiveOrZeroError(value)];
}

/// The value is not less than zero.
final class FormidableNegativeError extends FormidableValidationError {
  const FormidableNegativeError(this.actual);

  final num actual;

  @override
  List<Object?> get props => [actual];

  @override
  String toString() => 'Must be less than zero (got $actual).';
}

/// The value must be less than zero.
class Negative extends FormidableValidator<num> {
  const Negative();

  @override
  List<FormidableValidationError> validate(num value) =>
      value < 0 ? const [] : [FormidableNegativeError(value)];
}

/// The value is greater than zero.
final class FormidableNegativeOrZeroError extends FormidableValidationError {
  const FormidableNegativeOrZeroError(this.actual);

  final num actual;

  @override
  List<Object?> get props => [actual];

  @override
  String toString() => 'Must be zero or less (got $actual).';
}

/// The value must be zero or less.
class NegativeOrZero extends FormidableValidator<num> {
  const NegativeOrZero();

  @override
  List<FormidableValidationError> validate(num value) =>
      value <= 0 ? const [] : [FormidableNegativeOrZeroError(value)];
}

/// The value is zero.
final class FormidableNonZeroError extends FormidableValidationError {
  const FormidableNonZeroError();

  @override
  String toString() => 'Must not be zero.';
}

/// The value must not be zero.
class NonZero extends FormidableValidator<num> {
  const NonZero();

  @override
  List<FormidableValidationError> validate(num value) =>
      value == 0 ? const [FormidableNonZeroError()] : const [];
}

/// The value is not a multiple of the divisor of a [MultipleOf].
final class FormidableMultipleOfError extends FormidableValidationError {
  const FormidableMultipleOfError({
    required this.divisor,
    required this.actual,
  });

  final num divisor;
  final num actual;

  @override
  List<Object?> get props => [divisor, actual];

  @override
  String toString() => 'Must be a multiple of $divisor (got $actual).';
}

/// The value must be a multiple of [divisor], which cannot be zero.
///
/// Fractional divisors tolerate floating point noise, so `0.3` is a multiple
/// of `0.1`.
class MultipleOf extends FormidableValidator<num> {
  const MultipleOf(this.divisor) : assert(divisor != 0, 'divisor is zero');

  final num divisor;

  @override
  List<FormidableValidationError> validate(num value) {
    final bool multiple;
    if (value is int && divisor is int) {
      multiple = value % (divisor as int) == 0;
    } else {
      final quotient = value / divisor;
      multiple =
          quotient.isFinite &&
          (quotient - quotient.roundToDouble()).abs() <=
              1e-9 * (quotient.abs() > 1 ? quotient.abs() : 1);
    }
    return multiple
        ? const []
        : [FormidableMultipleOfError(divisor: divisor, actual: value)];
  }
}

/// The value is odd.
final class FormidableEvenError extends FormidableValidationError {
  const FormidableEvenError(this.actual);

  final int actual;

  @override
  List<Object?> get props => [actual];

  @override
  String toString() => 'Must be an even number (got $actual).';
}

/// The value must be even.
class Even extends FormidableValidator<int> {
  const Even();

  @override
  List<FormidableValidationError> validate(int value) =>
      value.isEven ? const [] : [FormidableEvenError(value)];
}

/// The value is even.
final class FormidableOddError extends FormidableValidationError {
  const FormidableOddError(this.actual);

  final int actual;

  @override
  List<Object?> get props => [actual];

  @override
  String toString() => 'Must be an odd number (got $actual).';
}

/// The value must be odd.
class Odd extends FormidableValidator<int> {
  const Odd();

  @override
  List<FormidableValidationError> validate(int value) =>
      value.isOdd ? const [] : [FormidableOddError(value)];
}

/// The value has more decimal places than a [DecimalPlaces] allows.
final class FormidableDecimalPlacesError extends FormidableValidationError {
  const FormidableDecimalPlacesError({
    required this.maxPlaces,
    required this.actualPlaces,
  });

  final int maxPlaces;
  final int actualPlaces;

  @override
  List<Object?> get props => [maxPlaces, actualPlaces];

  @override
  String toString() =>
      'Must have at most $maxPlaces decimal places (got $actualPlaces).';
}

/// The value must have at most [maxPlaces] decimal places.
///
/// The places are counted on the shortest decimal representation of the
/// number, so `0.1 + 0.2` has 17 places.
class DecimalPlaces extends FormidableValidator<num> {
  const DecimalPlaces(this.maxPlaces);

  final int maxPlaces;

  @override
  List<FormidableValidationError> validate(num value) {
    final places = _decimalPlacesOf(value);
    return places <= maxPlaces
        ? const []
        : [
            FormidableDecimalPlacesError(
              maxPlaces: maxPlaces,
              actualPlaces: places,
            ),
          ];
  }
}

int _decimalPlacesOf(num value) {
  if (value is int || !value.isFinite) return 0;
  final text = value.toString();
  final exponentAt = text.indexOf('e');
  final mantissa = exponentAt < 0 ? text : text.substring(0, exponentAt);
  final exponent = exponentAt < 0
      ? 0
      : int.parse(text.substring(exponentAt + 1));
  final dot = mantissa.indexOf('.');
  final fraction = dot < 0 ? '' : mantissa.substring(dot + 1);
  final trimmed = fraction == '0' ? '' : fraction;
  final places = trimmed.length - exponent;
  return places < 0 ? 0 : places;
}

/// The digits of the integer part, ignoring the sign. Zero has one digit and a
/// number that is not finite has none.
int _integerDigitsOf(num value) {
  if (!value.isFinite) return 0;
  return value.abs().truncate().toString().length;
}

/// The integer part of the value does not have the digits a [Digits] needs.
final class FormidableDigitsError extends FormidableValidationError {
  const FormidableDigitsError({
    required this.digits,
    required this.actualDigits,
  });

  final int digits;
  final int actualDigits;

  @override
  List<Object?> get props => [digits, actualDigits];

  @override
  String toString() => 'Must have exactly $digits digits (got $actualDigits).';
}

/// The integer part of the value must have exactly [digits] digits.
class Digits extends FormidableValidator<num> {
  const Digits(this.digits);

  final int digits;

  @override
  List<FormidableValidationError> validate(num value) {
    final actual = _integerDigitsOf(value);
    return actual == digits
        ? const []
        : [FormidableDigitsError(digits: digits, actualDigits: actual)];
  }
}

/// The integer part of the value has fewer digits than a [MinDigits] needs.
final class FormidableMinDigitsError extends FormidableValidationError {
  const FormidableMinDigitsError({
    required this.minDigits,
    required this.actualDigits,
  });

  final int minDigits;
  final int actualDigits;

  @override
  List<Object?> get props => [minDigits, actualDigits];

  @override
  String toString() =>
      'Must have at least $minDigits digits (got $actualDigits).';
}

/// The integer part of the value must have at least [minDigits] digits.
class MinDigits extends FormidableValidator<num> {
  const MinDigits(this.minDigits);

  final int minDigits;

  @override
  List<FormidableValidationError> validate(num value) {
    final actual = _integerDigitsOf(value);
    return actual >= minDigits
        ? const []
        : [
            FormidableMinDigitsError(
              minDigits: minDigits,
              actualDigits: actual,
            ),
          ];
  }
}

/// The integer part of the value has more digits than a [MaxDigits] allows.
final class FormidableMaxDigitsError extends FormidableValidationError {
  const FormidableMaxDigitsError({
    required this.maxDigits,
    required this.actualDigits,
  });

  final int maxDigits;
  final int actualDigits;

  @override
  List<Object?> get props => [maxDigits, actualDigits];

  @override
  String toString() =>
      'Must have at most $maxDigits digits (got $actualDigits).';
}

/// The integer part of the value must have at most [maxDigits] digits.
class MaxDigits extends FormidableValidator<num> {
  const MaxDigits(this.maxDigits);

  final int maxDigits;

  @override
  List<FormidableValidationError> validate(num value) {
    final actual = _integerDigitsOf(value);
    return actual <= maxDigits
        ? const []
        : [
            FormidableMaxDigitsError(
              maxDigits: maxDigits,
              actualDigits: actual,
            ),
          ];
  }
}

/// The value is not a TCP or UDP port.
final class FormidablePortError extends FormidableValidationError {
  const FormidablePortError(this.actual);

  final int actual;

  @override
  List<Object?> get props => [actual];

  @override
  String toString() => 'Must be a port between 1 and 65535 (got $actual).';
}

/// The value must be a port number, from 1 to 65535.
class Port extends FormidableValidator<int> {
  const Port();

  @override
  List<FormidableValidationError> validate(int value) =>
      value >= 1 && value <= 65535 ? const [] : [FormidablePortError(value)];
}

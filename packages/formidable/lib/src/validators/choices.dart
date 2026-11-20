import '../validation/validation_error.dart';
import '../validation/validator.dart';

// Choice and equality Validators. The values to compare with are const, so
// they can be numbers, strings, booleans or enum values.

/// The value is not true.
final class FormidableIsTrueError extends FormidableValidationError {
  const FormidableIsTrueError();

  @override
  String toString() => 'Must be accepted.';
}

/// The value must be true, for example a "I accept the terms" checkbox.
class IsTrue extends FormidableValidator<bool> {
  const IsTrue();

  @override
  List<FormidableValidationError> validate(bool value) =>
      value ? const [] : const [FormidableIsTrueError()];
}

/// Another name for [IsTrue].
typedef Accepted = IsTrue;

/// The value is not false.
final class FormidableIsFalseError extends FormidableValidationError {
  const FormidableIsFalseError();

  @override
  String toString() => 'Must be declined.';
}

/// The value must be false.
class IsFalse extends FormidableValidator<bool> {
  const IsFalse();

  @override
  List<FormidableValidationError> validate(bool value) =>
      value ? const [FormidableIsFalseError()] : const [];
}

/// Another name for [IsFalse].
typedef Declined = IsFalse;

bool _sameChoice(Object? a, Object? b, {required bool ignoreCase}) =>
    ignoreCase && a is String && b is String
    ? a.toLowerCase() == b.toLowerCase()
    : a == b;

/// The value is not one of the allowed values of a [OneOf].
final class FormidableOneOfError extends FormidableValidationError {
  const FormidableOneOfError({required this.allowed, required this.actual});

  /// The values the Validator accepts, in declaration order.
  final List<Object?> allowed;

  /// The rejected value.
  final Object? actual;

  @override
  List<Object?> get props => [allowed.length, ...allowed, actual];

  @override
  String toString() => 'Must be one of ${allowed.join(', ')}.';
}

/// The value must be one of [values]. With [ignoreCase], strings are compared
/// without regard to case.
class OneOf extends FormidableValidator<Object> {
  const OneOf(this.values, {this.ignoreCase = false});

  final List<Object?> values;
  final bool ignoreCase;

  @override
  List<FormidableValidationError> validate(Object value) =>
      values.any(
        (allowed) => _sameChoice(allowed, value, ignoreCase: ignoreCase),
      )
      ? const []
      : [FormidableOneOfError(allowed: values, actual: value)];
}

/// The value is one of the forbidden values of a [NoneOf].
final class FormidableNoneOfError extends FormidableValidationError {
  const FormidableNoneOfError({required this.disallowed, required this.actual});

  /// The values the Validator rejects, in declaration order.
  final List<Object?> disallowed;

  /// The rejected value.
  final Object? actual;

  @override
  List<Object?> get props => [disallowed.length, ...disallowed, actual];

  @override
  String toString() => 'Must not be any of ${disallowed.join(', ')}.';
}

/// The value must not be any of [values]. With [ignoreCase], strings are
/// compared without regard to case.
class NoneOf extends FormidableValidator<Object> {
  const NoneOf(this.values, {this.ignoreCase = false});

  final List<Object?> values;
  final bool ignoreCase;

  @override
  List<FormidableValidationError> validate(Object value) =>
      values.any((banned) => _sameChoice(banned, value, ignoreCase: ignoreCase))
      ? [FormidableNoneOfError(disallowed: values, actual: value)]
      : const [];
}

/// The value is not equal to the constant of an [EqualTo].
final class FormidableEqualToError extends FormidableValidationError {
  const FormidableEqualToError({required this.expected, required this.actual});

  final Object? expected;
  final Object? actual;

  @override
  List<Object?> get props => [expected, actual];

  @override
  String toString() => 'Must be equal to $expected.';
}

/// The value must be equal to a constant. To compare with another Field, use a
/// cross-field rule.
class EqualTo extends FormidableValidator<Object> {
  const EqualTo(this.expected);

  final Object expected;

  @override
  List<FormidableValidationError> validate(Object value) => value == expected
      ? const []
      : [FormidableEqualToError(expected: expected, actual: value)];
}

/// The value is equal to the constant of a [NotEqualTo].
final class FormidableNotEqualToError extends FormidableValidationError {
  const FormidableNotEqualToError({required this.unexpected});

  final Object? unexpected;

  @override
  List<Object?> get props => [unexpected];

  @override
  String toString() => 'Must not be equal to $unexpected.';
}

/// The value must differ from a constant.
class NotEqualTo extends FormidableValidator<Object> {
  const NotEqualTo(this.unexpected);

  final Object unexpected;

  @override
  List<FormidableValidationError> validate(Object value) => value == unexpected
      ? [FormidableNotEqualToError(unexpected: unexpected)]
      : const [];
}

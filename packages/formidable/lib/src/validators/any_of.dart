import '../validation/validation_error.dart';
import '../validation/validator.dart';

/// None of the alternatives of an [AnyOf] accepted the value.
final class FormidableAnyOfError extends FormidableValidationError {
  const FormidableAnyOfError(this.failures);

  /// The errors of each alternative, in the order they were declared.
  final List<List<FormidableValidationError>> failures;

  @override
  List<Object?> get props => [
    for (final errors in failures) ...[errors.length, ...errors],
  ];

  @override
  String toString() => 'Does not satisfy any of the allowed rules.';
}

/// The value passes when any of the [validators] passes. It is the only
/// built-in combinator.
///
/// It is not generic, so the Validators it holds can be typed differently, for
/// example a `String` Validator next to a `Pattern` Validator. The generator
/// checks each one against the type of the Field, so a Validator that does not
/// fit fails the build.
///
/// A Validator that is skipped because the chosen value is null counts as
/// passing, like it does outside a combinator. An `AnyOf` without Validators
/// never passes.
class AnyOf extends FormidableValidator<Object?> {
  const AnyOf(this.validators);

  final List<FormidableValidator<Object?>> validators;

  @override
  List<FormidableValidationError> validate(Object? value) {
    final failures = <List<FormidableValidationError>>[];
    for (final validator in validators) {
      if (value == null && !validator.acceptsNull) return const [];
      final errors = validator.validate(value);
      if (errors.isEmpty) return const [];
      failures.add(errors);
    }
    return [FormidableAnyOfError(failures)];
  }
}

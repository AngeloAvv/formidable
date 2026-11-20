import '../runtime/field.dart';
import '../validation/validation_error.dart';
import 'rule.dart';

/// The Field has to be empty because another Field has a given value.
final class FormidableProhibitedIfError extends FormidableValidationError {
  const FormidableProhibitedIfError();

  @override
  List<Object?> get props => const [];

  @override
  String toString() => 'This field is not allowed.';
}

/// The Field has to be empty because another Field does not have a given value.
final class FormidableProhibitedUnlessError extends FormidableValidationError {
  const FormidableProhibitedUnlessError();

  @override
  List<Object?> get props => const [];

  @override
  String toString() => 'This field is not allowed.';
}

/// The Field is filled while a Field it excludes is filled too.
final class FormidableProhibitsError extends FormidableValidationError {
  const FormidableProhibitsError();

  @override
  List<Object?> get props => const [];

  @override
  String toString() =>
      'This field cannot be used together with the related fields.';
}

/// The Field has to be true because another Field has a given value.
final class FormidableAcceptedIfError extends FormidableValidationError {
  const FormidableAcceptedIfError();

  @override
  List<Object?> get props => const [];

  @override
  String toString() => 'This must be accepted.';
}

/// The Field has to be false because another Field has a given value.
final class FormidableDeclinedIfError extends FormidableValidationError {
  const FormidableDeclinedIfError();

  @override
  List<Object?> get props => const [];

  @override
  String toString() => 'This must be declined.';
}

/// The Field has to be empty when another Field equals [value].
class ProhibitedIf extends FormidableCrossFieldRule {
  const ProhibitedIf(Symbol other, Object? value)
    : super(other: other, hasOperand: true, operand: value);

  @override
  List<FormidableValidationError> validate(
    FormidableField<Object?> target,
    List<FormidableField<Object?>> references,
  ) => target.isFilled && formidableFieldEquals(references.single, operand)
      ? const [FormidableProhibitedIfError()]
      : const [];
}

/// The Field has to be empty unless another Field equals [value]. An Unset
/// referenced Field does not equal it, so the Field is then prohibited.
class ProhibitedUnless extends FormidableCrossFieldRule {
  const ProhibitedUnless(Symbol other, Object? value)
    : super(other: other, hasOperand: true, operand: value);

  @override
  List<FormidableValidationError> validate(
    FormidableField<Object?> target,
    List<FormidableField<Object?>> references,
  ) => target.isFilled && !formidableFieldEquals(references.single, operand)
      ? const [FormidableProhibitedUnlessError()]
      : const [];
}

/// When the Field is filled, none of the other Fields may be: mutually
/// exclusive inputs. The error goes on the Field that carries the rule.
class Prohibits extends FormidableCrossFieldRule {
  const Prohibits(List<Symbol> others) : super(others: others);

  @override
  List<FormidableValidationError> validate(
    FormidableField<Object?> target,
    List<FormidableField<Object?>> references,
  ) => target.isFilled && references.any((f) => f.isFilled)
      ? const [FormidableProhibitsError()]
      : const [];
}

/// The `bool` Field has to be true when another Field equals [value]: "the
/// consent must be accepted when the user is under age". Unset is not true.
class AcceptedIf extends FormidableCrossFieldRule {
  const AcceptedIf(Symbol other, Object? value)
    : super(
        other: other,
        targetFit: FormidableTargetFit.boolean,
        hasOperand: true,
        operand: value,
      );

  @override
  List<FormidableValidationError> validate(
    FormidableField<Object?> target,
    List<FormidableField<Object?>> references,
  ) =>
      formidableFieldEquals(references.single, operand) &&
          !formidableFieldEquals(target, true)
      ? const [FormidableAcceptedIfError()]
      : const [];
}

/// The `bool` Field has to be false when another Field equals [value]. Unset
/// is not false.
class DeclinedIf extends FormidableCrossFieldRule {
  const DeclinedIf(Symbol other, Object? value)
    : super(
        other: other,
        targetFit: FormidableTargetFit.boolean,
        hasOperand: true,
        operand: value,
      );

  @override
  List<FormidableValidationError> validate(
    FormidableField<Object?> target,
    List<FormidableField<Object?>> references,
  ) =>
      formidableFieldEquals(references.single, operand) &&
          !formidableFieldEquals(target, false)
      ? const [FormidableDeclinedIfError()]
      : const [];
}

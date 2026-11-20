import '../runtime/field.dart';
import '../validation/validation_error.dart';
import 'rule.dart';

/// The Field is required because another Field has a given value.
final class FormidableRequiredIfError extends FormidableValidationError {
  const FormidableRequiredIfError();

  @override
  List<Object?> get props => const [];

  @override
  String toString() => 'This field is required.';
}

/// The Field is required because another Field does not have a given value.
final class FormidableRequiredUnlessError extends FormidableValidationError {
  const FormidableRequiredUnlessError();

  @override
  List<Object?> get props => const [];

  @override
  String toString() => 'This field is required.';
}

/// The Field is required because another Field is filled.
final class FormidableRequiredWithError extends FormidableValidationError {
  const FormidableRequiredWithError();

  @override
  List<Object?> get props => const [];

  @override
  String toString() => 'This field is required.';
}

/// The Field is required because all the other Fields are filled.
final class FormidableRequiredWithAllError extends FormidableValidationError {
  const FormidableRequiredWithAllError();

  @override
  List<Object?> get props => const [];

  @override
  String toString() => 'This field is required.';
}

/// The Field is required because another Field is empty.
final class FormidableRequiredWithoutError extends FormidableValidationError {
  const FormidableRequiredWithoutError();

  @override
  List<Object?> get props => const [];

  @override
  String toString() => 'This field is required.';
}

/// The Field is required because all the other Fields are empty.
final class FormidableRequiredWithoutAllError
    extends FormidableValidationError {
  const FormidableRequiredWithoutAllError();

  @override
  List<Object?> get props => const [];

  @override
  String toString() => 'This field is required.';
}

/// The Field is required because another Field is accepted.
final class FormidableRequiredIfAcceptedError
    extends FormidableValidationError {
  const FormidableRequiredIfAcceptedError();

  @override
  List<Object?> get props => const [];

  @override
  String toString() => 'This field is required.';
}

/// The Field is required because another Field is declined.
final class FormidableRequiredIfDeclinedError
    extends FormidableValidationError {
  const FormidableRequiredIfDeclinedError();

  @override
  List<Object?> get props => const [];

  @override
  String toString() => 'This field is required.';
}

/// The Field has to be filled when another Field equals [value]:
/// `@RequiredIf(#type, AccountType.company)`.
///
/// The type of [value] has to fit the referenced Field. An Unset referenced
/// Field never equals a value. A Field is filled when it is set and holds
/// something: see `isFilled`.
class RequiredIf extends FormidableCrossFieldRule {
  const RequiredIf(Symbol other, Object? value)
    : super(other: other, hasOperand: true, operand: value);

  @override
  List<FormidableValidationError> validate(
    FormidableField<Object?> target,
    List<FormidableField<Object?>> references,
  ) => !target.isFilled && formidableFieldEquals(references.single, operand)
      ? const [FormidableRequiredIfError()]
      : const [];
}

/// The Field has to be filled unless another Field equals [value]. An Unset
/// referenced Field does not equal it, so the Field is then required.
class RequiredUnless extends FormidableCrossFieldRule {
  const RequiredUnless(Symbol other, Object? value)
    : super(other: other, hasOperand: true, operand: value);

  @override
  List<FormidableValidationError> validate(
    FormidableField<Object?> target,
    List<FormidableField<Object?>> references,
  ) => !target.isFilled && !formidableFieldEquals(references.single, operand)
      ? const [FormidableRequiredUnlessError()]
      : const [];
}

/// The Field has to be filled when any of the other Fields is filled.
class RequiredWith extends FormidableCrossFieldRule {
  const RequiredWith(List<Symbol> others) : super(others: others);

  @override
  List<FormidableValidationError> validate(
    FormidableField<Object?> target,
    List<FormidableField<Object?>> references,
  ) => !target.isFilled && references.any((f) => f.isFilled)
      ? const [FormidableRequiredWithError()]
      : const [];
}

/// The Field has to be filled when all the other Fields are filled.
class RequiredWithAll extends FormidableCrossFieldRule {
  const RequiredWithAll(List<Symbol> others) : super(others: others);

  @override
  List<FormidableValidationError> validate(
    FormidableField<Object?> target,
    List<FormidableField<Object?>> references,
  ) => !target.isFilled && references.every((f) => f.isFilled)
      ? const [FormidableRequiredWithAllError()]
      : const [];
}

/// The Field has to be filled when any of the other Fields is empty, that is
/// not filled.
class RequiredWithout extends FormidableCrossFieldRule {
  const RequiredWithout(List<Symbol> others) : super(others: others);

  @override
  List<FormidableValidationError> validate(
    FormidableField<Object?> target,
    List<FormidableField<Object?>> references,
  ) => !target.isFilled && references.any((f) => !f.isFilled)
      ? const [FormidableRequiredWithoutError()]
      : const [];
}

/// The Field has to be filled when all the other Fields are empty: "phone,
/// unless an email is given".
class RequiredWithoutAll extends FormidableCrossFieldRule {
  const RequiredWithoutAll(List<Symbol> others) : super(others: others);

  @override
  List<FormidableValidationError> validate(
    FormidableField<Object?> target,
    List<FormidableField<Object?>> references,
  ) => !target.isFilled && references.every((f) => !f.isFilled)
      ? const [FormidableRequiredWithoutAllError()]
      : const [];
}

/// The Field has to be filled when a `bool` Field is true.
class RequiredIfAccepted extends FormidableCrossFieldRule {
  const RequiredIfAccepted(Symbol flag)
    : super(other: flag, referenceFit: FormidableReferenceFit.boolean);

  @override
  List<FormidableValidationError> validate(
    FormidableField<Object?> target,
    List<FormidableField<Object?>> references,
  ) => !target.isFilled && formidableFieldEquals(references.single, true)
      ? const [FormidableRequiredIfAcceptedError()]
      : const [];
}

/// The Field has to be filled when a `bool` Field is false. An Unset flag is
/// neither accepted nor declined.
class RequiredIfDeclined extends FormidableCrossFieldRule {
  const RequiredIfDeclined(Symbol flag)
    : super(other: flag, referenceFit: FormidableReferenceFit.boolean);

  @override
  List<FormidableValidationError> validate(
    FormidableField<Object?> target,
    List<FormidableField<Object?>> references,
  ) => !target.isFilled && formidableFieldEquals(references.single, false)
      ? const [FormidableRequiredIfDeclinedError()]
      : const [];
}

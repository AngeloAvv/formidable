import '../runtime/field.dart';
import '../validation/validation_error.dart';
import 'rule.dart';

/// None of the Fields of a group is filled.
final class FormidableAtLeastOneOfError extends FormidableValidationError {
  const FormidableAtLeastOneOfError();

  @override
  List<Object?> get props => const [];

  @override
  String toString() => 'Fill in at least one of the related fields.';
}

/// The number of filled Fields of a group is not one.
final class FormidableExactlyOneOfError extends FormidableValidationError {
  const FormidableExactlyOneOfError();

  @override
  List<Object?> get props => const [];

  @override
  String toString() => 'Fill in exactly one of the related fields.';
}

/// More than one Field of a group is filled.
final class FormidableAtMostOneOfError extends FormidableValidationError {
  const FormidableAtMostOneOfError();

  @override
  List<Object?> get props => const [];

  @override
  String toString() => 'Fill in at most one of the related fields.';
}

/// At least one of the Field that carries the rule and the named Fields has
/// to be filled: "phone or email". Carry it on one Field of the group, which
/// receives the error.
class AtLeastOneOf extends FormidableCrossFieldRule {
  const AtLeastOneOf(List<Symbol> others) : super(others: others);

  @override
  List<FormidableValidationError> validate(
    FormidableField<Object?> target,
    List<FormidableField<Object?>> references,
  ) => _filledCount(target, references) < 1
      ? const [FormidableAtLeastOneOfError()]
      : const [];
}

/// Exactly one of the Field that carries the rule and the named Fields has to
/// be filled.
class ExactlyOneOf extends FormidableCrossFieldRule {
  const ExactlyOneOf(List<Symbol> others) : super(others: others);

  @override
  List<FormidableValidationError> validate(
    FormidableField<Object?> target,
    List<FormidableField<Object?>> references,
  ) => _filledCount(target, references) != 1
      ? const [FormidableExactlyOneOfError()]
      : const [];
}

/// At most one of the Field that carries the rule and the named Fields may be
/// filled.
class AtMostOneOf extends FormidableCrossFieldRule {
  const AtMostOneOf(List<Symbol> others) : super(others: others);

  @override
  List<FormidableValidationError> validate(
    FormidableField<Object?> target,
    List<FormidableField<Object?>> references,
  ) => _filledCount(target, references) > 1
      ? const [FormidableAtMostOneOfError()]
      : const [];
}

int _filledCount(
  FormidableField<Object?> target,
  List<FormidableField<Object?>> references,
) => [target, ...references].where((f) => f.isFilled).length;

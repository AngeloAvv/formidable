import '../runtime/field.dart';
import '../validation/validation_error.dart';
import 'rule.dart';

/// The Field does not match the Field it has to match.
final class FormidableMustMatchError extends FormidableValidationError {
  const FormidableMustMatchError();

  @override
  List<Object?> get props => const [];

  @override
  String toString() => 'The values do not match.';
}

/// The Field has to match another Field, for example a password confirmation.
///
/// It runs when the Field has a value. The Fields must have the same type. An
/// Unset referenced Field matches nothing.
class MustMatch extends FormidableCrossFieldRule {
  const MustMatch(Symbol other)
    : super(
        other: other,
        referenceFit: FormidableReferenceFit.sameAsTarget,
      );

  @override
  List<FormidableValidationError> validate(
    FormidableField<Object?> target,
    List<FormidableField<Object?>> references,
  ) {
    final other = references.single;
    if (!target.isSet) return const [];
    return other.isSet && other.value == target.value
        ? const []
        : const [FormidableMustMatchError()];
  }
}

/// Another name for [MustMatch].
typedef Confirmed = MustMatch;

/// The Field has the same value as the Field it has to differ from.
final class FormidableDifferentError extends FormidableValidationError {
  const FormidableDifferentError();

  @override
  List<Object?> get props => const [];

  @override
  String toString() => 'Must be different from the other value.';
}

/// The Field has to differ from another Field of the same type, for example a
/// new password that must not repeat the old one.
///
/// It runs when both Fields have a value.
class Different extends FormidableCrossFieldRule {
  const Different(Symbol other)
    : super(
        other: other,
        referenceFit: FormidableReferenceFit.sameAsTarget,
      );

  @override
  List<FormidableValidationError> validate(
    FormidableField<Object?> target,
    List<FormidableField<Object?>> references,
  ) {
    final other = references.single;
    if (!target.isSet || !other.isSet) return const [];
    return other.value == target.value
        ? const [FormidableDifferentError()]
        : const [];
  }
}

/// How [Compare] relates the Field to the other one.
enum FormidableComparison {
  equalTo,
  notEqualTo,
  lessThan,
  lessThanOrEqualTo,
  greaterThan,
  greaterThanOrEqualTo;

  /// Whether a value that compares as [order] (negative, zero or positive)
  /// with the other one satisfies this comparison.
  bool accepts(int order) => switch (this) {
    equalTo => order == 0,
    notEqualTo => order != 0,
    lessThan => order < 0,
    lessThanOrEqualTo => order <= 0,
    greaterThan => order > 0,
    greaterThanOrEqualTo => order >= 0,
  };
}

/// The Field is not in the relation [comparison] with the other Field.
final class FormidableCompareError extends FormidableValidationError {
  const FormidableCompareError(this.comparison);

  final FormidableComparison comparison;

  @override
  List<Object?> get props => [comparison];

  @override
  String toString() => switch (comparison) {
    FormidableComparison.equalTo => 'Must be equal to the other value.',
    FormidableComparison.notEqualTo => 'Must be different from the other value.',
    FormidableComparison.lessThan => 'Must be less than the other value.',
    FormidableComparison.lessThanOrEqualTo =>
      'Must be less than or equal to the other value.',
    FormidableComparison.greaterThan => 'Must be greater than the other value.',
    FormidableComparison.greaterThanOrEqualTo =>
      'Must be greater than or equal to the other value.',
  };
}

/// The Field has to be in the relation [comparison] with another Field, for
/// example `@Compare(FormidableComparison.greaterThan, #min)`.
///
/// Both Fields must be `Comparable` of the same type, or numbers. It runs when
/// both have a value that is not null.
class Compare extends FormidableCrossFieldRule {
  const Compare(this.comparison, Symbol other)
    : super(
        other: other,
        targetFit: FormidableTargetFit.comparable,
        referenceFit: FormidableReferenceFit.comparableWithTarget,
      );

  final FormidableComparison comparison;

  @override
  List<FormidableValidationError> validate(
    FormidableField<Object?> target,
    List<FormidableField<Object?>> references,
  ) {
    final other = references.single;
    final a = target.isSet ? target.value : null;
    final b = other.isSet ? other.value : null;
    if (a == null || b == null) return const [];
    // Safe: the generator only accepts two comparable Fields of one type.
    final order = (a as Comparable<Object?>).compareTo(b);
    return comparison.accepts(order)
        ? const []
        : [FormidableCompareError(comparison)];
  }
}

/// The date is before the start of its range.
final class FormidableDateRangeOrderError extends FormidableValidationError {
  const FormidableDateRangeOrderError({required this.allowSame});

  /// Whether the same moment as the start was accepted.
  final bool allowSame;

  @override
  List<Object?> get props => [allowSame];

  @override
  String toString() => allowSame
      ? 'Must not be before the start date.'
      : 'Must be after the start date.';
}

/// The end date of a range, which has to come after the start date: put it on
/// the end Field and name the start Field.
///
/// With [allowSame] false the end has to be strictly later. It runs when both
/// Fields have a value that is not null.
class DateRangeOrder extends FormidableCrossFieldRule {
  const DateRangeOrder(Symbol start, {this.allowSame = true})
    : super(
        other: start,
        targetFit: FormidableTargetFit.dateTime,
        referenceFit: FormidableReferenceFit.dateTime,
      );

  final bool allowSame;

  @override
  List<FormidableValidationError> validate(
    FormidableField<Object?> target,
    List<FormidableField<Object?>> references,
  ) {
    final other = references.single;
    final end = target.isSet ? target.value : null;
    final start = other.isSet ? other.value : null;
    if (end is! DateTime || start is! DateTime) return const [];
    final ordered = allowSame ? !end.isBefore(start) : end.isAfter(start);
    return ordered
        ? const []
        : [FormidableDateRangeOrderError(allowSame: allowSame)];
  }
}

import '../runtime/field.dart';
import '../validation/validation_error.dart';
import 'rule.dart';

/// The value is not in the list held by another Field.
final class FormidableInListError extends FormidableValidationError {
  const FormidableInListError();

  @override
  List<Object?> get props => const [];

  @override
  String toString() => 'Must be one of the available values.';
}

/// Another element of the list held by another Field has the same key.
final class FormidableUniqueByError extends FormidableValidationError {
  const FormidableUniqueByError();

  @override
  List<Object?> get props => const [];

  @override
  String toString() => 'This value is already in the list.';
}

/// The value has to be an element of the list held by another Field, for
/// example the chosen option among the options loaded elsewhere in the Form.
///
/// The referenced Field must be an `Iterable` of a type that can hold the
/// value. It runs when the Field has a value that is not null. An Unset list is
/// an empty list, so nothing is in it.
class InList extends FormidableCrossFieldRule {
  const InList(Symbol list)
    : super(other: list, referenceFit: FormidableReferenceFit.iterableOfTarget);

  @override
  List<FormidableValidationError> validate(
    FormidableField<Object?> target,
    List<FormidableField<Object?>> references,
  ) {
    final value = target.isSet ? target.value : null;
    if (value == null) return const [];
    final list = references.single;
    final items = list.isSet ? list.value : null;
    return items is Iterable<Object?> && items.contains(value)
        ? const []
        : const [FormidableInListError()];
  }
}

/// The value must not have the same [key] as an element of the list held by
/// another Field: `@UniqueBy(#existing, nameOf)` rejects a name that is
/// already taken, however the elements are spelled.
///
/// [key] is a top-level or static function of the element type [E], which both
/// the Field and the elements of the list must have. It runs when the Field has
/// a value that is not null.
class UniqueBy<E> extends FormidableCrossFieldRule {
  const UniqueBy(Symbol list, this.key)
    : super(other: list, referenceFit: FormidableReferenceFit.iterableOfTarget);

  /// The key two elements are compared by.
  final Object? Function(E element) key;

  @override
  List<FormidableValidationError> validate(
    FormidableField<Object?> target,
    List<FormidableField<Object?>> references,
  ) {
    final value = target.isSet ? target.value : null;
    final list = references.single;
    final items = list.isSet ? list.value : null;
    if (value == null || items is! Iterable<Object?>) return const [];
    // Safe: the generator checks the type of the Field and of the elements.
    final wanted = key(value as E);
    return items.any((item) => key(item as E) == wanted)
        ? const [FormidableUniqueByError()]
        : const [];
  }
}

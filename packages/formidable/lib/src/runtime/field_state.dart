import '../validation/validation_error.dart';
import 'status.dart';

/// An immutable snapshot of a Field.
///
/// [value] is null both when the Field is Unset and when null was chosen, so
/// read [isSet] to tell them apart.
final class FormidableFieldState<T> {
  FormidableFieldState({
    required this.value,
    required this.isSet,
    required List<FormidableValidationError> errors,
    required this.touched,
  }) : errors = List.unmodifiable(errors);

  /// The chosen value, or null while the Field is Unset.
  final T? value;

  /// Whether the Field holds a value. An Unset Field is not set.
  final bool isSet;

  /// Every error of the Field, in the order of its annotations.
  final List<FormidableValidationError> errors;

  /// Whether the user has interacted with the Field and then left it.
  final bool touched;

  FormidableStatus get status =>
      errors.isEmpty ? FormidableStatus.valid : FormidableStatus.invalid;

  @override
  bool operator ==(Object other) =>
      other is FormidableFieldState<T> &&
      other.value == value &&
      other.isSet == isSet &&
      other.touched == touched &&
      _sameErrors(other.errors, errors);

  @override
  int get hashCode =>
      Object.hash(value, isSet, touched, Object.hashAll(errors));

  @override
  String toString() =>
      'FormidableFieldState(value: $value, isSet: $isSet, '
      'touched: $touched, errors: $errors)';

  static bool _sameErrors(
    List<FormidableValidationError> a,
    List<FormidableValidationError> b,
  ) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

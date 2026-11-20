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
    this.dirty = false,
    this.enabled = true,
    this.submitted = false,
  }) : errors = List.unmodifiable(errors);

  /// The chosen value, or null while the Field is Unset.
  final T? value;

  /// Whether the Field holds a value. An Unset Field is not set.
  final bool isSet;

  /// Every error of the Field, in the order of its annotations.
  final List<FormidableValidationError> errors;

  /// Whether the user has interacted with the Field and then left it.
  final bool touched;

  /// Whether the value or presence differs from the initial state. Going back
  /// to the initial state makes the Field clean again.
  final bool dirty;

  /// Whether the Field takes part in the Form. A disabled Field is not
  /// validated and does not block submit.
  final bool enabled;

  /// Whether the Form was submitted since the Field was created. Submitting
  /// also makes the Field touched.
  final bool submitted;

  FormidableStatus get status =>
      errors.isEmpty ? FormidableStatus.valid : FormidableStatus.invalid;

  @override
  bool operator ==(Object other) =>
      other is FormidableFieldState<T> &&
      other.value == value &&
      other.isSet == isSet &&
      other.touched == touched &&
      other.dirty == dirty &&
      other.enabled == enabled &&
      other.submitted == submitted &&
      _sameErrors(other.errors, errors);

  @override
  int get hashCode => Object.hash(
    value,
    isSet,
    touched,
    dirty,
    enabled,
    submitted,
    Object.hashAll(errors),
  );

  @override
  String toString() =>
      'FormidableFieldState(value: $value, isSet: $isSet, '
      'touched: $touched, dirty: $dirty, enabled: $enabled, '
      'submitted: $submitted, errors: $errors)';

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

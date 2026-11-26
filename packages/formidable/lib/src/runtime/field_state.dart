import '../validation/validation_error.dart';
import 'status.dart';

/// The error thrown when the `value` of an Unset Field is read.
StateError unsetFieldError(String? name) => StateError(
  '${name == null ? 'The Field' : 'Field `$name`'} is Unset: check `defined` '
  'before reading `value`, or read `valueOrNull`.',
);

/// An immutable snapshot of a Field.
///
/// [value] throws while the Field is Unset, so read [defined] first. [valueOrNull]
/// is null both when the Field is Unset and when null was chosen, so only
/// [defined] tells them apart.
final class FormidableFieldState<T> {
  FormidableFieldState({
    required T? value,
    required this.defined,
    this.name,
    required List<FormidableValidationError> errors,
    required this.touched,
    this.dirty = false,
    this.enabled = true,
    this.submitted = false,
    this.pending = false,
  }) : _value = value,
       errors = List.unmodifiable(errors);

  final T? _value;

  /// The name of the Field in its Schema, used in error messages. Null for a
  /// Field that has none, such as an item of a Field Array.
  final String? name;

  /// The chosen value. It is null when null was chosen on a nullable Field.
  ///
  /// Throws a [StateError] while the Field is Unset (ADR-0003): check
  /// [defined] first, or read [valueOrNull].
  T get value {
    if (!defined) throw unsetFieldError(name);
    return _value as T;
  }

  /// The chosen value, or null while the Field is Unset. On a nullable Field
  /// it cannot tell Unset from a chosen null: read [defined] for that.
  T? get valueOrNull => _value;

  /// Whether the Field holds a value. An Unset Field is not set.
  final bool defined;

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

  /// Whether an Async Validator is still checking the Field's value, or an
  /// asynchronous Form Validator that reads it is. The errors of a pending
  /// check are not in [errors] yet.
  final bool pending;

  /// Whether the Field can be submitted now: it has no errors and no check is
  /// running. It is `status == FormidableStatus.valid`, so it is false while
  /// the Field is [pending].
  bool get valid => status == FormidableStatus.valid;

  /// [FormidableStatus.invalid] when the Field has errors, even if a check is
  /// still running; [FormidableStatus.pending] when it has none but a check is
  /// running; [FormidableStatus.valid] otherwise.
  FormidableStatus get status => errors.isNotEmpty
      ? FormidableStatus.invalid
      : pending
      ? FormidableStatus.pending
      : FormidableStatus.valid;

  @override
  bool operator ==(Object other) =>
      other is FormidableFieldState<T> &&
      other._value == _value &&
      other.defined == defined &&
      other.touched == touched &&
      other.dirty == dirty &&
      other.enabled == enabled &&
      other.submitted == submitted &&
      other.pending == pending &&
      _sameErrors(other.errors, errors);

  @override
  int get hashCode => Object.hash(
    _value,
    defined,
    touched,
    dirty,
    enabled,
    submitted,
    pending,
    Object.hashAll(errors),
  );

  @override
  String toString() =>
      'FormidableFieldState(value: $_value, defined: $defined, '
      'touched: $touched, dirty: $dirty, enabled: $enabled, '
      'submitted: $submitted, pending: $pending, errors: $errors)';

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

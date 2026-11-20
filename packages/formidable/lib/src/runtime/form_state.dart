import '../validation/validation_error.dart';
import 'status.dart';

/// An immutable snapshot of a Form.
///
/// A generated Form publishes a subclass of this (`SignUpFormState`) that also
/// holds the state of every child: the [FormidableFieldState] of each Field,
/// the state of each Field Array and of each Nested Form. Equality is deep, so
/// any change below the Form gives a state that is different from the previous
/// one.
///
/// [value] does not take part in equality. It is derived from the states of the
/// children, and a Schema is not required to define `==`, which would make
/// every snapshot differ from the last one.
class FormidableFormState {
  FormidableFormState({
    required this.status,
    this.dirty = false,
    this.pending = false,
    this.isSet = true,
    this.value,
    List<FormidableValidationError> errors = const [],
  }) : errors = List.unmodifiable(errors);

  /// Whether the Form, with every Field below it, has errors.
  final FormidableStatus status;

  /// Whether any Field differs from its initial state.
  final bool dirty;

  /// Whether any Field is still waiting for a result.
  final bool pending;

  /// Whether the Form holds a value. It is false only for an optional Nested
  /// Form that is Unset.
  final bool isSet;

  /// The Schema instance while the Form is valid, not pending and set, null
  /// otherwise. A generated state narrows it to the type of the Schema.
  final Object? value;

  /// Errors that belong to the Form as a whole, not to a Field.
  final List<FormidableValidationError> errors;

  @override
  bool operator ==(Object other) =>
      other is FormidableFormState &&
      other.runtimeType == runtimeType &&
      other.status == status &&
      other.dirty == dirty &&
      other.pending == pending &&
      other.isSet == isSet &&
      _sameErrors(other.errors, errors);

  @override
  int get hashCode =>
      Object.hash(status, dirty, pending, isSet, Object.hashAll(errors));

  @override
  String toString() =>
      'FormidableFormState(status: $status, dirty: $dirty, '
      'pending: $pending, isSet: $isSet, errors: $errors)';

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

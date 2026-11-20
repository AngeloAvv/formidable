import '../validation/validation_error.dart';
import 'status.dart';

/// An immutable snapshot of a Form.
final class FormidableFormState {
  FormidableFormState({
    required this.status,
    this.dirty = false,
    this.pending = false,
    List<FormidableValidationError> errors = const [],
  }) : errors = List.unmodifiable(errors);

  /// Whether the Form, with every Field below it, has errors.
  final FormidableStatus status;

  /// Whether any Field differs from its initial state.
  final bool dirty;

  /// Whether any Field is still waiting for a result.
  final bool pending;

  /// Errors that belong to the Form as a whole, not to a Field.
  final List<FormidableValidationError> errors;

  @override
  bool operator ==(Object other) =>
      other is FormidableFormState &&
      other.status == status &&
      other.dirty == dirty &&
      other.pending == pending &&
      _sameErrors(other.errors, errors);

  @override
  int get hashCode =>
      Object.hash(status, dirty, pending, Object.hashAll(errors));

  @override
  String toString() =>
      'FormidableFormState(status: $status, dirty: $dirty, '
      'pending: $pending, errors: $errors)';

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

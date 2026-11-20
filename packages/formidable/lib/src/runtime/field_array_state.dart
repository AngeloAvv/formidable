import '../validation/validation_error.dart';

/// An immutable snapshot of a Field Array.
///
/// [errors] are the errors of the array itself (a minimum number of items, a
/// required array), not those of its items: every item reports its own.
final class FormidableFieldArrayState {
  FormidableFieldArrayState({
    required List<int> ids,
    required List<FormidableValidationError> errors,
    this.touched = false,
    this.dirty = false,
    this.submitted = false,
  }) : ids = List.unmodifiable(ids),
       errors = List.unmodifiable(errors);

  /// The identifiers of the items, in order. A move changes the order, so the
  /// state differs and listeners are called.
  final List<int> ids;

  /// The errors of the array itself.
  final List<FormidableValidationError> errors;

  /// Whether the array was touched, for example by a submit.
  final bool touched;

  /// Whether the items, their order or any of their values differ from the
  /// initial state.
  final bool dirty;

  /// Whether the Form was submitted since the array was created.
  final bool submitted;

  /// How many items the array has.
  int get length => ids.length;

  /// Whether the array holds a value. An empty array is Unset.
  bool get isSet => ids.isNotEmpty;

  @override
  bool operator ==(Object other) =>
      other is FormidableFieldArrayState &&
      other.touched == touched &&
      other.dirty == dirty &&
      other.submitted == submitted &&
      _same(other.ids, ids) &&
      _same(other.errors, errors);

  @override
  int get hashCode => Object.hash(
    touched,
    dirty,
    submitted,
    Object.hashAll(ids),
    Object.hashAll(errors),
  );

  @override
  String toString() =>
      'FormidableFieldArrayState(ids: $ids, touched: $touched, '
      'dirty: $dirty, submitted: $submitted, errors: $errors)';

  static bool _same(List<Object?> a, List<Object?> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

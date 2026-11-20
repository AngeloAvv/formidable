import '../validation/validation_error.dart';

/// An immutable snapshot of a Field Array.
///
/// [S] is the state of one item: a [FormidableFieldState] for an array of
/// Fields, the generated state of the Nested Form (`PhoneFormState`) for an
/// array of Nested Forms. Equality is deep, so editing an item, adding,
/// removing or moving one gives a state that differs from the previous one.
///
/// [errors] are the errors of the array itself (a minimum number of items, a
/// required array), not those of its items: every item reports its own.
final class FormidableFieldArrayState<S> {
  FormidableFieldArrayState({
    required List<int> ids,
    required List<S> items,
    required List<FormidableValidationError> errors,
    this.touched = false,
    this.dirty = false,
    this.submitted = false,
  }) : assert(ids.length == items.length),
       ids = List.unmodifiable(ids),
       items = List.unmodifiable(items),
       errors = List.unmodifiable(errors);

  /// The identifiers of the items, in order. A move changes the order, so the
  /// state differs and listeners are called.
  final List<int> ids;

  /// The state of every item, in the same order as [ids].
  final List<S> items;

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
      other is FormidableFieldArrayState<S> &&
      other.touched == touched &&
      other.dirty == dirty &&
      other.submitted == submitted &&
      _same(other.ids, ids) &&
      _same(other.items, items) &&
      _same(other.errors, errors);

  @override
  int get hashCode => Object.hash(
    touched,
    dirty,
    submitted,
    Object.hashAll(ids),
    Object.hashAll(items),
    Object.hashAll(errors),
  );

  @override
  String toString() =>
      'FormidableFieldArrayState(ids: $ids, items: $items, '
      'touched: $touched, dirty: $dirty, submitted: $submitted, '
      'errors: $errors)';

  static bool _same(List<Object?> a, List<Object?> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

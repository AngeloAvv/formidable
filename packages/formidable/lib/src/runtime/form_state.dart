import '../validation/validation_error.dart';
import 'status.dart';

/// The metadata of a Form, as one immutable snapshot: its status, its flags,
/// its Form-level errors and its Schema value.
///
/// It is what `state.meta` returns, for a generated Form and for a plain one,
/// so that code reads `state.meta.status` either way. The Fields of the Form
/// live next to it in the state (`state.email`), which is why the metadata has
/// a namespace of its own: a Schema field can be called `status` or `dirty`
/// without hiding anything.
///
/// Equality compares everything but [value].
final class FormidableFormMeta<S> {
  /// Creates the metadata of a Form.
  ///
  /// [buildValue] makes the Schema instance. It is called at most once, on the
  /// first read of [value], and only when the Form is valid, not pending and
  /// set.
  FormidableFormMeta({
    required this.status,
    this.dirty = false,
    this.pending = false,
    this.defined = true,
    List<FormidableValidationError> errors = const [],
    S? Function()? buildValue,
  }) : errors = List.unmodifiable(errors),
       _buildValue = buildValue;

  /// [FormidableStatus.invalid] when the Form or any Field below it has
  /// errors, even if other checks are still running; [FormidableStatus.pending]
  /// when there are none but a check is running; [FormidableStatus.valid]
  /// otherwise.
  final FormidableStatus status;

  /// Whether the Form can be submitted now: no errors below it and no check
  /// running. It is `status == FormidableStatus.valid`, so it is false while
  /// the Form is [pending], and it does not look at whether the Form is
  /// [defined]. The Schema [value] is built only when the Form is valid.
  bool get valid => status == FormidableStatus.valid;

  /// Whether any Field differs from its initial state.
  final bool dirty;

  /// Whether any Field is still waiting for a result.
  final bool pending;

  /// Whether the Form holds a value. It is false only for an optional Nested
  /// Form that is Unset.
  final bool defined;

  /// Errors that belong to the Form as a whole, not to a Field.
  final List<FormidableValidationError> errors;

  S? Function()? _buildValue;
  S? _value;
  bool _built = false;

  /// The Schema instance while the Form is valid, not pending and set, null
  /// otherwise.
  ///
  /// It is lazy: the Schema constructor runs on the first read, never when the
  /// state is published, and the result is cached. It does not take part in
  /// equality, because a Schema is not required to define `==`.
  S? get value {
    if (!_built) {
      final build = _buildValue;
      _buildValue = null;
      _built = true;
      if (build != null &&
          defined &&
          status == FormidableStatus.valid &&
          !pending) {
        _value = build();
      }
    }
    return _value;
  }

  @override
  bool operator ==(Object other) =>
      other is FormidableFormMeta<Object?> &&
      other.status == status &&
      other.dirty == dirty &&
      other.pending == pending &&
      other.defined == defined &&
      _sameErrors(other.errors, errors);

  @override
  int get hashCode =>
      Object.hash(status, dirty, pending, defined, Object.hashAll(errors));

  @override
  String toString() =>
      'FormidableFormMeta(status: $status, dirty: $dirty, '
      'pending: $pending, defined: $defined, errors: $errors)';

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

/// An immutable snapshot of a Form.
///
/// The metadata of the Form (status, dirty, pending, errors, the Schema value)
/// is under [meta]. A generated Form publishes a subclass of this
/// (`SignUpFormState`) that also holds the state of every child: the
/// [FormidableFieldState] of each Field, the state of each Field Array and of
/// each Nested Form, one getter per Schema field. Equality is deep, so any
/// change below the Form gives a state that is different from the previous
/// one.
class FormidableFormState {
  /// Creates a state around [meta].
  FormidableFormState({required this.meta});

  /// The metadata of the Form: [FormidableFormMeta.status],
  /// [FormidableFormMeta.dirty], [FormidableFormMeta.pending],
  /// [FormidableFormMeta.defined], [FormidableFormMeta.errors] and
  /// [FormidableFormMeta.value]. A generated state narrows it to the Schema.
  final FormidableFormMeta<Object?> meta;

  @override
  bool operator ==(Object other) =>
      other is FormidableFormState &&
      other.runtimeType == runtimeType &&
      other.meta == meta;

  @override
  int get hashCode => meta.hashCode;

  @override
  String toString() => 'FormidableFormState($meta)';
}

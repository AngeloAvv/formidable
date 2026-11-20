import '../validation/required_error.dart';
import '../validation/validation_error.dart';
import '../validation/validator.dart';
import 'field_state.dart';
import 'node.dart';
import 'notifier.dart';

/// A single value inside a Form, reached through a typed handle.
///
/// Generated Forms create one per Schema field. All behavior lives here, so
/// the generated code only configures it.
///
/// A Field is either Unset or holds a value of type [T], and that value can be
/// null when [T] is nullable (ADR-0003).
final class FormidableField<T>
    with FormidableNotifierMixin
    implements FormidableNode, FormidableObservable<FormidableFieldState<T>> {
  /// Creates a Field.
  ///
  /// - [validators] run in order, only while the Field has a value. They are
  ///   typed `Object?` because a Validator typed for a supertype of [T] fits
  ///   too, which Dart cannot express; the generator rejects a Validator that
  ///   does not fit before the Form is generated.
  /// - [required] is `@Required()`: Unset blocks submit even if [T] allows null
  ///   or a default exists.
  /// - [defaultValue] is the constructor default of the Schema field. The Field
  ///   starts with it and the output falls back to it while the Field is Unset.
  /// - [initial] is the starting value. A null record starts the Field Unset
  ///   (or at its default).
  FormidableField({
    List<FormidableValidator<Object?>> validators = const [],
    bool required = false,
    T? defaultValue,
    ({T value})? initial,
  }) : _validators = validators,
       _required = required,
       _defaultValue = defaultValue {
    final start =
        initial ?? (defaultValue == null ? null : (value: defaultValue));
    _state = _stateFor(
      isSet: start != null,
      value: start?.value,
      touched: false,
    );
  }

  final List<FormidableValidator<Object?>> _validators;
  final bool _required;
  final T? _defaultValue;
  late FormidableFieldState<T> _state;
  List<FormidableValidationError> _formErrors = const [];

  @override
  FormidableFieldState<T> get state => _state;

  /// The current value, or null while the Field is Unset. Null is also a valid
  /// chosen value for a nullable [T], so check [isSet] to tell them apart.
  T? get value => _state.value;

  /// Whether the Field holds a value.
  bool get isSet => _state.isSet;

  /// Whether the Field has no errors.
  @override
  bool get isValid => _state.errors.isEmpty;

  /// Gives the Field a value. The type is exactly the Field's type, so the
  /// compiler rejects null for a non-nullable Field.
  void setValue(T value) => _update(isSet: true, value: value);

  /// Makes the Field Unset.
  void clear() => _update(isSet: false, value: null);

  /// Replaces the errors that the Form Validators address to this Field.
  ///
  /// They are added after the Field's own errors. Called by the Form; an
  /// application has no reason to call it.
  void replaceFormErrors(List<FormidableValidationError> errors) {
    if (_sameErrors(_formErrors, errors)) return;
    _formErrors = List.unmodifiable(errors);
    _update();
  }

  /// Records that the user interacted with the Field and left it.
  void markAsTouched() => _update(touched: true);

  /// The value the Field contributes to the Schema instance.
  ///
  /// An Unset Field produces its default, then null when [T] is nullable. If
  /// neither applies the Field has a required error and this throws.
  T get output {
    if (_state.isSet) return _state.value as T;
    if (_defaultValue != null) return _defaultValue as T;
    if (null is T) return null as T;
    throw StateError('A required Field is Unset and has no output.');
  }

  @override
  void collectErrors(
    Map<FormidableField<Object?>, List<FormidableValidationError>> into,
  ) {
    if (_state.errors.isNotEmpty) into[this] = _state.errors;
  }

  void _update({bool? isSet, T? value, bool? touched}) {
    final next = _stateFor(
      isSet: isSet ?? _state.isSet,
      value: isSet == null ? _state.value : value,
      touched: touched ?? _state.touched,
    );
    if (next == _state) return;
    _state = next;
    notifyListeners();
  }

  FormidableFieldState<T> _stateFor({
    required bool isSet,
    required T? value,
    required bool touched,
  }) => FormidableFieldState<T>(
    value: value,
    isSet: isSet,
    touched: touched,
    errors: [
      ...(isSet ? _validate(value) : _presenceErrors()),
      ..._formErrors,
    ],
  );

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

  /// Errors of an Unset Field: required unless something supplies the output.
  List<FormidableValidationError> _presenceErrors() {
    final supplied = _defaultValue != null || null is T;
    return _required || !supplied
        ? const [FormidableRequiredError()]
        : const [];
  }

  List<FormidableValidationError> _validate(T? value) => [
    for (final validator in _validators)
      if (value != null || validator.acceptsNull)
        ...validator.validate(value),
  ];
}

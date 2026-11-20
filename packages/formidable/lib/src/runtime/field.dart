import '../normalizers/normalizer.dart';
import '../validation/required_error.dart';
import '../validation/validation_error.dart';
import '../validation/validator.dart';
import 'field_state.dart';
import 'node.dart';
import 'notifier.dart';
import 'pipeline.dart';

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
  /// - [normalizers] rewrite every value written to the Field, in order, before
  ///   validation, and only while the Field has a value. A Normalizer can turn
  ///   the value into Unset.
  /// - [validators] run in order, only while the Field has a value. They are
  ///   typed `Object?` because a Validator typed for a supertype of [T] fits
  ///   too, which Dart cannot express; the generator rejects a Validator that
  ///   does not fit before the Form is generated.
  /// - [required] is `@Required()`: Unset blocks submit even if [T] allows null
  ///   or a default exists.
  /// - [defaultValue] is the constructor default of the Schema field. The Field
  ///   starts with it and the output falls back to it while the Field is Unset.
  /// - [initial] is the starting value, which goes through the Normalizers. A
  ///   null record starts the Field Unset (or at its default).
  FormidableField({
    List<FormidableNormalizer<T>> normalizers = const [],
    List<FormidableValidator<Object?>> validators = const [],
    bool required = false,
    T? defaultValue,
    ({T value})? initial,
  }) : _normalizers = normalizers,
       _validators = validators,
       _required = required,
       _defaultValue = defaultValue {
    final start = initial == null
        ? (defaultValue == null ? null : (value: defaultValue))
        : _normalize(initial.value);
    _isSet = start != null;
    _value = start?.value;
    _initialIsSet = _isSet;
    _initialValue = _value;
    _state = _stateFor();
    _notified = _state;
  }

  final List<FormidableNormalizer<T>> _normalizers;
  final List<FormidableValidator<Object?>> _validators;
  List<FormidableValidationError> _formErrors = const [];
  final bool _required;
  final T? _defaultValue;
  FormidablePipeline? _pipeline;
  T? _value;
  bool _isSet = false;
  bool _touched = false;
  bool _stale = false;
  late FormidableFieldState<T> _state;
  late FormidableFieldState<T> _notified;
  late bool _initialIsSet;
  late T? _initialValue;

  @override
  FormidableFieldState<T> get state => _state;

  /// The current value, or null while the Field is Unset. Null is also a valid
  /// chosen value for a nullable [T], so check [isSet] to tell them apart.
  ///
  /// It is current even while Form Effects run, unlike [state].
  T? get value => _value;

  /// Whether the Field holds a value.
  bool get isSet => _isSet;

  /// Whether the Field has no errors.
  @override
  bool get isValid => _state.errors.isEmpty;

  /// Gives the Field a value. The type is exactly the Field's type, so the
  /// compiler rejects null for a non-nullable Field.
  ///
  /// The value goes through the Normalizers, then the Form Effects, then the
  /// Validators. A Normalizer can make the Field Unset instead.
  void setValue(T value) => _write(() => _assign(_normalize(value)));

  /// Makes the Field Unset.
  void clear() => _write(() => _assign(null));

  /// Replaces the errors that the Form Validators address to this Field. They
  /// are added after the Field's own errors. Called by the Form before it
  /// revalidates; an application has no reason to call it.
  void replaceFormErrors(List<FormidableValidationError> errors) {
    if (_sameErrors(_formErrors, errors)) return;
    _formErrors = List.unmodifiable(errors);
    _stale = true;
  }

  /// Records that the user interacted with the Field and left it.
  void markAsTouched() {
    if (_touched) return;
    _touched = true;
    _commit();
  }

  /// The value the Field contributes to the Schema instance.
  ///
  /// An Unset Field produces its default, then null when [T] is nullable. If
  /// neither applies the Field has a required error and this throws.
  T get output {
    if (_isSet) return _value as T;
    if (_defaultValue != null) return _defaultValue as T;
    if (null is T) return null as T;
    throw StateError('A required Field is Unset and has no output.');
  }

  @override
  bool get isDirty => _state.dirty;

  @override
  bool get isPending => false;

  @override
  void collectErrors(
    Map<FormidableField<Object?>, List<FormidableValidationError>> into,
  ) {
    if (_state.errors.isNotEmpty) into[this] = _state.errors;
  }

  @override
  void bindPipeline(FormidablePipeline pipeline) {
    assert(_pipeline == null, 'bindPipeline must be called once.');
    _pipeline = pipeline;
  }

  @override
  void revalidate() {
    if (_stale) _commit();
  }

  /// Runs [mutate] through the Form pipeline, or on its own when the Field is
  /// not part of a Form.
  void _write(bool Function() mutate) {
    final pipeline = _pipeline;
    if (pipeline == null) {
      if (mutate()) _commit();
    } else {
      pipeline.change(this, mutate);
    }
  }

  /// Replaces the value and presence without validating. Returns whether
  /// either changed.
  bool _assign(({T value})? next) {
    final isSet = next != null;
    final value = next?.value;
    if (isSet == _isSet && value == _value) return false;
    _isSet = isSet;
    _value = value;
    _stale = true;
    return true;
  }

  /// The value after the Normalizers, or null when it ends up Unset.
  ({T value})? _normalize(T value) {
    var current = value;
    for (final normalizer in _normalizers) {
      if (current == null && !normalizer.acceptsNull) continue;
      current = normalizer.normalize(current);
      if (normalizer.makesUnset(current)) return null;
    }
    return (value: current);
  }

  /// Validates the current value and notifies listeners if the state changed.
  void _commit() {
    _stale = false;
    _state = _stateFor();
    if (_state == _notified) return;
    _notified = _state;
    notifyListeners();
  }

  FormidableFieldState<T> _stateFor() => FormidableFieldState<T>(
    value: _value,
    isSet: _isSet,
    touched: _touched,
    dirty: _isSet != _initialIsSet || (_isSet && _value != _initialValue),
    errors: [
      ...(_isSet ? _validate(_value) : _presenceErrors()),
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

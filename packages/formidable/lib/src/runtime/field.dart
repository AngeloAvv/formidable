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
  /// - [validators] run in order, only while the Field has a value.
  /// - [required] is `@Required()`: Unset blocks submit even if [T] allows null
  ///   or a default exists.
  /// - [defaultValue] is the constructor default of the Schema field. The Field
  ///   starts with it and the output falls back to it while the Field is Unset.
  /// - [initial] is the starting value, which goes through the Normalizers. A
  ///   null record starts the Field Unset (or at its default).
  FormidableField({
    List<FormidableNormalizer<T>> normalizers = const [],
    List<FormidableValidator<T>> validators = const [],
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
  final List<FormidableValidator<T>> _validators;
  final bool _required;
  final T? _defaultValue;
  FormidablePipeline? _pipeline;
  T? _value;
  bool _isSet = false;
  bool _touched = false;
  bool _stale = false;
  FormidableValidationError? _inputError;
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

  /// Restores the initial value and presence, clears the errors and forgets
  /// that the user touched the Field. Form Effects do not run.
  @override
  void reset() {
    _assign(_initialIsSet ? (value: _initialValue as T) : null);
    _touched = false;
    _stale = true;
    _settle();
  }

  /// Makes the current value and presence the new initial state, so the Field
  /// is no longer dirty.
  @override
  void commit() {
    _initialIsSet = _isSet;
    _initialValue = _value;
    _stale = true;
    _settle();
  }

  /// Rejects what the user typed: the Field becomes Unset and invalid with
  /// [error], even when it is optional, so that bad input never turns into a
  /// null silently. [error] replaces the required error.
  ///
  /// Widgets call it when a Codec fails to parse their input. The next
  /// [setValue] or [clear] lifts the rejection.
  void reject(FormidableValidationError error) =>
      _write(() => _reject(error));

  /// The error given to [reject], or null when the last input was accepted.
  FormidableValidationError? get inputError => _inputError;

  /// Records that the user interacted with the Field and left it.
  void markAsTouched() {
    if (_touched) return;
    _touched = true;
    _refresh();
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
    if (_stale) _refresh();
  }

  /// Brings the state up to date: through the Form when there is one, so it
  /// notifies once for a batch of writes, otherwise on its own.
  void _settle() {
    final pipeline = _pipeline;
    if (pipeline == null) {
      _refresh();
    } else {
      pipeline.settle();
    }
  }

  /// Runs [mutate] through the Form pipeline, or on its own when the Field is
  /// not part of a Form.
  void _write(bool Function() mutate) {
    final pipeline = _pipeline;
    if (pipeline == null) {
      if (mutate()) _refresh();
    } else {
      pipeline.change(this, mutate);
    }
  }

  /// Replaces the value and presence without validating. Returns whether
  /// either changed.
  bool _assign(({T value})? next) {
    final lifted = _inputError != null;
    _inputError = null;
    final isSet = next != null;
    final value = next?.value;
    if (isSet == _isSet && value == _value) {
      if (lifted) _stale = true;
      return lifted;
    }
    _isSet = isSet;
    _value = value;
    _stale = true;
    return true;
  }

  /// Makes the Field Unset with [error]. Returns whether anything changed.
  bool _reject(FormidableValidationError error) {
    if (!_isSet && _inputError == error) return false;
    _isSet = false;
    _value = null;
    _inputError = error;
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
  void _refresh() {
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
    errors: _isSet
        ? _validate(_value)
        : _inputError != null
        ? [_inputError!]
        : _presenceErrors(),
  );

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
        ...validator.validate(value as T),
  ];
}

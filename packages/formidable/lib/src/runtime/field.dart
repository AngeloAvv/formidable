import 'dart:async';

import 'package:meta/meta.dart';

import '../normalizers/normalizer.dart';
import '../validation/async_validator.dart';
import '../validation/required_error.dart';
import '../validation/validation_error.dart';
import '../validation/validator.dart';
import 'field_state.dart';
import 'focus_target.dart';
import 'node.dart';
import 'notifier.dart';
import 'pipeline.dart';
import 'status.dart';
import 'streams.dart';

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
  /// - [asyncValidators] run after the synchronous ones pass, once the Field
  ///   has been unchanged for their debounce. The Field is pending until they
  ///   answer.
  /// - [required] is `@Required()`: Unset blocks submit even if [T] allows null
  ///   or a default exists.
  /// - [defaultValue] is the constructor default of the Schema field. The Field
  ///   starts with it and the output falls back to it while the Field is Unset.
  /// - [initial] is the starting value, which goes through the Normalizers. A
  ///   null record starts the Field Unset (or at its default).
  /// - [name] is the name of the Schema field, used in error messages.
  FormidableField({
    List<FormidableNormalizer<T>> normalizers = const [],
    List<FormidableValidator<Object?>> validators = const [],
    List<FormidableAsyncValidator<Object?>> asyncValidators = const [],
    bool required = false,
    T? defaultValue,
    ({T value})? initial,
    this.name,
  }) : _normalizers = normalizers,
       _validators = validators,
       _asyncValidators = asyncValidators,
       _required = required,
       _defaultValue = defaultValue {
    final start = initial == null
        ? (defaultValue == null ? null : (value: defaultValue))
        : _normalize(initial.value);
    _defined = start != null;
    _value = start?.value;
    _initialDefined = _defined;
    _initialValue = _value;
    _state = _stateFor();
    _notified = _state;
  }

  /// The name of the Schema field, or null.
  final String? name;

  final List<FormidableNormalizer<T>> _normalizers;
  final List<FormidableValidator<Object?>> _validators;
  final List<FormidableAsyncValidator<Object?>> _asyncValidators;
  List<FormidableValidationError> _formErrors = const [];
  final bool _required;
  final T? _defaultValue;
  FormidablePipeline? _pipeline;
  T? _value;
  bool _defined = false;
  bool _touched = false;
  bool _enabled = true;
  bool _submitted = false;
  final List<FormidableFocusTarget> _focusTargets = [];
  final List<void Function()> _focusLayoutListeners = [];
  List<FormidableValidationError> _applied = const [];
  bool _stale = false;
  FormidableValidationError? _inputError;
  Timer? _asyncTimer;
  int _asyncToken = 0;
  // The value the running or finished async check is about, null when no
  // check is wanted.
  ({T? value})? _asyncInput;
  bool _asyncPending = false;
  List<FormidableValidationError> _asyncErrors = const [];
  List<FormidableValidationError> _asyncFormErrors = const [];
  bool _asyncFormPending = false;
  bool _readyForFormCheck = false;
  late FormidableFieldState<T> _state;
  late FormidableFieldState<T> _notified;
  late bool _initialDefined;
  late T? _initialValue;

  @override
  FormidableFieldState<T> get state => _state;

  FormidableStreamHub? _streamHub;

  FormidableStreamHub get _hub =>
      _streamHub ??= FormidableStreamHub(this, () => isDisposed);

  /// Every state of the Field, as it changes: the value, but also touched,
  /// errors, pending, enabled and the rest.
  ///
  /// It is a broadcast stream that delivers synchronously, right after the
  /// change, like [addListener]. It never emits the state the Field is in when
  /// you listen, it listens to the Field only while it has subscribers, and it
  /// closes when the Field is disposed. The same holds for [valueChanges],
  /// [statusChanges] and [select].
  Stream<FormidableFieldState<T>> get changes =>
      _hub.derive(() => _state, (state) => state, same: (_, _) => false);

  /// The value of the Field, each time its value or presence changes, and
  /// only then: touching the Field, focusing it or changing its errors is not
  /// a value change.
  ///
  /// The event is `null` both when the Field becomes Unset and when null is
  /// chosen on a nullable Field, so a change from one to the other emits
  /// `null` although the value read as `null` before too. Read [defined] in the
  /// listener to tell them apart (ADR-0003).
  ///
  /// ```dart
  /// form.query.valueChanges.listen((query) => search(query));
  /// ```
  Stream<T?> get valueChanges => _hub.derive<({bool defined, T? value}), T?>(
    () => (defined: _state.defined, value: _state.valueOrNull),
    (key) => key.value,
  );

  /// The status of the Field, each time it changes between valid, invalid and
  /// pending.
  Stream<FormidableStatus> get statusChanges =>
      _hub.derive(() => _state.status, (status) => status);

  /// What [selector] returns for the state of the Field, each time it differs
  /// (by `==`) from what it returned before. The first selection is computed
  /// when you listen, so the first event is a real change.
  ///
  /// ```dart
  /// field.select((state) => state.touched && state.errors.isNotEmpty);
  /// ```
  Stream<R> select<R>(R Function(FormidableFieldState<T> state) selector) =>
      _hub.derive(() => selector(_state), (selection) => selection);

  /// The current value. It is null when null was chosen on a nullable [T].
  ///
  /// Throws a [StateError] while the Field is Unset (ADR-0003). Check
  /// [defined] first, or read [valueOrNull].
  ///
  /// It is current even while Form Effects run, unlike [state]. In a Form
  /// Effect, which can run on an Unset Field, check `defined` and then read
  /// `value`: [valueOrNull] cannot tell Unset from null on a nullable Field.
  ///
  /// ```dart
  /// if (form.province.defined) form.city.setValue(form.province.value);
  /// ```
  T get value {
    if (!_defined) throw unsetFieldError(name);
    return _value as T;
  }

  /// The current value, or null while the Field is Unset. Null is also a valid
  /// chosen value for a nullable [T], so only [defined] tells them apart.
  T? get valueOrNull => _value;

  /// Whether the Field holds a value.
  bool get defined => _defined;

  /// Whether the Field has no errors. A running check does not count.
  @override
  @internal
  bool get isValid => _state.errors.isEmpty;

  /// Gives the Field a value. The type is exactly the Field's type, so the
  /// compiler rejects null for a non-nullable Field.
  ///
  /// The value goes through the Normalizers, then the Form Effects, then the
  /// Validators. A Normalizer can make the Field Unset instead.
  void setValue(T value) => _write(() => _assign(_normalize(value)));

  /// Makes the Field Unset.
  void clear() => _write(() => _assign(null));

  /// Makes the Field take part in the Form again, and validates it.
  void enable() => _setEnabled(true);

  /// Takes the Field out of validation: its Validators, the Form Validators and
  /// cross-field rules that address it, and the Async Validators stop judging
  /// it, and applied errors are hidden. It keeps its value and still
  /// contributes to the output. An Unset Field that is required still blocks
  /// submit, because no valid output exists without it.
  void disable() => _setEnabled(false);

  /// Shows [errors] on the Field, after the errors of its Validators, and makes
  /// the Field invalid. Use it for errors that only a server can find. They
  /// replace the errors applied before and go away on the next change of the
  /// Field's value or presence. An empty list removes them right away.
  ///
  /// A disabled Field shows no applied errors.
  void applyErrors(List<FormidableValidationError> errors) {
    _applied = List.unmodifiable(errors);
    _stale = true;
    _settle();
  }

  void _setEnabled(bool enabled) {
    if (_enabled == enabled) return;
    _enabled = enabled;
    _stale = true;
    // Through the Form: the rules that read this Field, and the asynchronous
    // Form Validators that wait for it, have to run again.
    _settle();
    _focusLayoutChanged();
  }

  /// Replaces the errors that the Form Validators address to this Field. They
  /// are added after the Field's own errors. Called by the Form before it
  /// revalidates; an application has no reason to call it.
  void replaceFormErrors(List<FormidableValidationError> errors) {
    if (_sameErrors(_formErrors, errors)) return;
    _formErrors = List.unmodifiable(errors);
    _stale = true;
  }

  /// Brings [state] up to date with the Field's own rules (presence, Validators
  /// and Async Validators) and without the errors of the Form Validators, then
  /// leaves the Field stale so that the next `revalidate` publishes the final
  /// state. It does not notify. The Form calls it before it runs the Form
  /// Validators, so that they read the current errors of the Fields; an
  /// application has no reason to call it.
  void refreshOwnState() {
    _formErrors = const [];
    _state = _stateFor();
    _stale = true;
  }

  /// Restores the initial value and presence, clears the errors and forgets
  /// that the user touched the Field. Form Effects do not run.
  @override
  void reset() {
    _assign(_initialDefined ? (value: _initialValue as T) : null);
    _touched = false;
    _stale = true;
    _settle();
  }

  /// Makes the current value and presence the new initial state, so the Field
  /// is no longer dirty.
  @override
  void commit() {
    _initialDefined = _defined;
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
  void reject(FormidableValidationError error) => _write(() => _reject(error));

  /// The error given to [reject], or null when the last input was accepted.
  FormidableValidationError? get inputError => _inputError;

  /// Records that the user interacted with the Field and left it.
  void touch() {
    if (_touched) return;
    _touched = true;
    _refresh();
  }

  /// Registers the widget that shows this Field, so that [focus] and [unfocus]
  /// reach it. When several are registered the last one wins. Returns a
  /// function that removes the registration.
  void Function() registerFocusTarget(FormidableFocusTarget target) {
    _focusTargets.add(target);
    _focusLayoutChanged();
    return () {
      if (_focusTargets.remove(target)) _focusLayoutChanged();
    };
  }

  /// Calls [listener] when a widget is registered for any Field of the Form
  /// (or removed), which can change whether this Field is the last one that
  /// the keyboard reaches. A standalone Field only hears about itself.
  void addFocusLayoutListener(void Function() listener) =>
      _focusLayoutListeners.add(listener);

  void removeFocusLayoutListener(void Function() listener) =>
      _focusLayoutListeners.remove(listener);

  /// Calls the focus layout listeners. Public only because Fields and Forms
  /// are different libraries: a Form calls it on every Field.
  void notifyFocusLayout() {
    for (final listener in List.of(_focusLayoutListeners)) {
      listener();
    }
  }

  void _focusLayoutChanged() {
    final pipeline = _pipeline;
    if (pipeline == null) {
      notifyFocusLayout();
    } else {
      pipeline.focusLayoutChanged();
    }
  }

  /// The Field after this one in Schema declaration order that the keyboard
  /// can reach (enabled and shown by a widget), or null for the last one and
  /// for a standalone Field.
  FormidableField<Object?>? get nextFocusable {
    final order = _pipeline?.focusOrder;
    if (order == null) return null;
    final index = order.indexOf(this);
    if (index < 0) return null;
    return order.skip(index + 1).where((field) => field.canFocus).firstOrNull;
  }

  /// Moves the input focus to [nextFocusable]. Returns false, and moves
  /// nothing, when there is none.
  bool focusNext() {
    final next = nextFocusable;
    if (next == null) return false;
    next.focus();
    return true;
  }

  /// Whether [focus] can do something: the Field is enabled and a widget is
  /// registered for it.
  bool get canFocus => _enabled && _focusTargets.isNotEmpty;

  /// Moves the input focus to the widget of the Field. It does nothing when
  /// the Field is disabled or no widget shows it.
  void focus() {
    if (canFocus) _focusTargets.last.focus();
  }

  /// Takes the input focus away from the widget of the Field.
  void unfocus() {
    if (_focusTargets.isNotEmpty) _focusTargets.last.unfocus();
  }

  @override
  void markSubmitted() {
    if (_touched && _submitted) return;
    _touched = true;
    _submitted = true;
    _refresh();
  }

  /// The value the Field contributes to the Schema instance.
  ///
  /// An Unset Field produces its default, then null when [T] is nullable. If
  /// neither applies the Field has a required error and this throws.
  T get output {
    if (_defined) return _value as T;
    if (_defaultValue != null) return _defaultValue as T;
    if (null is T) return null as T;
    throw StateError('A required Field is Unset and has no output.');
  }

  @override
  @internal
  bool get isDirty => _state.dirty;

  @override
  @internal
  bool get isPending => _state.pending;

  /// Whether an asynchronous Form Validator that reads this Field may run:
  /// the Field has a value and nothing but that check has any error to report
  /// and no check of its own is running. Used by the Form.
  bool get readyForFormCheck => _readyForFormCheck;

  /// Replaces the result of the asynchronous Form Validators that read this
  /// Field: the [errors] they addressed to it and whether one of them is still
  /// [pending]. Called by the Form before it revalidates; an application has
  /// no reason to call it.
  void replaceAsyncFormResult(
    List<FormidableValidationError> errors, {
    required bool pending,
  }) {
    if (pending == _asyncFormPending && _sameErrors(_asyncFormErrors, errors)) {
      return;
    }
    _asyncFormPending = pending;
    _asyncFormErrors = List.unmodifiable(errors);
    _stale = true;
  }

  @override
  void dispose() {
    _cancelAsync();
    _streamHub?.close();
    super.dispose();
  }

  @override
  void collectErrors(
    Map<FormidableNode, List<FormidableValidationError>> into,
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
    final defined = next != null;
    final value = next?.value;
    if (defined == _defined && value == _value) {
      if (lifted) _stale = true;
      return lifted;
    }
    _defined = defined;
    _value = value;
    _applied = const [];
    _stale = true;
    return true;
  }

  /// Makes the Field Unset with [error]. Returns whether anything changed.
  bool _reject(FormidableValidationError error) {
    if (!_defined && _inputError == error) return false;
    _defined = false;
    _value = null;
    _inputError = error;
    _applied = const [];
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

  FormidableFieldState<T> _stateFor() {
    final own = _defined
        ? (_enabled ? _validate(_value) : const <FormidableValidationError>[])
        : _inputError != null
        ? [_inputError!]
        : _presenceErrors();
    final passes = _defined && _enabled && own.isEmpty && _formErrors.isEmpty;
    _driveAsync(wanted: passes);
    _readyForFormCheck = passes && !_asyncPending && _asyncErrors.isEmpty;
    return FormidableFieldState<T>(
      value: _value,
      name: name,
      defined: _defined,
      touched: _touched,
      enabled: _enabled,
      submitted: _submitted,
      dirty:
          _defined != _initialDefined || (_defined && _value != _initialValue),
      pending: _asyncPending || (_enabled && _asyncFormPending),
      errors: [
        ...own,
        // A disabled Field takes no part in validation: only its presence
        // errors (in `own`) remain, so every rule that judges its value or
        // spans several Fields is dropped.
        if (_enabled) ..._formErrors,
        ..._asyncErrors,
        if (_enabled) ..._asyncFormErrors,
        if (_enabled) ..._applied,
      ],
    );
  }

  /// The Async Validators that judge [value]: the ones that accept null are
  /// the only ones that see it.
  List<FormidableAsyncValidator<Object?>> _asyncFor(T? value) => [
    for (final validator in _asyncValidators)
      if (value != null || validator.acceptsNull) validator,
  ];

  /// Starts, keeps or cancels the async check so that it matches the current
  /// value. [wanted] is whether the Field may be checked at all: it has a
  /// value and every synchronous rule passes.
  void _driveAsync({required bool wanted}) {
    if (_asyncValidators.isEmpty) return;
    final validators = wanted
        ? _asyncFor(_value)
        : const <FormidableAsyncValidator<Object?>>[];
    if (validators.isEmpty) {
      _cancelAsync();
      return;
    }
    final input = _asyncInput;
    if (input != null && input.value == _value) return;
    _asyncTimer?.cancel();
    final token = ++_asyncToken;
    final value = _value;
    _asyncInput = (value: value);
    _asyncErrors = const [];
    _asyncPending = true;
    final debounce = validators
        .map((v) => v.debounce)
        .reduce((a, b) => a >= b ? a : b);
    _asyncTimer = Timer(debounce, () => _runAsync(token, value, validators));
  }

  /// Drops the running async check and its result. The future of a running
  /// check is not interrupted, but nobody listens to it anymore.
  void _cancelAsync() {
    _asyncTimer?.cancel();
    _asyncTimer = null;
    _asyncToken++;
    _asyncInput = null;
    _asyncPending = false;
    _asyncErrors = const [];
  }

  Future<void> _runAsync(
    int token,
    T? value,
    List<FormidableAsyncValidator<Object?>> validators,
  ) async {
    List<FormidableValidationError> errors;
    try {
      final results = await Future.wait([
        for (final validator in validators)
          Future.sync(() => validator.validate(value)),
      ]);
      errors = [for (final result in results) ...result];
    } on Object catch (error) {
      errors = [FormidableAsyncCheckFailedError(error)];
    }
    // A newer value, Unset, disable or dispose made this result stale.
    if (token != _asyncToken || isDisposed) return;
    _asyncTimer = null;
    _asyncPending = false;
    _asyncErrors = List.unmodifiable(errors);
    _stale = true;
    _settle();
  }

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
      if (value != null || validator.acceptsNull) ...validator.validate(value),
  ];
}

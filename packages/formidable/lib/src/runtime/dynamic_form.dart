import 'package:meta/meta.dart';

import '../normalizers/normalizer.dart';
import '../validation/async_validator.dart';
import '../validation/validation_error.dart';
import '../validation/validator.dart';
import 'field.dart';
import 'field_state.dart';
import 'form.dart';
import 'form_state.dart';
import 'node.dart';
import 'notifier.dart';
import 'pipeline.dart';
import 'status.dart';
import 'streams.dart';

/// Thrown when a key of a [FormidableDynamicForm] is used wrongly: it is
/// already registered, or nothing is registered under it.
final class FormidableDynamicKeyError extends StateError {
  FormidableDynamicKeyError(String key, {required bool registered})
    : super(
        registered
            ? 'A Dynamic Form already has a Field registered under "$key". '
                  'Remove it first, or use another key.'
            : 'A Dynamic Form has nothing registered under "$key". Register '
                  'it first, or check `contains`.',
      );
}

/// Thrown when a Dynamic Form is asked for a Field with another type than the
/// one it was registered with, or given a Validator or a value that does not
/// fit that type.
final class FormidableDynamicTypeError extends StateError {
  FormidableDynamicTypeError(super.message);
}

/// What observers of a [FormidableDynamicForm] see: the keys that are
/// registered, in registration order, and the state of what is registered
/// under each of them.
///
/// It changes when a Field is registered or removed and when any of them
/// changes, so a widget that follows it rebuilds then and only then. Equality
/// is deep.
final class FormidableDynamicFormState {
  FormidableDynamicFormState(
    Map<String, Object> states, {
    this.enabled = true,
    Map<String, Object? Function(Object state)> readers = const {},
  }) : states = Map.unmodifiable(states),
       _readers = readers;

  final Map<String, Object? Function(Object state)> _readers;

  /// The values of the registered Fields and Nested Forms, by key, in
  /// registration order, built from the states this one holds (so it never
  /// reads a Dynamic Form that has moved on). A Nested Form that is Unset has
  /// null. Read it only while the Form is valid, like any output. It does not
  /// take part in equality.
  Map<String, Object?> get output => {
    for (final entry in states.entries)
      entry.key: _readers[entry.key]!(entry.value),
  };

  /// Whether the Dynamic Form takes part in the Form: its own flag (`enable()`
  /// and `disable()`) and every container above it. While it is false, every
  /// Field and Nested Form registered in it is disabled as well.
  final bool enabled;

  /// The state of every registered node, by key, in registration order: a
  /// [FormidableFieldState] for a Field, the generated state of a Nested Form
  /// for a Nested Form.
  final Map<String, Object> states;

  /// [FormidableStatus.invalid] when any registered Field or Nested Form has
  /// errors, even if a check is still running; [FormidableStatus.pending] when
  /// there are none but a check is running; [FormidableStatus.valid]
  /// otherwise, which includes nothing being registered. It is derived from
  /// [states].
  FormidableStatus get status {
    final failed = states.values.any(
      (state) => switch (state) {
        FormidableFieldState<Object?>(:final errors) => errors.isNotEmpty,
        FormidableFormState(:final meta) =>
          meta.status == FormidableStatus.invalid,
        _ => false,
      },
    );
    if (failed) return FormidableStatus.invalid;
    return pending ? FormidableStatus.pending : FormidableStatus.valid;
  }

  /// Whether the Dynamic Form can be submitted now: nothing registered has
  /// errors and no check is running. It is `status == FormidableStatus.valid`,
  /// so it is false while the Dynamic Form is [pending].
  bool get valid => status == FormidableStatus.valid;

  /// Whether any registered Field or Nested Form differs from its initial
  /// state. It is derived from [states].
  bool get dirty => states.values.any(
    (state) => switch (state) {
      FormidableFieldState<Object?>(:final dirty) => dirty,
      FormidableFormState(:final meta) => meta.dirty,
      _ => false,
    },
  );

  /// Whether any registered Field or Nested Form is still waiting for a
  /// result. It is derived from [states].
  bool get pending => states.values.any(
    (state) => switch (state) {
      FormidableFieldState<Object?>(:final pending) => pending,
      FormidableFormState(:final meta) => meta.pending,
      _ => false,
    },
  );

  /// The registered keys, in registration order.
  List<String> get keys => states.keys.toList(growable: false);

  /// Whether something is registered under [key].
  bool contains(String key) => states.containsKey(key);

  /// The state of the Field registered under [key], with the type it was
  /// registered with. Throws a [FormidableDynamicKeyError] when nothing is
  /// registered under [key] and a [FormidableDynamicTypeError] when [T] is not
  /// the type of the Field.
  FormidableFieldState<T> field<T>(String key) {
    final state = states[key];
    if (state == null) {
      throw FormidableDynamicKeyError(key, registered: false);
    }
    if (state is! FormidableFieldState<T>) {
      throw FormidableDynamicTypeError(
        '"$key" holds ${state.runtimeType}, which is not the state of a Field '
        'of type $T. Look it up with the type it was registered with '
        '(nullability included).',
      );
    }
    return state;
  }

  /// The state of the Nested Form registered under [key], typed as [S].
  S form<S extends FormidableFormState>(String key) {
    final state = states[key];
    if (state == null) {
      throw FormidableDynamicKeyError(key, registered: false);
    }
    if (state is! S) {
      throw FormidableDynamicTypeError(
        '"$key" holds ${state.runtimeType}, which is not a $S.',
      );
    }
    return state;
  }

  @override
  bool operator ==(Object other) =>
      other is FormidableDynamicFormState &&
      other.enabled == enabled &&
      _same(other.states, states);

  @override
  int get hashCode => Object.hashAll([
    enabled,
    for (final entry in states.entries) Object.hash(entry.key, entry.value),
  ]);

  @override
  String toString() => 'FormidableDynamicFormState($states, enabled: $enabled)';

  static bool _same(Map<String, Object> a, Map<String, Object> b) {
    if (a.length != b.length) return false;
    final left = a.entries.iterator;
    final right = b.entries.iterator;
    while (left.moveNext() && right.moveNext()) {
      if (left.current.key != right.current.key ||
          left.current.value != right.current.value) {
        return false;
      }
    }
    return true;
  }
}

/// The part of a Form that is described at runtime: a `@Dynamic()` map Field
/// of the Schema.
///
/// Fields (and Nested Forms) are registered under a string key, each with an
/// explicit type, and are then looked up by the same key and type. They are
/// ordinary nodes of the Form: their writes go through the Form Effects and
/// validation, they count for dirty, reset, commit, submit and focus order,
/// and Form Validators can address them. The output is a map of the values in
/// registration order.
///
/// Registering or removing a Field is a change of the Form like a write: Form
/// Effects run and every Field is validated again. It does not make the Form
/// dirty, because the structure is not user input. Neither `reset()` nor
/// `commit()` registers or removes anything.
///
/// A Dynamic Form owns what is registered in it: removing a Field or disposing
/// the Form disposes the Field.
final class FormidableDynamicForm
    with FormidableNotifierMixin
    implements
        FormidableNode,
        FormidableObservable<FormidableDynamicFormState> {
  /// Creates an empty Dynamic Form. [initial] holds values for keys that are
  /// not registered yet: a Field registered later under one of them starts with
  /// that value, which must have the Field's type.
  FormidableDynamicForm({Map<String, Object?>? initial})
    : _offers = {...?initial};

  final Map<String, _Entry> _entries = {};
  final Map<String, Object?> _offers;
  FormidablePipeline? _pipeline;
  bool _enabled = true;
  bool _locked = false;
  FormidableDynamicFormState _state = FormidableDynamicFormState(const {});
  FormidableDynamicFormState _notified = FormidableDynamicFormState(const {});

  @override
  FormidableDynamicFormState get state => _state;

  FormidableStreamHub? _streamHub;

  FormidableStreamHub get _hub =>
      _streamHub ??= FormidableStreamHub(this, () => isDisposed);

  /// Every state of the Dynamic Form, as it changes: what is registered in it
  /// and every state below.
  ///
  /// It is a broadcast stream that delivers synchronously, right after the
  /// change, like [addListener]. It never emits the state the Dynamic Form is
  /// in when you listen, it listens to it only while it has subscribers, and it
  /// closes when the Dynamic Form is disposed. The same holds for
  /// [valueChanges], [statusChanges] and [select].
  Stream<FormidableDynamicFormState> get changes =>
      _hub.derive(() => _state, (state) => state, same: (_, _) => false);

  /// The state of the Dynamic Form, each time a Field or a Nested Form is
  /// registered or removed, or the value or presence of a Field in it changes.
  /// Touching, submitting and errors are not value changes.
  Stream<FormidableDynamicFormState> get valueChanges =>
      _hub.derive<List<Object?>, FormidableDynamicFormState>(
        () => valueKeyOf(this),
        (_) => _state,
        same: sameValueKey,
      );

  /// The status of the Dynamic Form, each time it changes between valid,
  /// invalid and pending. It is invalid when anything registered in it is, and
  /// pending when there are no errors but a check is running.
  Stream<FormidableStatus> get statusChanges =>
      _hub.derive(() => _state.status, (status) => status);

  /// What [selector] returns for the state of the Dynamic Form, each time it
  /// differs (by `==`) from what it returned before. The first selection is
  /// computed when you listen, so the first event is a real change.
  Stream<R> select<R>(R Function(FormidableDynamicFormState state) selector) =>
      _hub.derive(() => selector(_state), (selection) => selection);

  /// Makes the Dynamic Form take part again: what is registered in it goes back
  /// to what its own flags say, so a Field that was disabled on its own stays
  /// disabled. It notifies once.
  void enable() => _setEnabled(true);

  /// Disables every Field and Nested Form registered in it, and the ones
  /// registered later, exactly like a Field disabled on its own and without
  /// changing their flags. `state.enabled` reports the effective value (its own
  /// flag and every container above it). It notifies once.
  void disable() => _setEnabled(false);

  void _setEnabled(bool enabled) {
    if (_enabled == enabled) return;
    _enabled = enabled;
    _pushLock();
    final pipeline = _pipeline;
    if (pipeline == null) {
      revalidate();
    } else {
      pipeline.settle();
      pipeline.focusLayoutChanged();
    }
  }

  bool get _containerEnabled => _enabled && !_locked;

  void _pushLock() {
    for (final node in children) {
      node.applyLock(!_containerEnabled);
    }
  }

  @override
  void applyLock(bool locked) {
    if (_locked == locked) return;
    _locked = locked;
    _pushLock();
  }

  /// The registered keys, in registration order.
  List<String> get keys => _entries.keys.toList(growable: false);

  /// The registered nodes, in registration order.
  Iterable<FormidableNode> get children =>
      _entries.values.map((entry) => entry.node);

  /// Whether something is registered under [key].
  bool contains(String key) => _entries.containsKey(key);

  /// Registers a Field of type [T] under [key] and returns it.
  ///
  /// [T] is the exact type of the Field, nullability included: `register<int>`
  /// makes a required Field, `register<int?>` an optional one. [validators]
  /// must accept [T], or this throws a [FormidableDynamicTypeError]. So must
  /// [asyncValidators]: the instances you pass live as long as the Field, like
  /// the ones a generated Form takes, and run under the same rules (see
  /// [FormidableAsyncValidator]). The other arguments are those of
  /// [FormidableField].
  ///
  /// A value for [key] given when the Dynamic Form was created, or written to
  /// it before, is the starting value of the Field.
  FormidableField<T> register<T>(
    String key, {
    List<FormidableNormalizer<T>> normalizers = const [],
    List<FormidableValidator<Object?>> validators = const [],
    List<FormidableAsyncValidator<Object?>> asyncValidators = const [],
    bool required = false,
    T? defaultValue,
  }) {
    _checkFree(key);
    for (final validator in asyncValidators) {
      if (!validator.fitsValueType<T>()) {
        throw FormidableDynamicTypeError(
          'The Async Validator ${validator.runtimeType} cannot be used on '
          '"$key": the Field is registered as $T, which that Async Validator '
          'does not accept.',
        );
      }
    }
    for (final validator in validators) {
      if (!validator.fitsValueType<T>()) {
        throw FormidableDynamicTypeError(
          'The Validator ${validator.runtimeType} cannot be used on "$key": '
          'the Field is registered as $T, which that Validator does not '
          'accept.',
        );
      }
    }
    ({T value})? initial;
    if (_offers.containsKey(key)) {
      final offered = _offers.remove(key);
      if (offered is! T) {
        throw FormidableDynamicTypeError(
          'The initial value of "$key" is ${offered.runtimeType}, but the '
          'Field is registered as $T.',
        );
      }
      initial = (value: offered);
    }
    final field = FormidableField<T>(
      normalizers: normalizers,
      validators: validators,
      asyncValidators: asyncValidators,
      required: required,
      defaultValue: defaultValue,
      initial: initial,
      name: key,
    );
    _add(
      key,
      _Entry(
        T,
        field,
        write: (value) {
          if (value is! T) {
            throw FormidableDynamicTypeError(
              'The value of "$key" is ${value.runtimeType}, but the Field is '
              'registered as $T.',
            );
          }
          field.setValue(value);
        },
        clear: field.clear,
        output: () => field.output,
        read: (state) {
          final fieldState = state as FormidableFieldState<T>;
          if (fieldState.defined) return fieldState.value;
          if (defaultValue != null) return defaultValue;
          if (null is T) return null;
          throw StateError('A required Field is Unset and has no output.');
        },
        state: () => field.state,
      ),
    );
    return field;
  }

  /// Registers a Nested Form under [key] and returns it. Its value in the
  /// output map is the Schema instance, or null while it is an Unset optional
  /// Nested Form.
  F registerForm<F extends FormidableForm<Object?>>(String key, F form) {
    _checkFree(key);
    _add(
      key,
      _Entry(
        F,
        form,
        clear: form.clear,
        output: () => form.outputOrNull,
        read: (state) => (state as FormidableFormState).meta.valueOrNull,
        state: () => form.state,
      ),
    );
    return form;
  }

  /// The Field registered under [key] with the type [T].
  ///
  /// It throws a [FormidableDynamicKeyError] when nothing is registered under
  /// [key], and a [FormidableDynamicTypeError] when [T] is not the type the
  /// Field was registered with (`int` is not `int?`).
  FormidableField<T> field<T>(String key) {
    final entry = _lookup(key, 'a Field', T);
    final node = entry.node;
    if (node is! FormidableField<Object?> || entry.type != T) {
      throw _mismatch(key, entry, 'a Field', T);
    }
    return node as FormidableField<T>;
  }

  /// The Nested Form registered under [key] with the type [F].
  ///
  /// Throws like [field].
  F form<F extends FormidableForm<Object?>>(String key) {
    final entry = _lookup(key, 'a Nested Form', F);
    final node = entry.node;
    if (node is! FormidableForm<Object?> || entry.type != F) {
      throw _mismatch(key, entry, 'a Nested Form', F);
    }
    return node as F;
  }

  /// Removes and disposes what is registered under [key]. Throws a
  /// [FormidableDynamicKeyError] when there is nothing.
  void remove(String key) {
    final entry = _entries.remove(key);
    if (entry == null) {
      throw FormidableDynamicKeyError(key, registered: false);
    }
    _unfollow(entry.node);
    entry.node.dispose();
    _structureChanged(this);
  }

  /// The values of the registered Fields, by key, in registration order. Call
  /// it only when the Form is valid, like the output of any Field.
  Map<String, Object?> get output => {
    for (final entry in _entries.entries) entry.key: entry.value.output(),
  };

  /// Writes the values of the registered Fields whose key is in [values]; call
  /// it inside the `batch` of the Form. A value for a key that is not
  /// registered waits for the Field registered under it. Nested Forms are
  /// skipped: write them through their own `replace`.
  ///
  /// A value that does not have the type of its Field throws a
  /// [FormidableDynamicTypeError].
  void patch(Map<String, Object?> values) {
    values.forEach((key, value) {
      final entry = _entries[key];
      if (entry == null) {
        _offers[key] = value;
      } else {
        entry.write?.call(value);
      }
    });
  }

  /// Like [patch], and every registered Field that is not in [values] becomes
  /// Unset, as does every Nested Form, so the Dynamic Form ends up holding
  /// exactly [values]. Values that waited for a Field are dropped.
  void replace(Map<String, Object?> values) {
    _offers.clear();
    patch(values);
    for (final entry in _entries.entries) {
      if (!values.containsKey(entry.key)) entry.value.clear();
    }
  }

  void _checkFree(String key) {
    if (_entries.containsKey(key)) {
      throw FormidableDynamicKeyError(key, registered: true);
    }
  }

  _Entry _lookup(String key, String wanted, Type type) =>
      _entries[key] ??
      (throw FormidableDynamicKeyError(key, registered: false));

  FormidableDynamicTypeError _mismatch(
    String key,
    _Entry entry,
    String wanted,
    Type type,
  ) {
    final registered = entry.node is FormidableForm<Object?>
        ? 'a Nested Form of type ${entry.type}'
        : 'a Field of type ${entry.type}';
    return FormidableDynamicTypeError(
      '"$key" is $registered, but it was looked up as $wanted of type $type. '
      'Look it up with the type it was registered with (nullability '
      'included).',
    );
  }

  void _add(String key, _Entry entry) {
    _entries[key] = entry;
    final pipeline = _pipeline;
    if (pipeline != null) entry.node.bindPipeline(pipeline);
    entry.node.applyLock(!_containerEnabled);
    _follow(entry.node);
    _structureChanged(entry.node);
  }

  /// Publishes the new state, and lets the Form treat the structure change
  /// like a write: [changed] goes to the Form Effects, then everything is
  /// validated again.
  void _structureChanged(FormidableNode changed) {
    _publish();
    final pipeline = _pipeline;
    if (pipeline != null) {
      pipeline.change(changed, () => true);
      pipeline.focusLayoutChanged();
    }
    _notifyIfChanged();
  }

  /// Follows what is registered: the state of the Dynamic Form holds the state
  /// of every child, so a change below it is a change of its state.
  void _follow(FormidableNode node) => node.addListener(_onChildChanged);

  void _unfollow(FormidableNode node) => node.removeListener(_onChildChanged);

  void _onChildChanged() {
    _publish();
    _notifyIfChanged();
  }

  void _publish() {
    _state = FormidableDynamicFormState(
      {for (final entry in _entries.entries) entry.key: entry.value.state()},
      enabled: _containerEnabled,
      readers: {
        for (final entry in _entries.entries) entry.key: entry.value.read,
      },
    );
  }

  void _notifyIfChanged() {
    if (_state == _notified) return;
    _notified = _state;
    notifyListeners();
  }

  // FormidableNode.

  @override
  @internal
  bool get isValid => children.every((node) => node.isValid);

  @override
  @internal
  bool get isDirty => children.any((node) => node.isDirty);

  @override
  @internal
  bool get isPending => children.any((node) => node.isPending);

  @override
  void collectErrors(
    Map<FormidableNode, List<FormidableValidationError>> into,
  ) {
    for (final node in children) {
      node.collectErrors(into);
    }
  }

  @override
  void markSubmitted() {
    for (final node in children) {
      node.markSubmitted();
    }
  }

  @override
  void bindPipeline(FormidablePipeline pipeline) {
    assert(_pipeline == null, 'bindPipeline must be called once.');
    _pipeline = pipeline;
    for (final node in children) {
      node.bindPipeline(pipeline);
    }
  }

  @override
  void reset() {
    for (final node in children.toList()) {
      node.reset();
    }
  }

  @override
  void commit() {
    for (final node in children.toList()) {
      node.commit();
    }
  }

  @override
  void revalidate() {
    for (final node in children.toList()) {
      node.revalidate();
    }
    _publish();
    _notifyIfChanged();
  }

  @override
  void dispose() {
    for (final node in children.toList()) {
      _unfollow(node);
      node.dispose();
    }
    _entries.clear();
    _streamHub?.close();
    super.dispose();
  }
}

/// What the Dynamic Form remembers about a registered node: its exact type, and
/// how to write, clear and read it without knowing the type.
final class _Entry {
  _Entry(
    this.type,
    this.node, {
    this.write,
    required this.clear,
    required this.output,
    required this.read,
    required this.state,
  });

  final Type type;
  final FormidableNode node;

  /// Writes a value of the registered type, or null for a Nested Form.
  final void Function(Object?)? write;
  final void Function() clear;
  final Object? Function() output;

  /// The value of the node from one of its states.
  final Object? Function(Object state) read;

  /// The current state of the node, a [FormidableFieldState] or the state of
  /// the Nested Form.
  final Object Function() state;
}

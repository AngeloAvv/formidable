import '../normalizers/normalizer.dart';
import '../validation/async_validator.dart';
import '../validation/validation_error.dart';
import '../validation/validator.dart';
import 'field.dart';
import 'form.dart';
import 'node.dart';
import 'notifier.dart';
import 'pipeline.dart';

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
/// registered, in registration order. It changes when a Field is registered or
/// removed, so a widget that lists the Fields rebuilds then and only then.
final class FormidableDynamicFormState {
  FormidableDynamicFormState(List<String> keys)
    : keys = List.unmodifiable(keys);

  final List<String> keys;

  @override
  bool operator ==(Object other) =>
      other is FormidableDynamicFormState && _same(other.keys, keys);

  @override
  int get hashCode => Object.hashAll(keys);

  @override
  String toString() => 'FormidableDynamicFormState(keys: $keys)';

  static bool _same(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
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
  final List<void Function()> _changeListeners = [];
  FormidablePipeline? _pipeline;
  FormidableDynamicFormState _state = FormidableDynamicFormState(const []);

  @override
  FormidableDynamicFormState get state => _state;

  /// The registered keys, in registration order.
  List<String> get keys => _state.keys;

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
      _Entry(F, form, clear: form.clear, output: () => form.outputOrNull),
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
    _follow(entry.node);
    _structureChanged(entry.node);
  }

  /// Publishes the new key list, and lets the Form treat the structure change
  /// like a write: [changed] goes to the Form Effects, then everything is
  /// validated again.
  void _structureChanged(FormidableNode changed) {
    final next = FormidableDynamicFormState(_entries.keys.toList());
    final keysChanged = next != _state;
    _state = next;
    final pipeline = _pipeline;
    if (pipeline == null) {
      _notifyChange();
    } else {
      pipeline.change(changed, () => true);
      pipeline.focusLayoutChanged();
    }
    if (keysChanged) notifyListeners();
  }

  void _follow(FormidableNode node) => node is FormidableForm<Object?>
      ? node.addChangeListener(_notifyChange)
      : node.addListener(_notifyChange);

  void _unfollow(FormidableNode node) => node is FormidableForm<Object?>
      ? node.removeChangeListener(_notifyChange)
      : node.removeListener(_notifyChange);

  /// Calls [listener] after every change of any child or of the keys, even one
  /// that leaves [state] equal. A listener of [state] is called only when the
  /// keys change. A parent Form follows its Dynamic Form with this.
  void addChangeListener(void Function() listener) {
    assert(!isDisposed, 'Cannot add a listener to a disposed object.');
    _changeListeners.add(listener);
  }

  void removeChangeListener(void Function() listener) =>
      _changeListeners.remove(listener);

  void _notifyChange() {
    if (isDisposed) return;
    for (final listener in List.of(_changeListeners)) {
      if (_changeListeners.contains(listener)) listener();
    }
  }

  // FormidableNode.

  @override
  bool get isValid => children.every((node) => node.isValid);

  @override
  bool get isDirty => children.any((node) => node.isDirty);

  @override
  bool get isPending => children.any((node) => node.isPending);

  @override
  void collectErrors(
    Map<FormidableField<Object?>, List<FormidableValidationError>> into,
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
  }

  @override
  void dispose() {
    for (final node in children.toList()) {
      _unfollow(node);
      node.dispose();
    }
    _entries.clear();
    _changeListeners.clear();
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
  });

  final Type type;
  final FormidableNode node;

  /// Writes a value of the registered type, or null for a Nested Form.
  final void Function(Object?)? write;
  final void Function() clear;
  final Object? Function() output;
}

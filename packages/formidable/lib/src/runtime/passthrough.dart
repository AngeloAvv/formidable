import 'package:meta/meta.dart';

import '../validation/validation_error.dart';
import 'node.dart';
import 'notifier.dart';
import 'pipeline.dart';
import 'status.dart';
import 'streams.dart';

/// A Passthrough Field: its value is supplied when the Form is created and it
/// can never be Unset.
///
/// It is not bound to a widget, so it has no errors, is never touched and has
/// no `clear()`. The Form can still change it with [setValue], and it can be
/// observed: its [state] is its current value.
final class FormidablePassthrough<T>
    with FormidableNotifierMixin
    implements FormidableNode, FormidableObservable<T> {
  FormidablePassthrough(T value)
    : _value = value,
      _initial = value,
      _notified = value;

  T _value;
  T _initial;
  FormidablePipeline? _pipeline;
  T _notified;

  /// The current value.
  T get value => _value;

  @override
  T get state => _value;

  FormidableStreamHub? _streamHub;

  FormidableStreamHub get _hub =>
      _streamHub ??= FormidableStreamHub(this, () => isDisposed);

  /// The value, each time it changes. Its state is its value, so this is the
  /// same as [valueChanges]. See `FormidableField.changes` for how the streams
  /// behave.
  Stream<T> get changes => _hub.derive(() => _value, (value) => value);

  /// The value, each time it changes.
  Stream<T> get valueChanges => _hub.derive(() => _value, (value) => value);

  /// A Passthrough Field is always valid, so this never emits. It is here so
  /// that every Field offers the same streams.
  Stream<FormidableStatus> get statusChanges =>
      _hub.derive(() => FormidableStatus.valid, (status) => status);

  /// What [selector] returns for the value, each time it differs (by `==`) from
  /// what it returned before.
  Stream<R> select<R>(R Function(T value) selector) =>
      _hub.derive(() => selector(_value), (selection) => selection);

  @override
  void dispose() {
    _streamHub?.close();
    super.dispose();
  }

  /// Replaces the value. The type is exactly the Field's type. The change goes
  /// through the Form Effects like a change to any other Field.
  void setValue(T value) {
    bool mutate() {
      if (value == _value) return false;
      _value = value;
      return true;
    }

    final pipeline = _pipeline;
    if (pipeline == null) {
      if (mutate()) revalidate();
    } else {
      pipeline.change(this, mutate);
    }
  }

  /// The value the Field contributes to the Schema instance.
  T get output => _value;

  @override
  @internal
  bool get isValid => true;

  @override
  @internal
  bool get isDirty => _value != _initial;

  @override
  @internal
  bool get isPending => false;

  @override
  void reset() {
    _value = _initial;
    _settle();
  }

  @override
  void commit() {
    _initial = _value;
    _settle();
  }

  @override
  void bindPipeline(FormidablePipeline pipeline) {
    assert(_pipeline == null, 'bindPipeline must be called once.');
    _pipeline = pipeline;
  }

  void _settle() {
    final pipeline = _pipeline;
    if (pipeline == null) {
      revalidate();
    } else {
      pipeline.settle();
    }
  }

  @override
  void revalidate() {
    if (_notified == _value) return;
    _notified = _value;
    notifyListeners();
  }

  @override
  @internal
  void markSubmitted() {}

  @override
  void applyLock(bool locked) {}

  @override
  @internal
  void touchTree() {}

  @override
  @internal
  void untouchTree() {}

  @override
  void collectErrors(
    Map<FormidableNode, List<FormidableValidationError>> into,
  ) {}
}

import '../validation/validation_error.dart';
import 'field.dart';
import 'node.dart';
import 'notifier.dart';
import 'pipeline.dart';

/// A Passthrough Field: its value is supplied when the Form is created and it
/// can never be Unset.
///
/// It is not bound to a widget, so it has no errors, is never touched and has
/// no `clear()`. The Form can still change it with [setValue], and it can be
/// observed: its [state] is its current value.
final class FormidablePassthrough<T>
    with FormidableNotifierMixin
    implements FormidableNode, FormidableObservable<T> {
  FormidablePassthrough(T value) : _value = value, _initial = value;

  T _value;
  final T _initial;
  FormidablePipeline? _pipeline;
  late T _notified;

  /// The current value.
  T get value => _value;

  @override
  T get state => _value;

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
      if (mutate()) notifyListeners();
    } else {
      pipeline.change(this, mutate);
    }
  }

  /// The value the Field contributes to the Schema instance.
  T get output => _value;

  @override
  bool get isValid => true;

  @override
  bool get isDirty => _value != _initial;

  @override
  bool get isPending => false;

  @override
  void bindPipeline(FormidablePipeline pipeline) {
    assert(_pipeline == null, 'bindPipeline must be called once.');
    _pipeline = pipeline;
    _notified = _value;
  }

  @override
  void revalidate() {
    if (_notified == _value) return;
    _notified = _value;
    notifyListeners();
  }

  @override
  void markSubmitted() {}

  @override
  void collectErrors(
    Map<FormidableField<Object?>, List<FormidableValidationError>> into,
  ) {}
}

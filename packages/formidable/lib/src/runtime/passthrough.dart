import '../validation/validation_error.dart';
import 'field.dart';
import 'node.dart';
import 'notifier.dart';

/// A Passthrough Field: its value is supplied when the Form is created and it
/// can never be Unset.
///
/// It is not bound to a widget, so it has no errors, is never touched and has
/// no `clear()`. The Form can still change it with [setValue], and it can be
/// observed: its [state] is its current value.
final class FormidablePassthrough<T>
    with FormidableNotifierMixin
    implements FormidableNode, FormidableObservable<T> {
  FormidablePassthrough(T value) : _value = value;

  T _value;

  /// The current value.
  T get value => _value;

  @override
  T get state => _value;

  /// Replaces the value. The type is exactly the Field's type.
  void setValue(T value) {
    if (value == _value) return;
    _value = value;
    notifyListeners();
  }

  /// The value the Field contributes to the Schema instance.
  T get output => _value;

  @override
  bool get isValid => true;

  @override
  void collectErrors(
    Map<FormidableField<Object?>, List<FormidableValidationError>> into,
  ) {}
}

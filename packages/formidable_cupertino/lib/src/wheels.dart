import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:formidable_flutter/formidable_flutter.dart';

/// The control of the pickers made of wheels, which only read their initial
/// value: a value the wheels did not report came from code, and the wheels
/// start again on it (a new key).
///
/// Internal: it is not exported from the package.
class FormidableWheelsState<V extends Object>
    extends FormidableFieldWidgetState<V?, V?> {
  // What the wheels last reported.
  V? _reported;
  int _revision = 0;

  /// The key to give to the wheels for the current [value].
  Key keyFor(V? value) {
    if (value != null && value != _reported) {
      _reported = value;
      _revision++;
    }
    return ValueKey(_revision);
  }

  /// The wheels moved to [value].
  void wheelsChanged(V value) {
    if (!enabled) return;
    _reported = value;
    didChange(value, touch: true);
  }
}

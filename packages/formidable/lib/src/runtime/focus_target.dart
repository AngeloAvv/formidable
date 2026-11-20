/// Something that can take or give up input focus on behalf of a Field, such
/// as the focus node of a widget. The core never knows what it is; the
/// Flutter layer registers one per Binding.
abstract interface class FormidableFocusTarget {
  /// Moves the input focus here.
  void focus();

  /// Takes the input focus away from here.
  void unfocus();
}

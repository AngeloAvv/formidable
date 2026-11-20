import 'package:flutter/widgets.dart';
import 'package:formidable/formidable.dart';

/// The link between one Field and one widget.
///
/// It keeps the value the widget shows, its focus and its errors in sync with
/// the Field. It is headless: it draws nothing, so it works with any widget,
/// including third-party ones. Most code gets one from
/// [FormidableBindingBuilder].
///
/// It owns its [focusNode] and [textController] unless they are passed in.
/// Objects that are passed in are never disposed by the Binding.
class FormidableBinding<T> extends ChangeNotifier {
  FormidableBinding({
    required this.field,
    required this.resolveMessage,
    FocusNode? focusNode,
    TextEditingController? textController,
    this._formatText,
    this._parseText,
  }) : _ownsFocusNode = focusNode == null,
       _ownsTextController = textController == null,
       focusNode = focusNode ?? FocusNode(),
       _textController = textController {
    field.addListener(_onFieldChanged);
    this.focusNode.addListener(_onFocusChanged);
    _hadFocus = this.focusNode.hasFocus;
    if (_textController != null) _syncText();
  }

  final FormidableField<T> field;
  final FocusNode focusNode;

  /// Turns a Validation Error into the text shown for it.
  final String Function(FormidableValidationError error) resolveMessage;
  final String Function(T value)? _formatText;
  final T? Function(String text)? _parseText;
  final bool _ownsFocusNode;
  final bool _ownsTextController;
  TextEditingController? _textController;
  bool _hadFocus = false;

  /// The snapshot of the Field.
  FormidableFieldState<T> get state => field.state;

  /// The value of the Field, or null while it is Unset.
  T? get value => field.value;

  /// Whether the Field holds a value.
  bool get isSet => field.isSet;

  /// Whether the widget accepts input.
  bool get enabled => true;

  /// The Validation Message to show, or null when no error should be shown.
  ///
  /// Errors are shown once the Field is touched, and the first error in the
  /// order of the annotations wins.
  String? get errorText {
    final state = field.state;
    if (!state.touched || state.errors.isEmpty) return null;
    return resolveMessage(state.errors.first);
  }

  /// Controls the text of a text widget and stays in sync with the Field.
  ///
  /// Needs `formatText` and `parseText`. An empty text is Unset.
  TextEditingController get textController {
    assert(
      _formatText != null && _parseText != null,
      'A text controller needs formatText and parseText.',
    );
    if (_textController == null) {
      _textController = TextEditingController();
      _syncText();
    }
    return _textController!;
  }

  /// The widget produced a new value.
  void onChanged(T value) => field.setValue(value);

  /// The widget has no value any more.
  void onCleared() => field.clear();

  /// The user typed [text] into a text widget.
  void onTextChanged(String text) {
    final parsed = _parseText!(text);
    if (parsed == null) {
      field.clear();
    } else {
      field.setValue(parsed);
    }
  }

  /// The user interacted with a widget that cannot take focus and left it.
  void onTouched() => field.markAsTouched();

  void _onFieldChanged() {
    _syncText();
    notifyListeners();
  }

  void _onFocusChanged() {
    final hasFocus = focusNode.hasFocus;
    if (_hadFocus && !hasFocus) field.markAsTouched();
    _hadFocus = hasFocus;
  }

  /// Writes the Field's value to the text controller, unless the controller
  /// already shows it. That check keeps the cursor still while the user types.
  void _syncText() {
    final controller = _textController;
    if (controller == null) return;
    final fieldValue = field.isSet ? field.value : null;
    if (_parseText!(controller.text) == fieldValue) return;
    final text = fieldValue == null ? '' : _formatText!(fieldValue);
    controller.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }

  @override
  void dispose() {
    field.removeListener(_onFieldChanged);
    focusNode.removeListener(_onFocusChanged);
    if (_ownsFocusNode) focusNode.dispose();
    if (_ownsTextController) _textController?.dispose();
    super.dispose();
  }
}

import 'package:flutter/widgets.dart';
import 'package:formidable/formidable.dart';

import 'error_display.dart';

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
    this._codec,
    this.errorDisplay = FormidableErrorDisplay.touched,
  }) : _ownsFocusNode = focusNode == null,
       _ownsTextController = textController == null,
       focusNode = focusNode ?? FocusNode(),
       _textController = textController {
    field.addListener(_onFieldChanged);
    this.focusNode.addListener(_onFocusChanged);
    _unregisterFocus = field.registerFocusTarget(
      _FocusNodeTarget(this.focusNode),
    );
    _hadFocus = this.focusNode.hasFocus;
    if (_textController != null) _syncText();
  }

  final FormidableField<T> field;
  final FocusNode focusNode;

  /// Turns a Validation Error into the text shown for it.
  final String Function(FormidableValidationError error) resolveMessage;
  late final void Function() _unregisterFocus;

  /// When errors are shown. The builder keeps it current.
  FormidableErrorDisplay errorDisplay;
  final bool _ownsFocusNode;
  final bool _ownsTextController;
  TextEditingController? _textController;
  FormidableCodec<T, String>? _codec;
  bool _hadFocus = false;

  /// The snapshot of the Field.
  FormidableFieldState<T> get state => field.state;

  /// The value of the Field, or null while it is Unset.
  T? get value => field.value;

  /// Whether the Field holds a value.
  bool get isSet => field.isSet;

  /// Whether the widget accepts input.
  bool get enabled => field.state.enabled;

  /// The Validation Message to show, or null when no error should be shown.
  ///
  /// Errors are shown according to [errorDisplay], and the first error in the
  /// order of the annotations wins. A disabled Field has none.
  String? get errorText {
    final state = field.state;
    if (state.errors.isEmpty) return null;
    final shown = errorDisplay.shows(
      touched: state.touched,
      dirty: state.dirty,
      submitted: state.submitted,
    );
    if (!shown) return null;
    return resolveMessage(state.errors.first);
  }

  /// The Codec between the Field and the text of a text widget, or null when
  /// there is none for this pair of types.
  FormidableCodec<T, String>? get codec => _codec;

  /// Changes the Codec and shows the Field again through it.
  void updateCodec(FormidableCodec<T, String>? codec) {
    if (codec == _codec) return;
    _codec = codec;
    _syncText(force: true);
  }

  /// Controls the text of a text widget and stays in sync with the Field.
  ///
  /// Needs a Codec to text. What the user types goes through
  /// [FormidableCodec.parse]: input that can't be parsed stays in the
  /// controller, and the Field becomes invalid with the parse error.
  TextEditingController get textController {
    assert(
      _codec != null,
      'A text controller needs a Codec between $T and String. '
      'Pass one with `codec:`, or add one to FormidableConfig.codecs.',
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

  /// The user chose [value] in a widget that is not a text input, such as a
  /// checkbox, a switch or a picker.
  ///
  /// Sets the Field and marks it touched: such a widget has no moment where it
  /// "loses focus", so the first interaction is what counts. [value] can be
  /// null when the type of the Field allows it, because choosing null is a
  /// value and not an Unset Field.
  void onPicked(T value) {
    field.setValue(value);
    field.markAsTouched();
  }

  /// The user removed the value of a widget that is not a text input.
  ///
  /// Clears the Field (it becomes Unset) and marks it touched.
  void onUnpicked() {
    field.clear();
    field.markAsTouched();
  }

  /// The user typed [text] into a text widget.
  ///
  /// The Codec decides what [text] means: a value, no value (the Field becomes
  /// Unset) or a parse error (the Field is rejected, even when it is optional).
  void onTextChanged(String text) {
    switch (_codec!.parse(text)) {
      case FormidableParsedValue<T>(:final value):
        field.setValue(value);
      case FormidableParsedUnset<T>():
        field.clear();
      case FormidableParseFailure<T>(:final error):
        field.reject(error);
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

  /// Writes the Field to the text controller, unless the controller already
  /// shows it. That check keeps the cursor still while the user types, and it
  /// keeps input that can't be parsed on screen while the Field holds the
  /// error it caused.
  void _syncText({bool force = false}) {
    final controller = _textController;
    final codec = _codec;
    if (controller == null || codec == null) return;
    final fieldValue = field.isSet ? field.value : null;
    if (!force && _showsField(codec.parse(controller.text), fieldValue)) return;
    final text = fieldValue == null ? '' : codec.format(fieldValue);
    controller.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }

  bool _showsField(FormidableParseResult<T> shown, T? fieldValue) =>
      switch (shown) {
        FormidableParsedValue<T>(:final value) =>
          field.isSet && value == fieldValue,
        FormidableParsedUnset<T>() => !field.isSet && field.inputError == null,
        FormidableParseFailure<T>(:final error) => field.inputError == error,
      };

  @override
  void dispose() {
    field.removeListener(_onFieldChanged);
    _unregisterFocus();
    focusNode.removeListener(_onFocusChanged);
    if (_ownsFocusNode) focusNode.dispose();
    if (_ownsTextController) _textController?.dispose();
    super.dispose();
  }
}

class _FocusNodeTarget implements FormidableFocusTarget {
  _FocusNodeTarget(this._focusNode);

  final FocusNode _focusNode;

  @override
  void focus() => _focusNode.requestFocus();

  @override
  void unfocus() => _focusNode.unfocus();
}

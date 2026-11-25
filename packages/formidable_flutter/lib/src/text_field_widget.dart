import 'package:flutter/widgets.dart';
import 'package:formidable/formidable.dart';

import 'config.dart';
import 'field_widget.dart';

/// Builds the text widget of a [FormidableTextFieldWidget] from its [control].
typedef FormidableTextFieldWidgetBuilder<T> = Widget Function(
  BuildContext context,
  FormidableTextFieldWidgetState<T> control,
);

/// A [FormidableFieldWidget] for widgets that edit text, such as a `TextField`.
///
/// The view value is a `String`. The control owns the
/// [TextEditingController][FormidableTextFieldWidgetState.textController] and
/// keeps it in sync with the Field. What the user types goes through the Codec
/// between [T] and the text: it is the [codec] of the widget, else the one
/// registered for [T] in the nearest `FormidableConfig`, else a built-in one
/// (`String`, `int`, `double`, `num` and `DateTime`, also when nullable).
/// Blank text leaves the Field Unset. Text that can't be parsed stays visible
/// and makes the Field invalid with a parse error, even when it is optional.
///
/// The Material and Cupertino text fields are built on it.
class FormidableTextFieldWidget<T> extends FormidableFieldWidget<T, String> {
  FormidableTextFieldWidget({
    super.key,
    required super.field,
    required FormidableTextFieldWidgetBuilder<T> builder,
    super.codec,
    super.messages,
    super.errorDisplay,
    super.focusNode,
    this.textController,
  }) : super(
         builder: (context, control) =>
             builder(context, control as FormidableTextFieldWidgetState<T>),
       );

  /// Used instead of a text controller owned by the widget. Never disposed by
  /// it.
  final TextEditingController? textController;

  @override
  State<FormidableFieldWidget<T, String>> createState() =>
      FormidableTextFieldWidgetState<T>();
}

/// The control of a [FormidableTextFieldWidget]. It keeps a text controller in
/// sync with the Field.
class FormidableTextFieldWidgetState<T>
    extends FormidableFieldWidgetState<T, String> {
  late TextEditingController _controller;
  late bool _ownsController;

  // True while didChange writes the Field: that change is the user's.
  bool _writing = false;

  // What the Field held right after the last text the user typed.
  ({bool defined, T? value, FormidableValidationError? inputError})? _typed;

  @override
  FormidableTextFieldWidget<T> get widget =>
      super.widget as FormidableTextFieldWidget<T>;

  /// The controller to give to the text widget.
  ///
  /// Needs a Codec to text: pass `codec:` or add one to
  /// `FormidableConfig.codecs`.
  TextEditingController get textController {
    assert(
      codec != null,
      'A text controller needs a Codec between $T and String. '
      'Pass one with `codec:`, or add one to FormidableConfig.codecs.',
    );
    return _controller;
  }

  /// The user typed [value] into the text widget (or code wants the widget to
  /// show it).
  ///
  /// The Codec decides what the text means: a value, no value (the Field
  /// becomes Unset) or a parse error (the Field is rejected, even when it is
  /// optional). Null is the empty text.
  ///
  /// The controller keeps what the user typed, even when a Normalizer rewrote
  /// it in the Field (`@Trim()` does not eat the space of "New York" as it is
  /// typed). It shows the Field again only when the Field changes from
  /// somewhere else: code, a reset, another widget.
  @override
  void didChange(String? value, {bool touched = false}) {
    final text = value ?? '';
    _writing = true;
    try {
      super.didChange(text, touched: touched);
    } finally {
      _writing = false;
    }
    _typed = (
      defined: field.defined,
      value: field.valueOrNull,
      inputError: field.inputError,
    );
    if (_controller.text != text) {
      _controller.value = TextEditingValue(
        text: text,
        selection: TextSelection.collapsed(offset: text.length),
      );
    }
  }

  @override
  FormidableCodec<T, String>? resolveCodec() {
    final registry =
        FormidableConfig.maybeOf(context)?.codecs ?? FormidableCodecs.defaults;
    return widget.codec ?? registry.find<T, String>();
  }

  @override
  void initState() {
    super.initState();
    _attachController();
  }

  @override
  void didUpdateWidget(FormidableFieldWidget<T, String> oldWidget) {
    super.didUpdateWidget(oldWidget);
    final old = oldWidget as FormidableTextFieldWidget<T>;
    if (old.textController != widget.textController) {
      if (_ownsController) _controller.dispose();
      _attachController();
      _typed = null;
      _syncText();
    }
  }

  @override
  void dispose() {
    if (_ownsController) _controller.dispose();
    super.dispose();
  }

  @override
  void didChangeField() {
    _syncText();
  }

  @override
  void didChangeCodec({required bool initial}) {
    _syncText(force: !initial);
  }

  @override
  void didReplaceField() {
    _typed = null;
    _syncText();
  }

  void _attachController() {
    _ownsController = widget.textController == null;
    _controller = widget.textController ?? TextEditingController();
  }

  /// Writes the Field to the text controller, unless the controller already
  /// shows it. That check keeps the cursor still while the user types, and it
  /// keeps input that can't be parsed on screen while the Field holds the
  /// error it caused.
  void _syncText({bool force = false}) {
    final codec = this.codec;
    if (codec == null) return;
    if (!force && _writing) return;
    final typed = _typed;
    if (typed != null) {
      // The Field still holds what the user's last input made of it: the
      // controller is the user's, not a stale copy of the Field.
      if (!force &&
          typed.defined == field.defined &&
          typed.value == field.valueOrNull &&
          typed.inputError == field.inputError) {
        return;
      }
      _typed = null;
    }
    final fieldValue = field.defined ? field.value : null;
    if (!force && _showsField(codec.parse(_controller.text), fieldValue)) {
      return;
    }
    final text = fieldValue == null ? '' : codec.format(fieldValue);
    _controller.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }

  bool _showsField(FormidableParseResult<T> shown, T? fieldValue) =>
      switch (shown) {
        FormidableParsedValue<T>(:final value) =>
          field.defined && value == fieldValue,
        FormidableParsedUnset<T>() =>
          !field.defined && field.inputError == null,
        FormidableParseFailure<T>(:final error) => field.inputError == error,
      };
}

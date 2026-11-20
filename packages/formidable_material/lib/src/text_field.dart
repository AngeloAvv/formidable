import 'package:formidable/formidable.dart';
import 'package:formidable_flutter/formidable_flutter.dart';
import 'package:material_ui/material_ui.dart';

/// A Material text field bound to a Field of type [T].
///
/// It shows the value, updates the Field as the user types, makes the Field
/// touched when it loses focus and shows the Validation Message once the Field
/// is touched.
///
/// A Codec converts between [T] and the text. It is the [codec] of the widget,
/// else the one registered for [T] in the `FormidableConfig`, else a built-in
/// one: `String`, `int`, `double`, `num` and `DateTime`, also when nullable.
/// Blank text leaves the Field Unset. Text that can't be parsed stays visible
/// and makes the Field invalid with a parse error, even when it is optional.
///
/// It exposes the most common parameters. For everything else, build a
/// `TextField` from a [FormidableBindingBuilder].
class FormidableTextField<T> extends StatelessWidget {
  const FormidableTextField({
    super.key,
    required this.field,
    this.decoration = const InputDecoration(),
    this.keyboardType,
    this.textInputAction,
    this.onEditingComplete,
    this.obscureText = false,
    this.minLines,
    this.maxLines = 1,
    this.autofocus = false,
    this.focusNode,
    this.codec,
    this.messages,
    this.errorDisplay,
  });

  final FormidableField<T> field;
  final InputDecoration decoration;
  final TextInputType? keyboardType;

  /// The keyboard action. Null is "next" while another Field follows, "done"
  /// on the last one. A multiline field keeps its newline key.
  final TextInputAction? textInputAction;

  /// Called when the user presses the keyboard action. Null moves focus to the
  /// next Field in Schema declaration order. When it is set it replaces that.
  final VoidCallback? onEditingComplete;
  final bool obscureText;
  final int? minLines;
  final int? maxLines;
  final bool autofocus;

  /// Used instead of the focus node owned by the Binding. Never disposed here.
  final FocusNode? focusNode;

  /// Converts between the Field and the text. Wins over the config registry.
  final FormidableCodec<T, String>? codec;

  /// Messages for this field only, ahead of the config and the localizations.
  final FormidableMessages? messages;

  /// When the error shows. Null follows the Form Scope, then the config.
  final FormidableErrorDisplay? errorDisplay;

  @override
  Widget build(BuildContext context) => FormidableBindingBuilder<T>(
    field: field,
    focusNode: focusNode,
    codec: codec,
    messages: messages,
    errorDisplay: errorDisplay,
    builder: (context, binding) => TextField(
      controller: binding.textController,
      focusNode: binding.focusNode,
      onChanged: binding.onTextChanged,
      enabled: binding.enabled,
      decoration: decoration.copyWith(errorText: binding.errorText),
      keyboardType: keyboardType,
      textInputAction:
          textInputAction ?? (maxLines == 1 ? binding.textInputAction : null),
      onEditingComplete: onEditingComplete ?? binding.onEditingComplete,
      obscureText: obscureText,
      minLines: minLines,
      maxLines: maxLines,
      autofocus: autofocus,
    ),
  );
}

import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:formidable/formidable.dart';
import 'package:formidable_flutter/formidable_flutter.dart';

import 'error_caption.dart';

/// A Cupertino text field bound to a Field of type [T].
///
/// It shows the value, updates the Field as the user types, makes the Field
/// touched when it loses focus and shows the Validation Message under the
/// field once the Field is touched.
///
/// A Codec converts between [T] and the text. It is the [codec] of the widget,
/// else the one registered for [T] in the `FormidableConfig`, else a built-in
/// one: `String`, `int`, `double`, `num` and `DateTime`, also when nullable.
/// Blank text leaves the Field Unset. Text that can't be parsed stays visible
/// and makes the Field invalid with a parse error, even when it is optional.
///
/// It exposes the most common parameters. For everything else, build a
/// `CupertinoTextField` from a [FormidableBindingBuilder].
class FormidableCupertinoTextField<T> extends StatelessWidget {
  const FormidableCupertinoTextField({
    super.key,
    required this.field,
    this.placeholder,
    this.prefix,
    this.suffix,
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
    this.minLines,
    this.maxLines = 1,
    this.autofocus = false,
    this.focusNode,
    this.codec,
    this.messages,
  });

  final FormidableField<T> field;
  final String? placeholder;
  final Widget? prefix;
  final Widget? suffix;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
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

  @override
  Widget build(BuildContext context) => FormidableBindingBuilder<T>(
    field: field,
    focusNode: focusNode,
    codec: codec,
    messages: messages,
    builder: (context, binding) => FormidableCupertinoErrorCaption(
      binding: binding,
      child: CupertinoTextField(
        controller: binding.textController,
        focusNode: binding.focusNode,
        onChanged: binding.onTextChanged,
        enabled: binding.enabled,
        placeholder: placeholder,
        prefix: prefix,
        suffix: suffix,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        obscureText: obscureText,
        minLines: minLines,
        maxLines: maxLines,
        autofocus: autofocus,
      ),
    ),
  );
}

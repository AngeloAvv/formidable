import 'package:formidable/formidable.dart';
import 'package:formidable_flutter/formidable_flutter.dart';
import 'package:material_ui/material_ui.dart';

/// A Material text field bound to a `String` Field.
///
/// It shows the value, updates the Field as the user types, makes the Field
/// touched when it loses focus and shows the Validation Message once the Field
/// is touched. A completely empty text leaves the Field Unset.
///
/// It exposes the most common parameters. For everything else, build a
/// `TextField` from a [FormidableBindingBuilder].
class FormidableTextField extends StatelessWidget {
  const FormidableTextField({
    super.key,
    required this.field,
    this.decoration = const InputDecoration(),
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
    this.minLines,
    this.maxLines = 1,
    this.autofocus = false,
    this.focusNode,
  });

  final FormidableField<String> field;
  final InputDecoration decoration;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool obscureText;
  final int? minLines;
  final int? maxLines;
  final bool autofocus;

  /// Used instead of the focus node owned by the Binding. Never disposed here.
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) => FormidableBindingBuilder<String>(
    field: field,
    focusNode: focusNode,
    formatText: (value) => value,
    parseText: (text) => text.isEmpty ? null : text,
    builder: (context, binding) => TextField(
      controller: binding.textController,
      focusNode: binding.focusNode,
      onChanged: binding.onTextChanged,
      enabled: binding.enabled,
      decoration: decoration.copyWith(errorText: binding.errorText),
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      obscureText: obscureText,
      minLines: minLines,
      maxLines: maxLines,
      autofocus: autofocus,
    ),
  );
}

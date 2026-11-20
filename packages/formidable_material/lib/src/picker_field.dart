import 'package:formidable_flutter/formidable_flutter.dart';
import 'package:material_ui/material_ui.dart';

/// The read-only field shared by the date and time pickers: it shows [text],
/// and opens a dialog when tapped. The Validation Message shows in the
/// decoration, and an optional clear button puts the Field back to Unset.
class FormidablePickerField extends StatelessWidget {
  const FormidablePickerField({
    super.key,
    required this.binding,
    required this.text,
    required this.decoration,
    required this.onTap,
    required this.clearable,
    this.autofocus = false,
  });

  final FormidableBinding<Object?> binding;

  /// The formatted value, or null while the Field is Unset.
  final String? text;
  final InputDecoration decoration;
  final VoidCallback onTap;
  final bool clearable;
  final bool autofocus;

  @override
  Widget build(BuildContext context) => InkWell(
    focusNode: binding.focusNode,
    autofocus: autofocus,
    onTap: binding.enabled ? onTap : null,
    child: InputDecorator(
      decoration: decoration.copyWith(
        errorText: binding.errorText,
        suffixIcon: clearable && text != null
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: binding.enabled ? binding.onUnpicked : null,
              )
            : decoration.suffixIcon,
      ),
      isEmpty: text == null,
      child: text == null ? null : Text(text!),
    ),
  );
}

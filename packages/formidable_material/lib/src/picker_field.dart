import 'package:material_ui/material_ui.dart';

/// The read-only field shared by the date and time pickers: it shows [text],
/// and opens a dialog when tapped. The Validation Message shows in the
/// decoration, and an optional clear button puts the Field back to Unset.
///
/// Internal: it is not exported from the package, so it is not part of its
/// public API.
class FormidablePickerField extends StatelessWidget {
  const FormidablePickerField({
    super.key,
    required this.focusNode,
    required this.enabled,
    required this.errorText,
    required this.text,
    required this.decoration,
    required this.onTap,
    required this.onClear,
    this.autofocus = false,
  });

  final FocusNode focusNode;
  final bool enabled;
  final String? errorText;

  /// The formatted value, or null while the Field is Unset.
  final String? text;
  final InputDecoration decoration;
  final VoidCallback onTap;

  /// Puts the Field back to Unset. Null hides the clear button.
  final VoidCallback? onClear;
  final bool autofocus;

  @override
  Widget build(BuildContext context) => InkWell(
    focusNode: focusNode,
    autofocus: autofocus,
    onTap: enabled ? onTap : null,
    child: InputDecorator(
      decoration: decoration.copyWith(
        errorText: decoration.errorText ?? errorText,
        suffixIcon: onClear != null && text != null
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: enabled ? onClear : null,
              )
            : decoration.suffixIcon,
      ),
      isEmpty: text == null,
      child: text == null ? null : Text(text!),
    ),
  );
}

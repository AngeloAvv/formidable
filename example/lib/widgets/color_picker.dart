import 'package:formidable_flutter/formidable_flutter.dart';
import 'package:material_ui/material_ui.dart';

/// A row of color swatches. It knows nothing about Formidable: it shows the
/// color it is given and reports the one the user taps.
class SwatchPicker extends StatelessWidget {
  const SwatchPicker({
    super.key,
    required this.colors,
    required this.selected,
    required this.onSelected,
    this.errorText,
  });

  final List<Color> colors;
  final Color? selected;
  final ValueChanged<Color> onSelected;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          children: [
            for (final color in colors)
              GestureDetector(
                key: ValueKey(color),
                onTap: () => onSelected(color),
                child: CircleAvatar(
                  backgroundColor: color,
                  child: color == selected
                      ? const Icon(Icons.check, color: Colors.white)
                      : null,
                ),
              ),
          ],
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              errorText!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ),
      ],
    );
  }
}

/// A Formidable widget made by subclassing [FormidableFieldWidget]: the Field
/// is a `Color`, and so is what the picker shows.
///
/// The picker can't take focus, so the first tap is what touches the Field
/// (`touched: true`), and the Validation Message shows after it.
class FormidableColorPicker extends FormidableFieldWidget<Color?, Color?> {
  FormidableColorPicker({
    super.key,
    required super.field,
    required List<Color> colors,
    super.messages,
    super.errorDisplay,
    super.focusNode,
  }) : super(
         builder: (context, control) => SwatchPicker(
           colors: colors,
           selected: control.value,
           onSelected: (color) => control.didChange(color, touched: true),
           errorText: control.errorText,
         ),
       );
}

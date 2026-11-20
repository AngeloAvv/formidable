import 'package:formidable/formidable.dart';
import 'package:formidable_flutter/formidable_flutter.dart';
import 'package:material_ui/material_ui.dart';

import 'error_text.dart';

/// A Material segmented control bound to a Field of type [T]. One segment is
/// chosen at a time.
///
/// While the Field is Unset, no segment is selected. That includes a segment
/// whose value is null, which needs a nullable Field: choosing it sets the
/// Field to null, which is a value. Tapping the selected segment keeps it,
/// unless [allowDeselect] puts the Field back to Unset.
///
/// The first interaction marks the Field touched, and the Validation Message
/// shows below the control from then on.
///
/// It exposes the most common parameters. For everything else, build a
/// `SegmentedButton` from a [FormidableBindingBuilder].
class FormidableSegmentedButton<T> extends StatelessWidget {
  const FormidableSegmentedButton({
    super.key,
    required this.field,
    required this.segments,
    this.allowDeselect = false,
    this.showSelectedIcon = true,
    this.messages,
  });

  final FormidableField<T> field;
  final List<ButtonSegment<T>> segments;

  /// Whether tapping the selected segment puts the Field back to Unset.
  final bool allowDeselect;
  final bool showSelectedIcon;

  /// Messages for this widget only, ahead of the config and the localizations.
  final FormidableMessages? messages;

  @override
  Widget build(BuildContext context) => FormidableBindingBuilder<T>(
    field: field,
    messages: messages,
    builder: (context, binding) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Values are boxed in a record so that "nothing selected" (an empty
        // set) is different from the segment whose value is null.
        SegmentedButton<(T,)>(
          segments: [
            for (final segment in segments)
              ButtonSegment<(T,)>(
                value: (segment.value,),
                label: segment.label,
                icon: segment.icon,
                tooltip: segment.tooltip,
                enabled: segment.enabled,
              ),
          ],
          selected: {if (binding.isSet) (binding.value as T,)},
          // The empty selection is how an Unset Field is shown. Deselecting
          // is filtered below, so it only happens with allowDeselect.
          emptySelectionAllowed: true,
          showSelectedIcon: showSelectedIcon,
          onSelectionChanged: binding.enabled
              ? (selection) {
                  if (selection.isNotEmpty) {
                    binding.onPicked(selection.first.$1);
                  } else if (allowDeselect) {
                    binding.onUnpicked();
                  }
                }
              : null,
        ),
        FormidableErrorLine(text: binding.errorText),
      ],
    ),
  );
}

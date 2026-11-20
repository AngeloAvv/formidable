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
/// It takes every parameter of [SegmentedButton] except the ones Formidable
/// owns: `selected` and `onSelectionChanged` (the Field is the source of
/// truth), and `multiSelectionEnabled` and `emptySelectionAllowed` (one
/// segment at a time, and the empty selection is how an Unset Field is
/// shown). Each one is readable as a field of the widget. The control is
/// disabled while the Field is. A [direction] of [Axis.vertical] needs a
/// bounded height, as it does for [SegmentedButton].
class FormidableMaterialSegmentedButton<T> extends FormidableFieldWidget<T, T> {
  FormidableMaterialSegmentedButton({
    super.key,
    required super.field,
    required this.segments,
    this.allowDeselect = false,
    super.messages,
    super.errorDisplay,
    super.focusNode,
    this.expandedInsets,
    this.style,
    this.showSelectedIcon = true,
    this.selectedIcon,
    this.direction = Axis.horizontal,
  }) : super(
         builder: (context, control) {
           // Values are boxed in a record so that "nothing selected" (an
           // empty set) is different from the segment whose value is null.
           final button = SegmentedButton<(T,)>(
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
             selected: {if (control.isSet) (control.value as T,)},
             // The empty selection is how an Unset Field is shown.
             // Deselecting is filtered below, so it only happens with
             // allowDeselect.
             emptySelectionAllowed: true,
             onSelectionChanged: control.enabled
                 ? (selection) {
                     if (selection.isNotEmpty) {
                       control.didChange(selection.first.$1, touch: true);
                     } else if (allowDeselect) {
                       control.clear(touch: true);
                     }
                   }
                 : null,
             expandedInsets: expandedInsets,
             style: style,
             showSelectedIcon: showSelectedIcon,
             selectedIcon: selectedIcon,
             direction: direction,
           );
           return Column(
             crossAxisAlignment: CrossAxisAlignment.start,
             mainAxisSize: MainAxisSize.min,
             children: [
               // A vertical control fills the height it is given, so it needs
               // a bounded one: it takes what the error line leaves.
               if (direction == Axis.vertical)
                 Flexible(child: button)
               else
                 button,
               FormidableMaterialErrorLine(text: control.errorText),
             ],
           );
         },
       );

  /// The segments to choose from. See [SegmentedButton.segments].
  final List<ButtonSegment<T>> segments;

  /// Whether tapping the selected segment puts the Field back to Unset.
  final bool allowDeselect;

  /// See [SegmentedButton.expandedInsets].
  final EdgeInsets? expandedInsets;

  /// See [SegmentedButton.style].
  final ButtonStyle? style;

  /// See [SegmentedButton.showSelectedIcon].
  final bool showSelectedIcon;

  /// See [SegmentedButton.selectedIcon].
  final Widget? selectedIcon;

  /// See [SegmentedButton.direction].
  final Axis direction;
}

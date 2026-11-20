import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:formidable_flutter/formidable_flutter.dart';

import 'error_caption.dart';

/// A Cupertino sliding segmented control bound to a Field of type [T].
///
/// [children] maps each value the Field can take to the widget of its
/// segment. An Unset Field, or a value that has no segment, selects nothing.
/// The control can't take focus, so the Field becomes touched on the first
/// interaction.
///
/// For everything else, build a `CupertinoSlidingSegmentedControl` from a
/// [FormidableFieldWidget].
class FormidableCupertinoSlidingSegmentedControl<T extends Object>
    extends FormidableFieldWidget<T?, T?> {
  FormidableCupertinoSlidingSegmentedControl({
    super.key,
    required super.field,
    required Map<T, Widget> children,
    super.messages,
    super.errorDisplay,
    super.focusNode,
  }) : super(
         builder: (context, control) => FormidableCupertinoErrorCaption(
           errorText: control.errorText,
           child: CupertinoSlidingSegmentedControl<T>(
             children: children,
             groupValue: children.containsKey(control.value)
                 ? control.value
                 : null,
             onValueChanged: (value) {
               if (!control.enabled || value == null) return;
               control.didChange(value, touch: true);
             },
           ),
         ),
       );
}

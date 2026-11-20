import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:formidable_flutter/formidable_flutter.dart';

import 'error_caption.dart';

/// A group of `CupertinoRadio<T>` widgets bound to a Field of type [T].
///
/// Put the radios anywhere under [child]. The radio whose value equals the
/// Field is selected, and none is when the Field is Unset. A radio can't take
/// focus, so the Field becomes touched on the first interaction.
class FormidableCupertinoRadioGroup<T extends Object>
    extends FormidableFieldWidget<T?, T?> {
  FormidableCupertinoRadioGroup({
    super.key,
    required super.field,
    required Widget child,
    super.messages,
    super.errorDisplay,
    super.focusNode,
  }) : super(
         builder: (context, control) => FormidableCupertinoErrorCaption(
           errorText: control.errorText,
           child: RadioGroup<T>(
             groupValue: control.value,
             onChanged: (value) {
               if (!control.enabled || value == null) return;
               control.didChange(value, touch: true);
             },
             child: child,
           ),
         ),
       );
}

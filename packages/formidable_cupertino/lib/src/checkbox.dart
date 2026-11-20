import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:formidable_flutter/formidable_flutter.dart';

import 'error_caption.dart';

/// A Cupertino checkbox bound to a `bool` Field.
///
/// An Unset Field shows the box unchecked. A checkbox can't take focus, so the
/// Field becomes touched on the first interaction.
///
/// For everything else, build a `CupertinoCheckbox` from a
/// [FormidableFieldWidget].
class FormidableCupertinoCheckbox extends FormidableFieldWidget<bool?, bool?> {
  FormidableCupertinoCheckbox({
    super.key,
    required super.field,
    Color? activeColor,
    super.messages,
    super.errorDisplay,
    super.focusNode,
  }) : super(
         builder: (context, control) => FormidableCupertinoErrorCaption(
           errorText: control.errorText,
           child: CupertinoCheckbox(
             value: control.value ?? false,
             activeColor: activeColor,
             onChanged: control.enabled
                 ? (value) => control.didChange(value ?? false, touch: true)
                 : null,
           ),
         ),
       );
}

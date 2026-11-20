import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:formidable_flutter/formidable_flutter.dart';

import 'error_caption.dart';

/// A Cupertino switch bound to a `bool` Field.
///
/// An Unset Field shows the switch off. A switch can't take focus, so the
/// Field becomes touched on the first interaction, and the Validation Message
/// shows under the switch from then on.
///
/// For everything else, build a `CupertinoSwitch` from a
/// [FormidableFieldWidget].
class FormidableCupertinoSwitch extends FormidableFieldWidget<bool?, bool?> {
  FormidableCupertinoSwitch({
    super.key,
    required super.field,
    Color? activeTrackColor,
    super.messages,
    super.errorDisplay,
    super.focusNode,
  }) : super(
         builder: (context, control) => FormidableCupertinoErrorCaption(
           errorText: control.errorText,
           child: CupertinoSwitch(
             value: control.value ?? false,
             activeTrackColor: activeTrackColor,
             onChanged: control.enabled
                 ? (value) => control.didChange(value, touch: true)
                 : null,
           ),
         ),
       );
}

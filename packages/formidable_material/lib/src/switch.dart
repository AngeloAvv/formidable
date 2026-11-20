import 'package:formidable_flutter/formidable_flutter.dart';
import 'package:material_ui/material_ui.dart';

import 'error_text.dart';

/// A Material switch bound to a `bool` Field.
///
/// An Unset Field is shown off. The first interaction marks the Field touched,
/// and the Validation Message shows below the switch from then on. With a
/// [title], the whole row is tappable (a `SwitchListTile`).
///
/// It exposes the most common parameters. For everything else, build a
/// `Switch` from a [FormidableFieldWidget].
class FormidableMaterialSwitch extends FormidableFieldWidget<bool, bool> {
  FormidableMaterialSwitch({
    super.key,
    required super.field,
    Widget? title,
    bool autofocus = false,
    super.focusNode,
    super.messages,
    super.errorDisplay,
  }) : super(
         builder: (context, control) {
           // Unset is shown off: a switch has no state for "not chosen".
           final value = control.value ?? false;
           void onChanged(bool next) {
             if (control.enabled) control.didChange(next, touch: true);
           }

           final toggle = title == null
               ? Switch(
                   value: value,
                   onChanged: onChanged,
                   focusNode: control.focusNode,
                   autofocus: autofocus,
                 )
               : SwitchListTile(
                   value: value,
                   onChanged: onChanged,
                   focusNode: control.focusNode,
                   autofocus: autofocus,
                   title: title,
                 );
           return Column(
             crossAxisAlignment: CrossAxisAlignment.start,
             mainAxisSize: MainAxisSize.min,
             children: [
               toggle,
               FormidableMaterialErrorLine(text: control.errorText),
             ],
           );
         },
       );
}

import 'package:formidable_flutter/formidable_flutter.dart';
import 'package:material_ui/material_ui.dart';

import 'error_text.dart';

/// A Material checkbox bound to a `bool` Field.
///
/// An Unset Field is shown unchecked. The first interaction marks the Field
/// touched, and the Validation Message shows below the checkbox from then on.
///
/// With [tristate], a `bool?` Field can also choose null, which is shown as a
/// dash. With a [title], the whole row is tappable (a `CheckboxListTile`).
///
/// It exposes the most common parameters. For everything else, build a
/// `Checkbox` from a [FormidableFieldWidget].
class FormidableCheckbox<T extends bool?> extends FormidableFieldWidget<T, T> {
  FormidableCheckbox({
    super.key,
    required super.field,
    Widget? title,
    bool tristate = false,
    bool autofocus = false,
    super.focusNode,
    super.messages,
    super.errorDisplay,
  }) : super(
         builder: (context, control) {
           // Unset is shown as unchecked: the box has no state for "not chosen".
           final value = control.isSet ? control.value : false;
           void onChanged(bool? next) {
             if (control.enabled) control.didChange(next as T?, touch: true);
           }

           final box = title == null
               ? Checkbox(
                   value: value,
                   tristate: tristate,
                   onChanged: onChanged,
                   focusNode: control.focusNode,
                   autofocus: autofocus,
                 )
               : CheckboxListTile(
                   value: value,
                   tristate: tristate,
                   onChanged: onChanged,
                   focusNode: control.focusNode,
                   autofocus: autofocus,
                   title: title,
                   controlAffinity: ListTileControlAffinity.leading,
                 );
           return Column(
             crossAxisAlignment: CrossAxisAlignment.start,
             mainAxisSize: MainAxisSize.min,
             children: [
               box,
               FormidableErrorLine(text: control.errorText),
             ],
           );
         },
       );
}

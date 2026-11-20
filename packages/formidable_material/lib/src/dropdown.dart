import 'package:formidable_flutter/formidable_flutter.dart';
import 'package:material_ui/material_ui.dart';

/// A Material dropdown bound to a Field of type [T].
///
/// While the Field is Unset, `hint` is shown. Picking an item sets the Field,
/// including an item whose value is null, which needs a nullable Field. The
/// first pick marks the Field touched, and the Validation Message shows in the
/// decoration from then on.
///
/// It exposes the most common parameters. For everything else, build a
/// `DropdownButton` from a [FormidableFieldWidget].
class FormidableMaterialDropdown<T> extends FormidableFieldWidget<T, T> {
  FormidableMaterialDropdown({
    super.key,
    required super.field,
    required List<DropdownMenuItem<T>> items,
    InputDecoration decoration = const InputDecoration(),
    Widget? hint,
    bool isExpanded = true,
    bool autofocus = false,
    super.focusNode,
    super.messages,
    super.errorDisplay,
  }) : super(
         builder: (context, control) => InputDecorator(
           decoration: decoration.copyWith(
             errorText: decoration.errorText ?? control.errorText,
           ),
           isEmpty: !control.isSet,
           isFocused: control.focusNode.hasFocus,
           child: DropdownButtonHideUnderline(
             // Values are boxed in a record so that "nothing picked" (a null
             // value) is different from an item whose value is null.
             child: DropdownButton<(T,)>(
               value: control.isSet ? (control.value as T,) : null,
               items: [
                 for (final item in items)
                   DropdownMenuItem<(T,)>(
                     value: (item.value as T,),
                     enabled: item.enabled,
                     alignment: item.alignment,
                     child: item.child,
                   ),
               ],
               hint: hint,
               isExpanded: isExpanded,
               isDense: true,
               autofocus: autofocus,
               focusNode: control.focusNode,
               onChanged: control.enabled
                   ? (choice) {
                       if (choice != null) {
                         control.didChange(choice.$1, touch: true);
                       }
                     }
                   : null,
             ),
           ),
         ),
       );
}

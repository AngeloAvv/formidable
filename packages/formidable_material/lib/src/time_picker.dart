import 'package:formidable_flutter/formidable_flutter.dart';
import 'package:material_ui/material_ui.dart';

import 'picker_field.dart';

/// A Material time picker bound to a `TimeOfDay` Field.
///
/// It shows the time as a read-only field, and opens the Material time dialog
/// when tapped. Picking a time sets the Field; cancelling the dialog changes
/// nothing. Either way the Field is touched, so its Validation Message shows
/// afterwards.
///
/// While the Field is Unset the dialog opens on [initialTime], else on the
/// current time. [format] turns the value into the text shown, and defaults to
/// the time format of the Material localizations. With [clearable], a button
/// puts a Field that has a value back to Unset.
///
/// It exposes the most common parameters. For everything else, call
/// `showTimePicker` from a [FormidableFieldWidget].
class FormidableTimePicker<T extends TimeOfDay?>
    extends FormidableFieldWidget<T, T> {
  FormidableTimePicker({
    super.key,
    required super.field,
    InputDecoration decoration = const InputDecoration(),
    TimeOfDay? initialTime,
    TimePickerEntryMode initialEntryMode = TimePickerEntryMode.dial,
    String Function(TimeOfDay time)? format,
    bool clearable = false,
    bool autofocus = false,
    super.focusNode,
    super.messages,
    super.errorDisplay,
  }) : super(
         builder: (context, control) {
           final value = control.value;
           final formatter =
               format ?? MaterialLocalizations.of(context).formatTimeOfDay;
           return FormidablePickerField(
             focusNode: control.focusNode,
             enabled: control.enabled,
             errorText: control.errorText,
             text: value == null ? null : formatter(value),
             decoration: decoration,
             onClear: clearable ? () => control.clear(touch: true) : null,
             autofocus: autofocus,
             onTap: () async {
               final picked = await showTimePicker(
                 context: context,
                 initialTime: value ?? initialTime ?? TimeOfDay.now(),
                 initialEntryMode: initialEntryMode,
               );
               if (picked == null) {
                 control.markAsTouched();
               } else {
                 control.didChange(picked as T, touch: true);
               }
             },
           );
         },
       );
}

import 'package:formidable_flutter/formidable_flutter.dart';
import 'package:material_ui/material_ui.dart';

import 'picker_field.dart';

/// A Material date picker bound to a `DateTime` Field.
///
/// It shows the date as a read-only field, and opens the Material date dialog
/// when tapped. Picking a date sets the Field; cancelling the dialog changes
/// nothing. Either way the Field is touched, so its Validation Message shows
/// afterwards. The picked value is a date at midnight, in the local time zone.
///
/// While the Field is Unset the dialog opens on [initialDate], else on today,
/// kept within [firstDate] and [lastDate] (1900 to 2100 by default). [format]
/// turns the value into the text shown, and defaults to the medium date format
/// of the Material localizations. With [clearable], a button puts a Field that
/// has a value back to Unset.
///
/// It exposes the most common parameters. For everything else, call
/// `showDatePicker` from a [FormidableFieldWidget].
class FormidableMaterialDatePicker<T extends DateTime?>
    extends FormidableFieldWidget<T, T> {
  FormidableMaterialDatePicker({
    super.key,
    required super.field,
    InputDecoration decoration = const InputDecoration(),
    DateTime? initialDate,
    DateTime? firstDate,
    DateTime? lastDate,
    String Function(DateTime date)? format,
    bool clearable = false,
    bool autofocus = false,
    super.focusNode,
    super.messages,
    super.errorDisplay,
  }) : super(
         builder: (context, control) {
           final first = firstDate ?? DateTime(1900);
           final last = lastDate ?? DateTime(2100);
           DateTime clamp(DateTime date) => date.isBefore(first)
               ? first
               : date.isAfter(last)
               ? last
               : date;
           final value = control.value;
           final formatter =
               format ?? MaterialLocalizations.of(context).formatMediumDate;
           return FormidableMaterialPickerField(
             focusNode: control.focusNode,
             enabled: control.enabled,
             errorText: control.errorText,
             text: value == null ? null : formatter(value),
             decoration: decoration,
             onClear: clearable ? () => control.clear(touch: true) : null,
             autofocus: autofocus,
             onTap: () async {
               final picked = await showDatePicker(
                 context: context,
                 initialDate: clamp(value ?? initialDate ?? DateTime.now()),
                 firstDate: first,
                 lastDate: last,
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

import 'package:formidable/formidable.dart';
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
/// While the Field is Unset the dialog opens on [initialDate], else on today.
/// With [clearable], a button puts a Field that has a value back to Unset.
///
/// It exposes the most common parameters. For everything else, call
/// `showDatePicker` from a [FormidableBindingBuilder].
class FormidableDatePicker<T extends DateTime?> extends StatelessWidget {
  FormidableDatePicker({
    super.key,
    required this.field,
    this.decoration = const InputDecoration(),
    this.initialDate,
    DateTime? firstDate,
    DateTime? lastDate,
    this.format,
    this.clearable = false,
    this.autofocus = false,
    this.focusNode,
    this.messages,
  }) : firstDate = firstDate ?? DateTime(1900),
       lastDate = lastDate ?? DateTime(2100);

  final FormidableField<T> field;
  final InputDecoration decoration;

  /// The date the dialog opens on while the Field is Unset. Defaults to today,
  /// kept within [firstDate] and [lastDate].
  final DateTime? initialDate;
  final DateTime firstDate;
  final DateTime lastDate;

  /// Turns the value into the text shown. Defaults to the medium date format
  /// of the Material localizations.
  final String Function(DateTime date)? format;

  /// Whether a button puts a Field that has a value back to Unset.
  final bool clearable;
  final bool autofocus;

  /// Used instead of the focus node owned by the Binding. Never disposed here.
  final FocusNode? focusNode;

  /// Messages for this widget only, ahead of the config and the localizations.
  final FormidableMessages? messages;

  @override
  Widget build(BuildContext context) => FormidableBindingBuilder<T>(
    field: field,
    focusNode: focusNode,
    messages: messages,
    builder: (context, binding) {
      final value = binding.value;
      final formatter =
          format ?? MaterialLocalizations.of(context).formatMediumDate;
      return FormidablePickerField(
        binding: binding,
        text: value == null ? null : formatter(value),
        decoration: decoration,
        clearable: clearable,
        autofocus: autofocus,
        onTap: () async {
          final picked = await showDatePicker(
            context: context,
            initialDate: _clamp(value ?? initialDate ?? DateTime.now()),
            firstDate: firstDate,
            lastDate: lastDate,
          );
          if (picked == null) {
            binding.onTouched();
          } else {
            binding.onPicked(picked as T);
          }
        },
      );
    },
  );

  DateTime _clamp(DateTime date) => date.isBefore(firstDate)
      ? firstDate
      : date.isAfter(lastDate)
      ? lastDate
      : date;
}

import 'package:formidable/formidable.dart';
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
/// current time. With [clearable], a button puts a Field that has a value back
/// to Unset.
///
/// It exposes the most common parameters. For everything else, call
/// `showTimePicker` from a [FormidableBindingBuilder].
class FormidableTimePicker<T extends TimeOfDay?> extends StatelessWidget {
  const FormidableTimePicker({
    super.key,
    required this.field,
    this.decoration = const InputDecoration(),
    this.initialTime,
    this.initialEntryMode = TimePickerEntryMode.dial,
    this.format,
    this.clearable = false,
    this.autofocus = false,
    this.focusNode,
    this.messages,
  });

  final FormidableField<T> field;
  final InputDecoration decoration;

  /// The time the dialog opens on while the Field is Unset. Defaults to now.
  final TimeOfDay? initialTime;
  final TimePickerEntryMode initialEntryMode;

  /// Turns the value into the text shown. Defaults to the time format of the
  /// Material localizations.
  final String Function(TimeOfDay time)? format;

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
          format ?? MaterialLocalizations.of(context).formatTimeOfDay;
      return FormidablePickerField(
        binding: binding,
        text: value == null ? null : formatter(value),
        decoration: decoration,
        clearable: clearable,
        autofocus: autofocus,
        onTap: () async {
          final picked = await showTimePicker(
            context: context,
            initialTime: value ?? initialTime ?? TimeOfDay.now(),
            initialEntryMode: initialEntryMode,
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
}

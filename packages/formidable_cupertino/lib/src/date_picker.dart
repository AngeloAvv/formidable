import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:formidable/formidable.dart';
import 'package:formidable_flutter/formidable_flutter.dart';

import 'error_caption.dart';

/// A Cupertino date and time picker bound to a `DateTime` Field.
///
/// [mode] picks what the wheels show: a date, a time of the day, both, or a
/// month and year. A Field with a `DateTime` that has more parts than the mode
/// shows keeps them until the user picks again. An Unset Field shows the
/// current time on the wheels and stays Unset until the user moves them.
/// Wheels can't take focus, so the Field becomes touched on the first change.
///
/// The picker only reads its initial value, so a value set in code makes the
/// widget start the wheels again on it. Changes made by the user never do.
///
/// For everything else, build a `CupertinoDatePicker` from a
/// [FormidableBindingBuilder].
class FormidableCupertinoDatePicker extends StatefulWidget {
  const FormidableCupertinoDatePicker({
    super.key,
    required this.field,
    this.mode = CupertinoDatePickerMode.dateAndTime,
    this.minimumDate,
    this.maximumDate,
    this.minuteInterval = 1,
    this.use24hFormat = false,
    this.height = 216,
    this.messages,
  });

  final FormidableField<DateTime?> field;
  final CupertinoDatePickerMode mode;
  final DateTime? minimumDate;
  final DateTime? maximumDate;
  final int minuteInterval;
  final bool use24hFormat;

  /// The height of the wheels. A picker has no height of its own.
  final double height;

  /// Messages for this widget only, ahead of the config and the localizations.
  final FormidableMessages? messages;

  @override
  State<FormidableCupertinoDatePicker> createState() =>
      _FormidableCupertinoDatePickerState();
}

class _FormidableCupertinoDatePickerState
    extends State<FormidableCupertinoDatePicker> {
  // What the wheels last reported. A different Field value came from code, and
  // the wheels start again on it (a new key), because they never follow their
  // initial value on their own.
  DateTime? _reported;
  int _revision = 0;

  @override
  Widget build(BuildContext context) => FormidableBindingBuilder<DateTime?>(
    field: widget.field,
    messages: widget.messages,
    builder: (context, binding) {
      final value = binding.value;
      if (value != null && value != _reported) {
        _reported = value;
        _revision++;
      }
      return FormidableCupertinoErrorCaption(
        binding: binding,
        child: SizedBox(
          height: widget.height,
          child: CupertinoDatePicker(
            key: ValueKey(_revision),
            mode: widget.mode,
            initialDateTime: value,
            minimumDate: widget.minimumDate,
            maximumDate: widget.maximumDate,
            minuteInterval: widget.minuteInterval,
            use24hFormat: widget.use24hFormat,
            onDateTimeChanged: (date) {
              if (!binding.enabled) return;
              _reported = date;
              binding.onTouched();
              binding.onChanged(date);
            },
          ),
        ),
      );
    },
  );
}

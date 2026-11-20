import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:formidable/formidable.dart';
import 'package:formidable_flutter/formidable_flutter.dart';

import 'error_caption.dart';

/// A Cupertino timer picker bound to a `Duration` Field.
///
/// An Unset Field shows a duration of zero and stays Unset until the user
/// moves the wheels. Wheels can't take focus, so the Field becomes touched on
/// the first change.
///
/// The picker only reads its initial value, so a value set in code makes the
/// widget start the wheels again on it. Changes made by the user never do.
///
/// For everything else, build a `CupertinoTimerPicker` from a
/// [FormidableBindingBuilder].
class FormidableCupertinoTimerPicker extends StatefulWidget {
  const FormidableCupertinoTimerPicker({
    super.key,
    required this.field,
    this.mode = CupertinoTimerPickerMode.hms,
    this.minuteInterval = 1,
    this.secondInterval = 1,
    this.height = 216,
    this.messages,
  });

  final FormidableField<Duration?> field;
  final CupertinoTimerPickerMode mode;
  final int minuteInterval;
  final int secondInterval;

  /// The height of the wheels. A picker has no height of its own.
  final double height;

  /// Messages for this widget only, ahead of the config and the localizations.
  final FormidableMessages? messages;

  @override
  State<FormidableCupertinoTimerPicker> createState() =>
      _FormidableCupertinoTimerPickerState();
}

class _FormidableCupertinoTimerPickerState
    extends State<FormidableCupertinoTimerPicker> {
  // See the date picker: a Field value that the wheels did not report came
  // from code, and the wheels start again on it.
  Duration? _reported;
  int _revision = 0;

  @override
  Widget build(BuildContext context) => FormidableBindingBuilder<Duration?>(
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
          child: CupertinoTimerPicker(
            key: ValueKey(_revision),
            mode: widget.mode,
            initialTimerDuration: value ?? Duration.zero,
            minuteInterval: widget.minuteInterval,
            secondInterval: widget.secondInterval,
            onTimerDurationChanged: (duration) {
              if (!binding.enabled) return;
              _reported = duration;
              binding.onTouched();
              binding.onChanged(duration);
            },
          ),
        ),
      );
    },
  );
}

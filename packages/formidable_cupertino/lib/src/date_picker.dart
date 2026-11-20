import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:formidable_flutter/formidable_flutter.dart';

import 'error_caption.dart';
import 'wheels.dart';

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
/// [FormidableFieldWidget].
class FormidableCupertinoDatePicker
    extends FormidableFieldWidget<DateTime?, DateTime?> {
  FormidableCupertinoDatePicker({
    super.key,
    required super.field,
    CupertinoDatePickerMode mode = CupertinoDatePickerMode.dateAndTime,
    DateTime? minimumDate,
    DateTime? maximumDate,
    int minuteInterval = 1,
    bool use24hFormat = false,
    double height = 216,
    super.messages,
    super.errorDisplay,
    super.focusNode,
  }) : super(
         builder: (context, control) {
           final wheels = control as FormidableWheelsState<DateTime>;
           return FormidableCupertinoErrorCaption(
             errorText: control.errorText,
             child: SizedBox(
               height: height,
               child: CupertinoDatePicker(
                 key: wheels.keyFor(control.value),
                 mode: mode,
                 initialDateTime: control.value,
                 minimumDate: minimumDate,
                 maximumDate: maximumDate,
                 minuteInterval: minuteInterval,
                 use24hFormat: use24hFormat,
                 onDateTimeChanged: wheels.wheelsChanged,
               ),
             ),
           );
         },
       );

  @override
  State<FormidableFieldWidget<DateTime?, DateTime?>> createState() =>
      FormidableWheelsState<DateTime>();
}

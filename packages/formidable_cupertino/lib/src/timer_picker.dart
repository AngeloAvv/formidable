import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:formidable_flutter/formidable_flutter.dart';

import 'error_caption.dart';
import 'wheels.dart';

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
/// [FormidableFieldWidget].
class FormidableCupertinoTimerPicker
    extends FormidableFieldWidget<Duration?, Duration?> {
  FormidableCupertinoTimerPicker({
    super.key,
    required super.field,
    CupertinoTimerPickerMode mode = CupertinoTimerPickerMode.hms,
    int minuteInterval = 1,
    int secondInterval = 1,
    double height = 216,
    super.messages,
    super.errorDisplay,
    super.focusNode,
  }) : super(
         builder: (context, control) {
           final wheels = control as FormidableWheelsState<Duration>;
           return FormidableCupertinoErrorCaption(
             errorText: control.errorText,
             child: SizedBox(
               height: height,
               child: CupertinoTimerPicker(
                 key: wheels.keyFor(control.value),
                 mode: mode,
                 initialTimerDuration: control.value ?? Duration.zero,
                 minuteInterval: minuteInterval,
                 secondInterval: secondInterval,
                 onTimerDurationChanged: wheels.wheelsChanged,
               ),
             ),
           );
         },
       );

  @override
  State<FormidableFieldWidget<Duration?, Duration?>> createState() =>
      FormidableWheelsState<Duration>();
}

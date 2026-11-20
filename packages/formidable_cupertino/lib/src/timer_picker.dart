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
/// It takes every parameter of [CupertinoTimerPicker] except the ones
/// Formidable owns: the initial duration and `onTimerDurationChanged`.
/// [height] sizes the wheels. A null [itemExtent] gives the default of
/// Flutter.
///
/// For everything else, build a `CupertinoTimerPicker` from a
/// [FormidableFieldWidget].
class FormidableCupertinoTimerPicker
    extends FormidableFieldWidget<Duration?, Duration?> {
  FormidableCupertinoTimerPicker({
    super.key,
    required super.field,
    super.messages,
    super.errorDisplay,
    super.focusNode,
    this.mode = CupertinoTimerPickerMode.hms,
    this.minuteInterval = 1,
    this.secondInterval = 1,
    this.alignment = Alignment.center,
    this.backgroundColor,
    this.itemExtent,
    this.changeReportingBehavior = ChangeReportingBehavior.onScrollUpdate,
    this.selectionOverlayBuilder,
    this.height = 216,
  }) : super(
         builder: (context, control) {
           final wheels = control as FormidableWheelsState<Duration>;
           // The default extent of Flutter is private: read it from an
           // instance.
           final defaults = CupertinoTimerPicker(
             onTimerDurationChanged: (_) {},
           );
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
                 alignment: alignment,
                 backgroundColor: backgroundColor,
                 itemExtent: itemExtent ?? defaults.itemExtent,
                 onTimerDurationChanged: wheels.wheelsChanged,
                 changeReportingBehavior: changeReportingBehavior,
                 selectionOverlayBuilder: selectionOverlayBuilder,
               ),
             ),
           );
         },
       );

  /// See [CupertinoTimerPicker.mode].
  final CupertinoTimerPickerMode mode;

  /// See [CupertinoTimerPicker.minuteInterval].
  final int minuteInterval;

  /// See [CupertinoTimerPicker.secondInterval].
  final int secondInterval;

  /// See [CupertinoTimerPicker.alignment].
  final AlignmentGeometry alignment;

  /// See [CupertinoTimerPicker.backgroundColor].
  final Color? backgroundColor;

  /// See [CupertinoTimerPicker.itemExtent]. Null gives its default.
  final double? itemExtent;

  /// See [CupertinoTimerPicker.changeReportingBehavior].
  final ChangeReportingBehavior changeReportingBehavior;

  /// See [CupertinoTimerPicker.selectionOverlayBuilder].
  final SelectionOverlayBuilder? selectionOverlayBuilder;

  /// The height of the wheels.
  final double height;

  @override
  State<FormidableFieldWidget<Duration?, Duration?>> createState() =>
      FormidableWheelsState<Duration>();
}

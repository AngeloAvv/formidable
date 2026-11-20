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
/// It takes every parameter of [CupertinoDatePicker] except the ones
/// Formidable owns: the initial date and `onDateTimeChanged`. [height] sizes
/// the wheels. A null [itemExtent] gives the default of Flutter.
///
/// For everything else, build a `CupertinoDatePicker` from a
/// [FormidableFieldWidget].
class FormidableCupertinoDatePicker
    extends FormidableFieldWidget<DateTime?, DateTime?> {
  FormidableCupertinoDatePicker({
    super.key,
    required super.field,
    super.messages,
    super.errorDisplay,
    super.focusNode,
    this.mode = CupertinoDatePickerMode.dateAndTime,
    this.minimumDate,
    this.maximumDate,
    this.minimumYear = 1,
    this.maximumYear,
    this.minuteInterval = 1,
    this.use24hFormat = false,
    this.dateOrder,
    this.backgroundColor,
    this.showDayOfWeek = false,
    this.showTimeSeparator = false,
    this.itemExtent,
    this.selectionOverlayBuilder,
    this.selectableDayPredicate,
    this.changeReportingBehavior = ChangeReportingBehavior.onScrollUpdate,
    this.height = 216,
  }) : super(
         builder: (context, control) {
           final wheels = control as FormidableWheelsState<DateTime>;
           // The default extent of Flutter is private: read it from an
           // instance.
           final defaults = CupertinoDatePicker(onDateTimeChanged: (_) {});
           return FormidableCupertinoErrorCaption(
             errorText: control.errorText,
             child: SizedBox(
               height: height,
               child: CupertinoDatePicker(
                 key: wheels.keyFor(control.value),
                 mode: mode,
                 initialDateTime: control.value,
                 onDateTimeChanged: wheels.wheelsChanged,
                 minimumDate: minimumDate,
                 maximumDate: maximumDate,
                 minimumYear: minimumYear,
                 maximumYear: maximumYear,
                 minuteInterval: minuteInterval,
                 use24hFormat: use24hFormat,
                 dateOrder: dateOrder,
                 backgroundColor: backgroundColor,
                 showDayOfWeek: showDayOfWeek,
                 showTimeSeparator: showTimeSeparator,
                 itemExtent: itemExtent ?? defaults.itemExtent,
                 selectionOverlayBuilder: selectionOverlayBuilder,
                 selectableDayPredicate: selectableDayPredicate,
                 changeReportingBehavior: changeReportingBehavior,
               ),
             ),
           );
         },
       );

  /// See [CupertinoDatePicker.mode].
  final CupertinoDatePickerMode mode;

  /// See [CupertinoDatePicker.minimumDate].
  final DateTime? minimumDate;

  /// See [CupertinoDatePicker.maximumDate].
  final DateTime? maximumDate;

  /// See [CupertinoDatePicker.minimumYear].
  final int minimumYear;

  /// See [CupertinoDatePicker.maximumYear].
  final int? maximumYear;

  /// See [CupertinoDatePicker.minuteInterval].
  final int minuteInterval;

  /// See [CupertinoDatePicker.use24hFormat].
  final bool use24hFormat;

  /// See [CupertinoDatePicker.dateOrder].
  final DatePickerDateOrder? dateOrder;

  /// See [CupertinoDatePicker.backgroundColor].
  final Color? backgroundColor;

  /// See [CupertinoDatePicker.showDayOfWeek].
  final bool showDayOfWeek;

  /// See [CupertinoDatePicker.showTimeSeparator].
  final bool showTimeSeparator;

  /// See [CupertinoDatePicker.itemExtent]. Null gives its default.
  final double? itemExtent;

  /// See [CupertinoDatePicker.selectionOverlayBuilder].
  final SelectionOverlayBuilder? selectionOverlayBuilder;

  /// See [CupertinoDatePicker.selectableDayPredicate].
  final SelectableDayPredicate? selectableDayPredicate;

  /// See [CupertinoDatePicker.changeReportingBehavior].
  final ChangeReportingBehavior changeReportingBehavior;

  /// The height of the wheels.
  final double height;

  @override
  State<FormidableFieldWidget<DateTime?, DateTime?>> createState() =>
      FormidableWheelsState<DateTime>();
}

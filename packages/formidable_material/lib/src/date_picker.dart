import 'package:formidable_flutter/formidable_flutter.dart';
import 'package:material_ui/material_ui.dart';

import 'decoration.dart';
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
/// of the Material localizations. With [clearable], a button takes the value
/// back. Like deselecting, that is the user's choice: a `DateTime?` Field is
/// set to null and stays dirty, a `DateTime` Field goes back to Unset. Either
/// way the Field is touched.
///
/// The [decoration] is merged with what Formidable adds: it sets only
/// [InputDecoration.errorText], and only when yours has none. To build the
/// decoration from the state of the widget, pass a [decorationBuilder]
/// instead (not both). Its result is merged the same way. The clear button
/// takes the place of the `suffixIcon` while the Field has a value.
///
/// It takes every parameter of [showDatePicker] except `context`: the dialog
/// is opened on the context of the widget. Each one is readable as a field of
/// the widget.
class FormidableMaterialDatePicker<T extends DateTime?>
    extends FormidableFieldWidget<T, T> {
  FormidableMaterialDatePicker({
    super.key,
    required super.field,
    this.decoration = const InputDecoration(),
    this.decorationBuilder,
    this.initialDate,
    this.firstDate,
    this.lastDate,
    this.format,
    this.clearable = false,
    this.autofocus = false,
    super.focusNode,
    super.messages,
    super.errorDisplay,
    this.currentDate,
    this.initialEntryMode = DatePickerEntryMode.calendar,
    this.selectableDayPredicate,
    this.helpText,
    this.cancelText,
    this.confirmText,
    this.locale,
    this.barrierDismissible = true,
    this.barrierColor,
    this.barrierLabel,
    this.useRootNavigator = true,
    this.routeSettings,
    this.textDirection,
    this.dialogBuilder,
    this.initialDatePickerMode = DatePickerMode.day,
    this.errorFormatText,
    this.errorInvalidText,
    this.fieldHintText,
    this.fieldLabelText,
    this.keyboardType,
    this.anchorPoint,
    this.onDatePickerModeChange,
    this.switchToInputEntryModeIcon,
    this.switchToCalendarEntryModeIcon,
    this.dayBuilder,
    this.weekdayBuilder,
    this.calendarDelegate = const GregorianCalendarDelegate(),
  }) : assert(
         decorationBuilder == null ||
             identical(decoration, const InputDecoration()),
         'Pass either decoration or decorationBuilder, not both.',
       ),
       super(
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
             decoration:
                 decorationBuilder?.call(context, control) ?? decoration,
             onClear: clearable
                 ? () => control.didChange(null, touched: true)
                 : null,
             autofocus: autofocus,
             onTap: () async {
               final picked = await showDatePicker(
                 context: context,
                 initialDate: clamp(value ?? initialDate ?? DateTime.now()),
                 firstDate: first,
                 lastDate: last,
                 currentDate: currentDate,
                 initialEntryMode: initialEntryMode,
                 selectableDayPredicate: selectableDayPredicate,
                 helpText: helpText,
                 cancelText: cancelText,
                 confirmText: confirmText,
                 locale: locale,
                 barrierDismissible: barrierDismissible,
                 barrierColor: barrierColor,
                 barrierLabel: barrierLabel,
                 useRootNavigator: useRootNavigator,
                 routeSettings: routeSettings,
                 textDirection: textDirection,
                 builder: dialogBuilder,
                 initialDatePickerMode: initialDatePickerMode,
                 errorFormatText: errorFormatText,
                 errorInvalidText: errorInvalidText,
                 fieldHintText: fieldHintText,
                 fieldLabelText: fieldLabelText,
                 keyboardType: keyboardType,
                 anchorPoint: anchorPoint,
                 onDatePickerModeChange: onDatePickerModeChange,
                 switchToInputEntryModeIcon: switchToInputEntryModeIcon,
                 switchToCalendarEntryModeIcon: switchToCalendarEntryModeIcon,
                 dayBuilder: dayBuilder,
                 weekdayBuilder: weekdayBuilder,
                 calendarDelegate: calendarDelegate,
               );
               if (picked == null) {
                 control.touch();
               } else {
                 control.didChange(picked as T, touched: true);
               }
             },
           );
         },
       );

  /// The decoration of the field. Formidable adds the Validation Message as
  /// its [InputDecoration.errorText] unless it has one. Not together with
  /// [decorationBuilder].
  final InputDecoration decoration;

  /// Builds the decoration from the control, so that it can depend on the
  /// value, the focus or the error. Merged like [decoration], which it
  /// replaces.
  final FormidableMaterialDecorationBuilder<T, T>? decorationBuilder;

  /// The date the dialog opens on while the Field is Unset. Today when null.
  /// See the `initialDate` parameter of [showDatePicker].
  final DateTime? initialDate;

  /// The earliest date to choose, 1900 when null. See
  /// the `firstDate` parameter of [showDatePicker].
  final DateTime? firstDate;

  /// The latest date to choose, 2100 when null. See the `lastDate` parameter of [showDatePicker].
  final DateTime? lastDate;

  /// Turns the value into the text shown. Defaults to the medium date format
  /// of the Material localizations.
  final String Function(DateTime date)? format;

  /// Whether a button puts a Field that has a value back to Unset.
  final bool clearable;

  /// Whether the field takes focus when it is built.
  final bool autofocus;

  /// See the `currentDate` parameter of [showDatePicker].
  final DateTime? currentDate;

  /// See the `initialEntryMode` parameter of [showDatePicker].
  final DatePickerEntryMode initialEntryMode;

  /// See the `selectableDayPredicate` parameter of [showDatePicker].
  final SelectableDayPredicate? selectableDayPredicate;

  /// See the `helpText` parameter of [showDatePicker].
  final String? helpText;

  /// See the `cancelText` parameter of [showDatePicker].
  final String? cancelText;

  /// See the `confirmText` parameter of [showDatePicker].
  final String? confirmText;

  /// See the `locale` parameter of [showDatePicker].
  final Locale? locale;

  /// See the `barrierDismissible` parameter of [showDatePicker].
  final bool barrierDismissible;

  /// See the `barrierColor` parameter of [showDatePicker].
  final Color? barrierColor;

  /// See the `barrierLabel` parameter of [showDatePicker].
  final String? barrierLabel;

  /// See the `useRootNavigator` parameter of [showDatePicker].
  final bool useRootNavigator;

  /// See the `routeSettings` parameter of [showDatePicker].
  final RouteSettings? routeSettings;

  /// See the `textDirection` parameter of [showDatePicker].
  final TextDirection? textDirection;

  /// Wraps the dialog, as the `builder` parameter of [showDatePicker] does. Named apart
  /// from [FormidableFieldWidget.builder], which builds this widget.
  final TransitionBuilder? dialogBuilder;

  /// See the `initialDatePickerMode` parameter of [showDatePicker].
  final DatePickerMode initialDatePickerMode;

  /// See the `errorFormatText` parameter of [showDatePicker].
  final String? errorFormatText;

  /// See the `errorInvalidText` parameter of [showDatePicker].
  final String? errorInvalidText;

  /// See the `fieldHintText` parameter of [showDatePicker].
  final String? fieldHintText;

  /// See the `fieldLabelText` parameter of [showDatePicker].
  final String? fieldLabelText;

  /// See the `keyboardType` parameter of [showDatePicker].
  final TextInputType? keyboardType;

  /// See the `anchorPoint` parameter of [showDatePicker].
  final Offset? anchorPoint;

  /// See the `onDatePickerModeChange` parameter of [showDatePicker].
  final ValueChanged<DatePickerEntryMode>? onDatePickerModeChange;

  /// See the `switchToInputEntryModeIcon` parameter of [showDatePicker].
  final Icon? switchToInputEntryModeIcon;

  /// See the `switchToCalendarEntryModeIcon` parameter of [showDatePicker].
  final Icon? switchToCalendarEntryModeIcon;

  /// See the `dayBuilder` parameter of [showDatePicker].
  final CalendarDatePickerDayBuilder? dayBuilder;

  /// See the `weekdayBuilder` parameter of [showDatePicker].
  final CalendarDatePickerWeekdayBuilder? weekdayBuilder;

  /// See the `calendarDelegate` parameter of [showDatePicker].
  final CalendarDelegate<DateTime> calendarDelegate;
}

import 'package:formidable_flutter/formidable_flutter.dart';
import 'package:material_ui/material_ui.dart';

import 'decoration.dart';
import 'picker_field.dart';

/// A Material time picker bound to a `TimeOfDay` Field.
///
/// It shows the time as a read-only field, and opens the Material time dialog
/// when tapped. Picking a time sets the Field; cancelling the dialog changes
/// nothing. Either way the Field is touched, so its Validation Message shows
/// afterwards.
///
/// While the Field is Unset the dialog opens on [initialTime], else on the
/// current time. [format] turns the value into the text shown, and defaults to
/// the time format of the Material localizations. With [clearable], a button
/// takes the value back. Like deselecting, that is the user's choice: a
/// `TimeOfDay?` Field is set to null and stays dirty, a `TimeOfDay` Field goes
/// back to Unset. Either way the Field is touched.
///
/// The [decoration] is merged with what Formidable adds: it sets only
/// [InputDecoration.errorText], and only when yours has none. To build the
/// decoration from the state of the widget, pass a [decorationBuilder]
/// instead (not both). Its result is merged the same way. The clear button
/// takes the place of the `suffixIcon` while the Field has a value.
///
/// It takes every parameter of [showTimePicker] except `context`: the dialog
/// is opened on the context of the widget. Each one is readable as a field of
/// the widget.
class FormidableMaterialTimePicker<T extends TimeOfDay?>
    extends FormidableFieldWidget<T, T> {
  FormidableMaterialTimePicker({
    super.key,
    required super.field,
    this.decoration = const InputDecoration(),
    this.decorationBuilder,
    this.initialTime,
    this.format,
    this.clearable = false,
    this.autofocus = false,
    super.focusNode,
    super.messages,
    super.errorDisplay,
    this.dialogBuilder,
    this.barrierDismissible = true,
    this.barrierColor,
    this.barrierLabel,
    this.useRootNavigator = true,
    this.initialEntryMode = TimePickerEntryMode.dial,
    this.cancelText,
    this.confirmText,
    this.helpText,
    this.errorInvalidText,
    this.hourLabelText,
    this.minuteLabelText,
    this.routeSettings,
    this.onEntryModeChanged,
    this.anchorPoint,
    this.orientation,
    this.switchToInputEntryModeIcon,
    this.switchToTimerEntryModeIcon,
    this.emptyInitialInput = false,
  }) : assert(
         decorationBuilder == null ||
             identical(decoration, const InputDecoration()),
         'Pass either decoration or decorationBuilder, not both.',
       ),
       super(
         builder: (context, control) {
           final value = control.value;
           final formatter =
               format ?? MaterialLocalizations.of(context).formatTimeOfDay;
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
               final picked = await showTimePicker(
                 context: context,
                 initialTime: value ?? initialTime ?? TimeOfDay.now(),
                 builder: dialogBuilder,
                 barrierDismissible: barrierDismissible,
                 barrierColor: barrierColor,
                 barrierLabel: barrierLabel,
                 useRootNavigator: useRootNavigator,
                 initialEntryMode: initialEntryMode,
                 cancelText: cancelText,
                 confirmText: confirmText,
                 helpText: helpText,
                 errorInvalidText: errorInvalidText,
                 hourLabelText: hourLabelText,
                 minuteLabelText: minuteLabelText,
                 routeSettings: routeSettings,
                 onEntryModeChanged: onEntryModeChanged,
                 anchorPoint: anchorPoint,
                 orientation: orientation,
                 switchToInputEntryModeIcon: switchToInputEntryModeIcon,
                 switchToTimerEntryModeIcon: switchToTimerEntryModeIcon,
                 emptyInitialInput: emptyInitialInput,
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

  /// The time the dialog opens on while the Field is Unset. The current time
  /// when null. See the `initialTime` parameter of [showTimePicker].
  final TimeOfDay? initialTime;

  /// Turns the value into the text shown. Defaults to the time format of the
  /// Material localizations.
  final String Function(TimeOfDay time)? format;

  /// Whether a button puts a Field that has a value back to Unset.
  final bool clearable;

  /// Whether the field takes focus when it is built.
  final bool autofocus;

  /// Wraps the dialog, as the `builder` parameter of [showTimePicker] does. Named apart
  /// from [FormidableFieldWidget.builder], which builds this widget.
  final TransitionBuilder? dialogBuilder;

  /// See the `barrierDismissible` parameter of [showTimePicker].
  final bool barrierDismissible;

  /// See the `barrierColor` parameter of [showTimePicker].
  final Color? barrierColor;

  /// See the `barrierLabel` parameter of [showTimePicker].
  final String? barrierLabel;

  /// See the `useRootNavigator` parameter of [showTimePicker].
  final bool useRootNavigator;

  /// See the `initialEntryMode` parameter of [showTimePicker].
  final TimePickerEntryMode initialEntryMode;

  /// See the `cancelText` parameter of [showTimePicker].
  final String? cancelText;

  /// See the `confirmText` parameter of [showTimePicker].
  final String? confirmText;

  /// See the `helpText` parameter of [showTimePicker].
  final String? helpText;

  /// See the `errorInvalidText` parameter of [showTimePicker].
  final String? errorInvalidText;

  /// See the `hourLabelText` parameter of [showTimePicker].
  final String? hourLabelText;

  /// See the `minuteLabelText` parameter of [showTimePicker].
  final String? minuteLabelText;

  /// See the `routeSettings` parameter of [showTimePicker].
  final RouteSettings? routeSettings;

  /// See the `onEntryModeChanged` parameter of [showTimePicker].
  final EntryModeChangeCallback? onEntryModeChanged;

  /// See the `anchorPoint` parameter of [showTimePicker].
  final Offset? anchorPoint;

  /// See the `orientation` parameter of [showTimePicker].
  final Orientation? orientation;

  /// See the `switchToInputEntryModeIcon` parameter of [showTimePicker].
  final Icon? switchToInputEntryModeIcon;

  /// See the `switchToTimerEntryModeIcon` parameter of [showTimePicker].
  final Icon? switchToTimerEntryModeIcon;

  /// See the `emptyInitialInput` parameter of [showTimePicker].
  final bool emptyInitialInput;
}

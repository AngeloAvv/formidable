import 'package:flutter/gestures.dart' show DragStartBehavior;
import 'package:formidable_flutter/formidable_flutter.dart';
import 'package:material_ui/material_ui.dart';

import 'error_text.dart';

/// A Material switch bound to a `bool` Field.
///
/// An Unset Field is shown off. The first interaction marks the Field touched,
/// and the Validation Message shows below the switch from then on.
///
/// It takes every parameter of [Switch] except the ones Formidable owns:
/// `value` and `onChanged` (the Field is the source of truth), and the
/// deprecated `activeColor`. Each one is readable as a field of the widget.
/// The Switch is disabled while the Field is. For a tappable row with a title,
/// use [FormidableMaterialSwitchListTile].
class FormidableMaterialSwitch extends FormidableFieldWidget<bool, bool> {
  FormidableMaterialSwitch({
    super.key,
    required super.field,
    super.focusNode,
    super.messages,
    super.errorDisplay,
    this.activeThumbColor,
    this.activeTrackColor,
    this.inactiveThumbColor,
    this.inactiveTrackColor,
    this.activeThumbImage,
    this.onActiveThumbImageError,
    this.inactiveThumbImage,
    this.onInactiveThumbImageError,
    this.thumbColor,
    this.trackColor,
    this.trackOutlineColor,
    this.trackOutlineWidth,
    this.thumbIcon,
    this.materialTapTargetSize,
    this.dragStartBehavior = DragStartBehavior.start,
    this.mouseCursor,
    this.focusColor,
    this.hoverColor,
    this.overlayColor,
    this.splashRadius,
    this.onFocusChange,
    this.autofocus = false,
    this.padding,
  }) : super(
         builder: (context, control) {
           // Unset is shown off: a switch has no state for "not chosen".
           final value = control.value ?? false;
           return Column(
             crossAxisAlignment: CrossAxisAlignment.start,
             mainAxisSize: MainAxisSize.min,
             children: [
               Switch(
                 value: value,
                 onChanged: control.enabled
                     ? (next) => control.didChange(next, touch: true)
                     : null,
                 focusNode: control.focusNode,
                 activeThumbColor: activeThumbColor,
                 activeTrackColor: activeTrackColor,
                 inactiveThumbColor: inactiveThumbColor,
                 inactiveTrackColor: inactiveTrackColor,
                 activeThumbImage: activeThumbImage,
                 onActiveThumbImageError: onActiveThumbImageError,
                 inactiveThumbImage: inactiveThumbImage,
                 onInactiveThumbImageError: onInactiveThumbImageError,
                 thumbColor: thumbColor,
                 trackColor: trackColor,
                 trackOutlineColor: trackOutlineColor,
                 trackOutlineWidth: trackOutlineWidth,
                 thumbIcon: thumbIcon,
                 materialTapTargetSize: materialTapTargetSize,
                 dragStartBehavior: dragStartBehavior,
                 mouseCursor: mouseCursor,
                 focusColor: focusColor,
                 hoverColor: hoverColor,
                 overlayColor: overlayColor,
                 splashRadius: splashRadius,
                 onFocusChange: onFocusChange,
                 autofocus: autofocus,
                 padding: padding,
               ),
               FormidableMaterialErrorLine(text: control.errorText),
             ],
           );
         },
       );

  /// See [Switch.activeThumbColor].
  final Color? activeThumbColor;

  /// See [Switch.activeTrackColor].
  final Color? activeTrackColor;

  /// See [Switch.inactiveThumbColor].
  final Color? inactiveThumbColor;

  /// See [Switch.inactiveTrackColor].
  final Color? inactiveTrackColor;

  /// See [Switch.activeThumbImage].
  final ImageProvider? activeThumbImage;

  /// See [Switch.onActiveThumbImageError].
  final ImageErrorListener? onActiveThumbImageError;

  /// See [Switch.inactiveThumbImage].
  final ImageProvider? inactiveThumbImage;

  /// See [Switch.onInactiveThumbImageError].
  final ImageErrorListener? onInactiveThumbImageError;

  /// See [Switch.thumbColor].
  final WidgetStateProperty<Color?>? thumbColor;

  /// See [Switch.trackColor].
  final WidgetStateProperty<Color?>? trackColor;

  /// See [Switch.trackOutlineColor].
  final WidgetStateProperty<Color?>? trackOutlineColor;

  /// See [Switch.trackOutlineWidth].
  final WidgetStateProperty<double?>? trackOutlineWidth;

  /// See [Switch.thumbIcon].
  final WidgetStateProperty<Icon?>? thumbIcon;

  /// See [Switch.materialTapTargetSize].
  final MaterialTapTargetSize? materialTapTargetSize;

  /// See [Switch.dragStartBehavior].
  final DragStartBehavior dragStartBehavior;

  /// See [Switch.mouseCursor].
  final MouseCursor? mouseCursor;

  /// See [Switch.focusColor].
  final Color? focusColor;

  /// See [Switch.hoverColor].
  final Color? hoverColor;

  /// See [Switch.overlayColor].
  final WidgetStateProperty<Color?>? overlayColor;

  /// See [Switch.splashRadius].
  final double? splashRadius;

  /// See [Switch.onFocusChange].
  final ValueChanged<bool>? onFocusChange;

  /// See [Switch.autofocus].
  final bool autofocus;

  /// See [Switch.padding].
  final EdgeInsetsGeometry? padding;
}

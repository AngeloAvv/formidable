import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter/gestures.dart' show DragStartBehavior;
import 'package:formidable_flutter/formidable_flutter.dart';

import 'error_caption.dart';

/// A Cupertino switch bound to a `bool` Field.
///
/// An Unset Field shows the switch off. The control's focus node is attached
/// to the switch, so keyboard navigation between Fields reaches it and the
/// Field becomes touched when it loses focus. A pointer tap does not move
/// focus, so the Field also becomes touched on the first interaction, and the
/// Validation Message shows under the switch from then on.
///
/// It takes every parameter of [CupertinoSwitch] except the ones Formidable
/// owns (`value` and `onChanged`) and the deprecated `activeColor` and
/// `trackColor` (use [activeTrackColor] and [inactiveTrackColor]).
///
/// For everything else, build a `CupertinoSwitch` from a
/// [FormidableFieldWidget].
class FormidableCupertinoSwitch extends FormidableFieldWidget<bool?, bool?> {
  FormidableCupertinoSwitch({
    super.key,
    required super.field,
    super.messages,
    super.errorDisplay,
    super.focusNode,
    this.activeTrackColor,
    this.inactiveTrackColor,
    this.thumbColor,
    this.inactiveThumbColor,
    this.applyTheme,
    this.focusColor,
    this.onLabelColor,
    this.offLabelColor,
    this.activeThumbImage,
    this.onActiveThumbImageError,
    this.inactiveThumbImage,
    this.onInactiveThumbImageError,
    this.trackOutlineColor,
    this.trackOutlineWidth,
    this.thumbIcon,
    this.mouseCursor,
    this.onFocusChange,
    this.autofocus = false,
    this.dragStartBehavior = DragStartBehavior.start,
  }) : super(
         builder: (context, control) => FormidableCupertinoErrorCaption(
           errorText: control.errorText,
           child: CupertinoSwitch(
             value: control.value ?? false,
             onChanged: control.enabled
                 ? (value) => control.didChange(value, touched: true)
                 : null,
             activeTrackColor: activeTrackColor,
             inactiveTrackColor: inactiveTrackColor,
             thumbColor: thumbColor,
             inactiveThumbColor: inactiveThumbColor,
             applyTheme: applyTheme,
             focusColor: focusColor,
             onLabelColor: onLabelColor,
             offLabelColor: offLabelColor,
             activeThumbImage: activeThumbImage,
             onActiveThumbImageError: onActiveThumbImageError,
             inactiveThumbImage: inactiveThumbImage,
             onInactiveThumbImageError: onInactiveThumbImageError,
             trackOutlineColor: trackOutlineColor,
             trackOutlineWidth: trackOutlineWidth,
             thumbIcon: thumbIcon,
             mouseCursor: mouseCursor,
             focusNode: control.focusNode,
             onFocusChange: onFocusChange,
             autofocus: autofocus,
             dragStartBehavior: dragStartBehavior,
           ),
         ),
       );

  /// See [CupertinoSwitch.activeTrackColor].
  final Color? activeTrackColor;

  /// See [CupertinoSwitch.inactiveTrackColor].
  final Color? inactiveTrackColor;

  /// See [CupertinoSwitch.thumbColor].
  final Color? thumbColor;

  /// See [CupertinoSwitch.inactiveThumbColor].
  final Color? inactiveThumbColor;

  /// See [CupertinoSwitch.applyTheme].
  final bool? applyTheme;

  /// See [CupertinoSwitch.focusColor].
  final Color? focusColor;

  /// See [CupertinoSwitch.onLabelColor].
  final Color? onLabelColor;

  /// See [CupertinoSwitch.offLabelColor].
  final Color? offLabelColor;

  /// See [CupertinoSwitch.activeThumbImage].
  final ImageProvider? activeThumbImage;

  /// See [CupertinoSwitch.onActiveThumbImageError].
  final ImageErrorListener? onActiveThumbImageError;

  /// See [CupertinoSwitch.inactiveThumbImage].
  final ImageProvider? inactiveThumbImage;

  /// See [CupertinoSwitch.onInactiveThumbImageError].
  final ImageErrorListener? onInactiveThumbImageError;

  /// See [CupertinoSwitch.trackOutlineColor].
  final WidgetStateProperty<Color?>? trackOutlineColor;

  /// See [CupertinoSwitch.trackOutlineWidth].
  final WidgetStateProperty<double?>? trackOutlineWidth;

  /// See [CupertinoSwitch.thumbIcon].
  final WidgetStateProperty<Icon?>? thumbIcon;

  /// See [CupertinoSwitch.mouseCursor].
  final WidgetStateProperty<MouseCursor>? mouseCursor;

  /// Called when the switch gains or loses focus. The Field is touched on
  /// blur whether it is given or not.
  final ValueChanged<bool>? onFocusChange;

  /// See [CupertinoSwitch.autofocus].
  final bool autofocus;

  /// See [CupertinoSwitch.dragStartBehavior].
  final DragStartBehavior dragStartBehavior;
}

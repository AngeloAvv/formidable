import 'package:flutter/gestures.dart' show DragStartBehavior;
import 'package:formidable_flutter/formidable_flutter.dart';
import 'package:material_ui/material_ui.dart';

import 'error_text.dart';

/// A Material switch row bound to a `bool` Field: a tappable
/// [SwitchListTile] with a title.
///
/// An Unset Field is shown off. The first interaction marks the Field touched,
/// and the Validation Message shows below the row from then on.
///
/// It takes every parameter of [SwitchListTile] except the ones Formidable
/// owns: `value` and `onChanged` (the Field is the source of truth), the
/// deprecated `activeColor`, and `internalAddSemanticForOnTap`, which is for
/// the framework's own use. Each one is readable as a field of the widget.
class FormidableMaterialSwitchListTile
    extends FormidableFieldWidget<bool, bool> {
  FormidableMaterialSwitchListTile({
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
    this.thumbIcon,
    this.materialTapTargetSize,
    this.dragStartBehavior = DragStartBehavior.start,
    this.mouseCursor,
    this.overlayColor,
    this.splashRadius,
    this.statesController,
    this.onFocusChange,
    this.autofocus = false,
    this.tileColor,
    this.title,
    this.subtitle,
    this.isThreeLine,
    this.dense,
    this.contentPadding,
    this.secondary,
    this.selected = false,
    this.controlAffinity,
    this.shape,
    this.selectedTileColor,
    this.visualDensity,
    this.enableFeedback,
    this.horizontalTitleGap,
    this.minVerticalPadding,
    this.minLeadingWidth,
    this.minTileHeight,
    this.hoverColor,
  }) : super(
         builder: (context, control) {
           // Unset is shown off: a switch has no state for "not chosen".
           final value = control.value ?? false;
           return Column(
             crossAxisAlignment: CrossAxisAlignment.start,
             mainAxisSize: MainAxisSize.min,
             children: [
               SwitchListTile(
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
                 thumbIcon: thumbIcon,
                 materialTapTargetSize: materialTapTargetSize,
                 dragStartBehavior: dragStartBehavior,
                 mouseCursor: mouseCursor,
                 overlayColor: overlayColor,
                 splashRadius: splashRadius,
                 statesController: statesController,
                 onFocusChange: onFocusChange,
                 autofocus: autofocus,
                 tileColor: tileColor,
                 title: title,
                 subtitle: subtitle,
                 isThreeLine: isThreeLine,
                 dense: dense,
                 contentPadding: contentPadding,
                 secondary: secondary,
                 selected: selected,
                 controlAffinity: controlAffinity,
                 shape: shape,
                 selectedTileColor: selectedTileColor,
                 visualDensity: visualDensity,
                 enableFeedback: enableFeedback,
                 horizontalTitleGap: horizontalTitleGap,
                 minVerticalPadding: minVerticalPadding,
                 minLeadingWidth: minLeadingWidth,
                 minTileHeight: minTileHeight,
                 hoverColor: hoverColor,
               ),
               FormidableMaterialErrorLine(text: control.errorText),
             ],
           );
         },
       );

  /// See [SwitchListTile.activeThumbColor].
  final Color? activeThumbColor;

  /// See [SwitchListTile.activeTrackColor].
  final Color? activeTrackColor;

  /// See [SwitchListTile.inactiveThumbColor].
  final Color? inactiveThumbColor;

  /// See [SwitchListTile.inactiveTrackColor].
  final Color? inactiveTrackColor;

  /// See [SwitchListTile.activeThumbImage].
  final ImageProvider? activeThumbImage;

  /// See [SwitchListTile.onActiveThumbImageError].
  final ImageErrorListener? onActiveThumbImageError;

  /// See [SwitchListTile.inactiveThumbImage].
  final ImageProvider? inactiveThumbImage;

  /// See [SwitchListTile.onInactiveThumbImageError].
  final ImageErrorListener? onInactiveThumbImageError;

  /// See [SwitchListTile.thumbColor].
  final WidgetStateProperty<Color?>? thumbColor;

  /// See [SwitchListTile.trackColor].
  final WidgetStateProperty<Color?>? trackColor;

  /// See [SwitchListTile.trackOutlineColor].
  final WidgetStateProperty<Color?>? trackOutlineColor;

  /// See [SwitchListTile.thumbIcon].
  final WidgetStateProperty<Icon?>? thumbIcon;

  /// See [SwitchListTile.materialTapTargetSize].
  final MaterialTapTargetSize? materialTapTargetSize;

  /// See [SwitchListTile.dragStartBehavior].
  final DragStartBehavior dragStartBehavior;

  /// See [SwitchListTile.mouseCursor].
  final MouseCursor? mouseCursor;

  /// See [SwitchListTile.overlayColor].
  final WidgetStateProperty<Color?>? overlayColor;

  /// See [SwitchListTile.splashRadius].
  final double? splashRadius;

  /// See [SwitchListTile.statesController].
  final WidgetStatesController? statesController;

  /// See [SwitchListTile.onFocusChange].
  final ValueChanged<bool>? onFocusChange;

  /// See [SwitchListTile.autofocus].
  final bool autofocus;

  /// See [SwitchListTile.tileColor].
  final Color? tileColor;

  /// See [SwitchListTile.title].
  final Widget? title;

  /// See [SwitchListTile.subtitle].
  final Widget? subtitle;

  /// See [SwitchListTile.isThreeLine].
  final bool? isThreeLine;

  /// See [SwitchListTile.dense].
  final bool? dense;

  /// See [SwitchListTile.contentPadding].
  final EdgeInsetsGeometry? contentPadding;

  /// See [SwitchListTile.secondary].
  final Widget? secondary;

  /// See [SwitchListTile.selected].
  final bool selected;

  /// See [SwitchListTile.controlAffinity].
  final ListTileControlAffinity? controlAffinity;

  /// See [SwitchListTile.shape].
  final ShapeBorder? shape;

  /// See [SwitchListTile.selectedTileColor].
  final Color? selectedTileColor;

  /// See [SwitchListTile.visualDensity].
  final VisualDensity? visualDensity;

  /// See [SwitchListTile.enableFeedback].
  final bool? enableFeedback;

  /// See [SwitchListTile.horizontalTitleGap].
  final double? horizontalTitleGap;

  /// See [SwitchListTile.minVerticalPadding].
  final double? minVerticalPadding;

  /// See [SwitchListTile.minLeadingWidth].
  final double? minLeadingWidth;

  /// See [SwitchListTile.minTileHeight].
  final double? minTileHeight;

  /// See [SwitchListTile.hoverColor].
  final Color? hoverColor;
}

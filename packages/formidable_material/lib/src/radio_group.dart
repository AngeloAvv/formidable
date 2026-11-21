import 'package:formidable_flutter/formidable_flutter.dart';
import 'package:material_ui/material_ui.dart';

import 'error_text.dart';

/// One choice of a [FormidableMaterialRadioGroup]: the content and the
/// behavior of one `RadioListTile`.
///
/// What styles every tile alike (colors, density, padding, shape, ...) is set on
/// the group; what belongs to one choice is set here.
class FormidableMaterialRadioOption<T> {
  const FormidableMaterialRadioOption({
    required this.value,
    required this.title,
    this.subtitle,
    this.secondary,
    this.isThreeLine,
    this.enabled,
    this.autofocus = false,
    this.focusNode,
    this.statesController,
    this.onFocusChange,
  });

  /// The value the Field gets when this option is chosen. It is null for the
  /// option that represents null, which needs a nullable Field.
  final T value;

  /// See [RadioListTile.title].
  final Widget title;

  /// See [RadioListTile.subtitle].
  final Widget? subtitle;

  /// See [RadioListTile.secondary].
  final Widget? secondary;

  /// See [RadioListTile.isThreeLine].
  final bool? isThreeLine;

  /// Whether this option can be chosen. Null follows the Field, so a disabled
  /// Field disables every option. See [RadioListTile.enabled].
  final bool? enabled;

  /// See [RadioListTile.autofocus].
  final bool autofocus;

  /// See [RadioListTile.focusNode].
  final FocusNode? focusNode;

  /// See [RadioListTile.statesController].
  final WidgetStatesController? statesController;

  /// See [RadioListTile.onFocusChange].
  final ValueChanged<bool>? onFocusChange;
}

/// A group of Material radio buttons bound to a Field.
///
/// While the Field is Unset, no option is selected. That includes the option
/// whose value is null: choosing it sets the Field to null, which is a value,
/// whereas an Unset Field is not a choice at all. Put `@Required()` on the
/// nullable Field of the Schema to make the user choose among the options.
///
/// The first interaction marks the Field touched, and the Validation Message
/// shows below the group from then on.
///
/// With [toggleable], choosing the selected option again is the user
/// deselecting, which is a choice and not a reset. When the Field's type admits
/// null (`String?`), null becomes the chosen value: the Field stays set and is
/// dirty. When it does not (`String`), null cannot be written, so the Field
/// falls back to Unset, still touched.
///
/// Each of the [options] is a `RadioListTile`. The group takes every parameter
/// of [RadioListTile] that is not about one tile alone, and gives it to every
/// tile; the ones that are belong to [FormidableMaterialRadioOption]. The
/// parameters Formidable owns are not there: `value`, `groupValue` and
/// `onChanged` (the Field is the source of truth), and `selected` (the group
/// shows the selection). Neither is `internalAddSemanticForOnTap`, which is for
/// the framework's own use. Each one is readable as a field of the widget.
class FormidableMaterialRadioGroup<T> extends FormidableFieldWidget<T, T> {
  FormidableMaterialRadioGroup({
    super.key,
    required super.field,
    required this.options,
    super.messages,
    super.errorDisplay,
    super.focusNode,
    this.mouseCursor,
    this.toggleable = false,
    this.activeColor,
    this.fillColor,
    this.hoverColor,
    this.overlayColor,
    this.splashRadius,
    this.materialTapTargetSize,
    this.dense,
    this.controlAffinity,
    this.contentPadding,
    this.shape,
    this.tileColor,
    this.selectedTileColor,
    this.visualDensity,
    this.enableFeedback,
    this.horizontalTitleGap,
    this.minVerticalPadding,
    this.minLeadingWidth,
    this.minTileHeight,
    this.radioScaleFactor = 1.0,
    this.titleAlignment,
    this.radioBackgroundColor,
    this.radioSide,
    this.radioInnerRadius,
  }) : super(
         builder: (context, control) => Column(
           crossAxisAlignment: CrossAxisAlignment.start,
           mainAxisSize: MainAxisSize.min,
           children: [
             // Values are boxed in a record so that "nothing selected" (a null
             // group value) is different from the option whose value is null.
             RadioGroup<(T,)>(
               groupValue: control.isSet ? (control.value as T,) : null,
               onChanged: (choice) {
                 if (!control.enabled) return;
                 if (choice != null) {
                   control.didChange(choice.$1, touch: true);
                 } else if (toggleable) {
                   // Deselecting is a choice: null when the Field admits it,
                   // Unset when it does not.
                   control.didChange(null, touch: true);
                 }
               },
               child: Column(
                 mainAxisSize: MainAxisSize.min,
                 children: [
                   for (final option in options)
                     RadioListTile<(T,)>(
                       value: (option.value,),
                       title: option.title,
                       subtitle: option.subtitle,
                       secondary: option.secondary,
                       isThreeLine: option.isThreeLine,
                       enabled: control.enabled ? option.enabled : false,
                       autofocus: option.autofocus,
                       focusNode: option.focusNode,
                       statesController: option.statesController,
                       onFocusChange: option.onFocusChange,
                       mouseCursor: mouseCursor,
                       toggleable: toggleable,
                       activeColor: activeColor,
                       fillColor: fillColor,
                       hoverColor: hoverColor,
                       overlayColor: overlayColor,
                       splashRadius: splashRadius,
                       materialTapTargetSize: materialTapTargetSize,
                       dense: dense,
                       controlAffinity: controlAffinity,
                       contentPadding: contentPadding,
                       shape: shape,
                       tileColor: tileColor,
                       selectedTileColor: selectedTileColor,
                       visualDensity: visualDensity,
                       enableFeedback: enableFeedback,
                       horizontalTitleGap: horizontalTitleGap,
                       minVerticalPadding: minVerticalPadding,
                       minLeadingWidth: minLeadingWidth,
                       minTileHeight: minTileHeight,
                       radioScaleFactor: radioScaleFactor,
                       titleAlignment: titleAlignment,
                       radioBackgroundColor: radioBackgroundColor,
                       radioSide: radioSide,
                       radioInnerRadius: radioInnerRadius,
                     ),
                 ],
               ),
             ),
             FormidableMaterialErrorLine(text: control.errorText),
           ],
         ),
       );

  /// The choices of the group.
  final List<FormidableMaterialRadioOption<T>> options;

  /// See [RadioListTile.mouseCursor].
  final MouseCursor? mouseCursor;

  /// See [RadioListTile.toggleable].
  final bool toggleable;

  /// See [RadioListTile.activeColor].
  final Color? activeColor;

  /// See [RadioListTile.fillColor].
  final WidgetStateProperty<Color?>? fillColor;

  /// See [RadioListTile.hoverColor].
  final Color? hoverColor;

  /// See [RadioListTile.overlayColor].
  final WidgetStateProperty<Color?>? overlayColor;

  /// See [RadioListTile.splashRadius].
  final double? splashRadius;

  /// See [RadioListTile.materialTapTargetSize].
  final MaterialTapTargetSize? materialTapTargetSize;

  /// See [RadioListTile.dense].
  final bool? dense;

  /// See [RadioListTile.controlAffinity].
  final ListTileControlAffinity? controlAffinity;

  /// See [RadioListTile.contentPadding].
  final EdgeInsetsGeometry? contentPadding;

  /// See [RadioListTile.shape].
  final ShapeBorder? shape;

  /// See [RadioListTile.tileColor].
  final Color? tileColor;

  /// See [RadioListTile.selectedTileColor].
  final Color? selectedTileColor;

  /// See [RadioListTile.visualDensity].
  final VisualDensity? visualDensity;

  /// See [RadioListTile.enableFeedback].
  final bool? enableFeedback;

  /// See [RadioListTile.horizontalTitleGap].
  final double? horizontalTitleGap;

  /// See [RadioListTile.minVerticalPadding].
  final double? minVerticalPadding;

  /// See [RadioListTile.minLeadingWidth].
  final double? minLeadingWidth;

  /// See [RadioListTile.minTileHeight].
  final double? minTileHeight;

  /// See [RadioListTile.radioScaleFactor].
  final double radioScaleFactor;

  /// See [RadioListTile.titleAlignment].
  final ListTileTitleAlignment? titleAlignment;

  /// See [RadioListTile.radioBackgroundColor].
  final WidgetStateProperty<Color?>? radioBackgroundColor;

  /// See [RadioListTile.radioSide].
  final BorderSide? radioSide;

  /// See [RadioListTile.radioInnerRadius].
  final WidgetStateProperty<double?>? radioInnerRadius;
}

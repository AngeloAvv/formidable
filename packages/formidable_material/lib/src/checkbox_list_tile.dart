import 'package:formidable_flutter/formidable_flutter.dart';
import 'package:material_ui/material_ui.dart';

import 'error_text.dart';

/// A Material checkbox row bound to a `bool` Field: a tappable
/// [CheckboxListTile] with a title.
///
/// An Unset Field is shown unchecked. The first interaction marks the Field
/// touched, and the Validation Message shows below the row from then on. With
/// [tristate], a `bool?` Field can also choose null, which is shown as a dash.
/// Reaching the dash is a choice: the Field stays set and is dirty. A `bool`
/// Field cannot hold null, so there the dash makes it Unset (touched), and it
/// is shown unchecked again.
///
/// It takes every parameter of [CheckboxListTile] except the ones Formidable
/// owns: `value`, `onChanged` and `enabled` (the Field says it), and
/// `internalAddSemanticForOnTap`, which is for the framework's own use. Each
/// one is readable as a field of the widget. The [controlAffinity] defaults to
/// [ListTileControlAffinity.leading], the box before the title; pass null for
/// the default of the tile.
class FormidableMaterialCheckboxListTile<T extends bool?>
    extends FormidableFieldWidget<T, T> {
  FormidableMaterialCheckboxListTile({
    super.key,
    required super.field,
    super.focusNode,
    super.messages,
    super.errorDisplay,
    this.mouseCursor,
    this.activeColor,
    this.fillColor,
    this.checkColor,
    this.hoverColor,
    this.overlayColor,
    this.splashRadius,
    this.materialTapTargetSize,
    this.visualDensity,
    this.statesController,
    this.autofocus = false,
    this.shape,
    this.side,
    this.isError = false,
    this.tileColor,
    this.title,
    this.subtitle,
    this.isThreeLine,
    this.dense,
    this.secondary,
    this.selected = false,
    this.controlAffinity = ListTileControlAffinity.leading,
    this.contentPadding,
    this.tristate = false,
    this.checkboxShape,
    this.selectedTileColor,
    this.onFocusChange,
    this.enableFeedback,
    this.horizontalTitleGap,
    this.minVerticalPadding,
    this.minLeadingWidth,
    this.minTileHeight,
    this.checkboxSemanticLabel,
    this.checkboxScaleFactor = 1.0,
    this.titleAlignment,
  }) : super(
         builder: (context, control) {
           // Unset is shown as unchecked: the box has no state for "not chosen".
           final value = control.defined ? control.value : false;
           return Column(
             crossAxisAlignment: CrossAxisAlignment.start,
             mainAxisSize: MainAxisSize.min,
             children: [
               CheckboxListTile(
                 value: value,
                 onChanged: control.enabled
                     ? (next) => control.didChange(next as T?, touched: true)
                     : null,
                 focusNode: control.focusNode,
                 mouseCursor: mouseCursor,
                 activeColor: activeColor,
                 fillColor: fillColor,
                 checkColor: checkColor,
                 hoverColor: hoverColor,
                 overlayColor: overlayColor,
                 splashRadius: splashRadius,
                 materialTapTargetSize: materialTapTargetSize,
                 visualDensity: visualDensity,
                 statesController: statesController,
                 autofocus: autofocus,
                 shape: shape,
                 side: side,
                 isError: isError,
                 tileColor: tileColor,
                 title: title,
                 subtitle: subtitle,
                 isThreeLine: isThreeLine,
                 dense: dense,
                 secondary: secondary,
                 selected: selected,
                 controlAffinity: controlAffinity,
                 contentPadding: contentPadding,
                 tristate: tristate,
                 checkboxShape: checkboxShape,
                 selectedTileColor: selectedTileColor,
                 onFocusChange: onFocusChange,
                 enableFeedback: enableFeedback,
                 horizontalTitleGap: horizontalTitleGap,
                 minVerticalPadding: minVerticalPadding,
                 minLeadingWidth: minLeadingWidth,
                 minTileHeight: minTileHeight,
                 checkboxSemanticLabel: checkboxSemanticLabel,
                 checkboxScaleFactor: checkboxScaleFactor,
                 titleAlignment: titleAlignment,
               ),
               FormidableMaterialErrorLine(text: control.errorText),
             ],
           );
         },
       );

  /// See [CheckboxListTile.mouseCursor].
  final MouseCursor? mouseCursor;

  /// See [CheckboxListTile.activeColor].
  final Color? activeColor;

  /// See [CheckboxListTile.fillColor].
  final WidgetStateProperty<Color?>? fillColor;

  /// See [CheckboxListTile.checkColor].
  final Color? checkColor;

  /// See [CheckboxListTile.hoverColor].
  final Color? hoverColor;

  /// See [CheckboxListTile.overlayColor].
  final WidgetStateProperty<Color?>? overlayColor;

  /// See [CheckboxListTile.splashRadius].
  final double? splashRadius;

  /// See [CheckboxListTile.materialTapTargetSize].
  final MaterialTapTargetSize? materialTapTargetSize;

  /// See [CheckboxListTile.visualDensity].
  final VisualDensity? visualDensity;

  /// See [CheckboxListTile.statesController].
  final WidgetStatesController? statesController;

  /// See [CheckboxListTile.autofocus].
  final bool autofocus;

  /// See [CheckboxListTile.shape].
  final ShapeBorder? shape;

  /// See [CheckboxListTile.side].
  final BorderSide? side;

  /// See [CheckboxListTile.isError].
  final bool isError;

  /// See [CheckboxListTile.tileColor].
  final Color? tileColor;

  /// See [CheckboxListTile.title].
  final Widget? title;

  /// See [CheckboxListTile.subtitle].
  final Widget? subtitle;

  /// See [CheckboxListTile.isThreeLine].
  final bool? isThreeLine;

  /// See [CheckboxListTile.dense].
  final bool? dense;

  /// See [CheckboxListTile.secondary].
  final Widget? secondary;

  /// See [CheckboxListTile.selected].
  final bool selected;

  /// See [CheckboxListTile.controlAffinity].
  final ListTileControlAffinity? controlAffinity;

  /// See [CheckboxListTile.contentPadding].
  final EdgeInsetsGeometry? contentPadding;

  /// See [CheckboxListTile.tristate].
  final bool tristate;

  /// See [CheckboxListTile.checkboxShape].
  final OutlinedBorder? checkboxShape;

  /// See [CheckboxListTile.selectedTileColor].
  final Color? selectedTileColor;

  /// See [CheckboxListTile.onFocusChange].
  final ValueChanged<bool>? onFocusChange;

  /// See [CheckboxListTile.enableFeedback].
  final bool? enableFeedback;

  /// See [CheckboxListTile.horizontalTitleGap].
  final double? horizontalTitleGap;

  /// See [CheckboxListTile.minVerticalPadding].
  final double? minVerticalPadding;

  /// See [CheckboxListTile.minLeadingWidth].
  final double? minLeadingWidth;

  /// See [CheckboxListTile.minTileHeight].
  final double? minTileHeight;

  /// See [CheckboxListTile.checkboxSemanticLabel].
  final String? checkboxSemanticLabel;

  /// See [CheckboxListTile.checkboxScaleFactor].
  final double checkboxScaleFactor;

  /// See [CheckboxListTile.titleAlignment].
  final ListTileTitleAlignment? titleAlignment;
}

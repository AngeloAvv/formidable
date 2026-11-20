import 'package:formidable_flutter/formidable_flutter.dart';
import 'package:material_ui/material_ui.dart';

import 'error_text.dart';

/// A Material checkbox bound to a `bool` Field.
///
/// An Unset Field is shown unchecked. The first interaction marks the Field
/// touched, and the Validation Message shows below the checkbox from then on.
/// With [tristate], a `bool?` Field can also choose null, which is shown as a
/// dash. Reaching the dash is a choice: the Field stays set and is dirty. A
/// `bool` Field cannot hold null, so there the dash makes it Unset (touched),
/// and it is shown unchecked again.
///
/// It takes every parameter of [Checkbox] except the ones Formidable owns:
/// `value` and `onChanged` (the Field is the source of truth). Each one is
/// readable as a field of the widget. The Checkbox is disabled while the Field
/// is. For a tappable row with a title, use [FormidableMaterialCheckboxListTile].
class FormidableMaterialCheckbox<T extends bool?>
    extends FormidableFieldWidget<T, T> {
  FormidableMaterialCheckbox({
    super.key,
    required super.field,
    super.focusNode,
    super.messages,
    super.errorDisplay,
    this.tristate = false,
    this.mouseCursor,
    this.activeColor,
    this.fillColor,
    this.checkColor,
    this.focusColor,
    this.hoverColor,
    this.overlayColor,
    this.splashRadius,
    this.materialTapTargetSize,
    this.visualDensity,
    this.autofocus = false,
    this.shape,
    this.side,
    this.isError = false,
    this.semanticLabel,
    this.markInsets,
  }) : super(
         builder: (context, control) {
           // Unset is shown as unchecked: the box has no state for "not chosen".
           final value = control.isSet ? control.value : false;
           return Column(
             crossAxisAlignment: CrossAxisAlignment.start,
             mainAxisSize: MainAxisSize.min,
             children: [
               Checkbox(
                 value: value,
                 onChanged: control.enabled
                     ? (next) => control.didChange(next as T?, touch: true)
                     : null,
                 focusNode: control.focusNode,
                 tristate: tristate,
                 mouseCursor: mouseCursor,
                 activeColor: activeColor,
                 fillColor: fillColor,
                 checkColor: checkColor,
                 focusColor: focusColor,
                 hoverColor: hoverColor,
                 overlayColor: overlayColor,
                 splashRadius: splashRadius,
                 materialTapTargetSize: materialTapTargetSize,
                 visualDensity: visualDensity,
                 autofocus: autofocus,
                 shape: shape,
                 side: side,
                 isError: isError,
                 semanticLabel: semanticLabel,
                 markInsets: markInsets,
               ),
               FormidableMaterialErrorLine(text: control.errorText),
             ],
           );
         },
       );

  /// See [Checkbox.tristate].
  final bool tristate;

  /// See [Checkbox.mouseCursor].
  final MouseCursor? mouseCursor;

  /// See [Checkbox.activeColor].
  final Color? activeColor;

  /// See [Checkbox.fillColor].
  final WidgetStateProperty<Color?>? fillColor;

  /// See [Checkbox.checkColor].
  final Color? checkColor;

  /// See [Checkbox.focusColor].
  final Color? focusColor;

  /// See [Checkbox.hoverColor].
  final Color? hoverColor;

  /// See [Checkbox.overlayColor].
  final WidgetStateProperty<Color?>? overlayColor;

  /// See [Checkbox.splashRadius].
  final double? splashRadius;

  /// See [Checkbox.materialTapTargetSize].
  final MaterialTapTargetSize? materialTapTargetSize;

  /// See [Checkbox.visualDensity].
  final VisualDensity? visualDensity;

  /// See [Checkbox.autofocus].
  final bool autofocus;

  /// See [Checkbox.shape].
  final OutlinedBorder? shape;

  /// See [Checkbox.side].
  final BorderSide? side;

  /// See [Checkbox.isError].
  final bool isError;

  /// See [Checkbox.semanticLabel].
  final String? semanticLabel;

  /// See [Checkbox.markInsets].
  final EdgeInsets? markInsets;
}

import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:formidable_flutter/formidable_flutter.dart';

import 'error_caption.dart';

/// A Cupertino checkbox bound to a `bool` Field.
///
/// An Unset Field shows the box unchecked, or mixed when [tristate] is on.
/// The control's focus node is attached to the checkbox, so keyboard
/// navigation between Fields reaches it and the Field becomes touched when it
/// loses focus. A pointer tap does not move focus, so the Field also becomes
/// touched on the first interaction.
///
/// It takes every parameter of [CupertinoCheckbox] except the ones Formidable
/// owns (`value` and `onChanged`) and the deprecated `inactiveColor`. With
/// [tristate], cycling to the mixed state makes the Field Unset.
///
/// For everything else, build a `CupertinoCheckbox` from a
/// [FormidableFieldWidget].
class FormidableCupertinoCheckbox extends FormidableFieldWidget<bool?, bool?> {
  FormidableCupertinoCheckbox({
    super.key,
    required super.field,
    super.messages,
    super.errorDisplay,
    super.focusNode,
    this.tristate = false,
    this.mouseCursor,
    this.activeColor,
    this.fillColor,
    this.checkColor,
    this.focusColor,
    this.autofocus = false,
    this.side,
    this.shape,
    this.tapTargetSize,
    this.semanticLabel,
  }) : super(
         builder: (context, control) => FormidableCupertinoErrorCaption(
           errorText: control.errorText,
           child: CupertinoCheckbox(
             value: tristate ? control.value : control.value ?? false,
             tristate: tristate,
             onChanged: control.enabled
                 ? (value) => value == null
                       ? control.clear(touch: true)
                       : control.didChange(value, touch: true)
                 : null,
             mouseCursor: mouseCursor,
             activeColor: activeColor,
             fillColor: fillColor,
             checkColor: checkColor,
             focusColor: focusColor,
             focusNode: control.focusNode,
             autofocus: autofocus,
             side: side,
             shape: shape,
             tapTargetSize: tapTargetSize,
             semanticLabel: semanticLabel,
           ),
         ),
       );

  /// Whether the checkbox has a third, mixed state. The Field is Unset while
  /// it is mixed.
  final bool tristate;

  /// See [CupertinoCheckbox.mouseCursor].
  final MouseCursor? mouseCursor;

  /// See [CupertinoCheckbox.activeColor].
  final Color? activeColor;

  /// See [CupertinoCheckbox.fillColor].
  final WidgetStateProperty<Color?>? fillColor;

  /// See [CupertinoCheckbox.checkColor].
  final Color? checkColor;

  /// See [CupertinoCheckbox.focusColor].
  final Color? focusColor;

  /// See [CupertinoCheckbox.autofocus].
  final bool autofocus;

  /// See [CupertinoCheckbox.side].
  final BorderSide? side;

  /// See [CupertinoCheckbox.shape].
  final OutlinedBorder? shape;

  /// See [CupertinoCheckbox.tapTargetSize].
  final Size? tapTargetSize;

  /// See [CupertinoCheckbox.semanticLabel].
  final String? semanticLabel;
}

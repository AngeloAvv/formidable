import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:formidable_flutter/formidable_flutter.dart';

import 'error_caption.dart';

/// A Cupertino slider bound to a `double` Field.
///
/// An Unset Field shows the thumb at `min` and stays Unset until the user
/// moves it. A slider can't take focus, so the Field becomes touched when the
/// user starts to drag it.
///
/// It takes every parameter of [CupertinoSlider] except the ones Formidable
/// owns (`value` and `onChanged`). [onChangeStart] is called after the Field
/// was touched.
///
/// For everything else, build a `CupertinoSlider` from a
/// [FormidableFieldWidget].
class FormidableCupertinoSlider
    extends FormidableFieldWidget<double?, double?> {
  FormidableCupertinoSlider({
    super.key,
    required super.field,
    super.messages,
    super.errorDisplay,
    super.focusNode,
    this.onChangeStart,
    this.onChangeEnd,
    this.min = 0.0,
    this.max = 1.0,
    this.divisions,
    this.activeColor,
    this.thumbColor = CupertinoColors.white,
  }) : super(
         builder: (context, control) => FormidableCupertinoErrorCaption(
           errorText: control.errorText,
           child: CupertinoSlider(
             value: (control.value ?? min).clamp(min, max),
             onChanged: control.enabled ? control.didChange : null,
             onChangeStart: (value) {
               control.markAsTouched();
               onChangeStart?.call(value);
             },
             onChangeEnd: onChangeEnd,
             min: min,
             max: max,
             divisions: divisions,
             activeColor: activeColor,
             thumbColor: thumbColor,
           ),
         ),
       );

  /// Called when the user starts to drag the thumb, after the Field was
  /// touched.
  final ValueChanged<double>? onChangeStart;

  /// See [CupertinoSlider.onChangeEnd].
  final ValueChanged<double>? onChangeEnd;

  /// See [CupertinoSlider.min].
  final double min;

  /// See [CupertinoSlider.max].
  final double max;

  /// See [CupertinoSlider.divisions].
  final int? divisions;

  /// See [CupertinoSlider.activeColor].
  final Color? activeColor;

  /// See [CupertinoSlider.thumbColor].
  final Color thumbColor;
}

import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:formidable_flutter/formidable_flutter.dart';

import 'error_caption.dart';

/// A Cupertino slider bound to a `double` Field.
///
/// An Unset Field shows the thumb at `min` and stays Unset until the user
/// moves it. A slider can't take focus, so the Field becomes touched when the
/// user starts to drag it.
///
/// For everything else, build a `CupertinoSlider` from a
/// [FormidableFieldWidget].
class FormidableCupertinoSlider
    extends FormidableFieldWidget<double?, double?> {
  FormidableCupertinoSlider({
    super.key,
    required super.field,
    double min = 0.0,
    double max = 1.0,
    int? divisions,
    Color? activeColor,
    super.messages,
    super.errorDisplay,
    super.focusNode,
  }) : super(
         builder: (context, control) => FormidableCupertinoErrorCaption(
           errorText: control.errorText,
           child: CupertinoSlider(
             value: (control.value ?? min).clamp(min, max),
             min: min,
             max: max,
             divisions: divisions,
             activeColor: activeColor,
             onChangeStart: (_) => control.markAsTouched(),
             onChanged: control.enabled ? control.didChange : null,
           ),
         ),
       );
}

import 'package:formidable_flutter/formidable_flutter.dart';
import 'package:material_ui/material_ui.dart';

import 'error_text.dart';

/// A Material slider bound to a numeric Field: `double`, `int` or `num`,
/// nullable or not.
///
/// The thumb rests at [min] while the Field is Unset, and the Field stays Unset
/// until the user moves it. A value outside [min] and [max] is shown at the
/// nearest end. On an `int` Field the thumb value is rounded.
///
/// The first interaction marks the Field touched, and the Validation Message
/// shows below the slider from then on.
///
/// Without [divisions] the slider is continuous. With them, [labelBuilder]
/// builds the label above the thumb, which shows while the Field has a value.
/// It receives the value as the Field has it.
///
/// It exposes the most common parameters. For everything else, build a
/// `Slider` from a [FormidableFieldWidget].
class FormidableSlider<T extends num?> extends FormidableFieldWidget<T, T> {
  FormidableSlider({
    super.key,
    required super.field,
    double min = 0,
    double max = 1,
    int? divisions,
    String Function(num value)? labelBuilder,
    bool autofocus = false,
    super.focusNode,
    super.messages,
    super.errorDisplay,
  }) : super(
         builder: (context, control) {
           final current = control.value?.toDouble();
           final value = (current == null ? min : current.clamp(min, max))
               .toDouble();
           return Column(
             crossAxisAlignment: CrossAxisAlignment.start,
             mainAxisSize: MainAxisSize.min,
             children: [
               Slider(
                 value: value,
                 min: min,
                 max: max,
                 divisions: divisions,
                 label: current == null
                     ? null
                     : labelBuilder?.call(_toFieldType<T>(value) as num),
                 focusNode: control.focusNode,
                 autofocus: autofocus,
                 onChanged: (next) {
                   if (control.enabled) {
                     control.didChange(_toFieldType<T>(next), touch: true);
                   }
                 },
               ),
               FormidableErrorLine(text: control.errorText),
             ],
           );
         },
       );
}

/// The thumb value as the Field's type: a double stays one, anything else is
/// an `int` and is rounded.
T _toFieldType<T extends num?>(double next) =>
    (next is T ? next : next.round()) as T;

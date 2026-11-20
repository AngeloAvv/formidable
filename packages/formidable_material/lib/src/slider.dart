import 'package:formidable/formidable.dart';
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
/// It exposes the most common parameters. For everything else, build a
/// `Slider` from a [FormidableBindingBuilder].
class FormidableSlider<T extends num?> extends StatelessWidget {
  const FormidableSlider({
    super.key,
    required this.field,
    this.min = 0,
    this.max = 1,
    this.divisions,
    this.labelBuilder,
    this.autofocus = false,
    this.focusNode,
    this.messages,
  });

  final FormidableField<T> field;
  final double min;
  final double max;

  /// The number of discrete steps. Without it the slider is continuous.
  final int? divisions;

  /// Builds the label above the thumb while it is dragged, or while the Field
  /// has a value if [divisions] is set. Receives the value as the Field has it.
  final String Function(num value)? labelBuilder;
  final bool autofocus;

  /// Used instead of the focus node owned by the Binding. Never disposed here.
  final FocusNode? focusNode;

  /// Messages for this widget only, ahead of the config and the localizations.
  final FormidableMessages? messages;

  @override
  Widget build(BuildContext context) => FormidableBindingBuilder<T>(
    field: field,
    focusNode: focusNode,
    messages: messages,
    builder: (context, binding) {
      final current = binding.value?.toDouble();
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
                : labelBuilder?.call(_toFieldType(value) as num),
            focusNode: binding.focusNode,
            autofocus: autofocus,
            onChanged: (next) {
              if (binding.enabled) binding.onPicked(_toFieldType(next));
            },
          ),
          FormidableErrorLine(text: binding.errorText),
        ],
      );
    },
  );

  /// The thumb value as the Field's type: a double stays one, anything else
  /// is an `int` and is rounded.
  T _toFieldType(double next) => (next is T ? next : next.round()) as T;
}

import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:formidable/formidable.dart';
import 'package:formidable_flutter/formidable_flutter.dart';

import 'error_caption.dart';

/// A Cupertino slider bound to a `double` Field.
///
/// An Unset Field shows the thumb at [min] and stays Unset until the user
/// moves it. A slider can't take focus, so the Field becomes touched when the
/// user starts to drag it.
///
/// For everything else, build a `CupertinoSlider` from a
/// [FormidableBindingBuilder].
class FormidableCupertinoSlider extends StatelessWidget {
  const FormidableCupertinoSlider({
    super.key,
    required this.field,
    this.min = 0.0,
    this.max = 1.0,
    this.divisions,
    this.activeColor,
    this.messages,
  });

  final FormidableField<double?> field;
  final double min;
  final double max;
  final int? divisions;
  final Color? activeColor;

  /// Messages for this widget only, ahead of the config and the localizations.
  final FormidableMessages? messages;

  @override
  Widget build(BuildContext context) => FormidableBindingBuilder<double?>(
    field: field,
    messages: messages,
    builder: (context, binding) => FormidableCupertinoErrorCaption(
      binding: binding,
      child: CupertinoSlider(
        value: (binding.value ?? min).clamp(min, max),
        min: min,
        max: max,
        divisions: divisions,
        activeColor: activeColor,
        onChangeStart: (_) => binding.onTouched(),
        onChanged: binding.enabled ? binding.onChanged : null,
      ),
    ),
  );
}

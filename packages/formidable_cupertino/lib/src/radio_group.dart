import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:formidable/formidable.dart';
import 'package:formidable_flutter/formidable_flutter.dart';

import 'error_caption.dart';

/// A group of `CupertinoRadio<T>` widgets bound to a Field of type [T].
///
/// Put the radios anywhere under [child]. The radio whose value equals the
/// Field is selected, and none is when the Field is Unset. A radio can't take
/// focus, so the Field becomes touched on the first interaction.
class FormidableCupertinoRadioGroup<T extends Object> extends StatelessWidget {
  const FormidableCupertinoRadioGroup({
    super.key,
    required this.field,
    required this.child,
    this.messages,
  });

  final FormidableField<T?> field;
  final Widget child;

  /// Messages for this widget only, ahead of the config and the localizations.
  final FormidableMessages? messages;

  @override
  Widget build(BuildContext context) => FormidableBindingBuilder<T?>(
    field: field,
    messages: messages,
    builder: (context, binding) => FormidableCupertinoErrorCaption(
      binding: binding,
      child: RadioGroup<T>(
        groupValue: binding.value,
        onChanged: (value) {
          if (!binding.enabled || value == null) return;
          binding.onTouched();
          binding.onChanged(value);
        },
        child: child,
      ),
    ),
  );
}

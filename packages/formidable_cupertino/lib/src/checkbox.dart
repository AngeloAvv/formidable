import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:formidable/formidable.dart' hide Color;
import 'package:formidable_flutter/formidable_flutter.dart';

import 'error_caption.dart';

/// A Cupertino checkbox bound to a `bool` Field.
///
/// An Unset Field shows the box unchecked. A checkbox can't take focus, so the
/// Field becomes touched on the first interaction.
///
/// For everything else, build a `CupertinoCheckbox` from a
/// [FormidableBindingBuilder].
class FormidableCupertinoCheckbox extends StatelessWidget {
  const FormidableCupertinoCheckbox({
    super.key,
    required this.field,
    this.activeColor,
    this.messages,
  });

  final FormidableField<bool?> field;
  final Color? activeColor;

  /// Messages for this widget only, ahead of the config and the localizations.
  final FormidableMessages? messages;

  @override
  Widget build(BuildContext context) => FormidableBindingBuilder<bool?>(
    field: field,
    messages: messages,
    builder: (context, binding) => FormidableCupertinoErrorCaption(
      binding: binding,
      child: CupertinoCheckbox(
        value: binding.value ?? false,
        activeColor: activeColor,
        onChanged: binding.enabled
            ? (value) {
                binding.onTouched();
                binding.onChanged(value ?? false);
              }
            : null,
      ),
    ),
  );
}

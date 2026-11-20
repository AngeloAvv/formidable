import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:formidable/formidable.dart';
import 'package:formidable_flutter/formidable_flutter.dart';

import 'error_caption.dart';

/// A Cupertino switch bound to a `bool` Field.
///
/// An Unset Field shows the switch off. A switch can't take focus, so the
/// Field becomes touched on the first interaction, and the Validation Message
/// shows under the switch from then on.
///
/// For everything else, build a `CupertinoSwitch` from a
/// [FormidableBindingBuilder].
class FormidableCupertinoSwitch extends StatelessWidget {
  const FormidableCupertinoSwitch({
    super.key,
    required this.field,
    this.activeTrackColor,
    this.messages,
  });

  final FormidableField<bool?> field;
  final Color? activeTrackColor;

  /// Messages for this widget only, ahead of the config and the localizations.
  final FormidableMessages? messages;

  @override
  Widget build(BuildContext context) => FormidableBindingBuilder<bool?>(
    field: field,
    messages: messages,
    builder: (context, binding) => FormidableCupertinoErrorCaption(
      binding: binding,
      child: CupertinoSwitch(
        value: binding.value ?? false,
        activeTrackColor: activeTrackColor,
        onChanged: binding.enabled
            ? (value) {
                binding.onTouched();
                binding.onChanged(value);
              }
            : null,
      ),
    ),
  );
}

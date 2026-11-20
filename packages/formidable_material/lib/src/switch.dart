import 'package:formidable/formidable.dart';
import 'package:formidable_flutter/formidable_flutter.dart';
import 'package:material_ui/material_ui.dart';

import 'error_text.dart';

/// A Material switch bound to a `bool` Field.
///
/// An Unset Field is shown off. The first interaction marks the Field touched,
/// and the Validation Message shows below the switch from then on. With a
/// [title], the whole row is tappable (a `SwitchListTile`).
///
/// It exposes the most common parameters. For everything else, build a
/// `Switch` from a [FormidableBindingBuilder].
class FormidableSwitch extends StatelessWidget {
  const FormidableSwitch({
    super.key,
    required this.field,
    this.title,
    this.autofocus = false,
    this.focusNode,
    this.messages,
  });

  final FormidableField<bool> field;

  /// The label. Without it, only the switch is drawn.
  final Widget? title;
  final bool autofocus;

  /// Used instead of the focus node owned by the Binding. Never disposed here.
  final FocusNode? focusNode;

  /// Messages for this widget only, ahead of the config and the localizations.
  final FormidableMessages? messages;

  @override
  Widget build(BuildContext context) => FormidableBindingBuilder<bool>(
    field: field,
    focusNode: focusNode,
    messages: messages,
    builder: (context, binding) {
      // Unset is shown off: a switch has no state for "not chosen".
      final value = binding.value ?? false;
      void onChanged(bool next) {
        if (binding.enabled) binding.onPicked(next);
      }

      final control = title == null
          ? Switch(
              value: value,
              onChanged: onChanged,
              focusNode: binding.focusNode,
              autofocus: autofocus,
            )
          : SwitchListTile(
              value: value,
              onChanged: onChanged,
              focusNode: binding.focusNode,
              autofocus: autofocus,
              title: title,
            );
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          control,
          FormidableErrorLine(text: binding.errorText),
        ],
      );
    },
  );
}

import 'package:formidable/formidable.dart';
import 'package:formidable_flutter/formidable_flutter.dart';
import 'package:material_ui/material_ui.dart';

import 'error_text.dart';

/// A Material checkbox bound to a `bool` Field.
///
/// An Unset Field is shown unchecked. The first interaction marks the Field
/// touched, and the Validation Message shows below the checkbox from then on.
///
/// With [tristate], a `bool?` Field can also choose null, which is shown as a
/// dash. With a [title], the whole row is tappable (a `CheckboxListTile`).
///
/// It exposes the most common parameters. For everything else, build a
/// `Checkbox` from a [FormidableBindingBuilder].
class FormidableCheckbox<T extends bool?> extends StatelessWidget {
  const FormidableCheckbox({
    super.key,
    required this.field,
    this.title,
    this.tristate = false,
    this.autofocus = false,
    this.focusNode,
    this.messages,
  });

  final FormidableField<T> field;

  /// The label. Without it, only the box is drawn.
  final Widget? title;

  /// Whether the box has a third state for null. Needs a `bool?` Field to be
  /// useful; on a `bool` Field null can never be chosen.
  final bool tristate;
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
      // Unset is shown as unchecked: the box has no state for "not chosen".
      final value = binding.isSet ? binding.value : false;
      void onChanged(bool? next) {
        if (binding.enabled) binding.onPicked(next as T);
      }

      final control = title == null
          ? Checkbox(
              value: value,
              tristate: tristate,
              onChanged: onChanged,
              focusNode: binding.focusNode,
              autofocus: autofocus,
            )
          : CheckboxListTile(
              value: value,
              tristate: tristate,
              onChanged: onChanged,
              focusNode: binding.focusNode,
              autofocus: autofocus,
              title: title,
              controlAffinity: ListTileControlAffinity.leading,
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

import 'package:formidable/formidable.dart';
import 'package:formidable_flutter/formidable_flutter.dart';
import 'package:material_ui/material_ui.dart';

/// A Material dropdown bound to a Field of type [T].
///
/// While the Field is Unset, [hint] is shown. Picking an item sets the Field,
/// including an item whose value is null, which needs a nullable Field. The
/// first pick marks the Field touched, and the Validation Message shows in the
/// decoration from then on.
///
/// It exposes the most common parameters. For everything else, build a
/// `DropdownButton` from a [FormidableBindingBuilder].
class FormidableDropdown<T> extends StatelessWidget {
  const FormidableDropdown({
    super.key,
    required this.field,
    required this.items,
    this.decoration = const InputDecoration(),
    this.hint,
    this.isExpanded = true,
    this.autofocus = false,
    this.focusNode,
    this.messages,
  });

  final FormidableField<T> field;
  final List<DropdownMenuItem<T>> items;
  final InputDecoration decoration;

  /// Shown while the Field is Unset.
  final Widget? hint;
  final bool isExpanded;
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
    builder: (context, binding) => InputDecorator(
      decoration: decoration.copyWith(errorText: binding.errorText),
      isEmpty: !binding.isSet,
      isFocused: binding.focusNode.hasFocus,
      child: DropdownButtonHideUnderline(
        // Values are boxed in a record so that "nothing picked" (a null
        // value) is different from an item whose value is null.
        child: DropdownButton<(T,)>(
          value: binding.isSet ? (binding.value as T,) : null,
          items: [
            for (final item in items)
              DropdownMenuItem<(T,)>(
                value: (item.value as T,),
                enabled: item.enabled,
                alignment: item.alignment,
                child: item.child,
              ),
          ],
          hint: hint,
          isExpanded: isExpanded,
          isDense: true,
          autofocus: autofocus,
          focusNode: binding.focusNode,
          onChanged: binding.enabled
              ? (choice) {
                  if (choice != null) binding.onPicked(choice.$1);
                }
              : null,
        ),
      ),
    ),
  );
}

import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:formidable/formidable.dart';
import 'package:formidable_flutter/formidable_flutter.dart';

import 'error_caption.dart';

/// A Cupertino sliding segmented control bound to a Field of type [T].
///
/// [children] maps each value the Field can take to the widget of its
/// segment. An Unset Field, or a value that has no segment, selects nothing.
/// The control can't take focus, so the Field becomes touched on the first
/// interaction.
///
/// For everything else, build a `CupertinoSlidingSegmentedControl` from a
/// [FormidableBindingBuilder].
class FormidableCupertinoSlidingSegmentedControl<T extends Object>
    extends StatelessWidget {
  const FormidableCupertinoSlidingSegmentedControl({
    super.key,
    required this.field,
    required this.children,
    this.messages,
  });

  final FormidableField<T?> field;
  final Map<T, Widget> children;

  /// Messages for this widget only, ahead of the config and the localizations.
  final FormidableMessages? messages;

  @override
  Widget build(BuildContext context) => FormidableBindingBuilder<T?>(
    field: field,
    messages: messages,
    builder: (context, binding) => FormidableCupertinoErrorCaption(
      binding: binding,
      child: CupertinoSlidingSegmentedControl<T>(
        children: children,
        groupValue: children.containsKey(binding.value) ? binding.value : null,
        onValueChanged: (value) {
          if (!binding.enabled || value == null) return;
          binding.onTouched();
          binding.onChanged(value);
        },
      ),
    ),
  );
}

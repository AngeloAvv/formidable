import 'package:formidable_flutter/formidable_flutter.dart';
import 'package:material_ui/material_ui.dart';

import 'error_text.dart';

/// One choice of a [FormidableRadioGroup].
class FormidableRadioOption<T> {
  const FormidableRadioOption({
    required this.value,
    required this.title,
    this.subtitle,
  });

  /// The value the Field gets when this option is chosen. It is null for the
  /// option that represents null, which needs a nullable Field.
  final T value;
  final Widget title;
  final Widget? subtitle;
}

/// A group of Material radio buttons bound to a Field.
///
/// While the Field is Unset, no option is selected. That includes the option
/// whose value is null: choosing it sets the Field to null, which is a value,
/// whereas an Unset Field is not a choice at all. Put `@Required()` on the
/// nullable Field of the Schema to make the user choose among the options.
///
/// The first interaction marks the Field touched, and the Validation Message
/// shows below the group from then on.
///
/// It exposes the most common parameters. For everything else, build a
/// `RadioGroup` from a [FormidableFieldWidget].
class FormidableRadioGroup<T> extends FormidableFieldWidget<T, T> {
  FormidableRadioGroup({
    super.key,
    required super.field,
    required List<FormidableRadioOption<T>> options,
    super.messages,
    super.errorDisplay,
    super.focusNode,
  }) : super(
         builder: (context, control) => Column(
           crossAxisAlignment: CrossAxisAlignment.start,
           mainAxisSize: MainAxisSize.min,
           children: [
             // Values are boxed in a record so that "nothing selected" (a null
             // group value) is different from the option whose value is null.
             RadioGroup<(T,)>(
               groupValue: control.isSet ? (control.value as T,) : null,
               onChanged: (choice) {
                 if (control.enabled && choice != null) {
                   control.didChange(choice.$1, touch: true);
                 }
               },
               child: Column(
                 mainAxisSize: MainAxisSize.min,
                 children: [
                   for (final option in options)
                     RadioListTile<(T,)>(
                       value: (option.value,),
                       title: option.title,
                       subtitle: option.subtitle,
                     ),
                 ],
               ),
             ),
             FormidableErrorLine(text: control.errorText),
           ],
         ),
       );
}

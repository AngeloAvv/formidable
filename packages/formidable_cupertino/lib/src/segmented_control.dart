import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:formidable_flutter/formidable_flutter.dart';

import 'error_caption.dart';

/// A Cupertino segmented control bound to a Field of type [T].
///
/// [children] maps each value the Field can take to the widget of its
/// segment. An Unset Field, or a value that has no segment, selects nothing.
/// A segmented control can't take focus, so the Field becomes touched on the
/// first interaction.
///
/// It takes every parameter of [CupertinoSegmentedControl] except the ones
/// Formidable owns: the group value and `onValueChanged`.
///
/// For everything else, build a `CupertinoSegmentedControl` from a
/// [FormidableFieldWidget].
class FormidableCupertinoSegmentedControl<T extends Object>
    extends FormidableFieldWidget<T?, T?> {
  FormidableCupertinoSegmentedControl({
    super.key,
    required super.field,
    required this.children,
    super.messages,
    super.errorDisplay,
    super.focusNode,
    this.unselectedColor,
    this.selectedColor,
    this.borderColor,
    this.pressedColor,
    this.disabledColor,
    this.disabledTextColor,
    this.padding,
    this.disabledChildren = const {},
  }) : super(
         builder: (context, control) => FormidableCupertinoErrorCaption(
           errorText: control.errorText,
           child: CupertinoSegmentedControl<T>(
             children: children,
             groupValue: children.containsKey(control.value)
                 ? control.value
                 : null,
             onValueChanged: (value) {
               if (!control.enabled) return;
               control.didChange(value, touched: true);
             },
             unselectedColor: unselectedColor,
             selectedColor: selectedColor,
             borderColor: borderColor,
             pressedColor: pressedColor,
             disabledColor: disabledColor,
             disabledTextColor: disabledTextColor,
             padding: padding,
             disabledChildren: disabledChildren,
           ),
         ),
       );

  /// The value of each segment and the widget that shows it. See
  /// [CupertinoSegmentedControl.children].
  final Map<T, Widget> children;

  /// See [CupertinoSegmentedControl.unselectedColor].
  final Color? unselectedColor;

  /// See [CupertinoSegmentedControl.selectedColor].
  final Color? selectedColor;

  /// See [CupertinoSegmentedControl.borderColor].
  final Color? borderColor;

  /// See [CupertinoSegmentedControl.pressedColor].
  final Color? pressedColor;

  /// See [CupertinoSegmentedControl.disabledColor].
  final Color? disabledColor;

  /// See [CupertinoSegmentedControl.disabledTextColor].
  final Color? disabledTextColor;

  /// See [CupertinoSegmentedControl.padding].
  final EdgeInsetsGeometry? padding;

  /// The segments that can't be picked. See
  /// [CupertinoSegmentedControl.disabledChildren].
  final Set<T> disabledChildren;
}

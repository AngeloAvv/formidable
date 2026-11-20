import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:formidable_flutter/formidable_flutter.dart';

import 'error_caption.dart';

/// A Cupertino sliding segmented control bound to a Field of type [T].
///
/// [children] maps each value the Field can take to the widget of its
/// segment. An Unset Field, or a value that has no segment, selects nothing.
/// The control can't take focus, so the Field becomes touched on the first
/// interaction.
///
/// It takes every parameter of [CupertinoSlidingSegmentedControl] except the
/// ones Formidable owns: the group value and `onValueChanged`. A null
/// [thumbColor], [padding] or [backgroundColor] gives the default of Flutter.
///
/// For everything else, build a `CupertinoSlidingSegmentedControl` from a
/// [FormidableFieldWidget].
class FormidableCupertinoSlidingSegmentedControl<T extends Object>
    extends FormidableFieldWidget<T?, T?> {
  FormidableCupertinoSlidingSegmentedControl({
    super.key,
    required super.field,
    required this.children,
    super.messages,
    super.errorDisplay,
    super.focusNode,
    this.disabledChildren = const {},
    this.thumbColor,
    this.padding,
    this.backgroundColor,
    this.proportionalWidth = false,
    this.isMomentary = false,
  }) : super(
         builder: (context, control) {
           // The defaults of Flutter are private: read them from an instance.
           final defaults = CupertinoSlidingSegmentedControl<T>(
             children: children,
             onValueChanged: (_) {},
           );
           return FormidableCupertinoErrorCaption(
             errorText: control.errorText,
             child: CupertinoSlidingSegmentedControl<T>(
               children: children,
               groupValue: children.containsKey(control.value)
                   ? control.value
                   : null,
               onValueChanged: (value) {
                 if (!control.enabled || value == null) return;
                 control.didChange(value, touch: true);
               },
               disabledChildren: disabledChildren,
               thumbColor: thumbColor ?? defaults.thumbColor,
               padding: padding ?? defaults.padding,
               backgroundColor: backgroundColor ?? defaults.backgroundColor,
               proportionalWidth: proportionalWidth,
               isMomentary: isMomentary,
             ),
           );
         },
       );

  /// The value of each segment and the widget that shows it. See
  /// [CupertinoSlidingSegmentedControl.children].
  final Map<T, Widget> children;

  /// The segments that can't be picked. See
  /// [CupertinoSlidingSegmentedControl.disabledChildren].
  final Set<T> disabledChildren;

  /// See [CupertinoSlidingSegmentedControl.thumbColor]. Null gives its
  /// default.
  final Color? thumbColor;

  /// See [CupertinoSlidingSegmentedControl.padding]. Null gives its default.
  final EdgeInsetsGeometry? padding;

  /// See [CupertinoSlidingSegmentedControl.backgroundColor]. Null gives its
  /// default.
  final Color? backgroundColor;

  /// See [CupertinoSlidingSegmentedControl.proportionalWidth].
  final bool proportionalWidth;

  /// See [CupertinoSlidingSegmentedControl.isMomentary].
  final bool isMomentary;
}

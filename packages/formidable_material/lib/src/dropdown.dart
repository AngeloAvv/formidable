import 'package:formidable_flutter/formidable_flutter.dart';
import 'package:material_ui/material_ui.dart';

import 'decoration.dart';

/// A Material dropdown bound to a Field of type [T].
///
/// While the Field is Unset, `hint` is shown. Picking an item sets the Field,
/// including an item whose value is null, which needs a nullable Field. The
/// first pick marks the Field touched, and the Validation Message shows in the
/// decoration from then on.
///
/// The [decoration] is merged with what Formidable adds: it sets only
/// [InputDecoration.errorText], and only when yours has none. To build the
/// decoration from the state of the widget, for example a clear button while
/// the Field has a value, pass a [decorationBuilder] instead (not both). Its
/// result is merged the same way.
///
/// It takes every parameter of [DropdownButton] except the ones Formidable
/// owns: `value` and `onChanged` (the Field is the source of truth), and
/// `underline` (the [decoration] draws the border). Each one is readable as a
/// field of the widget. The dropdown is [isDense] and [isExpanded] unless told
/// otherwise, and is disabled (showing [disabledHint]) while the Field is.
class FormidableMaterialDropdown<T> extends FormidableFieldWidget<T, T> {
  FormidableMaterialDropdown({
    super.key,
    required super.field,
    required this.items,
    this.decoration = const InputDecoration(),
    this.decorationBuilder,
    super.focusNode,
    super.messages,
    super.errorDisplay,
    this.selectedItemBuilder,
    this.hint,
    this.disabledHint,
    this.onTap,
    this.elevation = 8,
    this.style,
    this.icon,
    this.iconDisabledColor,
    this.iconEnabledColor,
    this.iconSize = 24.0,
    this.isDense = true,
    this.isExpanded = true,
    this.itemHeight = kMinInteractiveDimension,
    this.menuWidth,
    this.focusColor,
    this.autofocus = false,
    this.dropdownColor,
    this.menuMaxHeight,
    this.enableFeedback,
    this.alignment = AlignmentDirectional.centerStart,
    this.borderRadius,
    this.padding,
    this.barrierDismissible = true,
    this.mouseCursor,
    this.dropdownMenuItemMouseCursor,
  }) : assert(
         decorationBuilder == null ||
             identical(decoration, const InputDecoration()),
         'Pass either decoration or decorationBuilder, not both.',
       ),
       super(
         builder: (context, control) => InputDecorator(
           decoration: resolveInputDecoration(
             context,
             control,
             decoration,
             decorationBuilder,
           ),
           isEmpty: !control.isSet,
           isFocused: control.focusNode.hasFocus,
           child: DropdownButtonHideUnderline(
             // Values are boxed in a record so that "nothing picked" (a null
             // value) is different from an item whose value is null.
             child: DropdownButton<(T,)>(
               value: control.isSet ? (control.value as T,) : null,
               items: [
                 for (final item in items)
                   DropdownMenuItem<(T,)>(
                     value: (item.value as T,),
                     onTap: item.onTap,
                     enabled: item.enabled,
                     alignment: item.alignment,
                     child: item.child,
                   ),
               ],
               focusNode: control.focusNode,
               onChanged: control.enabled
                   ? (choice) {
                       if (choice != null) {
                         control.didChange(choice.$1, touch: true);
                       }
                     }
                   : null,
               selectedItemBuilder: selectedItemBuilder,
               hint: hint,
               disabledHint: disabledHint,
               onTap: onTap,
               elevation: elevation,
               style: style,
               icon: icon,
               iconDisabledColor: iconDisabledColor,
               iconEnabledColor: iconEnabledColor,
               iconSize: iconSize,
               isDense: isDense,
               isExpanded: isExpanded,
               itemHeight: itemHeight,
               menuWidth: menuWidth,
               focusColor: focusColor,
               autofocus: autofocus,
               dropdownColor: dropdownColor,
               menuMaxHeight: menuMaxHeight,
               enableFeedback: enableFeedback,
               alignment: alignment,
               borderRadius: borderRadius,
               padding: padding,
               barrierDismissible: barrierDismissible,
               mouseCursor: mouseCursor,
               dropdownMenuItemMouseCursor: dropdownMenuItemMouseCursor,
             ),
           ),
         ),
       );

  /// The items to pick from. See [DropdownButton.items].
  final List<DropdownMenuItem<T>> items;

  /// The decoration of the field. Formidable adds the Validation Message as
  /// its [InputDecoration.errorText] unless it has one. Not together with
  /// [decorationBuilder].
  final InputDecoration decoration;

  /// Builds the decoration from the control, so that it can depend on the
  /// value, the focus or the error. Merged like [decoration], which it
  /// replaces.
  final FormidableMaterialDecorationBuilder<T, T>? decorationBuilder;

  /// See [DropdownButton.selectedItemBuilder].
  final DropdownButtonBuilder? selectedItemBuilder;

  /// See [DropdownButton.hint].
  final Widget? hint;

  /// See [DropdownButton.disabledHint].
  final Widget? disabledHint;

  /// See [DropdownButton.onTap].
  final VoidCallback? onTap;

  /// See [DropdownButton.elevation].
  final int elevation;

  /// See [DropdownButton.style].
  final TextStyle? style;

  /// See [DropdownButton.icon].
  final Widget? icon;

  /// See [DropdownButton.iconDisabledColor].
  final Color? iconDisabledColor;

  /// See [DropdownButton.iconEnabledColor].
  final Color? iconEnabledColor;

  /// See [DropdownButton.iconSize].
  final double iconSize;

  /// See [DropdownButton.isDense].
  final bool isDense;

  /// See [DropdownButton.isExpanded].
  final bool isExpanded;

  /// See [DropdownButton.itemHeight].
  final double? itemHeight;

  /// See [DropdownButton.menuWidth].
  final double? menuWidth;

  /// See [DropdownButton.focusColor].
  final Color? focusColor;

  /// See [DropdownButton.autofocus].
  final bool autofocus;

  /// See [DropdownButton.dropdownColor].
  final Color? dropdownColor;

  /// See [DropdownButton.menuMaxHeight].
  final double? menuMaxHeight;

  /// See [DropdownButton.enableFeedback].
  final bool? enableFeedback;

  /// See [DropdownButton.alignment].
  final AlignmentGeometry alignment;

  /// See [DropdownButton.borderRadius].
  final BorderRadius? borderRadius;

  /// See [DropdownButton.padding].
  final EdgeInsetsGeometry? padding;

  /// See [DropdownButton.barrierDismissible].
  final bool barrierDismissible;

  /// See [DropdownButton.mouseCursor].
  final MouseCursor? mouseCursor;

  /// See [DropdownButton.dropdownMenuItemMouseCursor].
  final MouseCursor? dropdownMenuItemMouseCursor;
}

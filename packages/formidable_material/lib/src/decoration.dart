import 'package:formidable_flutter/formidable_flutter.dart';
import 'package:material_ui/material_ui.dart';

/// Builds the [InputDecoration] of a Formidable Material widget from its
/// [control], so that the decoration can depend on the value, the focus or the
/// error of the Field.
///
/// The result is merged like a plain `decoration`: Formidable adds the
/// Validation Message as the `errorText`, and only when the decoration has none.
///
/// A typical use is a button that clears the field, shown only while it has a
/// value:
///
/// ```dart
/// FormidableMaterialTextField<String>(
///   field: form.name,
///   decorationBuilder: (context, control) => InputDecoration(
///     labelText: 'Name',
///     suffixIcon: (control.value ?? '').isEmpty
///         ? null
///         : IconButton(
///             icon: const Icon(Icons.clear),
///             onPressed: control.clear,
///           ),
///   ),
/// )
/// ```
typedef FormidableMaterialDecorationBuilder<T, V> = InputDecoration Function(
  BuildContext context,
  FormidableFieldWidgetState<T, V> control,
);

/// The decoration a widget draws: the one [builder] builds, else [decoration],
/// with the Validation Message of the [control] as its `errorText` when it has
/// none of its own.
InputDecoration resolveInputDecoration<T, V>(
  BuildContext context,
  FormidableFieldWidgetState<T, V> control,
  InputDecoration decoration,
  FormidableMaterialDecorationBuilder<T, V>? builder,
) {
  final base = builder?.call(context, control) ?? decoration;
  return base.copyWith(errorText: base.errorText ?? control.errorText);
}

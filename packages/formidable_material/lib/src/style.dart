import 'package:formidable_flutter/formidable_flutter.dart';
import 'package:material_ui/material_ui.dart';

/// Builds the [TextStyle] of a Formidable Material text field from its
/// [control], so that the style can depend on the value, the focus or the
/// error of the Field. Returning null gives the default style of the field.
///
/// A typical use is text that turns red while the Field has an error:
///
/// ```dart
/// FormidableMaterialTextField<String>(
///   field: form.name,
///   styleBuilder: (context, control) => control.errorText == null
///       ? null
///       : TextStyle(color: Theme.of(context).colorScheme.error),
/// )
/// ```
typedef FormidableMaterialStyleBuilder<T, V> = TextStyle? Function(
  BuildContext context,
  FormidableFieldWidgetState<T, V> control,
);

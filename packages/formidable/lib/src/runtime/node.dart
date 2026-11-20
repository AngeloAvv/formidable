import '../validation/validation_error.dart';
import 'field.dart';

/// A child of a Form, in Schema declaration order.
///
/// Fields are nodes today. Nested Forms and Field Arrays join them without
/// changing the Form.
abstract interface class FormidableNode {
  /// Whether this node and everything below it has no errors.
  bool get isValid;

  /// Whether this node or anything below it differs from its initial state.
  bool get isDirty;

  /// Whether this node or anything below it is still waiting for a result.
  bool get isPending;

  /// Adds the errors of every Field at or below this node to [into].
  void collectErrors(
    Map<FormidableField<Object?>, List<FormidableValidationError>> into,
  );

  /// Calls [listener] whenever anything at or below this node changes.
  void addListener(void Function() listener);

  void removeListener(void Function() listener);

  void dispose();
}

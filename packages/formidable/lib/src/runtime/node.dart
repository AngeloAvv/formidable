import '../validation/validation_error.dart';
import 'field.dart';
import 'pipeline.dart';

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

  /// Gives the node the pipeline of its Form. Writes to the node run through
  /// it. Called once by the Form.
  void bindPipeline(FormidablePipeline pipeline);

  /// Restores the initial value and presence, and forgets that the user
  /// touched the node. Form Effects do not run: the initial state is already
  /// consistent. Notifies like any other write.
  void reset();

  /// Makes the current value and presence the new initial state, so the node
  /// is no longer dirty.
  void commit();

  /// Brings the node's errors up to date with its value and notifies its
  /// listeners if its state changed. Called by the Form after Effects ran.
  void revalidate();

  /// Calls [listener] whenever anything at or below this node changes.
  void addListener(void Function() listener);

  void removeListener(void Function() listener);

  void dispose();
}

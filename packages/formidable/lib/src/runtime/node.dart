import 'package:meta/meta.dart';

import '../validation/validation_error.dart';
import 'pipeline.dart';

/// A child of a Form, in Schema declaration order.
///
/// Fields and Passthrough Fields are nodes, and so is a [FormidableForm]: a
/// Nested Form is just a Form that is the child of another one. Field Arrays
/// join them without changing the Form.
///
/// A node that has Fields below it implements [collectErrors], [isDirty] and
/// [isPending] by recursing, routes its writes through the pipeline it was
/// bound to, and implements [revalidate] as "recompute errors, notify only if
/// the snapshot changed".
abstract interface class FormidableNode {
  /// Whether this node and everything below it has no errors.
  @internal
  bool get isValid;

  /// Whether this node or anything below it differs from its initial state.
  @internal
  bool get isDirty;

  /// Whether this node or anything below it is still waiting for a result.
  @internal
  bool get isPending;

  /// Adds the errors of this node and of everything below it to [into], in
  /// tree order: a Field Array's own errors come before the errors of its
  /// items.
  void collectErrors(Map<FormidableNode, List<FormidableValidationError>> into);

  /// Marks every Field at or below this node as touched and submitted. Called
  /// by the Form when `submit()` starts.
  void markSubmitted();

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

  /// Calls [listener] whenever the state of the node changes. The state of a
  /// node that has others below it holds their states, so this is also called
  /// for every change below it.
  void addListener(void Function() listener);

  void removeListener(void Function() listener);

  void dispose();
}

import 'node.dart';

/// What a node uses to run the validation pipeline of its Form after it
/// changed: Normalizers (inside the node), then Form Effects, then validation.
abstract interface class FormidablePipeline {
  /// Applies [mutate] to [node], which returns whether the value or presence
  /// of the node changed, and runs the pipeline when it did.
  void change(FormidableNode node, bool Function() mutate);

  /// Brings every node up to date after one of them changed its own
  /// bookkeeping (for example its initial state) without changing a value,
  /// and notifies once. Form Effects do not run.
  void settle();
}

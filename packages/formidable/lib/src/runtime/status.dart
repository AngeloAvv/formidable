/// Where a Field, a Form, a Field Array or a Dynamic Form stands on validation.
///
/// The rule is the same for every State: [invalid] as soon as there is one
/// error, even if other checks are still running; otherwise [pending] while an
/// Async Validator or an asynchronous Form Validator is running; otherwise
/// [valid]. A running check never makes anything [invalid] and never shows a
/// Validation Message: only its result does.
enum FormidableStatus {
  /// There are no errors and nothing is running: the node can be submitted
  /// now.
  valid,

  /// There is at least one error, even if other checks are still running.
  invalid,

  /// There are no errors, but at least one Async Validator or asynchronous
  /// Form Validator is still running.
  pending,
}

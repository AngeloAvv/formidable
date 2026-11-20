import 'validation_error.dart';

/// A rule attached to a Field that needs time or an external service to
/// produce its result, for example "is this username free?".
///
/// Unlike a [FormidableValidator] it is not const and not created by the
/// generator: it is a class you write with its dependencies as constructor
/// parameters, declared on a Field with `@AsyncValidator<YourValidator>()`.
/// The generated Form takes one required, typed parameter for it, so the
/// compiler stops you from forgetting to pass the instance.
///
/// It runs only while the Field has a value and its synchronous Validators
/// pass, after [debounce] has elapsed without another change to the Field.
/// Only the result of the latest value counts, and the Field is pending until
/// it arrives. The Field going back to Unset, being disabled or being disposed
/// cancels the check: the future is not interrupted, its result is dropped.
abstract class FormidableAsyncValidator<T> {
  const FormidableAsyncValidator();

  /// Returns the errors for [value], or an empty list when it is valid. If it
  /// throws, the Field gets a [FormidableAsyncCheckFailedError], so that a
  /// value that could not be checked never passes.
  Future<List<FormidableValidationError>> validate(T value);

  /// How long the Field has to stay unchanged before the check starts. When a
  /// Field has several Async Validators the longest one applies.
  Duration get debounce => const Duration(milliseconds: 500);

  /// Whether a chosen value of null is passed to [validate].
  bool get acceptsNull => null is T;

  /// Whether this Async Validator can be called with a value of type [V].
  ///
  /// The generator checks this when a Validator is an annotation. A Dynamic
  /// Form has no annotations, so it asks the Async Validator at runtime
  /// instead.
  bool fitsValueType<V>() => <V>[] is List<T?>;
}

/// An Async Validator threw instead of answering, so the value could not be
/// checked. It blocks submit like any other error and goes away when the value
/// changes.
final class FormidableAsyncCheckFailedError extends FormidableValidationError {
  const FormidableAsyncCheckFailedError(this.cause);

  /// What the Async Validator threw.
  final Object cause;

  @override
  List<Object?> get props => [cause];

  @override
  String toString() => 'The value could not be checked: $cause';
}

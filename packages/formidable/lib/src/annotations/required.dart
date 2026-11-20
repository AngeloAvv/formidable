/// Forces the user to make a choice for a Field.
///
/// The Schema type already decides most presence: a non-nullable Field
/// without a default is required, and a nullable Field is optional. Put
/// `@Required()` on a nullable Field (or one with a default) to block submit
/// while it is Unset. Choosing null counts as a choice.
///
/// Putting it on a non-nullable Field without a default has no effect,
/// because that Field is already required, so the generator reports a
/// warning.
///
/// ```dart
/// @Formidable()
/// class Survey {
///   const Survey({required this.subscribed});
///
///   // Three radio buttons: yes, no, or "no preference" (null).
///   @Required()
///   final bool? subscribed;
/// }
/// ```
class Required {
  const Required();
}

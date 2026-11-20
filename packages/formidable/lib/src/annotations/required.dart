/// Marks a nullable Field as required: the user has to make a choice.
///
/// An Unset Required Field blocks submit, and choosing null counts as a
/// value. Putting it on a non-nullable Field has no effect, because those
/// Fields are already required, so the generator reports a warning.
///
/// ```dart
/// @Required()
/// final bool? newsletter;
/// ```
class Required {
  const Required();
}

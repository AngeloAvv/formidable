/// When the error of a Field is shown.
///
/// Under every policy, submitting the Form shows every error of every Field.
/// The policy decides what shows before that. It can be set for the whole app
/// in `FormidableConfig` and for one Form on its Form Scope.
enum FormidableErrorDisplay {
  /// Once the user has interacted with the Field and left it, or the Form was
  /// submitted. This is the default.
  touched,

  /// As soon as the value or presence differs from the initial state, or the
  /// Form was submitted.
  dirty,

  /// Only after the Form was submitted.
  submit;

  /// Whether the errors of a Field with these flags are shown.
  bool shows({
    required bool touched,
    required bool dirty,
    required bool submitted,
  }) => switch (this) {
    FormidableErrorDisplay.touched => touched,
    FormidableErrorDisplay.dirty => dirty || submitted,
    FormidableErrorDisplay.submit => submitted,
  };
}

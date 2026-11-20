/// Marks a `Map<String, Object?>` Field of a Schema as a Dynamic Form: a part
/// of the Form whose Fields are registered at runtime under string keys, each
/// with an explicit type and its own Validators.
///
/// Use it for server-driven sections inside an otherwise typed Form. The
/// generated Form exposes the Field as a `FormidableDynamicForm`, and the
/// Schema receives a map of the registered values.
///
/// ```dart
/// @Formidable()
/// class Survey {
///   const Survey({required this.title, required this.answers});
///
///   final String title;
///
///   @Dynamic()
///   final Map<String, Object?> answers;
/// }
///
/// // Later, when the server describes the section:
/// form.answers.register<int>('age', validators: const [Min(0)]);
/// ```
class Dynamic {
  const Dynamic();
}

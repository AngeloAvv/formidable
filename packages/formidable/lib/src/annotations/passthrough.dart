/// Marks a Field whose value is supplied when the Form is created.
///
/// A Passthrough Field can never be Unset and is not bound to a widget, for
/// example an identifier in an edit form. When it is non-nullable and has no
/// default, it is a required parameter of the partial Form constructor. The
/// Form can still change it, and it can be observed.
///
/// ```dart
/// @Formidable()
/// class EditUser {
///   const EditUser({required this.id, required this.name});
///
///   @Passthrough()
///   final int id;
///
///   final String name;
/// }
/// ```
class Passthrough {
  const Passthrough();
}

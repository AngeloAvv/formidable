/// Marks a plain Dart class as a Schema.
///
/// The generator turns every Schema into a typed Form. A Schema `SignUp`
/// becomes `SignUpForm`, written to a part file next to the Schema:
///
/// ```dart
/// part 'sign_up.formidable.dart';
///
/// @Formidable()
/// class SignUp {
///   const SignUp({required this.username});
///
///   @MinLength(4)
///   final String username;
/// }
/// ```
class Formidable {
  const Formidable();
}

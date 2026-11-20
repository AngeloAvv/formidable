import 'package:formidable/formidable.dart';

part 'sign_up.formidable.dart';

/// Tracer bullet Schema: one non-nullable `String` Field with a Validator.
@Formidable()
class SignUp {
  const SignUp({required this.username});

  @MinLength(4)
  final String username;
}

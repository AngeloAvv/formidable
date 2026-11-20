import 'package:formidable/formidable.dart';

part 'sign_up.formidable.dart';

/// The Schema of the sign-up form. The generator turns it into `SignUpForm`
/// and `SignUpFormScope`.
@Formidable()
class SignUp {
  const SignUp({required this.username});

  @MinLength(4)
  final String username;
}

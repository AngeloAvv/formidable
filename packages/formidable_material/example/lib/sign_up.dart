import 'package:formidable/formidable.dart';

part 'sign_up.formidable.dart';

/// The Schema of a sign-up Form. `dart run build_runner build` generates
/// `SignUpForm` from it.
@Formidable()
class SignUp {
  const SignUp({
    required this.email,
    required this.password,
    required this.confirmation,
    this.acceptedTerms = false,
  });

  @Trim()
  @Email()
  final String email;

  @MinLength(8)
  @HasUppercase()
  @HasDigit()
  final String password;

  @MustMatch(#password)
  final String confirmation;

  @IsTrue()
  final bool acceptedTerms;
}

import 'package:formidable/formidable.dart';

part 'sign_up.formidable.dart';

@Formidable()
class SignUp {
  const SignUp({required this.username});

  @MinLength(4)
  final String username;
}

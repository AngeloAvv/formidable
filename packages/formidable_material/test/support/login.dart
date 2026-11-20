import 'package:formidable/formidable.dart';

part 'login.formidable.dart';

@Formidable()
class Login {
  const Login({required this.username, required this.password});

  @MinLength(3)
  final String username;

  @MinLength(8)
  final String password;
}

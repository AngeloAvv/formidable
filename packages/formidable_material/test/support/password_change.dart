import 'package:formidable/formidable.dart';

part 'password_change.formidable.dart';

@Formidable()
class PasswordChange {
  const PasswordChange({required this.password, required this.confirmation});

  final String password;

  @MustMatch(#password)
  final String confirmation;
}

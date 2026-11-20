import 'package:formidable/formidable.dart';

part 'submit_flow.formidable.dart';

/// Several Fields that can be invalid at once, a nullable Field and a Field
/// that is required even though it is nullable.
@Formidable()
class Account {
  const Account({
    required this.username,
    required this.password,
    this.note,
    this.code,
  });

  @MinLength(3)
  final String username;

  @MinLength(8)
  final String password;

  final String? note;

  @Required()
  final String? code;
}

import 'package:formidable/formidable.dart';

part 'account.formidable.dart';

/// A custom Validation Error, to prove that messages for application errors
/// are registered in a typed way.
final class NotAdminError extends FormidableValidationError {
  const NotAdminError();
}

/// A custom Validator that produces [NotAdminError].
class NotAdmin extends FormidableValidator<String> {
  const NotAdmin();

  @override
  List<FormidableValidationError> validate(String value) =>
      value == 'admin' ? const [NotAdminError()] : const [];
}

@Formidable()
class Account {
  const Account({required this.username});

  @NotAdmin()
  @MinLength(4)
  final String username;
}

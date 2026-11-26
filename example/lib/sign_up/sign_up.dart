import 'package:formidable/formidable.dart';

part 'sign_up.formidable.dart';

enum AccountType { personal, company }

/// A Form Validator: it reads several Fields of the typed Form and addresses
/// its error to one of them.
class PasswordWithoutUsername extends FormidableFormValidator<SignUpForm> {
  const PasswordWithoutUsername();

  @override
  List<FormidableFieldError> validate(SignUpForm form) =>
      form.username.defined &&
          form.password.defined &&
          form.password.value.contains(form.username.value)
      ? [FormidableFieldError(form.password, const PasswordHasUsernameError())]
      : const [];
}

/// A Form Effect: only a company has a VAT number, so the Field is disabled
/// for everybody else. A disabled Field takes no input and is not validated.
class VatOnlyForCompanies extends FormidableEffect<SignUpForm> {
  const VatOnlyForCompanies();

  @override
  void apply(SignUpForm form, FormidableEffectContext context) {
    if (form.type.defined && form.type.value == AccountType.company) {
      form.vat.enable();
    } else {
      form.vat.disable();
    }
  }
}

/// The Schema of the sign-up guide. The generator turns it into `SignUpForm`
/// and `SignUpFormScope`.
///
/// - `@Trim()` normalizes the username before it is validated.
/// - `@AsyncValidator` asks a service whether the username is free. The
///   service is a constructor parameter of the generated Form.
/// - `@PasswordWithoutUsername` is a Form Validator and `@Effects` lists a Form
///   Effect, both typed on the generated Form.
/// - `@MustMatch` and `@RequiredIf` are cross-field rules: they name other
///   Fields by symbol and are checked by the generator.
@Formidable()
@PasswordWithoutUsername()
@Effects([VatOnlyForCompanies()])
class SignUp {
  const SignUp({
    required this.username,
    required this.password,
    required this.confirmation,
    this.type = AccountType.personal,
    this.vat,
  });

  @Trim()
  @MinLength(4)
  @AsyncValidator<UsernameAvailable>()
  final String username;

  @MinLength(8)
  final String password;

  @MustMatch(#password)
  final String confirmation;

  final AccountType type;

  @RequiredIf(#type, AccountType.company)
  final String? vat;
}

/// A service that knows which usernames are taken. Here it is a fake.
class UserRepository {
  const UserRepository();

  Future<bool> isTaken(String username) async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    return const {'admin', 'root'}.contains(username.toLowerCase());
  }
}

/// A Validation Error of your own. Its message is registered once, in
/// `exampleMessages`.
final class UsernameTakenError extends FormidableValidationError {
  const UsernameTakenError(this.username);

  final String username;

  @override
  List<Object?> get props => [username];
}

final class PasswordHasUsernameError extends FormidableValidationError {
  const PasswordHasUsernameError();
}

class UsernameAvailable extends FormidableAsyncValidator<String> {
  UsernameAvailable(this.repository);

  final UserRepository repository;

  @override
  Duration get debounce => const Duration(milliseconds: 300);

  @override
  Future<List<FormidableValidationError>> validate(String value) async =>
      await repository.isTaken(value) ? [UsernameTakenError(value)] : const [];
}

import '../runtime/form.dart';
import '../validation/async_form_validator.dart';
import '../validation/async_validator.dart';

/// Declares an Async Validator on a Field.
///
/// [V] is the class of the validator. The generated Form takes an instance of
/// it as a required named parameter, named after the class in lowerCamelCase
/// (`UsernameAvailable` becomes `usernameAvailable`), and shares it between
/// every Field of the Schema that names the same class.
///
/// ```dart
/// @AsyncValidator<UsernameAvailable>()
/// final String username;
///
/// final form = SignUpForm(
///   usernameAvailable: UsernameAvailable(repository),
/// );
/// ```
class AsyncValidator<V extends FormidableAsyncValidator<Object?>> {
  const AsyncValidator();
}

/// Declares an asynchronous Form Validator on a Schema class.
///
/// [V] is the class of the validator, which is typed on the generated Form.
/// The generated Form takes an instance of it as a required named parameter,
/// named after the class in lowerCamelCase.
class AsyncFormValidator<
  V extends FormidableAsyncFormValidator<FormidableForm<Object?>>
> {
  const AsyncFormValidator();
}

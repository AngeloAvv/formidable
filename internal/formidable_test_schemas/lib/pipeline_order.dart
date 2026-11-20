import 'package:formidable/formidable.dart';

part 'pipeline_order.formidable.dart';

final class ConfirmationMismatchError extends FormidableValidationError {
  const ConfirmationMismatchError();
}

/// A Form Validator that reads the state of a Field: it only compares the
/// confirmation once the password passes its own Validators, so it depends on
/// the synchronous Field Validators having run first.
class ComparesValidPassword extends FormidableFormValidator<NewPasswordForm> {
  const ComparesValidPassword();

  @override
  List<FormidableFieldError> validate(NewPasswordForm form) =>
      form.password.isValid &&
          form.confirmation.isSet &&
          form.password.value != form.confirmation.value
      ? [
          FormidableFieldError(
            form.confirmation,
            const ConfirmationMismatchError(),
          ),
        ]
      : const [];
}

@Formidable()
@ComparesValidPassword()
class NewPassword {
  const NewPassword({required this.password, required this.confirmation});

  @MinLength(8)
  final String password;

  final String confirmation;
}

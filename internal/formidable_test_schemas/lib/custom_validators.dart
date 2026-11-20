import 'package:formidable/formidable.dart';

part 'custom_validators.formidable.dart';

/// The recipe of a Validator in four steps: an error that carries data, a const
/// class, one `validate` method, and the annotation on a Field.
final class NoSpacesError extends FormidableValidationError {
  const NoSpacesError();
}

/// The value contains whitespace.
class NoSpaces extends FormidableValidator<String> {
  const NoSpaces();

  @override
  List<FormidableValidationError> validate(String value) =>
      value.contains(' ') ? const [NoSpacesError()] : const [];
}

final class OddError extends FormidableValidationError {
  const OddError(this.value);

  final int value;

  @override
  List<Object?> get props => [value];
}

class IsEven extends FormidableValidator<int> {
  const IsEven();

  @override
  List<FormidableValidationError> validate(int value) =>
      value.isEven ? const [] : [OddError(value)];
}

/// A Validator typed for a supertype of the Field type fits too.
class NotEmptyText extends FormidableValidator<Object> {
  const NotEmptyText();

  @override
  List<FormidableValidationError> validate(Object value) =>
      '$value'.isEmpty ? const [NoSpacesError()] : const [];
}

final class PasswordMismatchError extends FormidableValidationError {
  const PasswordMismatchError();
}

/// A Form Validator: typed on the generated Form, it returns errors addressed
/// to Field handles.
class PasswordsMatch extends FormidableFormValidator<RegistrationForm> {
  const PasswordsMatch();

  @override
  List<FormidableFieldError> validate(RegistrationForm form) =>
      form.password.isSet &&
          form.confirmation.isSet &&
          form.password.value != form.confirmation.value
      ? [FormidableFieldError(form.confirmation, const PasswordMismatchError())]
      : const [];
}

@Formidable()
@PasswordsMatch()
class Registration {
  const Registration({
    required this.password,
    required this.confirmation,
    this.lucky,
    required this.nickname,
    required this.handle,
  });

  /// Two Validators: errors come in the order of the annotations.
  @MinLength(8)
  @NoSpaces()
  final String password;

  /// Its own errors come first, then the ones from the Form Validator.
  @MinLength(8)
  final String confirmation;

  /// Nullable: the `int` Validator is skipped when null is chosen.
  @IsEven()
  final int? lucky;

  /// Same Validators as `password`, in the opposite order.
  @NoSpaces()
  @MinLength(8)
  final String nickname;

  @NotEmptyText()
  final String handle;
}

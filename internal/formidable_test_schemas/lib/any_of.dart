import 'package:formidable/formidable.dart';

part 'any_of.formidable.dart';

final class AtSignError extends FormidableValidationError {
  const AtSignError();
}

class HasAtSign extends FormidableValidator<String> {
  const HasAtSign();

  @override
  List<FormidableValidationError> validate(String value) =>
      value.contains('@') ? const [] : const [AtSignError()];
}

@Formidable()
class Contact {
  const Contact({required this.email, this.fax, required this.tagged});

  /// An email-like value or a phone-like one of at least 10 characters.
  @AnyOf([HasAtSign(), MinLength(10)])
  final String email;

  @AnyOf([HasAtSign(), MinLength(10)])
  final String? fax;

  @MinLength(3)
  @AnyOf([HasAtSign(), MinLength(10)])
  final String tagged;
}

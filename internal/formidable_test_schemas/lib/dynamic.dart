import 'package:formidable/formidable.dart';

part 'dynamic.formidable.dart';

/// A Schema with a typed part and a server-driven part.
@Formidable()
class Survey {
  const Survey({required this.title, required this.answers});

  @MinLength(2)
  final String title;

  /// Fields registered at runtime, each with an explicit type.
  @Dynamic()
  final Map<String, Object?> answers;
}

/// A Schema that a Dynamic Form nests.
@Formidable()
class Place {
  const Place({required this.street, this.zip});

  @MinLength(2)
  final String street;

  final String? zip;
}

/// Reacts to dynamic Fields: it clears `province` when `country` changes and
/// copies the title into `slug`.
class DynamicEffects extends FormidableEffect<QuestionnaireForm> {
  const DynamicEffects();

  @override
  void apply(QuestionnaireForm form, FormidableEffectContext context) {
    final answers = form.answers;
    if (answers.contains('country') &&
        answers.contains('province') &&
        context.changed(answers.field<String>('country'))) {
      answers.field<String?>('province').clear();
    }
    if (answers.contains('slug') && context.changed(form.title)) {
      answers.field<String?>('slug').setValue(form.title.value);
    }
  }
}

class PasswordMismatch extends FormidableValidationError {
  const PasswordMismatch();
}

/// Addresses an error to a dynamic Field.
class DynamicPasswordsMatch extends FormidableFormValidator<QuestionnaireForm> {
  const DynamicPasswordsMatch();

  @override
  List<FormidableFieldError> validate(QuestionnaireForm form) {
    final answers = form.answers;
    if (!answers.contains('password') || !answers.contains('confirm')) {
      return const [];
    }
    final password = answers.field<String>('password');
    final confirm = answers.field<String>('confirm');
    return password.value != confirm.value
        ? [FormidableFieldError(confirm, const PasswordMismatch())]
        : const [];
  }
}

/// A Schema whose typed Fields and dynamic Fields react to each other.
@Formidable()
@Effects([DynamicEffects()])
@DynamicPasswordsMatch()
class Questionnaire {
  const Questionnaire({required this.title, required this.answers});

  final String title;

  @Dynamic()
  final Map<String, Object?> answers;
}

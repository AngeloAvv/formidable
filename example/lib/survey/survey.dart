import 'package:formidable/formidable.dart';

part 'survey.formidable.dart';

/// The Schema of the Dynamic Form guide. `title` is a declared Field;
/// `answers` is a Dynamic Form whose Fields are registered at runtime.
@Formidable()
class Survey {
  const Survey({required this.title, required this.answers});

  @Trim()
  @MinLength(2)
  final String title;

  @Dynamic()
  final Map<String, Object?> answers;
}

/// A question as a server would describe it.
sealed class Question {
  const Question(this.key, this.label);

  final String key;
  final String label;
}

final class NumberQuestion extends Question {
  const NumberQuestion(super.key, super.label, {required this.min});

  final int min;
}

final class TextQuestion extends Question {
  const TextQuestion(super.key, super.label, {this.required = false});

  final bool required;
}

final class YesNoQuestion extends Question {
  const YesNoQuestion(super.key, super.label);
}

/// Two questionnaires, as if the server had sent them.
const questionnaires = <List<Question>>[
  [
    NumberQuestion('age', 'Age', min: 0),
    TextQuestion('nickname', 'Nickname'),
    YesNoQuestion('newsletter', 'Newsletter'),
  ],
  [
    TextQuestion('city', 'City', required: true),
    YesNoQuestion('pets', 'Do you have pets?'),
  ],
];

/// Registers one Field for every question. `register<T>` takes the exact type
/// of the Field, nullability included: `int` is required, `String?` is not.
void registerQuestions(SurveyForm form, List<Question> questions) {
  for (final question in questions) {
    switch (question) {
      case NumberQuestion(:final key, :final min):
        form.answers.register<int>(key, validators: [Min(min)]);
      case TextQuestion(:final key, required: true):
        form.answers.register<String>(
          key,
          normalizers: const [Trim()],
          validators: const [MinLength(2)],
        );
      case TextQuestion(:final key):
        form.answers.register<String?>(key, normalizers: const [Trim()]);
      case YesNoQuestion(:final key):
        form.answers.register<bool>(key, defaultValue: false);
    }
  }
}

/// Removes every registered Field. Removing disposes the Field.
void removeQuestions(SurveyForm form) {
  for (final key in form.answers.keys.toList()) {
    form.answers.remove(key);
  }
}

/// "Thanks, Pets: {age: 7}".
String describeAnswers(Survey survey) =>
    'Thanks, ${survey.title}: ${survey.answers}';

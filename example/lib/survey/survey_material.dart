import 'package:formidable/formidable.dart';
import 'package:formidable_flutter/formidable_flutter.dart';
import 'package:formidable_material/formidable_material.dart';
import 'package:material_ui/material_ui.dart';

import 'survey.dart';
import 'survey.formidable_scope.dart';

/// A Dynamic Form with Material widgets: the questions arrive at runtime and
/// each one is registered as a typed Field of `form.answers`.
class SurveyMaterialPage extends StatelessWidget {
  const SurveyMaterialPage({super.key});

  @override
  Widget build(BuildContext context) => SurveyFormScope(
    child: Scaffold(
      appBar: AppBar(title: const Text('Survey')),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: _SurveyBody(),
      ),
    ),
  );
}

class _SurveyBody extends StatefulWidget {
  const _SurveyBody();

  @override
  State<_SurveyBody> createState() => _SurveyBodyState();
}

class _SurveyBodyState extends State<_SurveyBody> {
  int _questionnaire = -1;
  String? _result;

  List<Question> get _questions =>
      _questionnaire < 0 ? const [] : questionnaires[_questionnaire];

  void _load(SurveyForm form) {
    removeQuestions(form);
    _questionnaire = (_questionnaire + 1) % questionnaires.length;
    registerQuestions(form, _questions);
    setState(() => _result = null);
  }

  Future<void> _save(SurveyForm form) async {
    final result = switch (await form.submit()) {
      FormidableSubmitValid(:final value) => describeAnswers(value),
      FormidableSubmitInvalid() => 'Please fix the errors above.',
    };
    if (mounted) setState(() => _result = result);
  }

  Widget _answer(SurveyForm form, Question question) => switch (question) {
    NumberQuestion(:final key, :final label) => FormidableTextField<int>(
      key: Key('answer-$key'),
      field: form.answers.field<int>(key),
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    ),
    TextQuestion(:final key, :final label, :final required) =>
      required
          ? FormidableTextField<String>(
              key: Key('answer-$key'),
              field: form.answers.field<String>(key),
              decoration: InputDecoration(
                labelText: label,
                border: const OutlineInputBorder(),
              ),
            )
          : FormidableTextField<String?>(
              key: Key('answer-$key'),
              field: form.answers.field<String?>(key),
              decoration: InputDecoration(
                labelText: label,
                border: const OutlineInputBorder(),
              ),
            ),
    YesNoQuestion(:final key, :final label) => FormidableSwitch(
      key: Key('answer-$key'),
      field: form.answers.field<bool>(key),
      title: Text(label),
    ),
  };

  @override
  Widget build(BuildContext context) {
    final form = context.surveyForm;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 16,
      children: [
        FormidableTextField(
          key: const Key('title'),
          field: form.title,
          decoration: const InputDecoration(
            labelText: 'Survey title',
            border: OutlineInputBorder(),
          ),
        ),
        // Rebuilds when a Field is registered, removed or edited.
        ValueListenableBuilder<FormidableDynamicFormState>(
          valueListenable: form.answers.asValueListenable(),
          builder: (context, state, _) => Column(
            spacing: 16,
            children: [
              for (final key in state.keys)
                _answer(form, _questions.firstWhere((q) => q.key == key)),
            ],
          ),
        ),
        FilledButton.tonal(
          onPressed: () => _load(form),
          child: Text(
            _questionnaire < 0 ? 'Load questions' : 'Switch questionnaire',
          ),
        ),
        FilledButton(
          onPressed: () => _save(form),
          child: const Text('Save survey'),
        ),
        if (_result != null) Text(_result!, key: const Key('result')),
      ],
    );
  }
}

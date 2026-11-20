import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:formidable/formidable.dart';
import 'package:formidable_cupertino/formidable_cupertino.dart';
import 'package:formidable_flutter/formidable_flutter.dart';

import 'survey.dart';
import 'survey.formidable_scope.dart';

/// The Dynamic Form guide with Cupertino widgets.
class SurveyCupertinoPage extends StatelessWidget {
  const SurveyCupertinoPage({super.key});

  @override
  Widget build(BuildContext context) => SurveyFormScope(
    child: const CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(middle: Text('Survey')),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: _SurveyBody(),
        ),
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
    NumberQuestion(:final key, :final label) =>
      FormidableCupertinoTextField<int>(
        key: Key('answer-$key'),
        field: form.answers.field<int>(key),
        placeholder: label,
        keyboardType: TextInputType.number,
      ),
    TextQuestion(:final key, :final label, :final required) =>
      required
          ? FormidableCupertinoTextField<String>(
              key: Key('answer-$key'),
              field: form.answers.field<String>(key),
              placeholder: label,
            )
          : FormidableCupertinoTextField<String?>(
              key: Key('answer-$key'),
              field: form.answers.field<String?>(key),
              placeholder: label,
            ),
    YesNoQuestion(:final key, :final label) => Row(
      key: Key('answer-$key'),
      children: [
        Expanded(child: Text(label)),
        FormidableCupertinoSwitch(field: form.answers.field<bool>(key)),
      ],
    ),
  };

  @override
  Widget build(BuildContext context) {
    final form = context.surveyForm;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 16,
      children: [
        FormidableCupertinoTextField(
          key: const Key('title'),
          field: form.title,
          placeholder: 'Survey title',
        ),
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
        CupertinoButton.tinted(
          onPressed: () => _load(form),
          child: Text(
            _questionnaire < 0 ? 'Load questions' : 'Switch questionnaire',
          ),
        ),
        CupertinoButton.filled(
          onPressed: () => _save(form),
          child: const Text('Save survey'),
        ),
        if (_result != null) Text(_result!, key: const Key('result')),
      ],
    );
  }
}

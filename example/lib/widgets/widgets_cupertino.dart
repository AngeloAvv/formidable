import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:formidable/formidable.dart';
import 'package:formidable_cupertino/formidable_cupertino.dart';

import 'cupertino_preferences.dart';
import 'cupertino_preferences.formidable_scope.dart';

/// Every Cupertino widget of `formidable_cupertino`, each bound to a Field of
/// the same Form. Errors show once a Field is touched, or after a submit.
class WidgetsCupertinoPage extends StatelessWidget {
  const WidgetsCupertinoPage({super.key});

  @override
  Widget build(BuildContext context) => CupertinoPreferencesFormScope(
    child: const CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(middle: Text('Cupertino widgets')),
      child: SafeArea(child: _Body()),
    ),
  );
}

class _Body extends StatefulWidget {
  const _Body();

  @override
  State<_Body> createState() => _BodyState();
}

class _BodyState extends State<_Body> {
  String? _result;

  Future<void> _submit(CupertinoPreferencesForm form) async {
    final result = switch (await form.submit()) {
      FormidableSubmitValid(:final value) => 'Saved ${value.name}.',
      FormidableSubmitInvalid() => 'Please fix the errors above.',
    };
    if (mounted) setState(() => _result = result);
  }

  @override
  Widget build(BuildContext context) {
    final form = context.cupertinoPreferencesForm;
    const segments = {
      'free': Text('Free'),
      'pro': Text('Pro'),
      'team': Text('Team'),
    };
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const _Label('Text field (String, with a clear button)'),
        FormidableCupertinoTextField(
          field: form.name,
          placeholder: 'Name',
          textInputAction: TextInputAction.next,
          // The suffix depends on the value: it shows once there is text.
          suffixBuilder: (context, control) => (control.value ?? '').isEmpty
              ? null
              : CupertinoButton(
                  key: const Key('clear-name'),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  minimumSize: Size.zero,
                  onPressed: control.clear,
                  child: const Icon(CupertinoIcons.clear_circled_solid),
                ),
        ),
        const _Label('Text field (int, through a Codec)'),
        FormidableCupertinoTextField(
          field: form.age,
          placeholder: 'Age',
          keyboardType: TextInputType.number,
        ),
        const _Label('Switch'),
        FormidableCupertinoSwitch(field: form.notifications),
        const _Label('Checkbox'),
        FormidableCupertinoCheckbox(field: form.newsletter),
        const _Label('Segmented control'),
        FormidableCupertinoSegmentedControl<String>(
          field: form.plan,
          children: segments,
        ),
        const _Label('Sliding segmented control'),
        FormidableCupertinoSlidingSegmentedControl<String>(
          field: form.billing,
          children: const {
            'monthly': Text('Monthly'),
            'yearly': Text('Yearly'),
          },
        ),
        const _Label('Radio group'),
        FormidableCupertinoRadioGroup<String>(
          field: form.size,
          child: const Row(
            spacing: 16,
            children: [
              Text('Small'),
              CupertinoRadio<String>(value: 'small'),
              Text('Large'),
              CupertinoRadio<String>(value: 'large'),
            ],
          ),
        ),
        const _Label('Slider'),
        FormidableCupertinoSlider(field: form.volume, max: 10, divisions: 10),
        const _Label('Date picker'),
        FormidableCupertinoDatePicker(
          field: form.born,
          mode: CupertinoDatePickerMode.date,
          height: 160,
        ),
        const _Label('Timer picker'),
        FormidableCupertinoTimerPicker(field: form.alarm, height: 160),
        const SizedBox(height: 16),
        CupertinoButton.filled(
          onPressed: () => _submit(form),
          child: const Text('Save'),
        ),
        if (_result != null) ...[
          const SizedBox(height: 16),
          Text(_result!, key: const Key('result')),
        ],
      ],
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 16, bottom: 6),
    child: Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        color: CupertinoColors.secondaryLabel,
      ),
    ),
  );
}

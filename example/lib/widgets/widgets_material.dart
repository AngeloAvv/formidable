import 'package:formidable/formidable.dart';
import 'package:formidable_flutter/formidable_flutter.dart';
import 'package:formidable_material/formidable_material.dart';
import 'package:material_ui/material_ui.dart';

import 'color_picker.dart';
import 'profile.dart';
import 'profile.formidable_scope.dart';

/// Shows every Material widget of `formidable_material`, each bound to one
/// Field of the `Profile` Schema.
class WidgetsMaterialPage extends StatelessWidget {
  const WidgetsMaterialPage({super.key});

  @override
  Widget build(BuildContext context) => ProfileFormScope(
    child: Scaffold(
      appBar: AppBar(title: const Text('Material widgets')),
      body: const _ProfileBody(),
    ),
  );
}

class _ProfileBody extends StatefulWidget {
  const _ProfileBody();

  @override
  State<_ProfileBody> createState() => _ProfileBodyState();
}

class _ProfileBodyState extends State<_ProfileBody> {
  String? _result;

  Future<void> _save(ProfileForm form) async {
    final result = switch (await form.submit()) {
      FormidableSubmitValid() => 'Saved.',
      FormidableSubmitInvalid() => 'Please fix the errors above.',
    };
    if (mounted) setState(() => _result = result);
  }

  @override
  Widget build(BuildContext context) {
    final form = context.profileForm;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        FormidableMaterialCheckboxListTile(
          field: form.acceptedTerms,
          title: const Text('I accept the terms'),
        ),
        FormidableMaterialSwitchListTile(
          field: form.notifications,
          title: const Text('Notifications'),
        ),
        const SizedBox(height: 16),
        FormidableMaterialTextField<String?>(
          field: form.nickname,
          decorationBuilder: (context, control) => InputDecoration(
            labelText: 'Nickname',
            border: const OutlineInputBorder(),
            suffixIcon: (control.value ?? '').isEmpty
                ? null
                : IconButton(
                    tooltip: 'Clear',
                    icon: const Icon(Icons.clear),
                    onPressed: control.clear,
                  ),
          ),
        ),
        const _Heading('Plan'),
        FormidableMaterialRadioGroup(
          field: form.plan,
          options: const [
            FormidableMaterialRadioOption(
              value: Plan.free,
              title: Text('Free'),
            ),
            FormidableMaterialRadioOption(
              value: Plan.plus,
              title: Text('Plus'),
            ),
            FormidableMaterialRadioOption(value: Plan.pro, title: Text('Pro')),
          ],
        ),
        const _Heading('Contact by email'),
        FormidableMaterialRadioGroup(
          field: form.contactByEmail,
          options: const [
            FormidableMaterialRadioOption(
              value: null,
              title: Text('No preference'),
            ),
            FormidableMaterialRadioOption(value: true, title: Text('Yes')),
            FormidableMaterialRadioOption(value: false, title: Text('No')),
          ],
        ),
        const _Heading('Volume'),
        FormidableMaterialSlider(
          field: form.volume,
          max: 10,
          divisions: 10,
          labelBuilder: (value) => '$value',
        ),
        const SizedBox(height: 16),
        FormidableMaterialDropdown<String>(
          field: form.country,
          decoration: const InputDecoration(
            labelText: 'Country',
            border: OutlineInputBorder(),
          ),
          items: const [
            DropdownMenuItem(value: 'IT', child: Text('Italy')),
            DropdownMenuItem(value: 'FR', child: Text('France')),
            DropdownMenuItem(value: 'DE', child: Text('Germany')),
          ],
        ),
        const SizedBox(height: 16),
        FormidableMaterialDatePicker(
          field: form.birthday,
          decoration: const InputDecoration(
            labelText: 'Birthday',
            border: OutlineInputBorder(),
          ),
          initialDate: DateTime(2000),
        ),
        const SizedBox(height: 16),
        FormidableMaterialTimePicker(
          field: form.reminder,
          decoration: const InputDecoration(
            labelText: 'Reminder',
            border: OutlineInputBorder(),
          ),
          initialTime: const TimeOfDay(hour: 9, minute: 0),
        ),
        const _Heading('Layout'),
        FormidableMaterialSegmentedButton(
          field: form.layout,
          segments: const [
            ButtonSegment(value: Layout.grid, label: Text('Grid')),
            ButtonSegment(value: Layout.list, label: Text('List')),
          ],
        ),
        const _Heading('Accent color'),
        FormidableColorPicker(
          field: form.accent,
          colors: const [Colors.red, Colors.green, Colors.blue],
        ),
        const _Heading('Rating'),
        FormidableFieldWidget<int, double>(
          field: form.rating,
          codec: const _RatingCodec(),
          builder: (context, control) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Slider(
                value: control.value ?? 0,
                divisions: 4,
                focusNode: control.focusNode,
                onChanged: (position) =>
                    control.didChange(position, touched: true),
              ),
              FormidableMaterialErrorLine(text: control.errorText),
            ],
          ),
        ),
        const SizedBox(height: 24),
        FilledButton(onPressed: () => _save(form), child: const Text('Save')),
        if (_result != null) ...[
          const SizedBox(height: 16),
          Text(_result!, key: const Key('result')),
        ],
      ],
    );
  }
}

class _Heading extends StatelessWidget {
  const _Heading(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 16),
    child: Text(text, style: Theme.of(context).textTheme.titleSmall),
  );
}

/// Maps a rating from 1 to 5 to a slider position from 0 to 1 and back.
class _RatingCodec extends FormidableCodec<int, double> {
  const _RatingCodec();

  @override
  double format(int value) => (value - 1) / 4;

  @override
  FormidableParseResult<int> parse(double input) =>
      FormidableParsedValue((input * 4).round() + 1);
}

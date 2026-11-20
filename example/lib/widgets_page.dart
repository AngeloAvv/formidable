import 'package:formidable/formidable.dart';
import 'package:formidable_material/formidable_material.dart';
import 'package:material_ui/material_ui.dart';

import 'profile.dart';
import 'profile.formidable_scope.dart';

/// Shows every Material widget of `formidable_material`, each bound to one
/// Field of the `Profile` Schema.
class WidgetsPage extends StatelessWidget {
  const WidgetsPage({super.key});

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
        FormidableCheckbox(
          field: form.acceptedTerms,
          title: const Text('I accept the terms'),
        ),
        FormidableSwitch(
          field: form.notifications,
          title: const Text('Notifications'),
        ),
        const _Heading('Plan'),
        FormidableRadioGroup(
          field: form.plan,
          options: const [
            FormidableRadioOption(value: Plan.free, title: Text('Free')),
            FormidableRadioOption(value: Plan.plus, title: Text('Plus')),
            FormidableRadioOption(value: Plan.pro, title: Text('Pro')),
          ],
        ),
        const _Heading('Contact by email'),
        FormidableRadioGroup(
          field: form.contactByEmail,
          options: const [
            FormidableRadioOption(value: null, title: Text('No preference')),
            FormidableRadioOption(value: true, title: Text('Yes')),
            FormidableRadioOption(value: false, title: Text('No')),
          ],
        ),
        const _Heading('Volume'),
        FormidableSlider(
          field: form.volume,
          max: 10,
          divisions: 10,
          labelBuilder: (value) => '$value',
        ),
        const SizedBox(height: 16),
        FormidableDropdown<String>(
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
        FormidableDatePicker(
          field: form.birthday,
          decoration: const InputDecoration(
            labelText: 'Birthday',
            border: OutlineInputBorder(),
          ),
          initialDate: DateTime(2000),
        ),
        const SizedBox(height: 16),
        FormidableTimePicker(
          field: form.reminder,
          decoration: const InputDecoration(
            labelText: 'Reminder',
            border: OutlineInputBorder(),
          ),
          initialTime: const TimeOfDay(hour: 9, minute: 0),
        ),
        const _Heading('Layout'),
        FormidableSegmentedButton(
          field: form.layout,
          segments: const [
            ButtonSegment(value: Layout.grid, label: Text('Grid')),
            ButtonSegment(value: Layout.list, label: Text('List')),
          ],
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

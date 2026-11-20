import 'package:formidable/formidable.dart';
import 'package:formidable_flutter/formidable_flutter.dart';
import 'package:formidable_material/formidable_material.dart';
import 'package:material_ui/material_ui.dart';

import 'wizard.dart';
import 'wizard.formidable_scope.dart';

/// A multi-step wizard with Material widgets.
///
/// The Form is one `BookingForm`, created once by the Form Scope, so what the
/// user typed in a step is still there when they come back. Every step is a
/// Nested Form: `next` submits just that step, and only the last step submits
/// the whole Form.
class WizardMaterialPage extends StatelessWidget {
  const WizardMaterialPage({super.key});

  @override
  Widget build(BuildContext context) => BookingFormScope(
    // Errors show only after a submit: a step is judged when the user presses
    // Next, not while they are still typing.
    errorDisplay: FormidableErrorDisplay.submit,
    child: Scaffold(
      appBar: AppBar(title: const Text('Wizard')),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: _WizardBody(),
      ),
    ),
  );
}

class _WizardBody extends StatefulWidget {
  const _WizardBody();

  @override
  State<_WizardBody> createState() => _WizardBodyState();
}

class _WizardBodyState extends State<_WizardBody> {
  int _step = 0;
  String? _result;

  Future<void> _next(BookingForm form) async {
    // Submitting a step touches its Fields and focuses the first invalid one.
    final advance = switch (await stepForm(form, _step).submit()) {
      FormidableSubmitValid() => true,
      FormidableSubmitInvalid() => false,
    };
    if (advance && mounted) setState(() => _step++);
  }

  Future<void> _book(BookingForm form) async {
    final result = switch (await form.submit()) {
      FormidableSubmitValid(:final value) => describeConfirmation(value),
      FormidableSubmitInvalid() => 'Please fix the errors above.',
    };
    if (mounted) setState(() => _result = result);
  }

  @override
  Widget build(BuildContext context) {
    final form = context.bookingForm;
    final last = _step == wizardStepTitles.length - 1;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 16,
      children: [
        Text(
          describeStep(_step),
          style: Theme.of(context).textTheme.titleMedium,
        ),
        LinearProgressIndicator(value: (_step + 1) / wizardStepTitles.length),
        ...switch (_step) {
          0 => _travelerStep(form),
          1 => _journeyStep(form),
          _ => _confirmStep(form),
        },
        Row(
          spacing: 12,
          children: [
            if (_step > 0)
              FilledButton.tonal(
                onPressed: () => setState(() => _step--),
                child: const Text('Back'),
              ),
            if (!last)
              FilledButton(
                onPressed: () => _next(form),
                child: const Text('Next'),
              )
            else
              FilledButton(
                onPressed: () => _book(form),
                child: const Text('Book'),
              ),
          ],
        ),
        if (_result != null) Text(_result!, key: const Key('result')),
      ],
    );
  }

  List<Widget> _travelerStep(BookingForm form) => [
    FormidableTextField(
      key: const Key('traveler-name'),
      field: form.traveler.name,
      decoration: const InputDecoration(
        labelText: 'Name',
        border: OutlineInputBorder(),
      ),
    ),
    FormidableTextField(
      key: const Key('traveler-email'),
      field: form.traveler.email,
      keyboardType: TextInputType.emailAddress,
      decoration: const InputDecoration(
        labelText: 'Email',
        border: OutlineInputBorder(),
      ),
    ),
  ];

  List<Widget> _journeyStep(BookingForm form) => [
    FormidableTextField(
      key: const Key('journey-from'),
      field: form.journey.from,
      decoration: const InputDecoration(
        labelText: 'From',
        border: OutlineInputBorder(),
      ),
    ),
    FormidableTextField(
      key: const Key('journey-to'),
      field: form.journey.to,
      decoration: const InputDecoration(
        labelText: 'To',
        border: OutlineInputBorder(),
      ),
    ),
    FormidableTextField(
      key: const Key('journey-passengers'),
      field: form.journey.passengers,
      keyboardType: TextInputType.number,
      decoration: const InputDecoration(
        labelText: 'Passengers',
        border: OutlineInputBorder(),
      ),
    ),
  ];

  List<Widget> _confirmStep(BookingForm form) => [
    FormidableFormBuilder<BookingForm>(
      builder: (context, _) => Text(describeBooking(form)),
    ),
    FormidableCheckbox(
      field: form.confirmation.acceptedTerms,
      title: const Text('I accept the terms'),
    ),
  ];
}

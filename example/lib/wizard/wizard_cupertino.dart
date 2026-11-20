import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:formidable/formidable.dart';
import 'package:formidable_cupertino/formidable_cupertino.dart';
import 'package:formidable_flutter/formidable_flutter.dart';

import 'wizard.dart';
import 'wizard.formidable_scope.dart';

/// The wizard guide with Cupertino widgets: the same Schema, Form and step
/// logic as the Material page.
class WizardCupertinoPage extends StatelessWidget {
  const WizardCupertinoPage({super.key});

  @override
  Widget build(BuildContext context) => BookingFormScope(
    // Errors show only after a submit: a step is judged when the user presses
    // Next, not while they are still typing.
    errorDisplay: FormidableErrorDisplay.submit,
    child: const CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(middle: Text('Wizard')),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: _WizardBody(),
        ),
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
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        ...switch (_step) {
          0 => _travelerStep(form),
          1 => _journeyStep(form),
          _ => _confirmStep(form),
        },
        Row(
          spacing: 12,
          children: [
            if (_step > 0)
              CupertinoButton.tinted(
                onPressed: () => setState(() => _step--),
                child: const Text('Back'),
              ),
            if (!last)
              CupertinoButton.filled(
                onPressed: () => _next(form),
                child: const Text('Next'),
              )
            else
              CupertinoButton.filled(
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
    FormidableCupertinoTextField(
      key: const Key('traveler-name'),
      field: form.traveler.name,
      placeholder: 'Name',
    ),
    FormidableCupertinoTextField(
      key: const Key('traveler-email'),
      field: form.traveler.email,
      placeholder: 'Email',
      keyboardType: TextInputType.emailAddress,
    ),
  ];

  List<Widget> _journeyStep(BookingForm form) => [
    FormidableCupertinoTextField(
      key: const Key('journey-from'),
      field: form.journey.from,
      placeholder: 'From',
    ),
    FormidableCupertinoTextField(
      key: const Key('journey-to'),
      field: form.journey.to,
      placeholder: 'To',
    ),
    FormidableCupertinoTextField(
      key: const Key('journey-passengers'),
      field: form.journey.passengers,
      placeholder: 'Passengers',
      keyboardType: TextInputType.number,
    ),
  ];

  List<Widget> _confirmStep(BookingForm form) => [
    BookingFormBuilder(
      builder: (context, _) => Text(describeBooking(form)),
    ),
    Row(
      spacing: 12,
      children: [
        FormidableCupertinoCheckbox(field: form.confirmation.acceptedTerms),
        const Text('I accept the terms'),
      ],
    ),
  ];
}

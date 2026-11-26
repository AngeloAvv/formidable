import 'package:formidable/formidable.dart';

part 'wizard.formidable.dart';

/// Step 1 of the wizard. Every step is a Nested Form of [Booking], so each one
/// can be submitted on its own while the whole Form stays one Form.
@Formidable()
class Traveler {
  const Traveler({required this.name, required this.email});

  @Trim()
  @MinLength(2)
  final String name;

  @Trim()
  @Email()
  final String email;
}

/// Step 2. `@Different` is a cross-field rule: the error lands on `to`.
@Formidable()
class Journey {
  const Journey({
    required this.from,
    required this.to,
    required this.passengers,
  });

  @Trim()
  @MinLength(2)
  final String from;

  @Trim()
  @MinLength(2)
  @Different(#from)
  final String to;

  @Min(1)
  @Max(9)
  final int passengers;
}

/// Step 3.
@Formidable()
class Confirmation {
  const Confirmation({this.acceptedTerms = false});

  @IsTrue()
  final bool acceptedTerms;
}

/// The Schema of the wizard guide: one Nested Form per step.
@Formidable()
class Booking {
  const Booking({
    required this.traveler,
    required this.journey,
    required this.confirmation,
  });

  final Traveler traveler;
  final Journey journey;
  final Confirmation confirmation;
}

const wizardStepTitles = ['Traveler', 'Journey', 'Confirm'];

/// "Step 2 of 3: Journey".
String describeStep(int step) =>
    'Step ${step + 1} of ${wizardStepTitles.length}: ${wizardStepTitles[step]}';

/// The review shown on the last step.
String describeBooking(BookingForm form) =>
    '${form.traveler.name.valueOrNull}, ${form.journey.from.valueOrNull} to '
    '${form.journey.to.valueOrNull}, ${form.journey.passengers.valueOrNull} passengers';

/// What the wizard says once the whole Form is valid.
String describeConfirmation(Booking booking) =>
    'Booked for ${booking.traveler.name}: '
    '${booking.journey.from} to ${booking.journey.to}.';

/// The Form of the step at [index], as a Form of any Schema: every Form can be
/// submitted on its own.
FormidableForm<Object?> stepForm(BookingForm form, int index) =>
    switch (index) {
      0 => form.traveler,
      1 => form.journey,
      _ => form.confirmation,
    };

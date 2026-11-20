import 'package:formidable/formidable.dart';

import '../format.dart';

/// Messages for the errors of the date Validators.
abstract mixin class FormidableDateMessages {
  /// The date is not after the reference, or not on or after it when inclusive.
  String after(DateTime reference, bool inclusive);

  /// The date is not before the reference, or not on or before it when inclusive.
  String before(DateTime reference, bool inclusive);

  /// The date is not in the future.
  String future();

  /// The date is not in the past.
  String past();

  /// The date is outside the days from [start] to [end].
  String dateBetween(DateTime start, DateTime end);

  /// The date is not on the day of [date].
  String sameDay(DateTime date);

  /// The person is younger than [minAge] years.
  String minAge(int minAge);

  /// The person is older than [maxAge] years.
  String maxAge(int maxAge);

  /// The message for a date error, or null for any other error.
  String? dateMessageOf(FormidableValidationError error) => switch (error) {
    FormidableAfterError(:final reference, :final inclusive) => after(
      reference,
      inclusive,
    ),
    FormidableBeforeError(:final reference, :final inclusive) => before(
      reference,
      inclusive,
    ),
    FormidableFutureError() => future(),
    FormidablePastError() => past(),
    FormidableDateBetweenError(:final start, :final end) => dateBetween(
      start,
      end,
    ),
    FormidableSameDayError(:final date) => sameDay(date),
    FormidableMinAgeError(:final minAge) => this.minAge(minAge),
    FormidableMaxAgeError(:final maxAge) => this.maxAge(maxAge),
    _ => null,
  };
}

mixin FormidableDateMessagesEn implements FormidableDateMessages {
  @override
  String after(DateTime reference, bool inclusive) => inclusive
      ? 'Must be on or after ${formatDateIso(reference)}.'
      : 'Must be after ${formatDateIso(reference)}.';

  @override
  String before(DateTime reference, bool inclusive) => inclusive
      ? 'Must be on or before ${formatDateIso(reference)}.'
      : 'Must be before ${formatDateIso(reference)}.';

  @override
  String future() => 'Must be in the future.';

  @override
  String past() => 'Must be in the past.';

  @override
  String dateBetween(DateTime start, DateTime end) =>
      'Must be between ${formatDateIso(start)} and ${formatDateIso(end)}.';

  @override
  String sameDay(DateTime date) => 'Must be on ${formatDateIso(date)}.';

  @override
  String minAge(int minAge) =>
      'You must be at least $minAge ${minAge == 1 ? 'year' : 'years'} old.';

  @override
  String maxAge(int maxAge) =>
      'You must be at most $maxAge ${maxAge == 1 ? 'year' : 'years'} old.';
}

mixin FormidableDateMessagesIt implements FormidableDateMessages {
  @override
  String after(DateTime reference, bool inclusive) => inclusive
      ? 'Deve essere uguale o successiva al ${formatDateSlashes(reference)}.'
      : 'Deve essere successiva al ${formatDateSlashes(reference)}.';

  @override
  String before(DateTime reference, bool inclusive) => inclusive
      ? 'Deve essere uguale o precedente al ${formatDateSlashes(reference)}.'
      : 'Deve essere precedente al ${formatDateSlashes(reference)}.';

  @override
  String future() => 'Deve essere una data futura.';

  @override
  String past() => 'Deve essere una data passata.';

  @override
  String dateBetween(DateTime start, DateTime end) =>
      'Deve essere compresa tra il ${formatDateSlashes(start)} e il ${formatDateSlashes(end)}.';

  @override
  String sameDay(DateTime date) => 'Deve essere il ${formatDateSlashes(date)}.';

  @override
  String minAge(int minAge) =>
      'Devi avere almeno $minAge ${minAge == 1 ? 'anno' : 'anni'}.';

  @override
  String maxAge(int maxAge) =>
      'Puoi avere al massimo $maxAge ${maxAge == 1 ? 'anno' : 'anni'}.';
}

mixin FormidableDateMessagesEs implements FormidableDateMessages {
  @override
  String after(DateTime reference, bool inclusive) => inclusive
      ? 'Debe ser igual o posterior al ${formatDateSlashes(reference)}.'
      : 'Debe ser posterior al ${formatDateSlashes(reference)}.';

  @override
  String before(DateTime reference, bool inclusive) => inclusive
      ? 'Debe ser igual o anterior al ${formatDateSlashes(reference)}.'
      : 'Debe ser anterior al ${formatDateSlashes(reference)}.';

  @override
  String future() => 'Debe ser una fecha futura.';

  @override
  String past() => 'Debe ser una fecha pasada.';

  @override
  String dateBetween(DateTime start, DateTime end) =>
      'Debe estar entre el ${formatDateSlashes(start)} y el ${formatDateSlashes(end)}.';

  @override
  String sameDay(DateTime date) => 'Debe ser el ${formatDateSlashes(date)}.';

  @override
  String minAge(int minAge) =>
      'Debes tener al menos $minAge ${minAge == 1 ? 'año' : 'años'}.';

  @override
  String maxAge(int maxAge) =>
      'Debes tener como máximo $maxAge ${maxAge == 1 ? 'año' : 'años'}.';
}

mixin FormidableDateMessagesFr implements FormidableDateMessages {
  @override
  String after(DateTime reference, bool inclusive) => inclusive
      ? 'Doit être égale ou postérieure au ${formatDateSlashes(reference)}.'
      : 'Doit être postérieure au ${formatDateSlashes(reference)}.';

  @override
  String before(DateTime reference, bool inclusive) => inclusive
      ? 'Doit être égale ou antérieure au ${formatDateSlashes(reference)}.'
      : 'Doit être antérieure au ${formatDateSlashes(reference)}.';

  @override
  String future() => 'Doit être une date future.';

  @override
  String past() => 'Doit être une date passée.';

  @override
  String dateBetween(DateTime start, DateTime end) =>
      'Doit être comprise entre le ${formatDateSlashes(start)} et le ${formatDateSlashes(end)}.';

  @override
  String sameDay(DateTime date) => 'Doit être le ${formatDateSlashes(date)}.';

  @override
  String minAge(int minAge) =>
      'Vous devez avoir au moins $minAge ${minAge <= 1 ? 'an' : 'ans'}.';

  @override
  String maxAge(int maxAge) =>
      'Vous devez avoir au plus $maxAge ${maxAge <= 1 ? 'an' : 'ans'}.';
}

mixin FormidableDateMessagesDe implements FormidableDateMessages {
  @override
  String after(DateTime reference, bool inclusive) => inclusive
      ? 'Muss am ${formatDateDots(reference)} oder danach liegen.'
      : 'Muss nach dem ${formatDateDots(reference)} liegen.';

  @override
  String before(DateTime reference, bool inclusive) => inclusive
      ? 'Muss am ${formatDateDots(reference)} oder davor liegen.'
      : 'Muss vor dem ${formatDateDots(reference)} liegen.';

  @override
  String future() => 'Muss in der Zukunft liegen.';

  @override
  String past() => 'Muss in der Vergangenheit liegen.';

  @override
  String dateBetween(DateTime start, DateTime end) =>
      'Muss zwischen dem ${formatDateDots(start)} und dem ${formatDateDots(end)} liegen.';

  @override
  String sameDay(DateTime date) => 'Muss der ${formatDateDots(date)} sein.';

  @override
  String minAge(int minAge) =>
      'Sie müssen mindestens $minAge ${minAge == 1 ? 'Jahr' : 'Jahre'} alt sein.';

  @override
  String maxAge(int maxAge) =>
      'Sie dürfen höchstens $maxAge ${maxAge == 1 ? 'Jahr' : 'Jahre'} alt sein.';
}

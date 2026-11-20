import '../validation/validation_error.dart';
import '../validation/validator.dart';
import 'clock.dart';

// Date Validators. They read the current time from [FormidableClock].
//
// A Validator that compares "days" looks at the calendar components of both
// dates as written (year, month, day), so the time of day and the time zone
// offset play no part. A Validator that compares "instants" uses the exact
// moment.
//
// Dates cannot be const in Dart, so a constant date is an ISO 8601 string,
// parsed when the Validator runs (`'2024-01-31'`, `'2024-01-31T09:30:00'`).
// A string that does not parse throws a [FormatException].

int _dayKey(DateTime date) => date.year * 10000 + date.month * 100 + date.day;

DateTime _startOfDay(DateTime date) => date.isUtc
    ? DateTime.utc(date.year, date.month, date.day)
    : DateTime(date.year, date.month, date.day);

/// Whether [iso] names a day without a time of day.
bool _isDateOnly(String iso) => !iso.contains('T') && !iso.contains(' ');

enum _Reference { date, now, today }

/// How [After] and [Before] resolve their reference, shared by both.
({DateTime reference, bool byDay}) _resolve(_Reference kind, String? iso) {
  switch (kind) {
    case _Reference.date:
      final date = DateTime.parse(iso!);
      return (
        reference: _isDateOnly(iso) ? _startOfDay(date) : date,
        byDay: _isDateOnly(iso),
      );
    case _Reference.now:
      return (reference: FormidableClock.now(), byDay: false);
    case _Reference.today:
      return (reference: _startOfDay(FormidableClock.now()), byDay: true);
  }
}

/// Negative when [value] is before [reference], zero when equal, positive when
/// after, comparing days or instants.
int _compare(DateTime value, DateTime reference, {required bool byDay}) => byDay
    ? _dayKey(value).compareTo(_dayKey(reference))
    : value.compareTo(reference);

/// The value is not after the reference of an [After].
final class FormidableAfterError extends FormidableValidationError {
  const FormidableAfterError({
    required this.reference,
    required this.inclusive,
    required this.actual,
  });

  /// The date or instant the value had to follow.
  final DateTime reference;

  /// Whether the reference itself was accepted.
  final bool inclusive;

  /// The rejected value.
  final DateTime actual;

  @override
  List<Object?> get props => [reference, inclusive, actual];

  @override
  String toString() => inclusive
      ? 'Must not be before ${reference.toIso8601String()}.'
      : 'Must be after ${reference.toIso8601String()}.';
}

/// The date must be after a constant date, now or today.
///
/// A date-only constant (`'2024-01-31'`) and [After.today] compare calendar
/// days; a constant with a time and [After.now] compare instants. With
/// [inclusive], the reference itself is accepted.
class After extends FormidableValidator<DateTime> {
  const After(String date, {this.inclusive = false})
    : _date = date,
      _kind = _Reference.date;

  const After.now({this.inclusive = false})
    : _date = null,
      _kind = _Reference.now;

  const After.today({this.inclusive = false})
    : _date = null,
      _kind = _Reference.today;

  final bool inclusive;
  final String? _date;
  final _Reference _kind;

  @override
  List<FormidableValidationError> validate(DateTime value) {
    final (:reference, :byDay) = _resolve(_kind, _date);
    final order = _compare(value, reference, byDay: byDay);
    return (inclusive ? order >= 0 : order > 0)
        ? const []
        : [
            FormidableAfterError(
              reference: reference,
              inclusive: inclusive,
              actual: value,
            ),
          ];
  }
}

/// The value is not before the reference of a [Before].
final class FormidableBeforeError extends FormidableValidationError {
  const FormidableBeforeError({
    required this.reference,
    required this.inclusive,
    required this.actual,
  });

  /// The date or instant the value had to precede.
  final DateTime reference;

  /// Whether the reference itself was accepted.
  final bool inclusive;

  /// The rejected value.
  final DateTime actual;

  @override
  List<Object?> get props => [reference, inclusive, actual];

  @override
  String toString() => inclusive
      ? 'Must not be after ${reference.toIso8601String()}.'
      : 'Must be before ${reference.toIso8601String()}.';
}

/// The date must be before a constant date, now or today. It takes the same
/// constructors and rules as [After].
class Before extends FormidableValidator<DateTime> {
  const Before(String date, {this.inclusive = false})
    : _date = date,
      _kind = _Reference.date;

  const Before.now({this.inclusive = false})
    : _date = null,
      _kind = _Reference.now;

  const Before.today({this.inclusive = false})
    : _date = null,
      _kind = _Reference.today;

  final bool inclusive;
  final String? _date;
  final _Reference _kind;

  @override
  List<FormidableValidationError> validate(DateTime value) {
    final (:reference, :byDay) = _resolve(_kind, _date);
    final order = _compare(value, reference, byDay: byDay);
    return (inclusive ? order <= 0 : order < 0)
        ? const []
        : [
            FormidableBeforeError(
              reference: reference,
              inclusive: inclusive,
              actual: value,
            ),
          ];
  }
}

/// The value is not in the future.
final class FormidableFutureError extends FormidableValidationError {
  const FormidableFutureError({required this.now, required this.actual});

  /// The time the clock gave when the value was judged.
  final DateTime now;

  final DateTime actual;

  @override
  List<Object?> get props => [now, actual];

  @override
  String toString() => 'Must be in the future.';
}

/// The date must be later than now. It is named `FutureDate` because `Future`
/// is a Dart core class.
class FutureDate extends FormidableValidator<DateTime> {
  const FutureDate();

  @override
  List<FormidableValidationError> validate(DateTime value) {
    final now = FormidableClock.now();
    return value.isAfter(now)
        ? const []
        : [FormidableFutureError(now: now, actual: value)];
  }
}

/// The value is not in the past.
final class FormidablePastError extends FormidableValidationError {
  const FormidablePastError({required this.now, required this.actual});

  /// The time the clock gave when the value was judged.
  final DateTime now;

  final DateTime actual;

  @override
  List<Object?> get props => [now, actual];

  @override
  String toString() => 'Must be in the past.';
}

/// The date must be earlier than now. It is named `PastDate` to pair with
/// [FutureDate].
class PastDate extends FormidableValidator<DateTime> {
  const PastDate();

  @override
  List<FormidableValidationError> validate(DateTime value) {
    final now = FormidableClock.now();
    return value.isBefore(now)
        ? const []
        : [FormidablePastError(now: now, actual: value)];
  }
}

/// The value is outside the days of a [DateBetween].
final class FormidableDateBetweenError extends FormidableValidationError {
  const FormidableDateBetweenError({
    required this.start,
    required this.end,
    required this.actual,
  });

  final DateTime start;
  final DateTime end;
  final DateTime actual;

  @override
  List<Object?> get props => [start, end, actual];

  @override
  String toString() =>
      'Must be between ${start.toIso8601String()} and '
      '${end.toIso8601String()}.';
}

/// The day of the date must be [start], [end] or between them. The constants
/// are ISO 8601 strings and only their day counts.
class DateBetween extends FormidableValidator<DateTime> {
  const DateBetween(this.start, this.end);

  final String start;
  final String end;

  @override
  List<FormidableValidationError> validate(DateTime value) {
    final from = DateTime.parse(start);
    final to = DateTime.parse(end);
    final day = _dayKey(value);
    return day >= _dayKey(from) && day <= _dayKey(to)
        ? const []
        : [
            FormidableDateBetweenError(
              start: _startOfDay(from),
              end: _startOfDay(to),
              actual: value,
            ),
          ];
  }
}

/// The value is not on the day of a [SameDay].
final class FormidableSameDayError extends FormidableValidationError {
  const FormidableSameDayError({required this.date, required this.actual});

  /// The start of the day the value had to fall on.
  final DateTime date;

  final DateTime actual;

  @override
  List<Object?> get props => [date, actual];

  @override
  String toString() => 'Must be on ${date.toIso8601String()}.';
}

/// The date must fall on a given day, whatever the time. The day is a constant
/// ISO 8601 string, or today with [SameDay.today].
class SameDay extends FormidableValidator<DateTime> {
  const SameDay(String date) : _date = date;

  const SameDay.today() : _date = null;

  final String? _date;

  @override
  List<FormidableValidationError> validate(DateTime value) {
    final day = _startOfDay(
      _date == null ? FormidableClock.now() : DateTime.parse(_date),
    );
    return _dayKey(value) == _dayKey(day)
        ? const []
        : [FormidableSameDayError(date: day, actual: value)];
  }
}

/// The age in whole years on [now], for someone born on [birth].
int _ageOn(DateTime now, DateTime birth) {
  final birthdayPassed =
      now.month > birth.month ||
      (now.month == birth.month && now.day >= birth.day);
  return now.year - birth.year - (birthdayPassed ? 0 : 1);
}

/// The person is younger than the age of a [MinAge].
final class FormidableMinAgeError extends FormidableValidationError {
  const FormidableMinAgeError({required this.minAge, required this.actualAge});

  final int minAge;

  /// The age in whole years, negative for a birth date in the future.
  final int actualAge;

  @override
  List<Object?> get props => [minAge, actualAge];

  @override
  String toString() => 'Must be at least $minAge years old (got $actualAge).';
}

/// The date of birth must give an age of at least [minAge] years today.
///
/// A birthday counts from the day itself, and a 29 February birthday is
/// reached on 1 March in a common year.
class MinAge extends FormidableValidator<DateTime> {
  const MinAge(this.minAge);

  final int minAge;

  @override
  List<FormidableValidationError> validate(DateTime value) {
    final age = _ageOn(FormidableClock.now(), value);
    return age >= minAge
        ? const []
        : [FormidableMinAgeError(minAge: minAge, actualAge: age)];
  }
}

/// The person is older than the age of a [MaxAge].
final class FormidableMaxAgeError extends FormidableValidationError {
  const FormidableMaxAgeError({required this.maxAge, required this.actualAge});

  final int maxAge;
  final int actualAge;

  @override
  List<Object?> get props => [maxAge, actualAge];

  @override
  String toString() => 'Must be at most $maxAge years old (got $actualAge).';
}

/// The date of birth must give an age of at most [maxAge] years today. The
/// person is [maxAge] until the day before the next birthday.
class MaxAge extends FormidableValidator<DateTime> {
  const MaxAge(this.maxAge);

  final int maxAge;

  @override
  List<FormidableValidationError> validate(DateTime value) {
    final age = _ageOn(FormidableClock.now(), value);
    return age <= maxAge
        ? const []
        : [FormidableMaxAgeError(maxAge: maxAge, actualAge: age)];
  }
}

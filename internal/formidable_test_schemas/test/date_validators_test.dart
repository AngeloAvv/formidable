import 'package:formidable/formidable.dart';
import 'package:formidable_test_schemas/date_validators.dart';
import 'package:test/test.dart';

/// "Now" for every test: Saturday 15 June 2024, noon.
final _now = DateTime(2024, 6, 15, 12);

void main() {
  setUp(() => FormidableClock.source = () => _now);
  tearDown(FormidableClock.reset);

  List<FormidableValidationError> errorsOf(
    FormidableField<DateTime?> Function(DateRulesForm form) pick,
    DateTime value,
  ) {
    final field = pick(DateRulesForm())..setValue(value);
    return field.state.errors;
  }

  group('FormidableClock', () {
    test('defaults to the system clock', () {
      FormidableClock.reset();
      final before = DateTime.now();

      final now = FormidableClock.now();

      expect(now.isBefore(before), isFalse);
      expect(now.difference(before).inMinutes, 0);
    });

    test('withClock overrides it only while the body runs', () {
      final inside = FormidableClock.withClock(
        () => DateTime(2000),
        FormidableClock.now,
      );

      expect(inside, DateTime(2000));
      expect(FormidableClock.now(), _now);
    });

    test('withClock restores the clock when the body throws', () {
      expect(
        () => FormidableClock.withClock(() => DateTime(2000), () => throw 1),
        throwsA(1),
      );

      expect(FormidableClock.now(), _now);
    });
  });

  group('After', () {
    test('compares calendar days for a date-only constant', () {
      expect(errorsOf((f) => f.afterDay, DateTime(2024, 1, 2)), isEmpty);
      expect(errorsOf((f) => f.afterDay, DateTime(2024, 1, 1, 23)), [
        FormidableAfterError(
          reference: DateTime(2024, 1, 1),
          inclusive: false,
          actual: DateTime(2024, 1, 1, 23),
        ),
      ]);
      expect(errorsOf((f) => f.afterDay, DateTime(2023, 12, 31)), hasLength(1));
    });

    test('inclusive accepts the same day', () {
      expect(
        errorsOf((f) => f.afterDayInclusive, DateTime(2024, 1, 1, 23)),
        isEmpty,
      );
      expect(
        errorsOf((f) => f.afterDayInclusive, DateTime(2023, 12, 31, 23)),
        hasLength(1),
      );
    });

    test('compares instants for a constant with a time', () {
      expect(
        errorsOf((f) => f.afterInstant, DateTime(2024, 1, 1, 9, 0, 1)),
        isEmpty,
      );
      expect(
        errorsOf((f) => f.afterInstant, DateTime(2024, 1, 1, 9)),
        hasLength(1),
      );
    });

    test('now compares instants against the clock', () {
      expect(
        errorsOf((f) => f.afterNow, _now.add(const Duration(seconds: 1))),
        isEmpty,
      );
      expect(errorsOf((f) => f.afterNow, _now), [
        FormidableAfterError(reference: _now, inclusive: false, actual: _now),
      ]);
    });

    test('today compares calendar days against the clock', () {
      expect(errorsOf((f) => f.afterToday, DateTime(2024, 6, 16)), isEmpty);
      expect(
        errorsOf((f) => f.afterToday, DateTime(2024, 6, 15, 23)),
        hasLength(1),
      );
    });

    test('follows a clock that moves', () {
      expect(errorsOf((f) => f.afterToday, DateTime(2024, 6, 16)), isEmpty);

      FormidableClock.source = () => DateTime(2024, 6, 17);

      expect(
        errorsOf((f) => f.afterToday, DateTime(2024, 6, 16)),
        hasLength(1),
      );
    });
  });

  group('Before', () {
    test('compares calendar days for a date-only constant', () {
      expect(errorsOf((f) => f.beforeDay, DateTime(2023, 12, 31, 23)), isEmpty);
      expect(errorsOf((f) => f.beforeDay, DateTime(2024, 1, 1)), [
        FormidableBeforeError(
          reference: DateTime(2024, 1, 1),
          inclusive: false,
          actual: DateTime(2024, 1, 1),
        ),
      ]);
    });

    test('now inclusive accepts the very instant', () {
      expect(errorsOf((f) => f.beforeNowInclusive, _now), isEmpty);
      expect(
        errorsOf(
          (f) => f.beforeNowInclusive,
          _now.add(const Duration(seconds: 1)),
        ),
        hasLength(1),
      );
    });

    test('today inclusive accepts the whole of today', () {
      expect(
        errorsOf((f) => f.beforeTodayInclusive, DateTime(2024, 6, 15, 23)),
        isEmpty,
      );
      expect(
        errorsOf((f) => f.beforeTodayInclusive, DateTime(2024, 6, 16)),
        hasLength(1),
      );
    });
  });

  group('FutureDate and PastDate', () {
    test('FutureDate needs an instant after now', () {
      expect(
        errorsOf((f) => f.future, _now.add(const Duration(minutes: 1))),
        isEmpty,
      );
      expect(errorsOf((f) => f.future, _now), [
        FormidableFutureError(now: _now, actual: _now),
      ]);
    });

    test('PastDate needs an instant before now', () {
      expect(
        errorsOf((f) => f.past, _now.subtract(const Duration(minutes: 1))),
        isEmpty,
      );
      expect(errorsOf((f) => f.past, _now), [
        FormidablePastError(now: _now, actual: _now),
      ]);
    });
  });

  test('DateBetween includes both days', () {
    expect(errorsOf((f) => f.between, DateTime(2024, 3, 1)), isEmpty);
    expect(errorsOf((f) => f.between, DateTime(2024, 3, 31, 23, 59)), isEmpty);
    expect(errorsOf((f) => f.between, DateTime(2024, 4, 1)), [
      FormidableDateBetweenError(
        start: DateTime(2024, 3, 1),
        end: DateTime(2024, 3, 31),
        actual: DateTime(2024, 4, 1),
      ),
    ]);
    expect(errorsOf((f) => f.between, DateTime(2024, 2, 29, 23)), hasLength(1));
  });

  group('SameDay', () {
    test('matches the day of a constant, whatever the time', () {
      expect(
        errorsOf((f) => f.sameDay, DateTime(2024, 6, 15, 23, 59)),
        isEmpty,
      );
      expect(errorsOf((f) => f.sameDay, DateTime(2024, 6, 16)), [
        FormidableSameDayError(
          date: DateTime(2024, 6, 15),
          actual: DateTime(2024, 6, 16),
        ),
      ]);
    });

    test('today matches the day of the clock', () {
      expect(
        errorsOf((f) => f.sameDayAsToday, DateTime(2024, 6, 15, 1)),
        isEmpty,
      );
      expect(
        errorsOf((f) => f.sameDayAsToday, DateTime(2024, 6, 14)),
        hasLength(1),
      );
    });
  });

  group('MinAge and MaxAge', () {
    test('a birthday counts on the day itself', () {
      // Turns 18 on 15 June 2024.
      expect(errorsOf((f) => f.minAge, DateTime(2006, 6, 15, 18)), isEmpty);
      expect(errorsOf((f) => f.minAge, DateTime(2006, 6, 16)), [
        const FormidableMinAgeError(minAge: 18, actualAge: 17),
      ]);
    });

    test('a birth date in the future has a negative age', () {
      expect(errorsOf((f) => f.minAge, DateTime(2025, 1, 1)), [
        const FormidableMinAgeError(minAge: 18, actualAge: -1),
      ]);
    });

    test('MaxAge rejects the day after the birthday of the limit', () {
      // Turns 66 on 15 June 2024: 65 is still allowed until the day before.
      expect(errorsOf((f) => f.maxAge, DateTime(1958, 6, 16)), isEmpty);
      expect(errorsOf((f) => f.maxAge, DateTime(1958, 6, 15)), [
        const FormidableMaxAgeError(maxAge: 65, actualAge: 66),
      ]);
    });

    test('a 29 February birthday is reached on 1 March', () {
      FormidableClock.source = () => DateTime(2026, 2, 28);
      expect(errorsOf((f) => f.minAge, DateTime(2008, 2, 29)), hasLength(1));

      FormidableClock.source = () => DateTime(2026, 3);
      expect(errorsOf((f) => f.minAge, DateTime(2008, 2, 29)), isEmpty);
    });
  });
}

import 'package:formidable/formidable.dart';

part 'date_validators.formidable.dart';

/// One Field per built-in date Validator.
@Formidable()
class DateRules {
  const DateRules({
    this.afterDay,
    this.afterDayInclusive,
    this.beforeDay,
    this.afterInstant,
    this.afterNow,
    this.beforeNowInclusive,
    this.afterToday,
    this.beforeTodayInclusive,
    this.future,
    this.past,
    this.between,
    this.sameDay,
    this.sameDayAsToday,
    this.minAge,
    this.maxAge,
  });

  @After('2024-01-01')
  final DateTime? afterDay;

  @After('2024-01-01', inclusive: true)
  final DateTime? afterDayInclusive;

  @Before('2024-01-01')
  final DateTime? beforeDay;

  @After('2024-01-01T09:00:00')
  final DateTime? afterInstant;

  @After.now()
  final DateTime? afterNow;

  @Before.now(inclusive: true)
  final DateTime? beforeNowInclusive;

  @After.today()
  final DateTime? afterToday;

  @Before.today(inclusive: true)
  final DateTime? beforeTodayInclusive;

  @FutureDate()
  final DateTime? future;

  @PastDate()
  final DateTime? past;

  @DateBetween('2024-03-01', '2024-03-31')
  final DateTime? between;

  @SameDay('2024-06-15')
  final DateTime? sameDay;

  @SameDay.today()
  final DateTime? sameDayAsToday;

  @MinAge(18)
  final DateTime? minAge;

  @MaxAge(65)
  final DateTime? maxAge;
}

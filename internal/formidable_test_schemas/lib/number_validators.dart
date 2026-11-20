import 'package:formidable/formidable.dart';

part 'number_validators.formidable.dart';

/// One Field per built-in number Validator.
@Formidable()
class NumberRules {
  const NumberRules({
    this.min,
    this.minExclusive,
    this.max,
    this.maxExclusive,
    this.range,
    this.positive,
    this.positiveOrZero,
    this.negative,
    this.negativeOrZero,
    this.nonZero,
    this.multipleOf,
    this.multipleOfDecimal,
    this.even,
    this.odd,
    this.decimalPlaces,
    this.digits,
    this.minDigits,
    this.maxDigits,
    this.port,
  });

  @Min(10)
  final int? min;

  @Min(10, exclusive: true)
  final double? minExclusive;

  @Max(10)
  final int? max;

  @Max(10, exclusive: true)
  final double? maxExclusive;

  @Range(1, 5)
  final int? range;

  @Positive()
  final int? positive;

  @PositiveOrZero()
  final int? positiveOrZero;

  @Negative()
  final int? negative;

  @NegativeOrZero()
  final int? negativeOrZero;

  @NonZero()
  final double? nonZero;

  @MultipleOf(5)
  final int? multipleOf;

  @MultipleOf(0.1)
  final double? multipleOfDecimal;

  @Even()
  final int? even;

  @Odd()
  final int? odd;

  @DecimalPlaces(2)
  final double? decimalPlaces;

  @Digits(3)
  final int? digits;

  @MinDigits(2)
  final int? minDigits;

  @MaxDigits(2)
  final int? maxDigits;

  @Port()
  final int? port;
}

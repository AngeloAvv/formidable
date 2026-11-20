import 'package:formidable/formidable.dart';
import 'package:formidable_test_schemas/number_validators.dart';
import 'package:test/test.dart';

void main() {
  /// Writes [value] to the Field picked by [pick] and returns its errors.
  List<FormidableValidationError> errorsOf<T extends Object>(
    FormidableField<T?> Function(NumberRulesForm form) pick,
    T value,
  ) {
    final field = pick(NumberRulesForm())..setValue(value);
    return field.state.errors;
  }

  group('Min', () {
    test('accepts the bound and above, rejects below', () {
      expect(errorsOf((f) => f.min, 10), isEmpty);
      expect(errorsOf((f) => f.min, 11), isEmpty);
      expect(errorsOf((f) => f.min, 9), [
        const FormidableMinError(min: 10, exclusive: false, actual: 9),
      ]);
    });

    test('rejects the bound itself when exclusive', () {
      expect(errorsOf((f) => f.minExclusive, 10.0), [
        const FormidableMinError(min: 10, exclusive: true, actual: 10.0),
      ]);
      expect(errorsOf((f) => f.minExclusive, 10.5), isEmpty);
    });

    test('rejects NaN', () {
      expect(errorsOf((f) => f.minExclusive, double.nan), hasLength(1));
    });
  });

  group('Max', () {
    test('accepts the bound and below, rejects above', () {
      expect(errorsOf((f) => f.max, 10), isEmpty);
      expect(errorsOf((f) => f.max, 11), [
        const FormidableMaxError(max: 10, exclusive: false, actual: 11),
      ]);
    });

    test('rejects the bound itself when exclusive', () {
      expect(errorsOf((f) => f.maxExclusive, 10.0), [
        const FormidableMaxError(max: 10, exclusive: true, actual: 10.0),
      ]);
      expect(errorsOf((f) => f.maxExclusive, 9.9), isEmpty);
    });

    test('rejects NaN', () {
      expect(errorsOf((f) => f.maxExclusive, double.nan), hasLength(1));
    });
  });

  test('Range accepts both bounds and rejects outside', () {
    expect(errorsOf((f) => f.range, 1), isEmpty);
    expect(errorsOf((f) => f.range, 5), isEmpty);
    expect(errorsOf((f) => f.range, 0), [
      const FormidableRangeError(min: 1, max: 5, actual: 0),
    ]);
    expect(errorsOf((f) => f.range, 6), [
      const FormidableRangeError(min: 1, max: 5, actual: 6),
    ]);
  });

  group('sign Validators', () {
    test('Positive', () {
      expect(errorsOf((f) => f.positive, 1), isEmpty);
      expect(errorsOf((f) => f.positive, 0), [
        const FormidablePositiveError(0),
      ]);
      expect(errorsOf((f) => f.positive, -1), hasLength(1));
    });

    test('PositiveOrZero', () {
      expect(errorsOf((f) => f.positiveOrZero, 0), isEmpty);
      expect(errorsOf((f) => f.positiveOrZero, -1), [
        const FormidablePositiveOrZeroError(-1),
      ]);
    });

    test('Negative', () {
      expect(errorsOf((f) => f.negative, -1), isEmpty);
      expect(errorsOf((f) => f.negative, 0), [
        const FormidableNegativeError(0),
      ]);
    });

    test('NegativeOrZero', () {
      expect(errorsOf((f) => f.negativeOrZero, 0), isEmpty);
      expect(errorsOf((f) => f.negativeOrZero, 1), [
        const FormidableNegativeOrZeroError(1),
      ]);
    });

    test('NonZero', () {
      expect(errorsOf((f) => f.nonZero, 0.5), isEmpty);
      expect(errorsOf((f) => f.nonZero, 0.0), [const FormidableNonZeroError()]);
    });

    test('NonZero accepts NaN, which is not zero', () {
      expect(errorsOf((f) => f.nonZero, double.nan), isEmpty);
    });
  });

  group('MultipleOf', () {
    test('works on integers', () {
      expect(errorsOf((f) => f.multipleOf, 15), isEmpty);
      expect(errorsOf((f) => f.multipleOf, 0), isEmpty);
      expect(errorsOf((f) => f.multipleOf, -10), isEmpty);
      expect(errorsOf((f) => f.multipleOf, 16), [
        const FormidableMultipleOfError(divisor: 5, actual: 16),
      ]);
    });

    test('tolerates floating point noise', () {
      expect(errorsOf((f) => f.multipleOfDecimal, 0.3), isEmpty);
      expect(errorsOf((f) => f.multipleOfDecimal, 1.1), isEmpty);
      expect(errorsOf((f) => f.multipleOfDecimal, 0.35), hasLength(1));
    });
  });

  test('Even and Odd', () {
    expect(errorsOf((f) => f.even, 4), isEmpty);
    expect(errorsOf((f) => f.even, -3), [const FormidableEvenError(-3)]);
    expect(errorsOf((f) => f.odd, -3), isEmpty);
    expect(errorsOf((f) => f.odd, 4), [const FormidableOddError(4)]);
  });

  group('DecimalPlaces', () {
    test('accepts up to the limit', () {
      expect(errorsOf((f) => f.decimalPlaces, 3.0), isEmpty);
      expect(errorsOf((f) => f.decimalPlaces, 3.1), isEmpty);
      expect(errorsOf((f) => f.decimalPlaces, 3.14), isEmpty);
    });

    test('rejects more places than the limit', () {
      expect(errorsOf((f) => f.decimalPlaces, 3.141), [
        const FormidableDecimalPlacesError(maxPlaces: 2, actualPlaces: 3),
      ]);
    });

    test('understands exponent notation', () {
      expect(errorsOf((f) => f.decimalPlaces, 1e-7), [
        const FormidableDecimalPlacesError(maxPlaces: 2, actualPlaces: 7),
      ]);
      expect(errorsOf((f) => f.decimalPlaces, 1.5e-3), [
        const FormidableDecimalPlacesError(maxPlaces: 2, actualPlaces: 4),
      ]);
      expect(errorsOf((f) => f.decimalPlaces, 1e21), isEmpty);
    });
  });

  group('digit counts', () {
    test('Digits needs exactly the count, ignoring sign', () {
      expect(errorsOf((f) => f.digits, 123), isEmpty);
      expect(errorsOf((f) => f.digits, -123), isEmpty);
      expect(errorsOf((f) => f.digits, 12), [
        const FormidableDigitsError(digits: 3, actualDigits: 2),
      ]);
      expect(errorsOf((f) => f.digits, 1234), hasLength(1));
    });

    test('MinDigits', () {
      expect(errorsOf((f) => f.minDigits, 10), isEmpty);
      expect(errorsOf((f) => f.minDigits, 9), [
        const FormidableMinDigitsError(minDigits: 2, actualDigits: 1),
      ]);
      expect(errorsOf((f) => f.minDigits, 0), hasLength(1));
    });

    test('MaxDigits', () {
      expect(errorsOf((f) => f.maxDigits, 99), isEmpty);
      expect(errorsOf((f) => f.maxDigits, 100), [
        const FormidableMaxDigitsError(maxDigits: 2, actualDigits: 3),
      ]);
    });
  });

  test('Port accepts 1 to 65535', () {
    expect(errorsOf((f) => f.port, 1), isEmpty);
    expect(errorsOf((f) => f.port, 8080), isEmpty);
    expect(errorsOf((f) => f.port, 65535), isEmpty);
    expect(errorsOf((f) => f.port, 0), [const FormidablePortError(0)]);
    expect(errorsOf((f) => f.port, 65536), [const FormidablePortError(65536)]);
  });

  test('a Validator does not run while the Field is Unset', () {
    expect(NumberRulesForm().min.state.errors, isEmpty);
  });
}

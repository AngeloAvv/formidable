import 'package:formidable/formidable.dart';
import 'package:formidable_test_schemas/codecs.dart';
import 'package:test/test.dart';

/// Seam 1: built-in Codecs are pure functions, tested directly, and the way a
/// parse error reaches a generated Form.
void main() {
  FormidableCodec<T, String> text<T>() =>
      FormidableCodecs.defaults.find<T, String>()!;

  T? parsed<T>(FormidableCodec<T, String> codec, String input) =>
      switch (codec.parse(input)) {
        FormidableParsedValue<T>(:final value) => value,
        _ => null,
      };

  group('int to text', () {
    final codec = text<int>();

    test('formats and parses', () {
      expect(codec.format(42), '42');
      expect(parsed(codec, '42'), 42);
      expect(parsed(codec, '-7'), -7);
    });

    test('ignores surrounding whitespace', () {
      expect(parsed(codec, '  15 '), 15);
    });

    test('blank text is Unset', () {
      expect(codec.parse(''), isA<FormidableParsedUnset<int>>());
      expect(codec.parse('   '), isA<FormidableParsedUnset<int>>());
    });

    test('text that is not a whole number is a typed parse error', () {
      for (final input in ['12a', '1.5', 'abc']) {
        final result = codec.parse(input);
        expect(result, isA<FormidableParseFailure<int>>(), reason: input);
        expect(
          (result as FormidableParseFailure<int>).error,
          FormidableNumberParseError(input: input),
        );
      }
    });
  });

  group('double to text', () {
    final codec = text<double>();

    test('formats and parses', () {
      expect(codec.format(1.5), '1.5');
      expect(parsed(codec, '1.5'), 1.5);
      expect(parsed(codec, '3'), 3.0);
    });

    test('blank text is Unset and garbage is a parse error', () {
      expect(codec.parse(''), isA<FormidableParsedUnset<double>>());
      expect(
        codec.parse('1,5x'),
        isA<FormidableParseFailure<double>>().having(
          (failure) => failure.error,
          'error',
          const FormidableNumberParseError(input: '1,5x'),
        ),
      );
    });
  });

  group('num to text', () {
    final codec = text<num>();

    test('keeps integers integers and decimals decimals', () {
      expect(parsed(codec, '4'), isA<int>());
      expect(parsed(codec, '4.5'), isA<double>());
      expect(codec.format(4), '4');
      expect(codec.format(4.5), '4.5');
    });

    test('blank text is Unset and garbage is a parse error', () {
      expect(codec.parse(' '), isA<FormidableParsedUnset<num>>());
      expect(codec.parse('x'), isA<FormidableParseFailure<num>>());
    });
  });

  group('DateTime to text', () {
    final codec = text<DateTime>();

    test('a date at midnight is written as a date', () {
      expect(codec.format(DateTime(2024, 1, 31)), '2024-01-31');
      expect(parsed(codec, '2024-01-31'), DateTime(2024, 1, 31));
    });

    test('a date with a time round-trips', () {
      final value = DateTime(2024, 1, 31, 10, 30);
      expect(parsed(codec, codec.format(value)), value);
    });

    test('blank text is Unset and garbage is a parse error', () {
      expect(codec.parse(''), isA<FormidableParsedUnset<DateTime>>());
      expect(
        codec.parse('31/01/2024'),
        isA<FormidableParseFailure<DateTime>>().having(
          (failure) => failure.error,
          'error',
          const FormidableDateParseError(input: '31/01/2024'),
        ),
      );
    });
  });

  group('String to text', () {
    final codec = text<String>();

    test('is the identity, and an empty text is Unset', () {
      expect(codec.format('hi'), 'hi');
      expect(parsed(codec, 'hi'), 'hi');
      expect(codec.parse(''), isA<FormidableParsedUnset<String>>());
    });

    test('whitespace is a value', () {
      expect(parsed(codec, ' '), ' ');
    });
  });

  group('registry', () {
    test('is chosen by the pair of types', () {
      expect(FormidableCodecs.defaults.find<int, String>(), isNotNull);
      expect(FormidableCodecs.defaults.find<int, int>(), isNull);
      expect(FormidableCodecs.defaults.find<bool, String>(), isNull);
    });

    test('a nullable Field type finds the codec of its value type', () {
      final codec = FormidableCodecs.defaults.find<int?, String>()!;
      expect(codec.format(3), '3');
      expect(parsed(codec, '3'), 3);
    });

    test('a num Field does not use the int codec', () {
      expect(parsed(text<num>(), '1.5'), 1.5);
    });

    test(
      'a custom codec wins over a built-in one, last registration first',
      () {
        final registry = FormidableCodecs.defaults
            .add(const _CentsCodec(prefix: 'a'))
            .add(const _CentsCodec(prefix: 'b'));

        expect(registry.find<int, String>()!.format(250), 'b2.50');
        expect(registry.find<double, String>(), isNotNull);
      },
    );

    test('registries with the same codecs are equal', () {
      const codec = _CentsCodec(prefix: 'a');
      expect(
        FormidableCodecs.defaults.add(codec),
        FormidableCodecs.defaults.add(codec),
      );
      expect(
        FormidableCodecs.defaults.add(codec),
        isNot(FormidableCodecs.defaults),
      );
    });
  });

  group('a parse error in a generated Form', () {
    test('makes an optional Field invalid, and blocks submit', () async {
      final form = MeasurementsForm(age: 30);
      expect(form.weight.isValid, isTrue);

      const error = FormidableNumberParseError(input: '12a');
      form.weight.reject(error);

      expect(form.weight.isSet, isFalse);
      expect(form.weight.state.errors, [error]);
      final result = await form.submit();
      final invalid = result as FormidableSubmitInvalid<Measurements>;
      expect(invalid.fieldErrors[form.weight], [error]);
    });

    test('is replaced by a value, and by clear()', () async {
      final form = MeasurementsForm(age: 30);
      const error = FormidableNumberParseError(input: 'x');

      form.weight.reject(error);
      form.weight.setValue(1.5);
      expect(form.weight.state.errors, isEmpty);

      form.weight.reject(error);
      form.weight.clear();
      expect(form.weight.state.errors, isEmpty);
      expect(await form.submit(), isA<FormidableSubmitValid<Measurements>>());
    });

    test('takes the place of the required error on a required Field', () {
      final form = MeasurementsForm()
        ..age.reject(const FormidableNumberParseError(input: 'x'));

      expect(form.age.state.errors, [
        const FormidableNumberParseError(input: 'x'),
      ]);
    });

    test('notifies listeners once, and only on a change', () {
      final form = MeasurementsForm(age: 30);
      var notifications = 0;
      form.weight.addListener(() => notifications++);

      const error = FormidableNumberParseError(input: 'x');
      form.weight.reject(error);
      form.weight.reject(error);

      expect(notifications, 1);
      expect(form.weight.inputError, error);
    });
  });
}

class _CentsCodec extends FormidableCodec<int, String> {
  const _CentsCodec({required this.prefix});

  final String prefix;

  @override
  String format(int value) => '$prefix${(value / 100).toStringAsFixed(2)}';

  @override
  FormidableParseResult<int> parse(String input) =>
      FormidableParsedValue((double.parse(input) * 100).round());
}

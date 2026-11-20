import 'package:formidable/formidable.dart';
import 'package:formidable_test_schemas/string_catalog.dart';
import 'package:test/test.dart';

class _Case {
  const _Case(
    this.name,
    this.field,
    this.error, {
    required this.valid,
    required this.invalid,
  });

  final String name;
  final FormidableField<String?> Function(StringCatalogForm form) field;
  final Matcher error;
  final List<String> valid;
  final List<String> invalid;
}

List<FormidableValidationError> _errorsOf(_Case c, String value) {
  final form = StringCatalogForm();
  final field = c.field(form)..setValue(value);
  return field.state.errors;
}

final _cases = <_Case>[
  _Case(
    'MaxLength',
    (f) => f.maxLength,
    isA<FormidableMaxLengthError>(),
    valid: ['', 'abc', 'abcde'],
    invalid: ['abcdef'],
  ),
  _Case(
    'Length.exactly',
    (f) => f.exactLength,
    isA<FormidableExactLengthError>(),
    valid: ['abcd'],
    invalid: ['', 'abc', 'abcde'],
  ),
  _Case(
    'Length.between (too short)',
    (f) => f.betweenLength,
    isA<FormidableMinLengthError>(),
    valid: ['ab', 'abc', 'abcd'],
    invalid: ['', 'a'],
  ),
  _Case(
    'Length.between (too long)',
    (f) => f.betweenLength,
    isA<FormidableMaxLengthError>(),
    valid: ['ab', 'abcd'],
    invalid: ['abcde'],
  ),
  _Case(
    'Pattern',
    (f) => f.pattern,
    isA<FormidablePatternError>(),
    valid: ['123', '007'],
    invalid: ['12', '1234', 'abc', ''],
  ),
  _Case(
    'Pattern(negate)',
    (f) => f.notPattern,
    isA<FormidablePatternError>(),
    valid: ['abc', ''],
    invalid: ['a1', '7'],
  ),
  _Case(
    'StartsWith',
    (f) => f.startsWith,
    isA<FormidableStartsWithError>(),
    valid: ['ab', 'abc'],
    invalid: ['', 'a', 'ba', 'xab'],
  ),
  _Case(
    'EndsWith',
    (f) => f.endsWith,
    isA<FormidableEndsWithError>(),
    valid: ['yz', 'xyz'],
    invalid: ['', 'y', 'zy', 'yzx'],
  ),
  _Case(
    'DoesntStartWith',
    (f) => f.doesntStartWith,
    isA<FormidableDoesntStartWithError>(),
    valid: ['', 'a', 'ba', 'xab'],
    invalid: ['ab', 'abc'],
  ),
  _Case(
    'DoesntEndWith',
    (f) => f.doesntEndWith,
    isA<FormidableDoesntEndWithError>(),
    valid: ['', 'y', 'zy', 'yzx'],
    invalid: ['yz', 'xyz'],
  ),
  _Case(
    'Contains',
    (f) => f.contains,
    isA<FormidableContainsError>(),
    valid: ['mid', 'a mid b'],
    invalid: ['', 'mi', 'MID'],
  ),
  _Case(
    'NotContains',
    (f) => f.notContains,
    isA<FormidableNotContainsError>(),
    valid: ['', 'good', 'BAD'],
    invalid: ['bad', 'a bad b'],
  ),
  _Case(
    'Alpha',
    (f) => f.alpha,
    isA<FormidableAlphaError>(),
    valid: ['abc', 'ABC', 'àèì', 'Straße'],
    invalid: ['a1', 'a b', 'a-b', ''],
  ),
  _Case(
    'AlphaNumeric',
    (f) => f.alphaNumeric,
    isA<FormidableAlphaNumericError>(),
    valid: ['abc', 'a1', '123', 'àè9'],
    invalid: ['a b', 'a-b', 'a_b', ''],
  ),
  _Case(
    'AlphaDash',
    (f) => f.alphaDash,
    isA<FormidableAlphaDashError>(),
    valid: ['abc', 'a-b', 'a_b', 'a1-2_c'],
    invalid: ['a b', 'a.b', ''],
  ),
  _Case(
    'AlphaSpaces',
    (f) => f.alphaSpaces,
    isA<FormidableAlphaSpacesError>(),
    valid: ['abc', 'a b', 'Mary Jane'],
    invalid: ['a1', 'a-b', ''],
  ),
  _Case(
    'Ascii',
    (f) => f.ascii,
    isA<FormidableAsciiError>(),
    valid: ['', 'abc 123 !~', 'line\tbreak'],
    invalid: ['è', 'a€', '日本'],
  ),
  _Case(
    'Lowercase',
    (f) => f.lowercase,
    isA<FormidableLowercaseError>(),
    valid: ['abc', 'abc 123', ''],
    invalid: ['Abc', 'ABC', 'abC'],
  ),
  _Case(
    'Uppercase',
    (f) => f.uppercase,
    isA<FormidableUppercaseError>(),
    valid: ['ABC', 'ABC 123', ''],
    invalid: ['Abc', 'abc', 'aBC'],
  ),
  _Case(
    'HasLowercase',
    (f) => f.hasLowercase,
    isA<FormidableHasLowercaseError>(),
    valid: ['aBC', 'abc'],
    invalid: ['ABC', '123', ''],
  ),
  _Case(
    'HasUppercase',
    (f) => f.hasUppercase,
    isA<FormidableHasUppercaseError>(),
    valid: ['Abc', 'ABC'],
    invalid: ['abc', '123', ''],
  ),
  _Case(
    'HasDigit',
    (f) => f.hasDigit,
    isA<FormidableHasDigitError>(),
    valid: ['a1', '123'],
    invalid: ['abc', '', '!'],
  ),
  _Case(
    'HasSpecialChar',
    (f) => f.hasSpecialChar,
    isA<FormidableHasSpecialCharError>(),
    valid: ['a!', 'a-b', r'$', 'a€'],
    invalid: ['abc', 'a1 b', ''],
  ),
  _Case(
    'HasSpecialChar(2)',
    (f) => f.hasTwoSpecialChars,
    isA<FormidableHasSpecialCharError>(),
    valid: ['a!b?', '!!'],
    invalid: ['a!b', '', 'abc'],
  ),
  _Case(
    'SingleLine',
    (f) => f.singleLine,
    isA<FormidableSingleLineError>(),
    valid: ['', 'one line', 'tabs\tare fine'],
    invalid: ['a\nb', 'a\r\nb', 'a\rb'],
  ),
  _Case(
    'MinWords',
    (f) => f.minWords,
    isA<FormidableMinWordsError>(),
    valid: ['two words', ' spaced   out ', 'one two three'],
    invalid: ['', '   ', 'one'],
  ),
  _Case(
    'MaxWords',
    (f) => f.maxWords,
    isA<FormidableMaxWordsError>(),
    valid: ['', 'one', 'one two three', 'one\ntwo\tthree'],
    invalid: ['one two three four'],
  ),
  _Case(
    'Slug',
    (f) => f.slug,
    isA<FormidableSlugError>(),
    valid: ['hello', 'hello-world', 'a1-b2-c3', '2024'],
    invalid: ['Hello', 'hello_world', '-hello', 'hello-', 'a--b', 'a b', ''],
  ),
];

void main() {
  group('string Validators', () {
    for (final c in _cases) {
      group(c.name, () {
        for (final value in c.valid) {
          test('accepts ${_show(value)}', () {
            expect(_errorsOf(c, value), isEmpty);
          });
        }
        for (final value in c.invalid) {
          test('rejects ${_show(value)}', () {
            expect(_errorsOf(c, value), [c.error]);
          });
        }
      });
    }

    test('are skipped while the Field is Unset', () {
      final form = StringCatalogForm();

      expect(form.slug.state.errors, isEmpty);
      expect(form.strongPassword.state.errors, isEmpty);
    });
  });

  group('error data', () {
    test('MaxLength reports the limit and the length', () {
      final form = StringCatalogForm()..maxLength.setValue('abcdefg');

      expect(form.maxLength.state.errors, [
        const FormidableMaxLengthError(maxLength: 5, actualLength: 7),
      ]);
    });

    test('Length.exactly reports the length and the actual length', () {
      final form = StringCatalogForm()..exactLength.setValue('ab');

      expect(form.exactLength.state.errors, [
        const FormidableExactLengthError(length: 4, actualLength: 2),
      ]);
    });

    test('Length.between reports the bound that failed', () {
      final form = StringCatalogForm()..betweenLength.setValue('a');

      expect(form.betweenLength.state.errors, [
        const FormidableMinLengthError(minLength: 2, actualLength: 1),
      ]);
    });

    test('Pattern reports the pattern and whether it was negated', () {
      final form = StringCatalogForm()
        ..pattern.setValue('x')
        ..notPattern.setValue('1');

      expect(form.pattern.state.errors, [
        const FormidablePatternError(pattern: r'^\d{3}$', negated: false),
      ]);
      expect(form.notPattern.state.errors, [
        const FormidablePatternError(pattern: r'\d', negated: true),
      ]);
    });

    test('StartsWith and Contains report the text they expect', () {
      final form = StringCatalogForm()
        ..startsWith.setValue('x')
        ..contains.setValue('x');

      expect(form.startsWith.state.errors, [
        const FormidableStartsWithError(prefix: 'ab'),
      ]);
      expect(form.contains.state.errors, [
        const FormidableContainsError(text: 'mid'),
      ]);
    });

    test('HasSpecialChar reports the minimum', () {
      final form = StringCatalogForm()..hasTwoSpecialChars.setValue('a!');

      expect(form.hasTwoSpecialChars.state.errors, [
        const FormidableHasSpecialCharError(min: 2, actual: 1),
      ]);
    });

    test('MinWords and MaxWords report the counts', () {
      final form = StringCatalogForm()
        ..minWords.setValue('one')
        ..maxWords.setValue('a b c d e');

      expect(form.minWords.state.errors, [
        const FormidableMinWordsError(minWords: 2, actualWords: 1),
      ]);
      expect(form.maxWords.state.errors, [
        const FormidableMaxWordsError(maxWords: 3, actualWords: 5),
      ]);
    });
  });

  group('StrongPassword', () {
    List<FormidableValidationError> errorsOf(String value) {
      final form = StringCatalogForm()..strongPassword.setValue(value);
      return form.strongPassword.state.errors;
    }

    test('accepts a password that meets every requirement', () {
      expect(errorsOf('Abcdef1!'), isEmpty);
      expect(errorsOf('Zz9-Zz9-Zz9'), isEmpty);
    });

    test('reports one error per missing requirement, in a stable order', () {
      expect(errorsOf(''), [
        const FormidableMinLengthError(minLength: 8, actualLength: 0),
        const FormidableHasLowercaseError(min: 1, actual: 0),
        const FormidableHasUppercaseError(min: 1, actual: 0),
        const FormidableHasDigitError(min: 1, actual: 0),
        const FormidableHasSpecialCharError(min: 1, actual: 0),
      ]);
    });

    test('reports only what is missing', () {
      expect(errorsOf('abcdefg1!'), [
        const FormidableHasUppercaseError(min: 1, actual: 0),
      ]);
      expect(errorsOf('Abcdef1'), [
        const FormidableMinLengthError(minLength: 8, actualLength: 7),
        const FormidableHasSpecialCharError(min: 1, actual: 0),
      ]);
    });

    test('counts the requirements it is given', () {
      const strict = StrongPassword(
        minLength: 4,
        minLower: 2,
        minUpper: 2,
        minDigits: 2,
        minSymbols: 0,
      );

      expect(strict.validate('aaBB11'), isEmpty);
      expect(strict.validate('aBB11'), [
        const FormidableHasLowercaseError(min: 2, actual: 1),
      ]);
    });
  });
}

String _show(String value) {
  if (value.isEmpty) return '(empty)';
  final escaped = value
      .replaceAll('\n', r'\n')
      .replaceAll('\r', r'\r')
      .replaceAll('\t', r'\t');
  return "'$escaped'";
}

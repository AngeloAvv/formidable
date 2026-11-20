import 'package:formidable/formidable.dart';
import 'package:formidable_test_schemas/catalog_locale.dart';
import 'package:test/test.dart';

/// Seam 1: the locale Validators of the built-in catalog.
void main() {
  void check(
    FormidableField<String> field, {
    required List<String> valid,
    required List<String> invalid,
    required FormidableValidationError error,
  }) {
    for (final value in valid) {
      field.setValue(value);
      expect(field.state.errors, isEmpty, reason: 'valid: "$value"');
    }
    for (final value in invalid) {
      field.setValue(value);
      expect(field.state.errors, [error], reason: 'invalid: "$value"');
    }
  }

  late TravelerForm form;
  setUp(() => form = TravelerForm());

  test('CountryCode accepts ISO 3166-1 alpha-2 codes in upper case', () {
    check(
      form.country,
      valid: ['IT', 'US', 'GB', 'DE', 'FR', 'ES', 'JP', 'BR', 'AX', 'ZW', 'AD'],
      invalid: [
        '',
        'it',
        'It',
        'ITA',
        'I',
        'ZZ',
        'AA',
        'XK',
        'UK',
        'EU',
        'I1',
        ' IT',
      ],
      error: const FormidableCountryCodeError(),
    );
  });

  test('LanguageCode accepts ISO 639-1 codes in lower case', () {
    check(
      form.language,
      valid: ['en', 'it', 'es', 'fr', 'de', 'zh', 'ja', 'he', 'id', 'yi'],
      invalid: ['', 'EN', 'En', 'eng', 'e', 'xx', 'iw', 'en-US', ' en'],
      error: const FormidableLanguageCodeError(),
    );
  });

  test('LocaleCode accepts a language, a script and a region', () {
    check(
      form.locale,
      valid: [
        'en',
        'en-US',
        'en_US',
        'it-IT',
        'zh-Hant',
        'zh-Hant-TW',
        'sr_Latn_RS',
        'es-419',
        'fil',
        'fil-PH',
      ],
      invalid: [
        '',
        'EN',
        'en-us',
        'en-USA',
        'e',
        'english',
        'en-',
        '-US',
        'en--US',
        'xx-US',
        'en-XX',
        'en_US-x',
        'zh-hant',
        'zh-Hant-',
        'en-US-Hant',
        'en US',
        'en-41',
      ],
      error: const FormidableLocaleCodeError(),
    );
  });

  test('Phone is an E.164 number: a plus, then up to 15 digits', () {
    check(
      form.phone,
      valid: [
        '+393331234567',
        '+12025550123',
        '+12',
        '+442071838750',
        '+123456789012345',
      ],
      invalid: [
        '',
        '393331234567',
        '+0123456',
        '+39 333 1234567',
        '+39-333-1234567',
        '++393331234567',
        '+1',
        '+1234567890123456',
        '+39abc',
        '+',
        '(+39) 333',
      ],
      error: const FormidablePhoneError(),
    );
  });
}

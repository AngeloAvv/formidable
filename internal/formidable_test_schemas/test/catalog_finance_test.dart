import 'package:formidable/formidable.dart';
import 'package:formidable_test_schemas/catalog_finance.dart';
import 'package:test/test.dart';

DateTime _midJune2026() => DateTime(2026, 6, 15);

/// Seam 1: the finance Validators of the built-in catalog.
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

  const visa = ['4111111111111111', '4012888888881881', '4222222222222'];
  const mastercard = [
    '5555555555554444',
    '2223003122003222',
    '5105105105105100',
  ];
  const amex = ['378282246310005', '371449635398431'];
  const discover = ['6011111111111117', '6011000990139424'];
  const diners = ['30569309025904', '38520000023237'];
  const jcb = ['3530111333300000', '3566002020360505'];
  const unionpay = ['6200000000000005'];
  const maestro = ['6759649826438453', '6304000000000000'];

  late PaymentForm form;
  setUp(() => form = PaymentForm());

  group('CreditCard', () {
    test('accepts the numbers of every brand when no brand is given', () {
      check(
        form.card,
        valid: [
          ...visa,
          ...mastercard,
          ...amex,
          ...discover,
          ...diners,
          ...jcb,
          ...unionpay,
          ...maestro,
        ],
        invalid: [
          '',
          'abcd',
          '4111111111111112',
          '411111111111',
          '41111111111111111111',
          '4111 1111 1111 111x',
        ],
        error: const FormidableCreditCardError(brands: []),
      );
    });

    test('ignores spaces and hyphens', () {
      final f = form..card.setValue('4111 1111-1111 1111');

      expect(f.card.state.errors, isEmpty);
    });

    test('limits the accepted brands', () {
      const error = FormidableCreditCardError(
        brands: [CardBrand.visa, CardBrand.mastercard],
      );
      check(
        form.visaOrMastercard,
        valid: [...visa, ...mastercard],
        invalid: [...amex, ...discover, ...diners, ...jcb, '4111111111111112'],
        error: error,
      );
    });

    test('recognizes each brand by itself', () {
      final byBrand = {
        CardBrand.visa: visa,
        CardBrand.mastercard: mastercard,
        CardBrand.amex: amex,
        CardBrand.discover: discover,
        CardBrand.diners: diners,
        CardBrand.jcb: jcb,
        CardBrand.unionpay: unionpay,
        CardBrand.maestro: maestro,
      };
      for (final MapEntry(key: brand, value: numbers) in byBrand.entries) {
        for (final other in byBrand.entries) {
          final accepted = CreditCard(brands: [brand]);
          for (final number in other.value) {
            final shouldPass = other.key == brand;
            // UnionPay is a superset of the 62 range, which includes some
            // Discover prefixes.
            if (!shouldPass &&
                (brand == CardBrand.unionpay || brand == CardBrand.discover)) {
              continue;
            }
            expect(
              accepted.validate(number).isEmpty,
              shouldPass,
              reason: '$number as ${brand.name}',
            );
          }
        }
        expect(numbers, isNotEmpty);
      }
    });
  });

  test('CardCvc accepts three or four digits', () {
    check(
      form.cvc,
      valid: ['123', '0000', '9876'],
      invalid: ['', '12', '12345', 'abc', '12a', ' 123', '1 23'],
      error: const FormidableCardCvcError(),
    );
  });

  group('CardExpiry', () {
    test('accepts a month and a year, in two or four digits', () {
      check(
        form.expiry,
        valid: ['12/99', '01/2099', '06/2150'],
        invalid: [
          '',
          '1/99',
          '13/99',
          '00/99',
          '12-99',
          '1299',
          '12/9',
          '12/099',
          'ab/cd',
        ],
        error: const FormidableCardExpiryError(),
      );
    });

    test('rejects a card that expired', () {
      final f = form..expiry.setValue('01/20');

      expect(f.expiry.state.errors, [const FormidableCardExpiredError()]);
    });

    test('is valid until the end of the month printed on the card', () {
      const validator = CardExpiry(now: _midJune2026);

      expect(validator.validate('06/26'), isEmpty);
      expect(validator.validate('06/2026'), isEmpty);
      expect(validator.validate('07/26'), isEmpty);
      expect(validator.validate('05/26'), [const FormidableCardExpiredError()]);
      expect(validator.validate('12/25'), [const FormidableCardExpiredError()]);
    });

    test('asks the clock when it validates', () {
      var now = DateTime(2026, 6, 15);
      final validator = CardExpiry(now: () => now);

      expect(validator.validate('06/26'), isEmpty);
      now = DateTime(2026, 7, 1);
      expect(validator.validate('06/26'), isNotEmpty);
    });
  });

  group('Iban', () {
    const valid = [
      'IT60X0542811101000000123456',
      'DE89370400440532013000',
      'GB82WEST12345698765432',
      'FR1420041010050500013M02606',
      'ES9121000418450200051332',
      'NL91ABNA0417164300',
      'CH9300762011623852957',
      'BE68539007547034',
    ];

    test('accepts valid numbers of any country', () {
      check(
        form.iban,
        valid: [
          ...valid,
          'DE89 3704 0044 0532 0130 00',
          'de89370400440532013000',
        ],
        invalid: [
          '',
          'DE89370400440532013001',
          'DE8937040044053201300',
          'DE893704004405320130000',
          'XX89370400440532013000',
          'DE00370400440532013000',
          '8937040044053201300DE',
          'DE89-3704-0044-0532-0130-00',
          'D',
        ],
        error: const FormidableIbanError(countries: []),
      );
    });

    test('limits the accepted countries', () {
      check(
        form.italianOrGermanIban,
        valid: ['IT60X0542811101000000123456', 'DE89370400440532013000'],
        invalid: [
          'GB82WEST12345698765432',
          'FR1420041010050500013M02606',
          'IT60X0542811101000000123457',
        ],
        error: const FormidableIbanError(countries: ['IT', 'DE']),
      );
    });

    test('knows the country list to be case insensitive', () {
      expect(
        const Iban(countries: ['it']).validate('IT60X0542811101000000123456'),
        isEmpty,
      );
    });
  });

  test('Bic accepts eight or eleven characters', () {
    check(
      form.bic,
      valid: [
        'DEUTDEFF',
        'DEUTDEFF500',
        'BCITITMM',
        'NEDSZAJJ',
        'CHASUS33XXX',
        'deutdeff',
      ],
      invalid: [
        '',
        'DEUTDEF',
        'DEUTDEFF50',
        'DEUTDEFF5000',
        'DEUT1EFF',
        'DEUT12FF',
        'DEUTDEF!',
        'DEUT DEFF',
      ],
      error: const FormidableBicError(),
    );
  });

  test('CurrencyCode accepts ISO 4217 codes in upper case', () {
    check(
      form.currency,
      valid: ['EUR', 'USD', 'GBP', 'JPY', 'CHF', 'BRL', 'INR', 'ZAR'],
      invalid: ['', 'eur', 'EU', 'EURO', 'XYZ', 'US1', 'AAA'],
      error: const FormidableCurrencyCodeError(),
    );
  });
}

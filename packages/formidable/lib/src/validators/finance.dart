import '../validation/validation_error.dart';
import '../validation/validator.dart';

/// A payment card network.
enum CardBrand {
  visa,
  mastercard,
  amex,
  discover,
  diners,
  jcb,
  unionpay,
  maestro,
}

final _brandPatterns = <CardBrand, RegExp>{
  CardBrand.visa: RegExp(r'^4\d{12}(?:\d{3}(?:\d{3})?)?$'),
  CardBrand.mastercard: RegExp(
    r'^(?:5[1-5]\d{2}|222[1-9]|22[3-9]\d|2[3-6]\d{2}|27[01]\d|2720)\d{12}$',
  ),
  CardBrand.amex: RegExp(r'^3[47]\d{13}$'),
  CardBrand.discover: RegExp(
    r'^(?:6011\d{12,15}|65\d{14,17}|64[4-9]\d{13,16}'
    r'|622(?:12[6-9]|1[3-9]\d|[2-8]\d{2}|9[01]\d|92[0-5])\d{10,13})$',
  ),
  CardBrand.diners: RegExp(r'^(?:30[0-5]\d|3095|36\d{2}|3[89]\d{2})\d{10,15}$'),
  CardBrand.jcb: RegExp(r'^35(?:2[89]|[3-8]\d)\d{12,15}$'),
  CardBrand.unionpay: RegExp(r'^62\d{14,17}$'),
  CardBrand.maestro: RegExp(
    r'^(?:5018|5020|5038|5893|6304|6759|6761|6762|6763)\d{8,15}$',
  ),
};

bool _luhn(String digits) {
  var sum = 0;
  for (var i = 0; i < digits.length; i++) {
    var digit = digits.codeUnitAt(digits.length - 1 - i) - 0x30;
    if (i.isOdd) {
      digit *= 2;
      if (digit > 9) digit -= 9;
    }
    sum += digit;
  }
  return sum % 10 == 0;
}

/// The value is not a valid card number.
final class FormidableCreditCardError extends FormidableValidationError {
  const FormidableCreditCardError({required this.brands});

  /// The brands the Validator accepts, empty for any.
  final List<CardBrand> brands;

  @override
  List<Object?> get props => [...brands];

  @override
  String toString() => 'Must be a valid card number.';
}

/// The value is a payment card number: digits (spaces and hyphens are
/// ignored) that pass the Luhn check.
///
/// With [brands], the number must also have the prefix and length of one of
/// them. Without, any number of 12 to 19 digits that passes the check is
/// accepted, so cards of networks that are not in [CardBrand] work too.
class CreditCard extends FormidableValidator<String> {
  const CreditCard({this.brands = const []});

  final List<CardBrand> brands;

  @override
  List<FormidableValidationError> validate(String value) {
    final digits = value.replaceAll(RegExp(r'[ -]'), '');
    final valid =
        RegExp(r'^\d{12,19}$').hasMatch(digits) &&
        _luhn(digits) &&
        (brands.isEmpty ||
            brands.any((brand) => _brandPatterns[brand]!.hasMatch(digits)));
    return valid ? const [] : [FormidableCreditCardError(brands: brands)];
  }
}

/// The value is not a card security code.
final class FormidableCardCvcError extends FormidableValidationError {
  const FormidableCardCvcError();

  @override
  String toString() => 'Must be a 3 or 4 digit security code.';
}

/// The value is a card security code: three or four digits.
class CardCvc extends FormidableValidator<String> {
  const CardCvc();

  @override
  List<FormidableValidationError> validate(String value) =>
      RegExp(r'^\d{3,4}$').hasMatch(value)
      ? const []
      : const [FormidableCardCvcError()];
}

/// The value is not written as a card expiry date.
final class FormidableCardExpiryError extends FormidableValidationError {
  const FormidableCardExpiryError();

  @override
  String toString() => 'Must be an expiry date written as MM/YY.';
}

/// The card has expired.
final class FormidableCardExpiredError extends FormidableValidationError {
  const FormidableCardExpiredError();

  @override
  String toString() => 'The card has expired.';
}

DateTime _systemNow() => DateTime.now();

/// The value is the expiry date of a card that has not expired yet, written as
/// `MM/YY` or `MM/YYYY`.
///
/// A card is valid until the end of the month printed on it. The month is
/// compared with the date [now] returns, the system clock by default, so tests
/// can pass a fixed one: `CardExpiry(now: fixedDate)`, where `fixedDate` is a
/// top-level function.
class CardExpiry extends FormidableValidator<String> {
  const CardExpiry({this.now = _systemNow});

  /// The clock of the Validator.
  final DateTime Function() now;

  @override
  List<FormidableValidationError> validate(String value) {
    final match = RegExp(r'^(\d{2})/(\d{2}|\d{4})$').firstMatch(value);
    final month = match == null ? 0 : int.parse(match.group(1)!);
    if (month < 1 || month > 12) {
      return const [FormidableCardExpiryError()];
    }
    final yearText = match!.group(2)!;
    final year = int.parse(yearText) + (yearText.length == 2 ? 2000 : 0);
    final today = now();
    final expired =
        year < today.year || (year == today.year && month < today.month);
    return expired ? const [FormidableCardExpiredError()] : const [];
  }
}

const _ibanLengths = <String, int>{
  'AD': 24,
  'AE': 23,
  'AL': 28,
  'AT': 20,
  'AZ': 28,
  'BA': 20,
  'BE': 16,
  'BG': 22,
  'BH': 22,
  'BI': 27,
  'BR': 29,
  'BY': 28,
  'CH': 21,
  'CR': 22,
  'CY': 28,
  'CZ': 24,
  'DE': 22,
  'DJ': 27,
  'DK': 18,
  'DO': 28,
  'EE': 20,
  'EG': 29,
  'ES': 24,
  'FI': 18,
  'FK': 18,
  'FO': 18,
  'FR': 27,
  'GB': 22,
  'GE': 22,
  'GI': 23,
  'GL': 18,
  'GR': 27,
  'GT': 28,
  'HR': 21,
  'HU': 28,
  'IE': 22,
  'IL': 23,
  'IQ': 23,
  'IS': 26,
  'IT': 27,
  'JO': 30,
  'KW': 30,
  'KZ': 20,
  'LB': 28,
  'LC': 32,
  'LI': 21,
  'LT': 20,
  'LU': 20,
  'LV': 21,
  'LY': 25,
  'MC': 27,
  'MD': 24,
  'ME': 22,
  'MK': 19,
  'MN': 20,
  'MR': 27,
  'MT': 31,
  'MU': 30,
  'NI': 28,
  'NL': 18,
  'NO': 15,
  'OM': 23,
  'PK': 24,
  'PL': 28,
  'PS': 29,
  'PT': 25,
  'QA': 29,
  'RO': 24,
  'RS': 22,
  'RU': 33,
  'SA': 24,
  'SC': 31,
  'SD': 18,
  'SE': 24,
  'SI': 19,
  'SK': 24,
  'SM': 27,
  'SO': 23,
  'ST': 25,
  'SV': 28,
  'TL': 23,
  'TN': 24,
  'TR': 26,
  'UA': 29,
  'VA': 22,
  'VG': 24,
  'XK': 20,
  'YE': 30,
};

bool _ibanChecksum(String iban) {
  final rearranged = iban.substring(4) + iban.substring(0, 4);
  var remainder = 0;
  for (final unit in rearranged.codeUnits) {
    // Digits stay as they are, letters become 10 (A) to 35 (Z).
    final number = unit >= 0x41 ? unit - 0x41 + 10 : unit - 0x30;
    remainder = (number > 9 ? remainder * 100 : remainder * 10) + number;
    remainder %= 97;
  }
  return remainder == 1;
}

/// The value is not a valid IBAN.
final class FormidableIbanError extends FormidableValidationError {
  const FormidableIbanError({required this.countries});

  /// The country codes the Validator accepts, empty for any.
  final List<String> countries;

  @override
  List<Object?> get props => [...countries];

  @override
  String toString() => 'Must be a valid IBAN.';
}

/// The value is an IBAN: a country code, two check digits and the account
/// part, with the length of its country and a valid mod 97 checksum.
///
/// Spaces are ignored and case does not matter. With [countries], only IBANs
/// of those ISO 3166 country codes are accepted.
class Iban extends FormidableValidator<String> {
  const Iban({this.countries = const []});

  final List<String> countries;

  @override
  List<FormidableValidationError> validate(String value) {
    final iban = value.replaceAll(' ', '').toUpperCase();
    final country = iban.length >= 2 ? iban.substring(0, 2) : '';
    final valid =
        RegExp(r'^[A-Z]{2}\d{2}[A-Z0-9]+$').hasMatch(iban) &&
        _ibanLengths[country] == iban.length &&
        _ibanChecksum(iban) &&
        (countries.isEmpty ||
            countries.any((code) => code.toUpperCase() == country));
    return valid ? const [] : [FormidableIbanError(countries: countries)];
  }
}

/// The value is not a valid BIC.
final class FormidableBicError extends FormidableValidationError {
  const FormidableBicError();

  @override
  String toString() => 'Must be a valid BIC.';
}

/// The value is a BIC (SWIFT code): four letters for the bank, two for the
/// country, two letters or digits for the location, and optionally three for
/// the branch. Case does not matter.
class Bic extends FormidableValidator<String> {
  const Bic();

  @override
  List<FormidableValidationError> validate(String value) =>
      RegExp(r'^[A-Za-z]{6}[A-Za-z0-9]{2}(?:[A-Za-z0-9]{3})?$').hasMatch(value)
      ? const []
      : const [FormidableBicError()];
}

/// The value is not a currency code.
final class FormidableCurrencyCodeError extends FormidableValidationError {
  const FormidableCurrencyCodeError();

  @override
  String toString() => 'Must be a valid currency code.';
}

const _currencyCodes = {
  'AED',
  'AFN',
  'ALL',
  'AMD',
  'ANG',
  'AOA',
  'ARS',
  'AUD',
  'AWG',
  'AZN',
  'BAM',
  'BBD',
  'BDT',
  'BGN',
  'BHD',
  'BIF',
  'BMD',
  'BND',
  'BOB',
  'BRL',
  'BSD',
  'BTN',
  'BWP',
  'BYN',
  'BZD',
  'CAD',
  'CDF',
  'CHF',
  'CLP',
  'CNY',
  'COP',
  'CRC',
  'CUP',
  'CVE',
  'CZK',
  'DJF',
  'DKK',
  'DOP',
  'DZD',
  'EGP',
  'ERN',
  'ETB',
  'EUR',
  'FJD',
  'FKP',
  'GBP',
  'GEL',
  'GHS',
  'GIP',
  'GMD',
  'GNF',
  'GTQ',
  'GYD',
  'HKD',
  'HNL',
  'HTG',
  'HUF',
  'IDR',
  'ILS',
  'INR',
  'IQD',
  'IRR',
  'ISK',
  'JMD',
  'JOD',
  'JPY',
  'KES',
  'KGS',
  'KHR',
  'KMF',
  'KPW',
  'KRW',
  'KWD',
  'KYD',
  'KZT',
  'LAK',
  'LBP',
  'LKR',
  'LRD',
  'LSL',
  'LYD',
  'MAD',
  'MDL',
  'MGA',
  'MKD',
  'MMK',
  'MNT',
  'MOP',
  'MRU',
  'MUR',
  'MVR',
  'MWK',
  'MXN',
  'MYR',
  'MZN',
  'NAD',
  'NGN',
  'NIO',
  'NOK',
  'NPR',
  'NZD',
  'OMR',
  'PAB',
  'PEN',
  'PGK',
  'PHP',
  'PKR',
  'PLN',
  'PYG',
  'QAR',
  'RON',
  'RSD',
  'RUB',
  'RWF',
  'SAR',
  'SBD',
  'SCR',
  'SDG',
  'SEK',
  'SGD',
  'SHP',
  'SLE',
  'SOS',
  'SRD',
  'SSP',
  'STN',
  'SVC',
  'SYP',
  'SZL',
  'THB',
  'TJS',
  'TMT',
  'TND',
  'TOP',
  'TRY',
  'TTD',
  'TWD',
  'TZS',
  'UAH',
  'UGX',
  'USD',
  'UYU',
  'UZS',
  'VES',
  'VND',
  'VUV',
  'WST',
  'XAF',
  'XCD',
  'XOF',
  'XPF',
  'YER',
  'ZAR',
  'ZMW',
  'ZWG',
};

/// The value is an ISO 4217 currency code in upper case, such as `EUR`.
///
/// Only the codes of currencies in circulation are known, not funds, metals
/// or test codes.
class CurrencyCode extends FormidableValidator<String> {
  const CurrencyCode();

  @override
  List<FormidableValidationError> validate(String value) =>
      _currencyCodes.contains(value)
      ? const []
      : const [FormidableCurrencyCodeError()];
}

import '../validation/validation_error.dart';
import '../validation/validator.dart';

// ISO 3166-1 alpha-2 codes, officially assigned.
final _countryCodes =
    ('AD AE AF AG AI AL AM AO AQ AR AS AT AU AW AX AZ BA BB BD BE BF BG '
            'BH BI BJ BL BM BN BO BQ BR BS BT BV BW BY BZ CA CC CD CF CG CH CI '
            'CK CL CM CN CO CR CU CV CW CX CY CZ DE DJ DK DM DO DZ EC EE EG EH '
            'ER ES ET FI FJ FK FM FO FR GA GB GD GE GF GG GH GI GL GM GN GP GQ '
            'GR GS GT GU GW GY HK HM HN HR HT HU ID IE IL IM IN IO IQ IR IS IT '
            'JE JM JO JP KE KG KH KI KM KN KP KR KW KY KZ LA LB LC LI LK LR LS '
            'LT LU LV LY MA MC MD ME MF MG MH MK ML MM MN MO MP MQ MR MS MT MU '
            'MV MW MX MY MZ NA NC NE NF NG NI NL NO NP NR NU NZ OM PA PE PF PG '
            'PH PK PL PM PN PR PS PT PW PY QA RE RO RS RU RW SA SB SC SD SE SG '
            'SH SI SJ SK SL SM SN SO SR SS ST SV SX SY SZ TC TD TF TG TH TJ TK '
            'TL TM TN TO TR TT TV TW TZ UA UG UM US UY UZ VA VC VE VG VI VN VU '
            'WF WS YE YT ZA ZM ZW')
        .split(' ')
        .toSet();

// ISO 639-1 codes.
final _languageCodes =
    ('aa ab ae af ak am an ar as av ay az ba be bg bh bi bm bn bo br bs '
            'ca ce ch co cr cs cu cv cy da de dv dz ee el en eo es et eu fa ff '
            'fi fj fo fr fy ga gd gl gn gu gv ha he hi ho hr ht hu hy hz ia id '
            'ie ig ii ik io is it iu ja jv ka kg ki kj kk kl km kn ko kr ks ku '
            'kv kw ky la lb lg li ln lo lt lu lv mg mh mi mk ml mn mr ms mt my '
            'na nb nd ne ng nl nn no nr nv ny oc oj om or os pa pi pl ps pt qu '
            'rm rn ro ru rw sa sc sd se sg si sk sl sm sn so sq sr ss st su sv '
            'sw ta te tg th ti tk tl tn to tr ts tt tw ty ug uk ur uz ve vi vo '
            'wa wo xh yi yo za zh zu')
        .split(' ')
        .toSet();

/// The value is not a country code.
final class FormidableCountryCodeError extends FormidableValidationError {
  const FormidableCountryCodeError();

  @override
  String toString() => 'Must be a valid country code.';
}

/// The value is an ISO 3166-1 alpha-2 country code in upper case, such as
/// `IT`. Only officially assigned codes are known.
class CountryCode extends FormidableValidator<String> {
  const CountryCode();

  @override
  List<FormidableValidationError> validate(String value) =>
      _countryCodes.contains(value)
      ? const []
      : const [FormidableCountryCodeError()];
}

/// The value is not a language code.
final class FormidableLanguageCodeError extends FormidableValidationError {
  const FormidableLanguageCodeError();

  @override
  String toString() => 'Must be a valid language code.';
}

/// The value is an ISO 639-1 language code in lower case, such as `it`.
class LanguageCode extends FormidableValidator<String> {
  const LanguageCode();

  @override
  List<FormidableValidationError> validate(String value) =>
      _languageCodes.contains(value)
      ? const []
      : const [FormidableLanguageCodeError()];
}

/// The value is not a locale.
final class FormidableLocaleCodeError extends FormidableValidationError {
  const FormidableLocaleCodeError();

  @override
  String toString() => 'Must be a valid locale.';
}

final _script = RegExp(r'^[A-Z][a-z]{3}$');
final _region = RegExp(r'^\d{3}$');

/// The value is a locale identifier: a language, then optionally a script and a
/// region, separated by hyphens or underscores, such as `en`, `en-US`,
/// `zh_Hant_TW` or `es-419`.
///
/// The language is an ISO 639-1 code, or three lower case letters for the
/// languages that have no two letter code (`fil`). The script is four letters
/// with a capital first one, the region an ISO 3166-1 alpha-2 code or three
/// digits. Variants and extensions are not supported. It is named
/// `LocaleCode` so it does not clash with Flutter's `Locale`.
class LocaleCode extends FormidableValidator<String> {
  const LocaleCode();

  @override
  List<FormidableValidationError> validate(String value) {
    final hyphen = value.contains('-');
    final underscore = value.contains('_');
    if (!(hyphen && underscore)) {
      final parts = value.split(hyphen ? '-' : '_');
      final language = parts.first;
      var rest = parts.skip(1).toList();
      final validLanguage =
          _languageCodes.contains(language) ||
          RegExp(r'^[a-z]{3}$').hasMatch(language);
      if (rest.isNotEmpty && _script.hasMatch(rest.first)) {
        rest = rest.skip(1).toList();
      }
      final validRegion =
          rest.isEmpty ||
          (rest.length == 1 &&
              (_countryCodes.contains(rest.single) ||
                  _region.hasMatch(rest.single)));
      if (validLanguage && validRegion) return const [];
    }
    return const [FormidableLocaleCodeError()];
  }
}

/// The value is not a phone number.
final class FormidablePhoneError extends FormidableValidationError {
  const FormidablePhoneError();

  @override
  String toString() => 'Must be a phone number in international format.';
}

/// The value has the shape of an E.164 phone number: a plus sign, a country
/// code that does not start with zero, and at most 15 digits in all, with no
/// spaces or punctuation.
///
/// It does not know which numbers exist or whether the country code is
/// assigned.
class Phone extends FormidableValidator<String> {
  const Phone();

  @override
  List<FormidableValidationError> validate(String value) =>
      RegExp(r'^\+[1-9]\d{1,14}$').hasMatch(value)
      ? const []
      : const [FormidablePhoneError()];
}

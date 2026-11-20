import 'package:flutter_test/flutter_test.dart';
import 'package:formidable/formidable.dart';
import 'package:formidable_flutter/formidable_flutter.dart';
import 'package:material_ui/material_ui.dart';

/// Seam 2: every error of the collection, file, network, finance and locale
/// Validators has a message in each language, found through the same lookup a
/// widget uses.
void main() {
  const languages = ['en', 'it', 'es', 'fr', 'de'];

  /// One instance of every error of this part of the catalog.
  final errors = <String, FormidableValidationError>{
    'notEmpty': const FormidableNotEmptyError(),
    'unique': const FormidableUniqueError(duplicates: ['a', 3]),
    'containsAll': const FormidableContainsAllError(missing: ['x', 'y']),
    'containsNone': const FormidableContainsNoneError(found: ['root']),
    'hasKeys': const FormidableHasKeysError(missing: ['host']),
    'each': const FormidableEachError({
      1: [FormidableNotEmptyError()],
    }),
    'eachMany': const FormidableEachError({
      0: [FormidableNotEmptyError()],
      3: [FormidableNotEmptyError()],
    }),
    'minFileSize': const FormidableMinFileSizeError(
      minBytes: 1536,
      actualBytes: 100,
    ),
    'maxFileSize': const FormidableMaxFileSizeError(
      maxBytes: 5 * 1024 * 1024,
      actualBytes: 7 * 1024 * 1024,
    ),
    'fileExtension': const FormidableFileExtensionError(
      allowed: ['pdf', 'docx'],
      actual: 'png',
    ),
    'mimeType': const FormidableMimeTypeError(
      allowed: ['image/*'],
      actual: null,
    ),
    'imageFile': const FormidableImageFileError(),
    'fileName': const FormidableFileNameError(maxLength: 40),
    'ipV4': const FormidableIpError(IpVersion.v4),
    'ipV6': const FormidableIpError(IpVersion.v6),
    'ip': const FormidableIpError(IpVersion.any),
    'cidrV4': const FormidableCidrError(IpVersion.v4),
    'cidrV6': const FormidableCidrError(IpVersion.v6),
    'cidr': const FormidableCidrError(IpVersion.any),
    'macAddress': const FormidableMacAddressError(),
    'hostname': const FormidableHostnameError(),
    'fqdn': const FormidableFqdnError(),
    'domain': const FormidableDomainError(),
    'latitude': const FormidableLatitudeError(),
    'longitude': const FormidableLongitudeError(),
    'latLng': const FormidableLatLngError(),
    'creditCard': const FormidableCreditCardError(brands: []),
    'creditCardBrands': const FormidableCreditCardError(
      brands: [CardBrand.visa, CardBrand.amex],
    ),
    'cardCvc': const FormidableCardCvcError(),
    'cardExpiry': const FormidableCardExpiryError(),
    'cardExpired': const FormidableCardExpiredError(),
    'iban': const FormidableIbanError(countries: []),
    'ibanCountries': const FormidableIbanError(countries: ['IT', 'DE']),
    'bic': const FormidableBicError(),
    'currencyCode': const FormidableCurrencyCodeError(),
    'countryCode': const FormidableCountryCodeError(),
    'languageCode': const FormidableLanguageCodeError(),
    'localeCode': const FormidableLocaleCodeError(),
    'phone': const FormidablePhoneError(),
  };

  /// Looks up the message of every error in [language] through the widget tree.
  Future<Map<String, String>> messagesIn(
    WidgetTester tester,
    String language,
  ) async {
    final messages = <String, String>{};
    await tester.pumpWidget(
      MaterialApp(
        locale: Locale(language),
        supportedLocales: FormidableLocalizations.supportedLocales,
        localizationsDelegates: [
          FormidableLocalizations.delegate,
          ...GlobalMaterialLocalizations.delegates,
        ],
        home: Builder(
          builder: (context) {
            for (final entry in errors.entries) {
              messages[entry.key] = formidableMessageOf(context, entry.value);
            }
            return const SizedBox();
          },
        ),
      ),
    );
    return messages;
  }

  const english = {
    'notEmpty': 'Must not be empty.',
    'unique': 'Must not contain duplicates: a, 3.',
    'containsAll': 'Must contain: x, y.',
    'containsNone': 'Must not contain: root.',
    'hasKeys': 'Must have the keys: host.',
    'each': 'Item 2 is invalid.',
    'eachMany': 'Items 1, 4 are invalid.',
    'minFileSize': 'The file must be at least 1.5 KB (it is 100 B).',
    'maxFileSize': 'The file must be at most 5 MB (it is 7 MB).',
    'fileExtension': 'The file must be one of these types: .pdf, .docx.',
    'mimeType': 'The file type must be one of: image/*.',
    'imageFile': 'The file must be an image.',
    'fileName':
        'The file name is not valid (at most 40 characters, '
        r'without / \ : * ? " < > |).',
    'ipV4': 'Must be a valid IPv4 address.',
    'ipV6': 'Must be a valid IPv6 address.',
    'ip': 'Must be a valid IP address.',
    'cidrV4': 'Must be a valid IPv4 network in CIDR notation.',
    'cidrV6': 'Must be a valid IPv6 network in CIDR notation.',
    'cidr': 'Must be a valid network in CIDR notation.',
    'macAddress': 'Must be a valid MAC address.',
    'hostname': 'Must be a valid host name.',
    'fqdn': 'Must be a fully qualified domain name.',
    'domain': 'Must be a valid domain name.',
    'latitude': 'Must be a latitude between -90 and 90.',
    'longitude': 'Must be a longitude between -180 and 180.',
    'latLng': 'Must be coordinates written as "latitude, longitude".',
    'creditCard': 'Must be a valid card number.',
    'creditCardBrands':
        'Must be a valid card number (accepted: Visa, American Express).',
    'cardCvc': 'Must be a 3 or 4 digit security code.',
    'cardExpiry': 'Must be an expiry date written as MM/YY.',
    'cardExpired': 'The card has expired.',
    'iban': 'Must be a valid IBAN.',
    'ibanCountries': 'Must be a valid IBAN from: IT, DE.',
    'bic': 'Must be a valid BIC.',
    'currencyCode': 'Must be a valid currency code.',
    'countryCode': 'Must be a valid country code.',
    'languageCode': 'Must be a valid language code.',
    'localeCode': 'Must be a valid locale, for example en-US.',
    'phone':
        'Must be a phone number in international format (for example '
        '+12025550123).',
  };

  /// Spot checks of the wording that depends on data, per language.
  const spots = {
    'it': {
      'each': "L'elemento 2 non è valido.",
      'eachMany': 'Gli elementi 1, 4 non sono validi.',
      'minFileSize': 'Il file deve essere di almeno 1,5 KB (è 100 B).',
      'ibanCountries': 'Deve essere un IBAN valido tra i paesi: IT, DE.',
      'cardCvc': 'Deve essere un codice di sicurezza di 3 o 4 cifre.',
    },
    'es': {
      'each': 'El elemento 2 no es válido.',
      'eachMany': 'Los elementos 1, 4 no son válidos.',
      'minFileSize': 'El archivo debe pesar al menos 1,5 KB (pesa 100 B).',
      'ibanCountries': 'Debe ser un IBAN válido de: IT, DE.',
      'cardExpired': 'La tarjeta ha caducado.',
    },
    'fr': {
      'each': "L'élément 2 n'est pas valide.",
      'eachMany': 'Les éléments 1, 4 ne sont pas valides.',
      'maxFileSize': 'Le fichier doit faire au plus 5 MB (il fait 7 MB).',
      'ibanCountries': 'Doit être un IBAN valide parmi les pays : IT, DE.',
      'cardExpired': 'La carte a expiré.',
    },
    'de': {
      'each': 'Element 2 ist ungültig.',
      'eachMany': 'Die Elemente 1, 4 sind ungültig.',
      'maxFileSize': 'Die Datei darf höchstens 5 MB groß sein (aktuell 7 MB).',
      'ibanCountries':
          'Muss eine gültige IBAN aus folgenden Ländern sein: IT, DE.',
      'cardExpired': 'Die Karte ist abgelaufen.',
    },
  };

  for (final language in languages) {
    testWidgets('says every error in $language', (tester) async {
      final messages = await messagesIn(tester, language);

      expect(messages.keys, errors.keys);
      for (final entry in messages.entries) {
        // The last resort is the English toString, so a message that equals
        // it in another language means the lookup found nothing.
        expect(entry.value, isNotEmpty, reason: entry.key);
        if (language == 'en') {
          expect(entry.value, english[entry.key], reason: entry.key);
        } else {
          expect(
            entry.value,
            isNot(english[entry.key]),
            reason: '${entry.key} is not translated to $language',
          );
        }
      }
      for (final spot in (spots[language] ?? const {}).entries) {
        expect(messages[spot.key], spot.value, reason: spot.key);
      }
    });
  }
}

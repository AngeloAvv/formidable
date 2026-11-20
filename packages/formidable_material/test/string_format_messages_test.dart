import 'package:flutter_test/flutter_test.dart';
import 'package:formidable/formidable.dart';
import 'package:formidable_flutter/formidable_flutter.dart';
import 'package:material_ui/material_ui.dart';

/// The messages of the built-in string and format errors in the five languages.
///
/// The first table checks the wording and the plural forms through the
/// localizations of each language. The widget tests check that the lookup of a
/// widget reaches them.
const _languages = ['en', 'it', 'es', 'fr', 'de'];

final _messages = <(String, FormidableValidationError, List<String>)>[
  (
    'MaxLength',
    const FormidableMaxLengthError(maxLength: 5, actualLength: 7),
    [
      'Must be at most 5 characters long (got 7).',
      'Deve contenere al massimo 5 caratteri (ne ha 7).',
      'Debe tener como máximo 5 caracteres (tiene 7).',
      'Doit contenir au plus 5 caractères (actuellement 7).',
      'Darf höchstens 5 Zeichen lang sein (aktuell 7).',
    ],
  ),
  (
    'MaxLength one',
    const FormidableMaxLengthError(maxLength: 1, actualLength: 2),
    [
      'Must be at most 1 character long (got 2).',
      'Deve contenere al massimo 1 carattere (ne ha 2).',
      'Debe tener como máximo 1 carácter (tiene 2).',
      'Doit contenir au plus 1 caractère (actuellement 2).',
      'Darf höchstens 1 Zeichen lang sein (aktuell 2).',
    ],
  ),
  (
    'Length.exactly',
    const FormidableExactLengthError(length: 4, actualLength: 2),
    [
      'Must be exactly 4 characters long (got 2).',
      'Deve contenere esattamente 4 caratteri (ne ha 2).',
      'Debe tener exactamente 4 caracteres (tiene 2).',
      'Doit contenir exactement 4 caractères (actuellement 2).',
      'Muss genau 4 Zeichen lang sein (aktuell 2).',
    ],
  ),
  (
    'Pattern',
    const FormidablePatternError(pattern: 'x', negated: false),
    [
      'Does not match the required format.',
      'Non corrisponde al formato richiesto.',
      'No coincide con el formato requerido.',
      'Ne correspond pas au format requis.',
      'Entspricht nicht dem erforderlichen Format.',
    ],
  ),
  (
    'Pattern negated',
    const FormidablePatternError(pattern: 'x', negated: true),
    [
      'Must not match the pattern.',
      'Non deve corrispondere al formato.',
      'No debe coincidir con el formato.',
      'Ne doit pas correspondre au format.',
      'Darf nicht dem Format entsprechen.',
    ],
  ),
  (
    'StartsWith',
    const FormidableStartsWithError(prefix: 'ab'),
    [
      'Must start with "ab".',
      'Deve iniziare con "ab".',
      'Debe empezar por "ab".',
      'Doit commencer par "ab".',
      'Muss mit "ab" beginnen.',
    ],
  ),
  (
    'EndsWith',
    const FormidableEndsWithError(suffix: 'yz'),
    [
      'Must end with "yz".',
      'Deve terminare con "yz".',
      'Debe terminar en "yz".',
      'Doit se terminer par "yz".',
      'Muss mit "yz" enden.',
    ],
  ),
  (
    'DoesntStartWith',
    const FormidableDoesntStartWithError(prefix: 'ab'),
    [
      'Must not start with "ab".',
      'Non deve iniziare con "ab".',
      'No debe empezar por "ab".',
      'Ne doit pas commencer par "ab".',
      'Darf nicht mit "ab" beginnen.',
    ],
  ),
  (
    'DoesntEndWith',
    const FormidableDoesntEndWithError(suffix: 'yz'),
    [
      'Must not end with "yz".',
      'Non deve terminare con "yz".',
      'No debe terminar en "yz".',
      'Ne doit pas se terminer par "yz".',
      'Darf nicht mit "yz" enden.',
    ],
  ),
  (
    'Contains',
    const FormidableContainsError(text: 'mid'),
    [
      'Must contain "mid".',
      'Deve contenere "mid".',
      'Debe contener "mid".',
      'Doit contenir "mid".',
      'Muss "mid" enthalten.',
    ],
  ),
  (
    'NotContains',
    const FormidableNotContainsError(text: 'bad'),
    [
      'Must not contain "bad".',
      'Non deve contenere "bad".',
      'No debe contener "bad".',
      'Ne doit pas contenir "bad".',
      'Darf "bad" nicht enthalten.',
    ],
  ),
  (
    'Alpha',
    const FormidableAlphaError(),
    [
      'Must contain only letters.',
      'Deve contenere solo lettere.',
      'Debe contener solo letras.',
      'Doit contenir uniquement des lettres.',
      'Darf nur Buchstaben enthalten.',
    ],
  ),
  (
    'AlphaNumeric',
    const FormidableAlphaNumericError(),
    [
      'Must contain only letters and digits.',
      'Deve contenere solo lettere e cifre.',
      'Debe contener solo letras y números.',
      'Doit contenir uniquement des lettres et des chiffres.',
      'Darf nur Buchstaben und Ziffern enthalten.',
    ],
  ),
  (
    'AlphaDash',
    const FormidableAlphaDashError(),
    [
      'Must contain only letters, digits, dashes and underscores.',
      'Deve contenere solo lettere, cifre, trattini e trattini bassi.',
      'Debe contener solo letras, números, guiones y guiones bajos.',
      'Doit contenir uniquement des lettres, des chiffres, des tirets et des tirets bas.',
      'Darf nur Buchstaben, Ziffern, Bindestriche und Unterstriche enthalten.',
    ],
  ),
  (
    'AlphaSpaces',
    const FormidableAlphaSpacesError(),
    [
      'Must contain only letters and spaces.',
      'Deve contenere solo lettere e spazi.',
      'Debe contener solo letras y espacios.',
      'Doit contenir uniquement des lettres et des espaces.',
      'Darf nur Buchstaben und Leerzeichen enthalten.',
    ],
  ),
  (
    'Ascii',
    const FormidableAsciiError(),
    [
      'Must contain only ASCII characters.',
      'Deve contenere solo caratteri ASCII.',
      'Debe contener solo caracteres ASCII.',
      'Doit contenir uniquement des caractères ASCII.',
      'Darf nur ASCII-Zeichen enthalten.',
    ],
  ),
  (
    'Lowercase',
    const FormidableLowercaseError(),
    [
      'Must be lowercase.',
      'Deve essere in minuscolo.',
      'Debe estar en minúsculas.',
      'Doit être en minuscules.',
      'Muss kleingeschrieben sein.',
    ],
  ),
  (
    'Uppercase',
    const FormidableUppercaseError(),
    [
      'Must be uppercase.',
      'Deve essere in maiuscolo.',
      'Debe estar en mayúsculas.',
      'Doit être en majuscules.',
      'Muss großgeschrieben sein.',
    ],
  ),
  (
    'HasLowercase',
    const FormidableHasLowercaseError(min: 2, actual: 1),
    [
      'Must contain at least 2 lowercase letters (got 1).',
      'Deve contenere almeno 2 lettere minuscole (ne ha 1).',
      'Debe tener al menos 2 letras minúsculas (tiene 1).',
      'Doit contenir au moins 2 lettres minuscules (actuellement 1).',
      'Muss mindestens 2 Kleinbuchstaben enthalten (aktuell 1).',
    ],
  ),
  (
    'HasLowercase one',
    const FormidableHasLowercaseError(min: 1, actual: 0),
    [
      'Must contain at least 1 lowercase letter (got 0).',
      'Deve contenere almeno 1 lettera minuscola (ne ha 0).',
      'Debe tener al menos 1 letra minúscula (tiene 0).',
      'Doit contenir au moins 1 lettre minuscule (actuellement 0).',
      'Muss mindestens 1 Kleinbuchstabe enthalten (aktuell 0).',
    ],
  ),
  (
    'HasUppercase',
    const FormidableHasUppercaseError(min: 2, actual: 1),
    [
      'Must contain at least 2 uppercase letters (got 1).',
      'Deve contenere almeno 2 lettere maiuscole (ne ha 1).',
      'Debe tener al menos 2 letras mayúsculas (tiene 1).',
      'Doit contenir au moins 2 lettres majuscules (actuellement 1).',
      'Muss mindestens 2 Großbuchstaben enthalten (aktuell 1).',
    ],
  ),
  (
    'HasDigit',
    const FormidableHasDigitError(min: 2, actual: 1),
    [
      'Must contain at least 2 digits (got 1).',
      'Deve contenere almeno 2 cifre (ne ha 1).',
      'Debe tener al menos 2 dígitos (tiene 1).',
      'Doit contenir au moins 2 chiffres (actuellement 1).',
      'Muss mindestens 2 Ziffern enthalten (aktuell 1).',
    ],
  ),
  (
    'HasSpecialChar',
    const FormidableHasSpecialCharError(min: 2, actual: 1),
    [
      'Must contain at least 2 special characters (got 1).',
      'Deve contenere almeno 2 caratteri speciali (ne ha 1).',
      'Debe tener al menos 2 caracteres especiales (tiene 1).',
      'Doit contenir au moins 2 caractères spéciaux (actuellement 1).',
      'Muss mindestens 2 Sonderzeichen enthalten (aktuell 1).',
    ],
  ),
  (
    'SingleLine',
    const FormidableSingleLineError(),
    [
      'Must be a single line.',
      'Deve essere su una sola riga.',
      'Debe ser una sola línea.',
      'Doit tenir sur une seule ligne.',
      'Muss einzeilig sein.',
    ],
  ),
  (
    'MinWords',
    const FormidableMinWordsError(minWords: 3, actualWords: 1),
    [
      'Must have at least 3 words (got 1).',
      'Deve contenere almeno 3 parole (ne ha 1).',
      'Debe tener al menos 3 palabras (tiene 1).',
      'Doit contenir au moins 3 mots (actuellement 1).',
      'Muss mindestens 3 Wörter enthalten (aktuell 1).',
    ],
  ),
  (
    'MinWords one',
    const FormidableMinWordsError(minWords: 1, actualWords: 0),
    [
      'Must have at least 1 word (got 0).',
      'Deve contenere almeno 1 parola (ne ha 0).',
      'Debe tener al menos 1 palabra (tiene 0).',
      'Doit contenir au moins 1 mot (actuellement 0).',
      'Muss mindestens 1 Wort enthalten (aktuell 0).',
    ],
  ),
  (
    'MaxWords',
    const FormidableMaxWordsError(maxWords: 3, actualWords: 5),
    [
      'Must have at most 3 words (got 5).',
      'Deve contenere al massimo 3 parole (ne ha 5).',
      'Debe tener como máximo 3 palabras (tiene 5).',
      'Doit contenir au plus 3 mots (actuellement 5).',
      'Darf höchstens 3 Wörter enthalten (aktuell 5).',
    ],
  ),
  (
    'Slug',
    const FormidableSlugError(),
    [
      'Must be a slug: lowercase letters and digits separated by single dashes.',
      'Deve essere uno slug: lettere minuscole e cifre separate da singoli trattini.',
      'Debe ser un slug: letras minúsculas y números separados por guiones simples.',
      'Doit être un slug : lettres minuscules et chiffres séparés par des tirets simples.',
      'Muss ein Slug sein: Kleinbuchstaben und Ziffern, getrennt durch einzelne Bindestriche.',
    ],
  ),
  (
    'Email',
    const FormidableEmailError(),
    [
      'Must be a valid email address.',
      'Deve essere un indirizzo email valido.',
      'Debe ser una dirección de correo válida.',
      'Doit être une adresse e-mail valide.',
      'Muss eine gültige E-Mail-Adresse sein.',
    ],
  ),
  (
    'Url',
    const FormidableUrlError(schemes: ['https'], requireTld: true),
    [
      'Must be a valid URL.',
      'Deve essere un URL valido.',
      'Debe ser una URL válida.',
      'Doit être une URL valide.',
      'Muss eine gültige URL sein.',
    ],
  ),
  (
    'Uuid',
    const FormidableUuidError(),
    [
      'Must be a valid UUID.',
      'Deve essere un UUID valido.',
      'Debe ser un UUID válido.',
      'Doit être un UUID valide.',
      'Muss eine gültige UUID sein.',
    ],
  ),
  (
    'Uuid v4',
    const FormidableUuidError(version: 4),
    [
      'Must be a valid UUID v4.',
      'Deve essere un UUID v4 valido.',
      'Debe ser un UUID v4 válido.',
      'Doit être un UUID v4 valide.',
      'Muss eine gültige UUID v4 sein.',
    ],
  ),
  (
    'Ulid',
    const FormidableUlidError(),
    [
      'Must be a valid ULID.',
      'Deve essere un ULID valido.',
      'Debe ser un ULID válido.',
      'Doit être un ULID valide.',
      'Muss eine gültige ULID sein.',
    ],
  ),
  (
    'HexColor',
    const FormidableHexColorError(),
    [
      'Must be a valid hex color, like #1A2B3C.',
      'Deve essere un colore esadecimale valido, ad esempio #1A2B3C.',
      'Debe ser un color hexadecimal válido, por ejemplo #1A2B3C.',
      'Doit être une couleur hexadécimale valide, par exemple #1A2B3C.',
      'Muss eine gültige Hex-Farbe sein, zum Beispiel #1A2B3C.',
    ],
  ),
  (
    'Color',
    const FormidableColorError(formats: [ColorFormat.hex, ColorFormat.rgb]),
    [
      'Must be a valid color (hex, rgb).',
      'Deve essere un colore valido (hex, rgb).',
      'Debe ser un color válido (hex, rgb).',
      'Doit être une couleur valide (hex, rgb).',
      'Muss eine gültige Farbe sein (hex, rgb).',
    ],
  ),
  (
    'Hexadecimal',
    const FormidableHexadecimalError(),
    [
      'Must be a hexadecimal number.',
      'Deve essere un numero esadecimale.',
      'Debe ser un número hexadecimal.',
      'Doit être un nombre hexadécimal.',
      'Muss eine Hexadezimalzahl sein.',
    ],
  ),
  (
    'Octal',
    const FormidableOctalError(),
    [
      'Must be an octal number.',
      'Deve essere un numero ottale.',
      'Debe ser un número octal.',
      'Doit être un nombre octal.',
      'Muss eine Oktalzahl sein.',
    ],
  ),
  (
    'Base64',
    const FormidableBase64Error(),
    [
      'Must be valid Base64.',
      'Deve essere un valore Base64 valido.',
      'Debe ser un valor Base64 válido.',
      'Doit être une valeur Base64 valide.',
      'Muss ein gültiger Base64-Wert sein.',
    ],
  ),
  (
    'Json',
    const FormidableJsonError(),
    [
      'Must be valid JSON.',
      'Deve essere un JSON valido.',
      'Debe ser un JSON válido.',
      'Doit être un JSON valide.',
      'Muss gültiges JSON sein.',
    ],
  ),
  (
    'Jwt',
    const FormidableJwtError(),
    [
      'Must be a valid JSON Web Token.',
      'Deve essere un JSON Web Token valido.',
      'Debe ser un JSON Web Token válido.',
      'Doit être un JSON Web Token valide.',
      'Muss ein gültiges JSON Web Token sein.',
    ],
  ),
  (
    'SemVer',
    const FormidableSemVerError(),
    [
      'Must be a valid semantic version, like 1.2.3.',
      'Deve essere una versione semantica valida, ad esempio 1.2.3.',
      'Debe ser una versión semántica válida, por ejemplo 1.2.3.',
      'Doit être une version sémantique valide, par exemple 1.2.3.',
      'Muss eine gültige semantische Version sein, zum Beispiel 1.2.3.',
    ],
  ),
  (
    'Luhn',
    const FormidableLuhnError(),
    [
      'Must be a valid number (checksum does not match).',
      'Deve essere un numero valido (il codice di controllo non corrisponde).',
      'Debe ser un número válido (el dígito de control no coincide).',
      'Doit être un numéro valide (la clé de contrôle ne correspond pas).',
      'Muss eine gültige Nummer sein (die Prüfsumme stimmt nicht).',
    ],
  ),
  (
    'Isbn',
    const FormidableIsbnError(),
    [
      'Must be a valid ISBN.',
      'Deve essere un ISBN valido.',
      'Debe ser un ISBN válido.',
      'Doit être un ISBN valide.',
      'Muss eine gültige ISBN sein.',
    ],
  ),
  (
    'Isbn-13',
    const FormidableIsbnError(version: 13),
    [
      'Must be a valid ISBN-13.',
      'Deve essere un ISBN-13 valido.',
      'Debe ser un ISBN-13 válido.',
      'Doit être un ISBN-13 valide.',
      'Muss eine gültige ISBN-13 sein.',
    ],
  ),
];

FormidableLocalizations _localizations(String language) => switch (language) {
  'it' => const FormidableLocalizationsIt(),
  'es' => const FormidableLocalizationsEs(),
  'fr' => const FormidableLocalizationsFr(),
  'de' => const FormidableLocalizationsDe(),
  _ => const FormidableLocalizationsEn(),
};

void main() {
  group('built-in string and format messages', () {
    for (final (name, error, texts) in _messages) {
      test('$name has a message in every language', () {
        for (var i = 0; i < _languages.length; i++) {
          expect(
            _localizations(_languages[i]).messageOf(error),
            texts[i],
            reason: '${_languages[i]}: $name',
          );
        }
      });
    }
  });

  group('lookup through a widget', () {
    Future<String> messageIn(
      WidgetTester tester,
      String language,
      FormidableValidationError error,
    ) async {
      late String message;
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
              message = formidableMessageOf(context, error);
              return const SizedBox();
            },
          ),
        ),
      );
      return message;
    }

    for (var i = 0; i < _languages.length; i++) {
      testWidgets('says a string and a format error in ${_languages[i]}', (
        tester,
      ) async {
        for (final name in ['MaxLength', 'Slug', 'Email', 'SemVer']) {
          final (_, error, texts) = _messages.firstWhere((m) => m.$1 == name);

          expect(await messageIn(tester, _languages[i], error), texts[i]);
        }
      });
    }
  });
}

import 'package:formidable/formidable.dart';

/// Messages for the errors of the locale Validators.
abstract mixin class FormidableLocaleMessages {
  /// The value is not a country code.
  String countryCode();

  /// The value is not a language code.
  String languageCode();

  /// The value is not a locale.
  String localeCode();

  /// The value is not a phone number in international format.
  String phone();

  /// The message for a locale error, or null for any other error.
  String? localeMessageOf(FormidableValidationError error) => switch (error) {
    FormidableCountryCodeError() => countryCode(),
    FormidableLanguageCodeError() => languageCode(),
    FormidableLocaleCodeError() => localeCode(),
    FormidablePhoneError() => phone(),
    _ => null,
  };
}

mixin FormidableLocaleMessagesEn implements FormidableLocaleMessages {
  @override
  String countryCode() => 'Must be a valid country code.';

  @override
  String languageCode() => 'Must be a valid language code.';

  @override
  String localeCode() => 'Must be a valid locale, for example en-US.';

  @override
  String phone() =>
      'Must be a phone number in international format (for example '
      '+12025550123).';
}

mixin FormidableLocaleMessagesIt implements FormidableLocaleMessages {
  @override
  String countryCode() => 'Deve essere un codice paese valido.';

  @override
  String languageCode() => 'Deve essere un codice lingua valido.';

  @override
  String localeCode() => 'Deve essere un locale valido, ad esempio it-IT.';

  @override
  String phone() =>
      'Deve essere un numero di telefono in formato internazionale (ad '
      'esempio +393331234567).';
}

mixin FormidableLocaleMessagesEs implements FormidableLocaleMessages {
  @override
  String countryCode() => 'Debe ser un código de país válido.';

  @override
  String languageCode() => 'Debe ser un código de idioma válido.';

  @override
  String localeCode() =>
      'Debe ser una configuración regional válida, por ejemplo es-ES.';

  @override
  String phone() =>
      'Debe ser un número de teléfono en formato internacional (por ejemplo '
      '+34612345678).';
}

mixin FormidableLocaleMessagesFr implements FormidableLocaleMessages {
  @override
  String countryCode() => 'Doit être un code pays valide.';

  @override
  String languageCode() => 'Doit être un code de langue valide.';

  @override
  String localeCode() => 'Doit être une locale valide, par exemple fr-FR.';

  @override
  String phone() =>
      'Doit être un numéro de téléphone au format international (par exemple '
      '+33612345678).';
}

mixin FormidableLocaleMessagesDe implements FormidableLocaleMessages {
  @override
  String countryCode() => 'Muss ein gültiger Ländercode sein.';

  @override
  String languageCode() => 'Muss ein gültiger Sprachcode sein.';

  @override
  String localeCode() =>
      'Muss ein gültiges Gebietsschema sein, zum Beispiel de-DE.';

  @override
  String phone() =>
      'Muss eine Telefonnummer im internationalen Format sein (zum Beispiel '
      '+4915123456789).';
}

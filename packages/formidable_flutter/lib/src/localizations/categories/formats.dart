import 'package:formidable/formidable.dart';

String _names(List<ColorFormat> formats) =>
    formats.map((format) => format.name).join(', ');

/// Messages for the errors of the formats and identifiers Validators.
abstract mixin class FormidableFormatMessages {
  /// The value is not an email address.
  String email();

  /// The value is not a URL.
  String url();

  /// The value is not a UUID, or not of [version].
  String uuid(int? version);

  /// The value is not a ULID.
  String ulid();

  /// The value is not a hex color.
  String hexColor();

  /// The value is not a color in one of the [formats].
  String color(List<ColorFormat> formats);

  /// The value is not a hexadecimal number.
  String hexadecimal();

  /// The value is not an octal number.
  String octal();

  /// The value is not Base64.
  String base64();

  /// The value is not JSON.
  String json();

  /// The value is not a JSON Web Token.
  String jwt();

  /// The value is not a semantic version.
  String semVer();

  /// The value fails the Luhn check.
  String luhn();

  /// The value is not an ISBN, or not of [version].
  String isbn(int? version);

  /// The message for a format error, or null for any other error.
  String? formatMessageOf(FormidableValidationError error) => switch (error) {
    FormidableEmailError() => email(),
    FormidableUrlError() => url(),
    FormidableUuidError(:final version) => uuid(version),
    FormidableUlidError() => ulid(),
    FormidableHexColorError() => hexColor(),
    FormidableColorError(:final formats) => color(formats),
    FormidableHexadecimalError() => hexadecimal(),
    FormidableOctalError() => octal(),
    FormidableBase64Error() => base64(),
    FormidableJsonError() => json(),
    FormidableJwtError() => jwt(),
    FormidableSemVerError() => semVer(),
    FormidableLuhnError() => luhn(),
    FormidableIsbnError(:final version) => isbn(version),
    _ => null,
  };
}

mixin FormidableFormatMessagesEn implements FormidableFormatMessages {
  @override
  String email() => 'Must be a valid email address.';

  @override
  String url() => 'Must be a valid URL.';

  @override
  String uuid(int? version) => version == null
      ? 'Must be a valid UUID.'
      : 'Must be a valid UUID v$version.';

  @override
  String ulid() => 'Must be a valid ULID.';

  @override
  String hexColor() => 'Must be a valid hex color, like #1A2B3C.';

  @override
  String color(List<ColorFormat> formats) =>
      'Must be a valid color (${_names(formats)}).';

  @override
  String hexadecimal() => 'Must be a hexadecimal number.';

  @override
  String octal() => 'Must be an octal number.';

  @override
  String base64() => 'Must be valid Base64.';

  @override
  String json() => 'Must be valid JSON.';

  @override
  String jwt() => 'Must be a valid JSON Web Token.';

  @override
  String semVer() => 'Must be a valid semantic version, like 1.2.3.';

  @override
  String luhn() => 'Must be a valid number (checksum does not match).';

  @override
  String isbn(int? version) => version == null
      ? 'Must be a valid ISBN.'
      : 'Must be a valid ISBN-$version.';
}

mixin FormidableFormatMessagesIt implements FormidableFormatMessages {
  @override
  String email() => 'Deve essere un indirizzo email valido.';

  @override
  String url() => 'Deve essere un URL valido.';

  @override
  String uuid(int? version) => version == null
      ? 'Deve essere un UUID valido.'
      : 'Deve essere un UUID v$version valido.';

  @override
  String ulid() => 'Deve essere un ULID valido.';

  @override
  String hexColor() =>
      'Deve essere un colore esadecimale valido, ad esempio #1A2B3C.';

  @override
  String color(List<ColorFormat> formats) =>
      'Deve essere un colore valido (${_names(formats)}).';

  @override
  String hexadecimal() => 'Deve essere un numero esadecimale.';

  @override
  String octal() => 'Deve essere un numero ottale.';

  @override
  String base64() => 'Deve essere un valore Base64 valido.';

  @override
  String json() => 'Deve essere un JSON valido.';

  @override
  String jwt() => 'Deve essere un JSON Web Token valido.';

  @override
  String semVer() =>
      'Deve essere una versione semantica valida, ad esempio 1.2.3.';

  @override
  String luhn() =>
      'Deve essere un numero valido (il codice di controllo non corrisponde).';

  @override
  String isbn(int? version) => version == null
      ? 'Deve essere un ISBN valido.'
      : 'Deve essere un ISBN-$version valido.';
}

mixin FormidableFormatMessagesEs implements FormidableFormatMessages {
  @override
  String email() => 'Debe ser una dirección de correo válida.';

  @override
  String url() => 'Debe ser una URL válida.';

  @override
  String uuid(int? version) => version == null
      ? 'Debe ser un UUID válido.'
      : 'Debe ser un UUID v$version válido.';

  @override
  String ulid() => 'Debe ser un ULID válido.';

  @override
  String hexColor() =>
      'Debe ser un color hexadecimal válido, por ejemplo #1A2B3C.';

  @override
  String color(List<ColorFormat> formats) =>
      'Debe ser un color válido (${_names(formats)}).';

  @override
  String hexadecimal() => 'Debe ser un número hexadecimal.';

  @override
  String octal() => 'Debe ser un número octal.';

  @override
  String base64() => 'Debe ser un valor Base64 válido.';

  @override
  String json() => 'Debe ser un JSON válido.';

  @override
  String jwt() => 'Debe ser un JSON Web Token válido.';

  @override
  String semVer() =>
      'Debe ser una versión semántica válida, por ejemplo 1.2.3.';

  @override
  String luhn() =>
      'Debe ser un número válido (el dígito de control no coincide).';

  @override
  String isbn(int? version) => version == null
      ? 'Debe ser un ISBN válido.'
      : 'Debe ser un ISBN-$version válido.';
}

mixin FormidableFormatMessagesFr implements FormidableFormatMessages {
  @override
  String email() => 'Doit être une adresse e-mail valide.';

  @override
  String url() => 'Doit être une URL valide.';

  @override
  String uuid(int? version) => version == null
      ? 'Doit être un UUID valide.'
      : 'Doit être un UUID v$version valide.';

  @override
  String ulid() => 'Doit être un ULID valide.';

  @override
  String hexColor() =>
      'Doit être une couleur hexadécimale valide, par exemple #1A2B3C.';

  @override
  String color(List<ColorFormat> formats) =>
      'Doit être une couleur valide (${_names(formats)}).';

  @override
  String hexadecimal() => 'Doit être un nombre hexadécimal.';

  @override
  String octal() => 'Doit être un nombre octal.';

  @override
  String base64() => 'Doit être une valeur Base64 valide.';

  @override
  String json() => 'Doit être un JSON valide.';

  @override
  String jwt() => 'Doit être un JSON Web Token valide.';

  @override
  String semVer() =>
      'Doit être une version sémantique valide, par exemple 1.2.3.';

  @override
  String luhn() =>
      'Doit être un numéro valide (la clé de contrôle ne correspond pas).';

  @override
  String isbn(int? version) => version == null
      ? 'Doit être un ISBN valide.'
      : 'Doit être un ISBN-$version valide.';
}

mixin FormidableFormatMessagesDe implements FormidableFormatMessages {
  @override
  String email() => 'Muss eine gültige E-Mail-Adresse sein.';

  @override
  String url() => 'Muss eine gültige URL sein.';

  @override
  String uuid(int? version) => version == null
      ? 'Muss eine gültige UUID sein.'
      : 'Muss eine gültige UUID v$version sein.';

  @override
  String ulid() => 'Muss eine gültige ULID sein.';

  @override
  String hexColor() =>
      'Muss eine gültige Hex-Farbe sein, zum Beispiel #1A2B3C.';

  @override
  String color(List<ColorFormat> formats) =>
      'Muss eine gültige Farbe sein (${_names(formats)}).';

  @override
  String hexadecimal() => 'Muss eine Hexadezimalzahl sein.';

  @override
  String octal() => 'Muss eine Oktalzahl sein.';

  @override
  String base64() => 'Muss ein gültiger Base64-Wert sein.';

  @override
  String json() => 'Muss gültiges JSON sein.';

  @override
  String jwt() => 'Muss ein gültiges JSON Web Token sein.';

  @override
  String semVer() =>
      'Muss eine gültige semantische Version sein, zum Beispiel 1.2.3.';

  @override
  String luhn() =>
      'Muss eine gültige Nummer sein (die Prüfsumme stimmt nicht).';

  @override
  String isbn(int? version) => version == null
      ? 'Muss eine gültige ISBN sein.'
      : 'Muss eine gültige ISBN-$version sein.';
}

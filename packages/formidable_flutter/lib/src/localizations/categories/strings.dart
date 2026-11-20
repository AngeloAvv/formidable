import 'package:formidable/formidable.dart';

/// Messages for the errors of the strings Validators.
abstract mixin class FormidableStringMessages {
  /// The value is shorter than [minLength].
  String minLength(int minLength, int actualLength);

  /// The value is longer than [maxLength].
  String maxLength(int maxLength, int actualLength);

  /// The value does not have the exact [length].
  String exactLength(int length, int actualLength);

  /// The value does not match [pattern], or matches it when [negated].
  String pattern(String pattern, bool negated);

  /// The value does not start with [prefix].
  String startsWith(String prefix);

  /// The value does not end with [suffix].
  String endsWith(String suffix);

  /// The value starts with [prefix].
  String doesntStartWith(String prefix);

  /// The value ends with [suffix].
  String doesntEndWith(String suffix);

  /// The value does not contain [text].
  String contains(String text);

  /// The value contains [text].
  String notContains(String text);

  /// The value has characters other than letters.
  String alpha();

  /// The value has characters other than letters and digits.
  String alphaNumeric();

  /// The value has characters other than letters, digits, dashes and underscores.
  String alphaDash();

  /// The value has characters other than letters and spaces.
  String alphaSpaces();

  /// The value has characters outside the ASCII range.
  String ascii();

  /// The value has uppercase letters.
  String lowercase();

  /// The value has lowercase letters.
  String uppercase();

  /// The value has fewer than [min] lowercase letters.
  String hasLowercase(int min, int actual);

  /// The value has fewer than [min] uppercase letters.
  String hasUppercase(int min, int actual);

  /// The value has fewer than [min] digits.
  String hasDigit(int min, int actual);

  /// The value has fewer than [min] special characters.
  String hasSpecialChar(int min, int actual);

  /// The value has a line break.
  String singleLine();

  /// The value has fewer than [minWords] words.
  String minWords(int minWords, int actualWords);

  /// The value has more than [maxWords] words.
  String maxWords(int maxWords, int actualWords);

  /// The value is not a slug.
  String slug();

  /// The message for a string error, or null for any other error.
  String? stringMessageOf(FormidableValidationError error) => switch (error) {
    FormidableMinLengthError(:final minLength, :final actualLength) =>
      this.minLength(minLength, actualLength),
    FormidableMaxLengthError(:final maxLength, :final actualLength) =>
      this.maxLength(maxLength, actualLength),
    FormidableExactLengthError(:final length, :final actualLength) =>
      exactLength(length, actualLength),
    FormidablePatternError(:final pattern, :final negated) => this.pattern(
      pattern,
      negated,
    ),
    FormidableStartsWithError(:final prefix) => startsWith(prefix),
    FormidableEndsWithError(:final suffix) => endsWith(suffix),
    FormidableDoesntStartWithError(:final prefix) => doesntStartWith(prefix),
    FormidableDoesntEndWithError(:final suffix) => doesntEndWith(suffix),
    FormidableContainsError(:final text) => contains(text),
    FormidableNotContainsError(:final text) => notContains(text),
    FormidableAlphaError() => alpha(),
    FormidableAlphaNumericError() => alphaNumeric(),
    FormidableAlphaDashError() => alphaDash(),
    FormidableAlphaSpacesError() => alphaSpaces(),
    FormidableAsciiError() => ascii(),
    FormidableLowercaseError() => lowercase(),
    FormidableUppercaseError() => uppercase(),
    FormidableHasLowercaseError(:final min, :final actual) => hasLowercase(
      min,
      actual,
    ),
    FormidableHasUppercaseError(:final min, :final actual) => hasUppercase(
      min,
      actual,
    ),
    FormidableHasDigitError(:final min, :final actual) => hasDigit(min, actual),
    FormidableHasSpecialCharError(:final min, :final actual) => hasSpecialChar(
      min,
      actual,
    ),
    FormidableSingleLineError() => singleLine(),
    FormidableMinWordsError(:final minWords, :final actualWords) =>
      this.minWords(minWords, actualWords),
    FormidableMaxWordsError(:final maxWords, :final actualWords) =>
      this.maxWords(maxWords, actualWords),
    FormidableSlugError() => slug(),
    _ => null,
  };
}

mixin FormidableStringMessagesEn implements FormidableStringMessages {
  @override
  String minLength(int minLength, int actualLength) =>
      'Must be at least $minLength ${minLength == 1 ? 'character' : 'characters'} long (got $actualLength).';

  @override
  String maxLength(int maxLength, int actualLength) =>
      'Must be at most $maxLength ${maxLength == 1 ? 'character' : 'characters'} long (got $actualLength).';

  @override
  String exactLength(int length, int actualLength) =>
      'Must be exactly $length ${length == 1 ? 'character' : 'characters'} long (got $actualLength).';

  @override
  String pattern(String pattern, bool negated) => negated
      ? 'Must not match the pattern.'
      : 'Does not match the required format.';

  @override
  String startsWith(String prefix) => 'Must start with "$prefix".';

  @override
  String endsWith(String suffix) => 'Must end with "$suffix".';

  @override
  String doesntStartWith(String prefix) => 'Must not start with "$prefix".';

  @override
  String doesntEndWith(String suffix) => 'Must not end with "$suffix".';

  @override
  String contains(String text) => 'Must contain "$text".';

  @override
  String notContains(String text) => 'Must not contain "$text".';

  @override
  String alpha() => 'Must contain only letters.';

  @override
  String alphaNumeric() => 'Must contain only letters and digits.';

  @override
  String alphaDash() =>
      'Must contain only letters, digits, dashes and underscores.';

  @override
  String alphaSpaces() => 'Must contain only letters and spaces.';

  @override
  String ascii() => 'Must contain only ASCII characters.';

  @override
  String lowercase() => 'Must be lowercase.';

  @override
  String uppercase() => 'Must be uppercase.';

  @override
  String hasLowercase(int min, int actual) =>
      'Must contain at least $min ${min == 1 ? 'lowercase letter' : 'lowercase letters'} (got $actual).';

  @override
  String hasUppercase(int min, int actual) =>
      'Must contain at least $min ${min == 1 ? 'uppercase letter' : 'uppercase letters'} (got $actual).';

  @override
  String hasDigit(int min, int actual) =>
      'Must contain at least $min ${min == 1 ? 'digit' : 'digits'} (got $actual).';

  @override
  String hasSpecialChar(int min, int actual) =>
      'Must contain at least $min ${min == 1 ? 'special character' : 'special characters'} (got $actual).';

  @override
  String singleLine() => 'Must be a single line.';

  @override
  String minWords(int minWords, int actualWords) =>
      'Must have at least $minWords ${minWords == 1 ? 'word' : 'words'} (got $actualWords).';

  @override
  String maxWords(int maxWords, int actualWords) =>
      'Must have at most $maxWords ${maxWords == 1 ? 'word' : 'words'} (got $actualWords).';

  @override
  String slug() =>
      'Must be a slug: lowercase letters and digits separated by single dashes.';
}

mixin FormidableStringMessagesIt implements FormidableStringMessages {
  @override
  String minLength(int minLength, int actualLength) =>
      'Deve contenere almeno $minLength ${minLength == 1 ? 'carattere' : 'caratteri'} (ne ha $actualLength).';

  @override
  String maxLength(int maxLength, int actualLength) =>
      'Deve contenere al massimo $maxLength ${maxLength == 1 ? 'carattere' : 'caratteri'} (ne ha $actualLength).';

  @override
  String exactLength(int length, int actualLength) =>
      'Deve contenere esattamente $length ${length == 1 ? 'carattere' : 'caratteri'} (ne ha $actualLength).';

  @override
  String pattern(String pattern, bool negated) => negated
      ? 'Non deve corrispondere al formato.'
      : 'Non corrisponde al formato richiesto.';

  @override
  String startsWith(String prefix) => 'Deve iniziare con "$prefix".';

  @override
  String endsWith(String suffix) => 'Deve terminare con "$suffix".';

  @override
  String doesntStartWith(String prefix) => 'Non deve iniziare con "$prefix".';

  @override
  String doesntEndWith(String suffix) => 'Non deve terminare con "$suffix".';

  @override
  String contains(String text) => 'Deve contenere "$text".';

  @override
  String notContains(String text) => 'Non deve contenere "$text".';

  @override
  String alpha() => 'Deve contenere solo lettere.';

  @override
  String alphaNumeric() => 'Deve contenere solo lettere e cifre.';

  @override
  String alphaDash() =>
      'Deve contenere solo lettere, cifre, trattini e trattini bassi.';

  @override
  String alphaSpaces() => 'Deve contenere solo lettere e spazi.';

  @override
  String ascii() => 'Deve contenere solo caratteri ASCII.';

  @override
  String lowercase() => 'Deve essere in minuscolo.';

  @override
  String uppercase() => 'Deve essere in maiuscolo.';

  @override
  String hasLowercase(int min, int actual) =>
      'Deve contenere almeno $min ${min == 1 ? 'lettera minuscola' : 'lettere minuscole'} (ne ha $actual).';

  @override
  String hasUppercase(int min, int actual) =>
      'Deve contenere almeno $min ${min == 1 ? 'lettera maiuscola' : 'lettere maiuscole'} (ne ha $actual).';

  @override
  String hasDigit(int min, int actual) =>
      'Deve contenere almeno $min ${min == 1 ? 'cifra' : 'cifre'} (ne ha $actual).';

  @override
  String hasSpecialChar(int min, int actual) =>
      'Deve contenere almeno $min ${min == 1 ? 'carattere speciale' : 'caratteri speciali'} (ne ha $actual).';

  @override
  String singleLine() => 'Deve essere su una sola riga.';

  @override
  String minWords(int minWords, int actualWords) =>
      'Deve contenere almeno $minWords ${minWords == 1 ? 'parola' : 'parole'} (ne ha $actualWords).';

  @override
  String maxWords(int maxWords, int actualWords) =>
      'Deve contenere al massimo $maxWords ${maxWords == 1 ? 'parola' : 'parole'} (ne ha $actualWords).';

  @override
  String slug() =>
      'Deve essere uno slug: lettere minuscole e cifre separate da singoli trattini.';
}

mixin FormidableStringMessagesEs implements FormidableStringMessages {
  @override
  String minLength(int minLength, int actualLength) =>
      'Debe tener al menos $minLength ${minLength == 1 ? 'carácter' : 'caracteres'} (tiene $actualLength).';

  @override
  String maxLength(int maxLength, int actualLength) =>
      'Debe tener como máximo $maxLength ${maxLength == 1 ? 'carácter' : 'caracteres'} (tiene $actualLength).';

  @override
  String exactLength(int length, int actualLength) =>
      'Debe tener exactamente $length ${length == 1 ? 'carácter' : 'caracteres'} (tiene $actualLength).';

  @override
  String pattern(String pattern, bool negated) => negated
      ? 'No debe coincidir con el formato.'
      : 'No coincide con el formato requerido.';

  @override
  String startsWith(String prefix) => 'Debe empezar por "$prefix".';

  @override
  String endsWith(String suffix) => 'Debe terminar en "$suffix".';

  @override
  String doesntStartWith(String prefix) => 'No debe empezar por "$prefix".';

  @override
  String doesntEndWith(String suffix) => 'No debe terminar en "$suffix".';

  @override
  String contains(String text) => 'Debe contener "$text".';

  @override
  String notContains(String text) => 'No debe contener "$text".';

  @override
  String alpha() => 'Debe contener solo letras.';

  @override
  String alphaNumeric() => 'Debe contener solo letras y números.';

  @override
  String alphaDash() =>
      'Debe contener solo letras, números, guiones y guiones bajos.';

  @override
  String alphaSpaces() => 'Debe contener solo letras y espacios.';

  @override
  String ascii() => 'Debe contener solo caracteres ASCII.';

  @override
  String lowercase() => 'Debe estar en minúsculas.';

  @override
  String uppercase() => 'Debe estar en mayúsculas.';

  @override
  String hasLowercase(int min, int actual) =>
      'Debe tener al menos $min ${min == 1 ? 'letra minúscula' : 'letras minúsculas'} (tiene $actual).';

  @override
  String hasUppercase(int min, int actual) =>
      'Debe tener al menos $min ${min == 1 ? 'letra mayúscula' : 'letras mayúsculas'} (tiene $actual).';

  @override
  String hasDigit(int min, int actual) =>
      'Debe tener al menos $min ${min == 1 ? 'dígito' : 'dígitos'} (tiene $actual).';

  @override
  String hasSpecialChar(int min, int actual) =>
      'Debe tener al menos $min ${min == 1 ? 'carácter especial' : 'caracteres especiales'} (tiene $actual).';

  @override
  String singleLine() => 'Debe ser una sola línea.';

  @override
  String minWords(int minWords, int actualWords) =>
      'Debe tener al menos $minWords ${minWords == 1 ? 'palabra' : 'palabras'} (tiene $actualWords).';

  @override
  String maxWords(int maxWords, int actualWords) =>
      'Debe tener como máximo $maxWords ${maxWords == 1 ? 'palabra' : 'palabras'} (tiene $actualWords).';

  @override
  String slug() =>
      'Debe ser un slug: letras minúsculas y números separados por guiones simples.';
}

mixin FormidableStringMessagesFr implements FormidableStringMessages {
  @override
  String minLength(int minLength, int actualLength) =>
      'Doit contenir au moins $minLength ${minLength == 1 ? 'caractère' : 'caractères'} (actuellement $actualLength).';

  @override
  String maxLength(int maxLength, int actualLength) =>
      'Doit contenir au plus $maxLength ${maxLength == 1 ? 'caractère' : 'caractères'} (actuellement $actualLength).';

  @override
  String exactLength(int length, int actualLength) =>
      'Doit contenir exactement $length ${length == 1 ? 'caractère' : 'caractères'} (actuellement $actualLength).';

  @override
  String pattern(String pattern, bool negated) => negated
      ? 'Ne doit pas correspondre au format.'
      : 'Ne correspond pas au format requis.';

  @override
  String startsWith(String prefix) => 'Doit commencer par "$prefix".';

  @override
  String endsWith(String suffix) => 'Doit se terminer par "$suffix".';

  @override
  String doesntStartWith(String prefix) =>
      'Ne doit pas commencer par "$prefix".';

  @override
  String doesntEndWith(String suffix) =>
      'Ne doit pas se terminer par "$suffix".';

  @override
  String contains(String text) => 'Doit contenir "$text".';

  @override
  String notContains(String text) => 'Ne doit pas contenir "$text".';

  @override
  String alpha() => 'Doit contenir uniquement des lettres.';

  @override
  String alphaNumeric() =>
      'Doit contenir uniquement des lettres et des chiffres.';

  @override
  String alphaDash() =>
      'Doit contenir uniquement des lettres, des chiffres, des tirets et des tirets bas.';

  @override
  String alphaSpaces() =>
      'Doit contenir uniquement des lettres et des espaces.';

  @override
  String ascii() => 'Doit contenir uniquement des caractères ASCII.';

  @override
  String lowercase() => 'Doit être en minuscules.';

  @override
  String uppercase() => 'Doit être en majuscules.';

  @override
  String hasLowercase(int min, int actual) =>
      'Doit contenir au moins $min ${min == 1 ? 'lettre minuscule' : 'lettres minuscules'} (actuellement $actual).';

  @override
  String hasUppercase(int min, int actual) =>
      'Doit contenir au moins $min ${min == 1 ? 'lettre majuscule' : 'lettres majuscules'} (actuellement $actual).';

  @override
  String hasDigit(int min, int actual) =>
      'Doit contenir au moins $min ${min == 1 ? 'chiffre' : 'chiffres'} (actuellement $actual).';

  @override
  String hasSpecialChar(int min, int actual) =>
      'Doit contenir au moins $min ${min == 1 ? 'caractère spécial' : 'caractères spéciaux'} (actuellement $actual).';

  @override
  String singleLine() => 'Doit tenir sur une seule ligne.';

  @override
  String minWords(int minWords, int actualWords) =>
      'Doit contenir au moins $minWords ${minWords == 1 ? 'mot' : 'mots'} (actuellement $actualWords).';

  @override
  String maxWords(int maxWords, int actualWords) =>
      'Doit contenir au plus $maxWords ${maxWords == 1 ? 'mot' : 'mots'} (actuellement $actualWords).';

  @override
  String slug() =>
      'Doit être un slug : lettres minuscules et chiffres séparés par des tirets simples.';
}

mixin FormidableStringMessagesDe implements FormidableStringMessages {
  @override
  String minLength(int minLength, int actualLength) =>
      'Muss mindestens $minLength Zeichen lang sein (aktuell $actualLength).';

  @override
  String maxLength(int maxLength, int actualLength) =>
      'Darf höchstens $maxLength Zeichen lang sein (aktuell $actualLength).';

  @override
  String exactLength(int length, int actualLength) =>
      'Muss genau $length Zeichen lang sein (aktuell $actualLength).';

  @override
  String pattern(String pattern, bool negated) => negated
      ? 'Darf nicht dem Format entsprechen.'
      : 'Entspricht nicht dem erforderlichen Format.';

  @override
  String startsWith(String prefix) => 'Muss mit "$prefix" beginnen.';

  @override
  String endsWith(String suffix) => 'Muss mit "$suffix" enden.';

  @override
  String doesntStartWith(String prefix) => 'Darf nicht mit "$prefix" beginnen.';

  @override
  String doesntEndWith(String suffix) => 'Darf nicht mit "$suffix" enden.';

  @override
  String contains(String text) => 'Muss "$text" enthalten.';

  @override
  String notContains(String text) => 'Darf "$text" nicht enthalten.';

  @override
  String alpha() => 'Darf nur Buchstaben enthalten.';

  @override
  String alphaNumeric() => 'Darf nur Buchstaben und Ziffern enthalten.';

  @override
  String alphaDash() =>
      'Darf nur Buchstaben, Ziffern, Bindestriche und Unterstriche enthalten.';

  @override
  String alphaSpaces() => 'Darf nur Buchstaben und Leerzeichen enthalten.';

  @override
  String ascii() => 'Darf nur ASCII-Zeichen enthalten.';

  @override
  String lowercase() => 'Muss kleingeschrieben sein.';

  @override
  String uppercase() => 'Muss großgeschrieben sein.';

  @override
  String hasLowercase(int min, int actual) =>
      'Muss mindestens $min ${min == 1 ? 'Kleinbuchstabe' : 'Kleinbuchstaben'} enthalten (aktuell $actual).';

  @override
  String hasUppercase(int min, int actual) =>
      'Muss mindestens $min ${min == 1 ? 'Großbuchstabe' : 'Großbuchstaben'} enthalten (aktuell $actual).';

  @override
  String hasDigit(int min, int actual) =>
      'Muss mindestens $min ${min == 1 ? 'Ziffer' : 'Ziffern'} enthalten (aktuell $actual).';

  @override
  String hasSpecialChar(int min, int actual) =>
      'Muss mindestens $min ${min == 1 ? 'Sonderzeichen' : 'Sonderzeichen'} enthalten (aktuell $actual).';

  @override
  String singleLine() => 'Muss einzeilig sein.';

  @override
  String minWords(int minWords, int actualWords) =>
      'Muss mindestens $minWords ${minWords == 1 ? 'Wort' : 'Wörter'} enthalten (aktuell $actualWords).';

  @override
  String maxWords(int maxWords, int actualWords) =>
      'Darf höchstens $maxWords ${maxWords == 1 ? 'Wort' : 'Wörter'} enthalten (aktuell $actualWords).';

  @override
  String slug() =>
      'Muss ein Slug sein: Kleinbuchstaben und Ziffern, getrennt durch einzelne Bindestriche.';
}

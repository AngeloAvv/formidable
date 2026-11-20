import '../validation/validation_error.dart';
import '../validation/validator.dart';
import 'min_length.dart';

/// The value has characters other than letters.
final class FormidableAlphaError extends FormidableValidationError {
  const FormidableAlphaError();

  @override
  String toString() => 'Must contain only letters.';
}

/// The value has characters other than letters and digits.
final class FormidableAlphaNumericError extends FormidableValidationError {
  const FormidableAlphaNumericError();

  @override
  String toString() => 'Must contain only letters and digits.';
}

/// The value has characters other than letters, digits, dashes and underscores.
final class FormidableAlphaDashError extends FormidableValidationError {
  const FormidableAlphaDashError();

  @override
  String toString() =>
      'Must contain only letters, digits, dashes and underscores.';
}

/// The value has characters other than letters and spaces.
final class FormidableAlphaSpacesError extends FormidableValidationError {
  const FormidableAlphaSpacesError();

  @override
  String toString() => 'Must contain only letters and spaces.';
}

/// The value has characters outside the ASCII range.
final class FormidableAsciiError extends FormidableValidationError {
  const FormidableAsciiError();

  @override
  String toString() => 'Must contain only ASCII characters.';
}

/// The value has uppercase letters.
final class FormidableLowercaseError extends FormidableValidationError {
  const FormidableLowercaseError();

  @override
  String toString() => 'Must be lowercase.';
}

/// The value has lowercase letters.
final class FormidableUppercaseError extends FormidableValidationError {
  const FormidableUppercaseError();

  @override
  String toString() => 'Must be uppercase.';
}

/// The value has fewer than [min] lowercase letters.
final class FormidableHasLowercaseError extends FormidableValidationError {
  const FormidableHasLowercaseError({required this.min, required this.actual});

  final int min;

  final int actual;

  @override
  List<Object?> get props => [min, actual];

  @override
  String toString() =>
      'Must contain at least $min lowercase letter${min == 1 ? '' : 's'} (got $actual).';
}

/// The value has fewer than [min] uppercase letters.
final class FormidableHasUppercaseError extends FormidableValidationError {
  const FormidableHasUppercaseError({required this.min, required this.actual});

  final int min;

  final int actual;

  @override
  List<Object?> get props => [min, actual];

  @override
  String toString() =>
      'Must contain at least $min uppercase letter${min == 1 ? '' : 's'} (got $actual).';
}

/// The value has fewer than [min] digits.
final class FormidableHasDigitError extends FormidableValidationError {
  const FormidableHasDigitError({required this.min, required this.actual});

  final int min;

  final int actual;

  @override
  List<Object?> get props => [min, actual];

  @override
  String toString() =>
      'Must contain at least $min digit${min == 1 ? '' : 's'} (got $actual).';
}

/// The value has fewer than [min] special characters.
final class FormidableHasSpecialCharError extends FormidableValidationError {
  const FormidableHasSpecialCharError({
    required this.min,
    required this.actual,
  });

  final int min;

  final int actual;

  @override
  List<Object?> get props => [min, actual];

  @override
  String toString() =>
      'Must contain at least $min special character${min == 1 ? '' : 's'} (got $actual).';
}

/// The value has a line break.
final class FormidableSingleLineError extends FormidableValidationError {
  const FormidableSingleLineError();

  @override
  String toString() => 'Must be a single line.';
}

/// The value has fewer words than required.
final class FormidableMinWordsError extends FormidableValidationError {
  const FormidableMinWordsError({
    required this.minWords,
    required this.actualWords,
  });

  final int minWords;

  final int actualWords;

  @override
  List<Object?> get props => [minWords, actualWords];

  @override
  String toString() =>
      'Must have at least $minWords ${minWords == 1 ? 'word' : 'words'} (got $actualWords).';
}

/// The value has more words than allowed.
final class FormidableMaxWordsError extends FormidableValidationError {
  const FormidableMaxWordsError({
    required this.maxWords,
    required this.actualWords,
  });

  final int maxWords;

  final int actualWords;

  @override
  List<Object?> get props => [maxWords, actualWords];

  @override
  String toString() =>
      'Must have at most $maxWords ${maxWords == 1 ? 'word' : 'words'} (got $actualWords).';
}

/// The value is not a slug.
final class FormidableSlugError extends FormidableValidationError {
  const FormidableSlugError();

  @override
  String toString() =>
      'Must be a slug: lowercase letters and digits separated by single dashes.';
}

/// The characters [HasSpecialChar] counts: anything that is not a letter, a
/// digit or whitespace.
final _special = RegExp(r'[^\p{L}\p{M}\p{N}\s]', unicode: true);
final _lower = RegExp(r'\p{Ll}', unicode: true);
final _upper = RegExp(r'\p{Lu}', unicode: true);
final _digit = RegExp(r'\p{Nd}', unicode: true);
final _alpha = RegExp(r'^[\p{L}\p{M}]+$', unicode: true);
final _alphaNumeric = RegExp(r'^[\p{L}\p{M}\p{Nd}]+$', unicode: true);
final _alphaDash = RegExp(r'^[\p{L}\p{M}\p{Nd}_-]+$', unicode: true);
final _alphaSpaces = RegExp(r'^(?=.*\p{L})[\p{L}\p{M} ]+$', unicode: true);
final _slug = RegExp(r'^[a-z0-9]+(?:-[a-z0-9]+)*$');

int _count(RegExp pattern, String value) => pattern.allMatches(value).length;

int _words(String value) =>
    value.split(RegExp(r'\s+')).where((word) => word.isNotEmpty).length;

/// The value must contain only letters (any script).
class Alpha extends FormidableValidator<String> {
  const Alpha();

  @override
  List<FormidableValidationError> validate(String value) =>
      _alpha.hasMatch(value) ? const [] : const [FormidableAlphaError()];
}

/// The value must contain only letters (any script) and digits.
class AlphaNumeric extends FormidableValidator<String> {
  const AlphaNumeric();

  @override
  List<FormidableValidationError> validate(String value) =>
      _alphaNumeric.hasMatch(value)
      ? const []
      : const [FormidableAlphaNumericError()];
}

/// The value must contain only letters, digits, dashes and underscores.
class AlphaDash extends FormidableValidator<String> {
  const AlphaDash();

  @override
  List<FormidableValidationError> validate(String value) =>
      _alphaDash.hasMatch(value)
      ? const []
      : const [FormidableAlphaDashError()];
}

/// The value must contain only letters and spaces, and at least one letter.
class AlphaSpaces extends FormidableValidator<String> {
  const AlphaSpaces();

  @override
  List<FormidableValidationError> validate(String value) =>
      _alphaSpaces.hasMatch(value)
      ? const []
      : const [FormidableAlphaSpacesError()];
}

/// The value must contain only ASCII characters (code points 0 to 127).
class Ascii extends FormidableValidator<String> {
  const Ascii();

  @override
  List<FormidableValidationError> validate(String value) =>
      value.codeUnits.every((unit) => unit < 128)
      ? const []
      : const [FormidableAsciiError()];
}

/// The value must have no uppercase letters. It only checks, it never changes
/// the value: use a Normalizer to change it.
class Lowercase extends FormidableValidator<String> {
  const Lowercase();

  @override
  List<FormidableValidationError> validate(String value) =>
      value == value.toLowerCase()
      ? const []
      : const [FormidableLowercaseError()];
}

/// The value must have no lowercase letters. It only checks, it never changes
/// the value: use a Normalizer to change it.
class Uppercase extends FormidableValidator<String> {
  const Uppercase();

  @override
  List<FormidableValidationError> validate(String value) =>
      value == value.toUpperCase()
      ? const []
      : const [FormidableUppercaseError()];
}

/// The value must have at least [min] lowercase letters.
class HasLowercase extends FormidableValidator<String> {
  const HasLowercase([this.min = 1]);

  final int min;

  @override
  List<FormidableValidationError> validate(String value) {
    final actual = _count(_lower, value);
    return actual >= min
        ? const []
        : [FormidableHasLowercaseError(min: min, actual: actual)];
  }
}

/// The value must have at least [min] uppercase letters.
class HasUppercase extends FormidableValidator<String> {
  const HasUppercase([this.min = 1]);

  final int min;

  @override
  List<FormidableValidationError> validate(String value) {
    final actual = _count(_upper, value);
    return actual >= min
        ? const []
        : [FormidableHasUppercaseError(min: min, actual: actual)];
  }
}

/// The value must have at least [min] digits.
class HasDigit extends FormidableValidator<String> {
  const HasDigit([this.min = 1]);

  final int min;

  @override
  List<FormidableValidationError> validate(String value) {
    final actual = _count(_digit, value);
    return actual >= min
        ? const []
        : [FormidableHasDigitError(min: min, actual: actual)];
  }
}

/// The value must have at least [min] special characters: anything that is not
/// a letter, a digit or whitespace.
class HasSpecialChar extends FormidableValidator<String> {
  const HasSpecialChar([this.min = 1]);

  final int min;

  @override
  List<FormidableValidationError> validate(String value) {
    final actual = _count(_special, value);
    return actual >= min
        ? const []
        : [FormidableHasSpecialCharError(min: min, actual: actual)];
  }
}

/// A password with a minimum length and a minimum count of lowercase letters,
/// uppercase letters, digits and symbols.
///
/// It reports one error per missing requirement, the same errors as
/// `MinLength`, `HasLowercase`, `HasUppercase`, `HasDigit` and
/// `HasSpecialChar`, in that order. Set a count to 0 to drop the requirement.
class StrongPassword extends FormidableValidator<String> {
  const StrongPassword({
    this.minLength = 8,
    this.minLower = 1,
    this.minUpper = 1,
    this.minDigits = 1,
    this.minSymbols = 1,
  });

  final int minLength;
  final int minLower;
  final int minUpper;
  final int minDigits;
  final int minSymbols;

  @override
  List<FormidableValidationError> validate(String value) => [
    if (value.length < minLength)
      FormidableMinLengthError(
        minLength: minLength,
        actualLength: value.length,
      ),
    ...HasLowercase(minLower).validate(value),
    ...HasUppercase(minUpper).validate(value),
    ...HasDigit(minDigits).validate(value),
    ...HasSpecialChar(minSymbols).validate(value),
  ];
}

/// The value must not contain a line break.
class SingleLine extends FormidableValidator<String> {
  const SingleLine();

  @override
  List<FormidableValidationError> validate(String value) =>
      value.contains('\n') || value.contains('\r')
      ? const [FormidableSingleLineError()]
      : const [];
}

/// The value must have at least [minWords] words, separated by whitespace.
class MinWords extends FormidableValidator<String> {
  const MinWords(this.minWords);

  final int minWords;

  @override
  List<FormidableValidationError> validate(String value) {
    final actual = _words(value);
    return actual >= minWords
        ? const []
        : [FormidableMinWordsError(minWords: minWords, actualWords: actual)];
  }
}

/// The value must have at most [maxWords] words, separated by whitespace.
class MaxWords extends FormidableValidator<String> {
  const MaxWords(this.maxWords);

  final int maxWords;

  @override
  List<FormidableValidationError> validate(String value) {
    final actual = _words(value);
    return actual <= maxWords
        ? const []
        : [FormidableMaxWordsError(maxWords: maxWords, actualWords: actual)];
  }
}

/// The value must be a slug: lowercase ASCII letters and digits, separated by
/// single dashes.
class Slug extends FormidableValidator<String> {
  const Slug();

  @override
  List<FormidableValidationError> validate(String value) =>
      _slug.hasMatch(value) ? const [] : const [FormidableSlugError()];
}

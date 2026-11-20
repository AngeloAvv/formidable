import 'package:formidable/formidable.dart';

import '../format.dart';

/// Messages for the errors of the number Validators.
abstract mixin class FormidableNumberMessages {
  /// The value is below the minimum, or equal to it when the bound is exclusive.
  String min(num min, bool exclusive);

  /// The value is above the maximum, or equal to it when the bound is exclusive.
  String max(num max, bool exclusive);

  /// The value is outside the range.
  String range(num min, num max);

  /// The value is not greater than zero.
  String positive();

  /// The value is less than zero.
  String positiveOrZero();

  /// The value is not less than zero.
  String negative();

  /// The value is greater than zero.
  String negativeOrZero();

  /// The value is zero.
  String nonZero();

  /// The value is not a multiple of [divisor].
  String multipleOf(num divisor);

  /// The value is odd.
  String even();

  /// The value is even.
  String odd();

  /// The value has more decimal places than [maxPlaces].
  String decimalPlaces(int maxPlaces);

  /// The integer part does not have exactly [digits] digits.
  String digits(int digits);

  /// The integer part has fewer than [minDigits] digits.
  String minDigits(int minDigits);

  /// The integer part has more than [maxDigits] digits.
  String maxDigits(int maxDigits);

  /// The value is not a port number.
  String port();

  /// The message for a number error, or null for any other error.
  String? numberMessageOf(FormidableValidationError error) => switch (error) {
    FormidableMinError(:final min, :final exclusive) => this.min(
      min,
      exclusive,
    ),
    FormidableMaxError(:final max, :final exclusive) => this.max(
      max,
      exclusive,
    ),
    FormidableRangeError(:final min, :final max) => range(min, max),
    FormidablePositiveError() => positive(),
    FormidablePositiveOrZeroError() => positiveOrZero(),
    FormidableNegativeError() => negative(),
    FormidableNegativeOrZeroError() => negativeOrZero(),
    FormidableNonZeroError() => nonZero(),
    FormidableMultipleOfError(:final divisor) => multipleOf(divisor),
    FormidableEvenError() => even(),
    FormidableOddError() => odd(),
    FormidableDecimalPlacesError(:final maxPlaces) => decimalPlaces(maxPlaces),
    FormidableDigitsError(:final digits) => this.digits(digits),
    FormidableMinDigitsError(:final minDigits) => this.minDigits(minDigits),
    FormidableMaxDigitsError(:final maxDigits) => this.maxDigits(maxDigits),
    FormidablePortError() => port(),
    _ => null,
  };
}

mixin FormidableNumberMessagesEn implements FormidableNumberMessages {
  @override
  String min(num min, bool exclusive) => exclusive
      ? 'Must be greater than ${formatNumber(min)}.'
      : 'Must be at least ${formatNumber(min)}.';

  @override
  String max(num max, bool exclusive) => exclusive
      ? 'Must be less than ${formatNumber(max)}.'
      : 'Must be at most ${formatNumber(max)}.';

  @override
  String range(num min, num max) =>
      'Must be between ${formatNumber(min)} and ${formatNumber(max)}.';

  @override
  String positive() => 'Must be greater than zero.';

  @override
  String positiveOrZero() => 'Must be zero or greater.';

  @override
  String negative() => 'Must be less than zero.';

  @override
  String negativeOrZero() => 'Must be zero or less.';

  @override
  String nonZero() => 'Must not be zero.';

  @override
  String multipleOf(num divisor) =>
      'Must be a multiple of ${formatNumber(divisor)}.';

  @override
  String even() => 'Must be an even number.';

  @override
  String odd() => 'Must be an odd number.';

  @override
  String decimalPlaces(int maxPlaces) =>
      'Must have at most $maxPlaces decimal ${maxPlaces == 1 ? 'place' : 'places'}.';

  @override
  String digits(int digits) =>
      'Must have exactly $digits ${digits == 1 ? 'digit' : 'digits'}.';

  @override
  String minDigits(int minDigits) =>
      'Must have at least $minDigits ${minDigits == 1 ? 'digit' : 'digits'}.';

  @override
  String maxDigits(int maxDigits) =>
      'Must have at most $maxDigits ${maxDigits == 1 ? 'digit' : 'digits'}.';

  @override
  String port() => 'Must be a port number between 1 and 65535.';
}

mixin FormidableNumberMessagesIt implements FormidableNumberMessages {
  @override
  String min(num min, bool exclusive) => exclusive
      ? 'Deve essere maggiore di ${formatNumber(min, decimal: ',')}.'
      : 'Deve essere almeno ${formatNumber(min, decimal: ',')}.';

  @override
  String max(num max, bool exclusive) => exclusive
      ? 'Deve essere minore di ${formatNumber(max, decimal: ',')}.'
      : 'Deve essere al massimo ${formatNumber(max, decimal: ',')}.';

  @override
  String range(num min, num max) =>
      'Deve essere compreso tra ${formatNumber(min, decimal: ',')} e ${formatNumber(max, decimal: ',')}.';

  @override
  String positive() => 'Deve essere maggiore di zero.';

  @override
  String positiveOrZero() => 'Deve essere zero o maggiore.';

  @override
  String negative() => 'Deve essere minore di zero.';

  @override
  String negativeOrZero() => 'Deve essere zero o minore.';

  @override
  String nonZero() => 'Non deve essere zero.';

  @override
  String multipleOf(num divisor) =>
      'Deve essere un multiplo di ${formatNumber(divisor, decimal: ',')}.';

  @override
  String even() => 'Deve essere un numero pari.';

  @override
  String odd() => 'Deve essere un numero dispari.';

  @override
  String decimalPlaces(int maxPlaces) =>
      'Deve avere al massimo $maxPlaces ${maxPlaces == 1 ? 'cifra decimale' : 'cifre decimali'}.';

  @override
  String digits(int digits) =>
      'Deve avere esattamente $digits ${digits == 1 ? 'cifra' : 'cifre'}.';

  @override
  String minDigits(int minDigits) =>
      'Deve avere almeno $minDigits ${minDigits == 1 ? 'cifra' : 'cifre'}.';

  @override
  String maxDigits(int maxDigits) =>
      'Deve avere al massimo $maxDigits ${maxDigits == 1 ? 'cifra' : 'cifre'}.';

  @override
  String port() => 'Deve essere una porta compresa tra 1 e 65535.';
}

mixin FormidableNumberMessagesEs implements FormidableNumberMessages {
  @override
  String min(num min, bool exclusive) => exclusive
      ? 'Debe ser mayor que ${formatNumber(min, decimal: ',')}.'
      : 'Debe ser al menos ${formatNumber(min, decimal: ',')}.';

  @override
  String max(num max, bool exclusive) => exclusive
      ? 'Debe ser menor que ${formatNumber(max, decimal: ',')}.'
      : 'Debe ser como máximo ${formatNumber(max, decimal: ',')}.';

  @override
  String range(num min, num max) =>
      'Debe estar entre ${formatNumber(min, decimal: ',')} y ${formatNumber(max, decimal: ',')}.';

  @override
  String positive() => 'Debe ser mayor que cero.';

  @override
  String positiveOrZero() => 'Debe ser cero o mayor.';

  @override
  String negative() => 'Debe ser menor que cero.';

  @override
  String negativeOrZero() => 'Debe ser cero o menor.';

  @override
  String nonZero() => 'No debe ser cero.';

  @override
  String multipleOf(num divisor) =>
      'Debe ser múltiplo de ${formatNumber(divisor, decimal: ',')}.';

  @override
  String even() => 'Debe ser un número par.';

  @override
  String odd() => 'Debe ser un número impar.';

  @override
  String decimalPlaces(int maxPlaces) =>
      'Debe tener como máximo $maxPlaces ${maxPlaces == 1 ? 'decimal' : 'decimales'}.';

  @override
  String digits(int digits) =>
      'Debe tener exactamente $digits ${digits == 1 ? 'dígito' : 'dígitos'}.';

  @override
  String minDigits(int minDigits) =>
      'Debe tener al menos $minDigits ${minDigits == 1 ? 'dígito' : 'dígitos'}.';

  @override
  String maxDigits(int maxDigits) =>
      'Debe tener como máximo $maxDigits ${maxDigits == 1 ? 'dígito' : 'dígitos'}.';

  @override
  String port() => 'Debe ser un puerto entre 1 y 65535.';
}

mixin FormidableNumberMessagesFr implements FormidableNumberMessages {
  @override
  String min(num min, bool exclusive) => exclusive
      ? 'Doit être supérieur à ${formatNumber(min, decimal: ',')}.'
      : 'Doit être au moins ${formatNumber(min, decimal: ',')}.';

  @override
  String max(num max, bool exclusive) => exclusive
      ? 'Doit être inférieur à ${formatNumber(max, decimal: ',')}.'
      : 'Doit être au plus ${formatNumber(max, decimal: ',')}.';

  @override
  String range(num min, num max) =>
      'Doit être compris entre ${formatNumber(min, decimal: ',')} et ${formatNumber(max, decimal: ',')}.';

  @override
  String positive() => 'Doit être supérieur à zéro.';

  @override
  String positiveOrZero() => 'Doit être supérieur ou égal à zéro.';

  @override
  String negative() => 'Doit être inférieur à zéro.';

  @override
  String negativeOrZero() => 'Doit être inférieur ou égal à zéro.';

  @override
  String nonZero() => 'Ne doit pas être zéro.';

  @override
  String multipleOf(num divisor) =>
      'Doit être un multiple de ${formatNumber(divisor, decimal: ',')}.';

  @override
  String even() => 'Doit être un nombre pair.';

  @override
  String odd() => 'Doit être un nombre impair.';

  @override
  String decimalPlaces(int maxPlaces) =>
      'Doit avoir au plus $maxPlaces ${maxPlaces <= 1 ? 'décimale' : 'décimales'}.';

  @override
  String digits(int digits) =>
      'Doit avoir exactement $digits ${digits <= 1 ? 'chiffre' : 'chiffres'}.';

  @override
  String minDigits(int minDigits) =>
      'Doit avoir au moins $minDigits ${minDigits <= 1 ? 'chiffre' : 'chiffres'}.';

  @override
  String maxDigits(int maxDigits) =>
      'Doit avoir au plus $maxDigits ${maxDigits <= 1 ? 'chiffre' : 'chiffres'}.';

  @override
  String port() => 'Doit être un numéro de port entre 1 et 65535.';
}

mixin FormidableNumberMessagesDe implements FormidableNumberMessages {
  @override
  String min(num min, bool exclusive) => exclusive
      ? 'Muss größer als ${formatNumber(min, decimal: ',')} sein.'
      : 'Muss mindestens ${formatNumber(min, decimal: ',')} sein.';

  @override
  String max(num max, bool exclusive) => exclusive
      ? 'Muss kleiner als ${formatNumber(max, decimal: ',')} sein.'
      : 'Darf höchstens ${formatNumber(max, decimal: ',')} sein.';

  @override
  String range(num min, num max) =>
      'Muss zwischen ${formatNumber(min, decimal: ',')} und ${formatNumber(max, decimal: ',')} liegen.';

  @override
  String positive() => 'Muss größer als null sein.';

  @override
  String positiveOrZero() => 'Muss null oder größer sein.';

  @override
  String negative() => 'Muss kleiner als null sein.';

  @override
  String negativeOrZero() => 'Muss null oder kleiner sein.';

  @override
  String nonZero() => 'Darf nicht null sein.';

  @override
  String multipleOf(num divisor) =>
      'Muss ein Vielfaches von ${formatNumber(divisor, decimal: ',')} sein.';

  @override
  String even() => 'Muss eine gerade Zahl sein.';

  @override
  String odd() => 'Muss eine ungerade Zahl sein.';

  @override
  String decimalPlaces(int maxPlaces) =>
      'Darf höchstens $maxPlaces ${maxPlaces == 1 ? 'Nachkommastelle' : 'Nachkommastellen'} haben.';

  @override
  String digits(int digits) =>
      'Muss genau $digits ${digits == 1 ? 'Ziffer' : 'Ziffern'} haben.';

  @override
  String minDigits(int minDigits) =>
      'Muss mindestens $minDigits ${minDigits == 1 ? 'Ziffer' : 'Ziffern'} haben.';

  @override
  String maxDigits(int maxDigits) =>
      'Darf höchstens $maxDigits ${maxDigits == 1 ? 'Ziffer' : 'Ziffern'} haben.';

  @override
  String port() => 'Muss eine Portnummer zwischen 1 und 65535 sein.';
}

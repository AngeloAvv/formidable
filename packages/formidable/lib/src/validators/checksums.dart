import '../validation/validation_error.dart';
import '../validation/validator.dart';

/// The value fails the Luhn check.
final class FormidableLuhnError extends FormidableValidationError {
  const FormidableLuhnError();

  @override
  String toString() => 'Must be a valid number (checksum does not match).';
}

/// The value is not an ISBN, or not one of the required version.
final class FormidableIsbnError extends FormidableValidationError {
  const FormidableIsbnError({this.version});

  /// The required version (10 or 13), or null when either is accepted.
  final int? version;

  @override
  List<Object?> get props => [version];

  @override
  String toString() => version == null
      ? 'Must be a valid ISBN.'
      : 'Must be a valid ISBN-$version.';
}

final _separators = RegExp(r'[ -]');
final _isbn10 = RegExp(r'^\d{9}[\dXx]$');
final _isbn13 = RegExp(r'^97[89]\d{10}$');

/// The value must pass the Luhn check, used by payment card numbers, IMEI
/// numbers and many account numbers. Spaces and dashes are ignored.
class Luhn extends FormidableValidator<String> {
  const Luhn();

  @override
  List<FormidableValidationError> validate(String value) {
    final digits = value.replaceAll(_separators, '');
    if (!RegExp(r'^\d{2,}$').hasMatch(digits)) {
      return const [FormidableLuhnError()];
    }
    var sum = 0;
    for (var i = 0; i < digits.length; i++) {
      var digit = int.parse(digits[digits.length - 1 - i]);
      if (i.isOdd) {
        digit *= 2;
        if (digit > 9) digit -= 9;
      }
      sum += digit;
    }
    return sum % 10 == 0 ? const [] : const [FormidableLuhnError()];
  }
}

/// The value must be an ISBN-10 or ISBN-13 with a correct check digit. With
/// [version] set, only that version is accepted. Spaces and dashes are ignored
/// and their position is not checked.
class Isbn extends FormidableValidator<String> {
  const Isbn({this.version})
    : assert(version == null || version == 10 || version == 13);

  final int? version;

  @override
  List<FormidableValidationError> validate(String value) {
    final digits = value.replaceAll(_separators, '');
    final valid =
        (version != 13 && _isIsbn10(digits)) ||
        (version != 10 && _isIsbn13(digits));
    return valid ? const [] : [FormidableIsbnError(version: version)];
  }

  static bool _isIsbn10(String digits) {
    if (!_isbn10.hasMatch(digits)) return false;
    var sum = 0;
    for (var i = 0; i < 10; i++) {
      final char = digits[i];
      final digit = char == 'X' || char == 'x' ? 10 : int.parse(char);
      sum += digit * (10 - i);
    }
    return sum % 11 == 0;
  }

  static bool _isIsbn13(String digits) {
    if (!_isbn13.hasMatch(digits)) return false;
    var sum = 0;
    for (var i = 0; i < 13; i++) {
      sum += int.parse(digits[i]) * (i.isEven ? 1 : 3);
    }
    return sum % 10 == 0;
  }
}

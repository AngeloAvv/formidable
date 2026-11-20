import 'dart:convert';

import '../validation/validation_error.dart';
import '../validation/validator.dart';

/// The value is not a hexadecimal number.
final class FormidableHexadecimalError extends FormidableValidationError {
  const FormidableHexadecimalError();

  @override
  String toString() => 'Must be a hexadecimal number.';
}

/// The value is not an octal number.
final class FormidableOctalError extends FormidableValidationError {
  const FormidableOctalError();

  @override
  String toString() => 'Must be an octal number.';
}

/// The value is not Base64.
final class FormidableBase64Error extends FormidableValidationError {
  const FormidableBase64Error({this.urlSafe = false});

  /// Whether the URL-safe alphabet was required.
  final bool urlSafe;

  @override
  List<Object?> get props => [urlSafe];

  @override
  String toString() => 'Must be valid Base64.';
}

/// The value is not valid JSON.
final class FormidableJsonError extends FormidableValidationError {
  const FormidableJsonError();

  @override
  String toString() => 'Must be valid JSON.';
}

/// The value is not a JSON Web Token.
final class FormidableJwtError extends FormidableValidationError {
  const FormidableJwtError();

  @override
  String toString() => 'Must be a valid JSON Web Token.';
}

final _hexadecimal = RegExp(r'^(?:0[xX])?[0-9a-fA-F]+$');
final _octal = RegExp(r'^(?:0[oO])?[0-7]+$');
final _base64 = RegExp(r'^[A-Za-z0-9+/]+={0,2}$');
final _base64Url = RegExp(r'^[A-Za-z0-9_-]+={0,2}$');
final _base64UrlSegment = RegExp(r'^[A-Za-z0-9_-]+$');

bool _isBase64(String value, {required bool urlSafe}) {
  if (!(urlSafe ? _base64Url : _base64).hasMatch(value)) return false;
  final stripped = value.replaceFirst(RegExp(r'=+$'), '');
  final padded = stripped.length != value.length;
  if (padded) return value.length % 4 == 0;
  return urlSafe ? stripped.length % 4 != 1 : stripped.length % 4 == 0;
}

Object? _decodeSegment(String segment) {
  if (!_base64UrlSegment.hasMatch(segment)) return null;
  try {
    return jsonDecode(
      utf8.decode(base64Url.decode(base64Url.normalize(segment))),
    );
  } on FormatException {
    return null;
  }
}

/// The value must be a hexadecimal number, with an optional `0x` prefix.
class Hexadecimal extends FormidableValidator<String> {
  const Hexadecimal();

  @override
  List<FormidableValidationError> validate(String value) =>
      _hexadecimal.hasMatch(value)
      ? const []
      : const [FormidableHexadecimalError()];
}

/// The value must be an octal number, with an optional `0o` prefix.
class Octal extends FormidableValidator<String> {
  const Octal();

  @override
  List<FormidableValidationError> validate(String value) =>
      _octal.hasMatch(value) ? const [] : const [FormidableOctalError()];
}

/// The value must be Base64 with correct padding. With [urlSafe] it uses the
/// URL-safe alphabet (`-` and `_`) and the padding is optional.
class Base64 extends FormidableValidator<String> {
  const Base64({this.urlSafe = false});

  final bool urlSafe;

  @override
  List<FormidableValidationError> validate(String value) =>
      _isBase64(value, urlSafe: urlSafe)
      ? const []
      : [FormidableBase64Error(urlSafe: urlSafe)];
}

/// The value must be a valid JSON document: an object, an array or a scalar.
class Json extends FormidableValidator<String> {
  const Json();

  @override
  List<FormidableValidationError> validate(String value) {
    try {
      jsonDecode(value);
      return const [];
    } on FormatException {
      return const [FormidableJsonError()];
    }
  }
}

/// The value must have the shape of a JSON Web Token: three base64url parts
/// separated by dots, where the header and the payload are JSON objects.
///
/// It does not verify the signature. That needs the key and belongs to the
/// server.
class Jwt extends FormidableValidator<String> {
  const Jwt();

  @override
  List<FormidableValidationError> validate(String value) {
    final parts = value.split('.');
    final valid =
        parts.length == 3 &&
        _decodeSegment(parts[0]) is Map &&
        _decodeSegment(parts[1]) is Map &&
        _base64UrlSegment.hasMatch(parts[2]);
    return valid ? const [] : const [FormidableJwtError()];
  }
}

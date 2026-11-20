import '../validation/validation_error.dart';
import '../validation/validator.dart';

/// The notations [Color] can accept.
enum ColorFormat {
  /// `#rgb`, `#rgba`, `#rrggbb` or `#rrggbbaa`.
  hex,

  /// `rgb(255, 0, 0)` or `rgb(100% 0% 0%)`.
  rgb,

  /// `rgba(255, 0, 0, 0.5)`.
  rgba,

  /// `hsl(120, 100%, 50%)`.
  hsl,

  /// `hsla(120, 100%, 50%, 0.5)`.
  hsla,
}

/// The value is not a hexadecimal color.
final class FormidableHexColorError extends FormidableValidationError {
  const FormidableHexColorError();

  @override
  String toString() => 'Must be a valid hex color, like #1a2b3c.';
}

/// The value is not a color in one of the accepted formats.
final class FormidableColorError extends FormidableValidationError {
  const FormidableColorError({required this.formats});

  /// The notations the Validator accepts.
  final List<ColorFormat> formats;

  @override
  List<Object?> get props => [...formats];

  @override
  String toString() =>
      'Must be a valid color (${formats.map((f) => f.name).join(', ')}).';
}

final _hex = RegExp(
  r'^[0-9a-f]{3,4}$|^[0-9a-f]{6}$|^[0-9a-f]{8}$',
  caseSensitive: false,
);
final _function = RegExp(r'^(rgba?|hsla?)\(([^()]*)\)$', caseSensitive: false);
final _number = RegExp(r'^\d+(?:\.\d+)?$');
final _percent = RegExp(r'^\d+(?:\.\d+)?%$');
final _hue = RegExp(r'^-?\d+(?:\.\d+)?(?:deg)?$');

bool _inRange(String token, num max, {bool percentOk = true}) {
  if (_number.hasMatch(token)) return double.parse(token) <= max;
  if (percentOk && _percent.hasMatch(token)) {
    return double.parse(token.substring(0, token.length - 1)) <= 100;
  }
  return false;
}

bool _isPercent(String token) =>
    _percent.hasMatch(token) &&
    double.parse(token.substring(0, token.length - 1)) <= 100;

bool _isAlpha(String token) => _inRange(token, 1);

bool _isHexColor(String value) =>
    value.startsWith('#') && _hex.hasMatch(value.substring(1));

bool _isColor(String value, List<ColorFormat> formats) {
  if (formats.contains(ColorFormat.hex) && _isHexColor(value)) return true;
  final match = _function.firstMatch(value);
  if (match == null) return false;
  final name = match[1]!.toLowerCase();
  if (!formats.any((format) => format.name == name)) return false;
  final tokens = match[2]!.trim().split(RegExp(r'[\s,/]+'));
  if (tokens.any((token) => token.isEmpty)) return false;
  return switch (name) {
    'rgb' => tokens.length == 3 && tokens.every((t) => _inRange(t, 255)),
    'rgba' =>
      tokens.length == 4 &&
          tokens.take(3).every((t) => _inRange(t, 255)) &&
          _isAlpha(tokens[3]),
    'hsl' => tokens.length == 3 && _isHsl(tokens),
    _ => tokens.length == 4 && _isHsl(tokens) && _isAlpha(tokens[3]),
  };
}

bool _isHsl(List<String> tokens) {
  if (!_hue.hasMatch(tokens[0])) return false;
  final hue = double.parse(tokens[0].replaceAll('deg', ''));
  return hue >= 0 &&
      hue <= 360 &&
      _isPercent(tokens[1]) &&
      _isPercent(tokens[2]);
}

/// The value must be a hex color: `#rgb`, `#rgba`, `#rrggbb` or `#rrggbbaa`.
/// With [requireHash] false the leading `#` is optional.
class HexColor extends FormidableValidator<String> {
  const HexColor({this.requireHash = true});

  final bool requireHash;

  @override
  List<FormidableValidationError> validate(String value) {
    final digits = value.startsWith('#')
        ? value.substring(1)
        : requireHash
        ? null
        : value;
    return digits != null && _hex.hasMatch(digits)
        ? const []
        : const [FormidableHexColorError()];
  }
}

/// The value must be a CSS color in one of [formats]. All formats by default.
///
/// RGB channels are 0 to 255 or 0% to 100%, hue is 0 to 360, saturation and
/// lightness are percentages, and alpha is 0 to 1 or 0% to 100%. Arguments are
/// separated by commas or spaces, and by a slash before the alpha. Named colors
/// such as `red` are not accepted.
///
/// Note that this name is also a type in `dart:ui`: import Formidable with
/// `hide Color` or a prefix in files that use both.
class Color extends FormidableValidator<String> {
  const Color({this.formats = ColorFormat.values});

  final List<ColorFormat> formats;

  @override
  List<FormidableValidationError> validate(String value) =>
      _isColor(value, formats)
      ? const []
      : [FormidableColorError(formats: formats)];
}

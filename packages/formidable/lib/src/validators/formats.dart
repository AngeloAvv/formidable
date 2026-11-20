import '../validation/validation_error.dart';
import '../validation/validator.dart';

/// The value is not an email address.
final class FormidableEmailError extends FormidableValidationError {
  const FormidableEmailError();

  @override
  String toString() => 'Must be a valid email address.';
}

/// The value is not a URL with an accepted scheme.
final class FormidableUrlError extends FormidableValidationError {
  const FormidableUrlError({required this.schemes, required this.requireTld});

  /// The schemes the Validator accepts.
  final List<String> schemes;

  /// Whether the host had to end with a top-level domain.
  final bool requireTld;

  @override
  List<Object?> get props => [requireTld, ...schemes];

  @override
  String toString() => 'Must be a valid URL.';
}

/// The value is not a UUID, or not one of the required version.
final class FormidableUuidError extends FormidableValidationError {
  const FormidableUuidError({this.version});

  /// The required version, or null when any version is accepted.
  final int? version;

  @override
  List<Object?> get props => [version];

  @override
  String toString() => version == null
      ? 'Must be a valid UUID.'
      : 'Must be a valid UUID v$version.';
}

/// The value is not a ULID.
final class FormidableUlidError extends FormidableValidationError {
  const FormidableUlidError();

  @override
  String toString() => 'Must be a valid ULID.';
}

/// The value is not a semantic version.
final class FormidableSemVerError extends FormidableValidationError {
  const FormidableSemVerError();

  @override
  String toString() => 'Must be a valid semantic version, like 1.2.3.';
}

// Local part: printable ASCII except the specials of RFC 5322.
final _emailLocal = RegExp(r"^[A-Za-z0-9!#$%&'*+/=?^_`{|}~.-]+$");
final _hostLabel = RegExp(r'^[A-Za-z0-9](?:[A-Za-z0-9-]{0,61}[A-Za-z0-9])?$');
final _tld = RegExp(r'^(?:[A-Za-z]{2,}|xn--[A-Za-z0-9-]+)$');
final _uuid = RegExp(
  r'^[0-9a-f]{8}-[0-9a-f]{4}-([1-8])[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
  caseSensitive: false,
);
final _ulid = RegExp(r'^[0-7][0-9A-HJKMNP-TV-Z]{25}$', caseSensitive: false);
final _semVer = RegExp(
  r'^(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)'
  r'(?:-((?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*)'
  r'(?:\.(?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*))*))?'
  r'(?:\+([0-9a-zA-Z-]+(?:\.[0-9a-zA-Z-]+)*))?$',
);

bool _isHost(String host) {
  if (host.isEmpty || host.length > 253) return false;
  final labels = host.split('.');
  return labels.every(_hostLabel.hasMatch);
}

bool _isIp(String host) {
  try {
    Uri.parseIPv4Address(host);
    return true;
  } on FormatException {
    // Not an IPv4 address.
  }
  try {
    Uri.parseIPv6Address(host);
    return true;
  } on FormatException {
    return false;
  }
}

/// The value must be an email address of the shape `local@domain.tld`.
///
/// This is a practical check, not the full RFC 5322 grammar: a plain local
/// part, and a domain of at least two labels. It cannot know whether the
/// mailbox exists; that belongs to an Async Validator.
class Email extends FormidableValidator<String> {
  const Email();

  @override
  List<FormidableValidationError> validate(String value) =>
      _isEmail(value) ? const [] : const [FormidableEmailError()];

  static bool _isEmail(String value) {
    if (value.length > 254) return false;
    final at = value.lastIndexOf('@');
    if (at < 1) return false;
    final local = value.substring(0, at);
    final domain = value.substring(at + 1);
    if (local.length > 64 ||
        !_emailLocal.hasMatch(local) ||
        local.startsWith('.') ||
        local.endsWith('.') ||
        local.contains('..')) {
      return false;
    }
    final labels = domain.split('.');
    return labels.length >= 2 &&
        _isHost(domain) &&
        !RegExp(r'^\d+$').hasMatch(labels.last);
  }
}

/// The value must be an absolute URL with a host and one of [schemes].
///
/// With [requireTld] the host must be a domain name that ends with a top-level
/// domain, or an IP address, so `http://localhost` is rejected. Turn it off for
/// internal hosts.
class Url extends FormidableValidator<String> {
  const Url({this.schemes = const ['http', 'https'], this.requireTld = true});

  final List<String> schemes;
  final bool requireTld;

  @override
  List<FormidableValidationError> validate(String value) => _isUrl(value)
      ? const []
      : [FormidableUrlError(schemes: schemes, requireTld: requireTld)];

  bool _isUrl(String value) {
    if (RegExp(r'\s').hasMatch(value)) return false;
    final uri = Uri.tryParse(value);
    if (uri == null || !uri.hasScheme || uri.host.isEmpty) return false;
    if (!schemes.any((scheme) => scheme.toLowerCase() == uri.scheme)) {
      return false;
    }
    final host = uri.host;
    if (_isIp(host)) return true;
    if (!_isHost(host)) return false;
    return !requireTld ||
        _tld.hasMatch(host.split('.').last) && host.contains('.');
  }
}

/// The value must be a UUID (RFC 9562) in the canonical 8-4-4-4-12 form. With
/// [version] set, it must be of that version (1 to 8).
class Uuid extends FormidableValidator<String> {
  const Uuid({this.version})
    : assert(version == null || (version >= 1 && version <= 8));

  final int? version;

  @override
  List<FormidableValidationError> validate(String value) {
    final match = _uuid.firstMatch(value);
    return match != null && (version == null || match[1] == '$version')
        ? const []
        : [FormidableUuidError(version: version)];
  }
}

/// The value must be a ULID: 26 characters of Crockford base32.
class Ulid extends FormidableValidator<String> {
  const Ulid();

  @override
  List<FormidableValidationError> validate(String value) =>
      _ulid.hasMatch(value) ? const [] : const [FormidableUlidError()];
}

/// The value must be a semantic version (semver.org), like `1.2.3` or
/// `1.0.0-beta.1+build.5`. A leading `v` is not part of the version.
class SemVer extends FormidableValidator<String> {
  const SemVer();

  @override
  List<FormidableValidationError> validate(String value) =>
      _semVer.hasMatch(value) ? const [] : const [FormidableSemVerError()];
}

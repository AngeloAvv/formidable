import '../validation/validation_error.dart';
import '../validation/validator.dart';

/// Which IP address family a Validator accepts.
enum IpVersion {
  /// Dotted quad addresses such as `192.168.1.1`.
  v4,

  /// Colon separated addresses such as `2001:db8::1`.
  v6,

  /// Either family.
  any,
}

final _ipv4 = RegExp(
  r'^(?:25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)'
  r'(?:\.(?:25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}$',
);

bool _isIpv4(String value) => _ipv4.hasMatch(value);

bool _isIpv6(String value) {
  if (!value.contains(':')) return false;
  try {
    Uri.parseIPv6Address(value);
    return true;
  } on FormatException {
    return false;
  }
}

bool _isIp(String value, IpVersion version) => switch (version) {
  IpVersion.v4 => _isIpv4(value),
  IpVersion.v6 => _isIpv6(value),
  IpVersion.any => _isIpv4(value) || _isIpv6(value),
};

/// The value is not an IP address of the required family.
final class FormidableIpError extends FormidableValidationError {
  const FormidableIpError(this.version);

  final IpVersion version;

  @override
  List<Object?> get props => [version];

  @override
  String toString() => switch (version) {
    IpVersion.v4 => 'Must be a valid IPv4 address.',
    IpVersion.v6 => 'Must be a valid IPv6 address.',
    IpVersion.any => 'Must be a valid IP address.',
  };
}

/// The value is an IP address of the given [version] (either by default).
class Ip extends FormidableValidator<String> {
  const Ip([this.version = IpVersion.any]);

  final IpVersion version;

  @override
  List<FormidableValidationError> validate(String value) =>
      _isIp(value, version) ? const [] : [FormidableIpError(version)];
}

/// The value is not a network in CIDR notation.
final class FormidableCidrError extends FormidableValidationError {
  const FormidableCidrError(this.version);

  final IpVersion version;

  @override
  List<Object?> get props => [version];

  @override
  String toString() => switch (version) {
    IpVersion.v4 => 'Must be a valid IPv4 network in CIDR notation.',
    IpVersion.v6 => 'Must be a valid IPv6 network in CIDR notation.',
    IpVersion.any => 'Must be a valid network in CIDR notation.',
  };
}

final _prefix = RegExp(r'^(?:0|[1-9]\d{0,2})$');

/// The value is a network in CIDR notation, such as `10.0.0.0/8`, of the given
/// [version] (either by default).
class Cidr extends FormidableValidator<String> {
  const Cidr([this.version = IpVersion.any]);

  final IpVersion version;

  @override
  List<FormidableValidationError> validate(String value) {
    final slash = value.indexOf('/');
    if (slash > 0) {
      final address = value.substring(0, slash);
      final prefix = value.substring(slash + 1);
      final maxPrefix = switch (version) {
        IpVersion.v4 => _isIpv4(address) ? 32 : -1,
        IpVersion.v6 => _isIpv6(address) ? 128 : -1,
        IpVersion.any =>
          _isIpv4(address)
              ? 32
              : _isIpv6(address)
              ? 128
              : -1,
      };
      if (maxPrefix >= 0 &&
          _prefix.hasMatch(prefix) &&
          int.parse(prefix) <= maxPrefix) {
        return const [];
      }
    }
    return [FormidableCidrError(version)];
  }
}

/// The value is not a MAC address.
final class FormidableMacAddressError extends FormidableValidationError {
  const FormidableMacAddressError();

  @override
  String toString() => 'Must be a valid MAC address.';
}

final _mac = RegExp(
  r'^(?:[0-9A-Fa-f]{2}(?<sep>[:-])(?:[0-9A-Fa-f]{2}\k<sep>){4}[0-9A-Fa-f]{2}'
  r'|(?:[0-9A-Fa-f]{4}\.){2}[0-9A-Fa-f]{4})$',
);

/// The value is a MAC address: six bytes in hexadecimal, separated by colons
/// or hyphens (`00:1A:2B:3C:4D:5E`), or in groups of four with dots
/// (`001A.2B3C.4D5E`).
class MacAddress extends FormidableValidator<String> {
  const MacAddress();

  @override
  List<FormidableValidationError> validate(String value) =>
      _mac.hasMatch(value) ? const [] : const [FormidableMacAddressError()];
}

final _label = RegExp(r'^[A-Za-z0-9](?:[A-Za-z0-9-]{0,61}[A-Za-z0-9])?$');
final _alphabeticTld = RegExp(r'^(?:[A-Za-z]{2,}|[Xx][Nn]--[A-Za-z0-9-]+)$');

/// Whether [value] is made of valid DNS labels, at most 253 characters in
/// all. [minLabels] is how many labels it needs.
bool _hasLabels(List<String> labels, {required int minLabels}) =>
    labels.length >= minLabels &&
    labels.join('.').length <= 253 &&
    labels.every(_label.hasMatch);

/// The value is not a valid host name.
final class FormidableHostnameError extends FormidableValidationError {
  const FormidableHostnameError();

  @override
  String toString() => 'Must be a valid host name.';
}

/// The value is a host name: one or more dot separated labels of letters,
/// digits and hyphens, each up to 63 characters, not starting or ending with a
/// hyphen, in at most 253 characters. A single label such as `localhost` is
/// valid.
class Hostname extends FormidableValidator<String> {
  const Hostname();

  @override
  List<FormidableValidationError> validate(String value) =>
      _hasLabels(value.split('.'), minLabels: 1)
      ? const []
      : const [FormidableHostnameError()];
}

/// The value is not a fully qualified domain name.
final class FormidableFqdnError extends FormidableValidationError {
  const FormidableFqdnError();

  @override
  String toString() => 'Must be a fully qualified domain name.';
}

/// The value is a fully qualified domain name: a host name of at least two
/// labels whose last label is not all digits (so an IPv4 address is not one).
/// A single trailing dot, the DNS root, is allowed.
class Fqdn extends FormidableValidator<String> {
  const Fqdn();

  @override
  List<FormidableValidationError> validate(String value) {
    final name = value.endsWith('.')
        ? value.substring(0, value.length - 1)
        : value;
    final labels = name.split('.');
    return _hasLabels(labels, minLabels: 2) &&
            !RegExp(r'^\d+$').hasMatch(labels.last)
        ? const []
        : const [FormidableFqdnError()];
  }
}

/// The value is not a domain name.
final class FormidableDomainError extends FormidableValidationError {
  const FormidableDomainError();

  @override
  String toString() => 'Must be a valid domain name.';
}

/// The value is a domain name such as `example.com`: at least two valid
/// labels, no trailing dot, and a top level domain of at least two letters (or
/// an internationalized `xn--` one).
class Domain extends FormidableValidator<String> {
  const Domain();

  @override
  List<FormidableValidationError> validate(String value) {
    final labels = value.split('.');
    return _hasLabels(labels, minLabels: 2) &&
            _alphabeticTld.hasMatch(labels.last)
        ? const []
        : const [FormidableDomainError()];
  }
}

final _decimal = RegExp(r'^[+-]?\d+(?:\.\d+)?$');

bool _isCoordinate(String value, double limit) =>
    _decimal.hasMatch(value) && double.parse(value).abs() <= limit;

/// The value is not a latitude.
final class FormidableLatitudeError extends FormidableValidationError {
  const FormidableLatitudeError();

  @override
  String toString() => 'Must be a latitude between -90 and 90.';
}

/// The value is a latitude in decimal degrees, from -90 to 90.
class Latitude extends FormidableValidator<String> {
  const Latitude();

  @override
  List<FormidableValidationError> validate(String value) =>
      _isCoordinate(value, 90) ? const [] : const [FormidableLatitudeError()];
}

/// The value is not a longitude.
final class FormidableLongitudeError extends FormidableValidationError {
  const FormidableLongitudeError();

  @override
  String toString() => 'Must be a longitude between -180 and 180.';
}

/// The value is a longitude in decimal degrees, from -180 to 180.
class Longitude extends FormidableValidator<String> {
  const Longitude();

  @override
  List<FormidableValidationError> validate(String value) =>
      _isCoordinate(value, 180) ? const [] : const [FormidableLongitudeError()];
}

/// The value is not a pair of coordinates.
final class FormidableLatLngError extends FormidableValidationError {
  const FormidableLatLngError();

  @override
  String toString() => 'Must be coordinates written as "latitude, longitude".';
}

/// The value is a latitude and a longitude in decimal degrees, separated by a
/// comma, such as `45.4642, 9.19`.
class LatLng extends FormidableValidator<String> {
  const LatLng();

  @override
  List<FormidableValidationError> validate(String value) {
    final parts = value.split(',');
    return parts.length == 2 &&
            _isCoordinate(parts[0].trim(), 90) &&
            _isCoordinate(parts[1].trim(), 180)
        ? const []
        : const [FormidableLatLngError()];
  }
}

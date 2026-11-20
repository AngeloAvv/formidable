import 'package:formidable/formidable.dart';

/// Messages for the errors of the network Validators.
abstract mixin class FormidableNetworkMessages {
  /// The value is not an IP address of the family [version].
  String ip(IpVersion version);

  /// The value is not a network in CIDR notation of the family [version].
  String cidr(IpVersion version);

  /// The value is not a MAC address.
  String macAddress();

  /// The value is not a host name.
  String hostname();

  /// The value is not a fully qualified domain name.
  String fqdn();

  /// The value is not a domain name.
  String domain();

  /// The value is not a latitude.
  String latitude();

  /// The value is not a longitude.
  String longitude();

  /// The value is not a pair of coordinates.
  String latLng();

  /// The message for a network error, or null for any other error.
  String? networkMessageOf(FormidableValidationError error) => switch (error) {
    FormidableIpError(:final version) => ip(version),
    FormidableCidrError(:final version) => cidr(version),
    FormidableMacAddressError() => macAddress(),
    FormidableHostnameError() => hostname(),
    FormidableFqdnError() => fqdn(),
    FormidableDomainError() => domain(),
    FormidableLatitudeError() => latitude(),
    FormidableLongitudeError() => longitude(),
    FormidableLatLngError() => latLng(),
    _ => null,
  };
}

mixin FormidableNetworkMessagesEn implements FormidableNetworkMessages {
  @override
  String ip(IpVersion version) => switch (version) {
    IpVersion.v4 => 'Must be a valid IPv4 address.',
    IpVersion.v6 => 'Must be a valid IPv6 address.',
    IpVersion.any => 'Must be a valid IP address.',
  };

  @override
  String cidr(IpVersion version) => switch (version) {
    IpVersion.v4 => 'Must be a valid IPv4 network in CIDR notation.',
    IpVersion.v6 => 'Must be a valid IPv6 network in CIDR notation.',
    IpVersion.any => 'Must be a valid network in CIDR notation.',
  };

  @override
  String macAddress() => 'Must be a valid MAC address.';

  @override
  String hostname() => 'Must be a valid host name.';

  @override
  String fqdn() => 'Must be a fully qualified domain name.';

  @override
  String domain() => 'Must be a valid domain name.';

  @override
  String latitude() => 'Must be a latitude between -90 and 90.';

  @override
  String longitude() => 'Must be a longitude between -180 and 180.';

  @override
  String latLng() => 'Must be coordinates written as "latitude, longitude".';
}

mixin FormidableNetworkMessagesIt implements FormidableNetworkMessages {
  @override
  String ip(IpVersion version) => switch (version) {
    IpVersion.v4 => 'Deve essere un indirizzo IPv4 valido.',
    IpVersion.v6 => 'Deve essere un indirizzo IPv6 valido.',
    IpVersion.any => 'Deve essere un indirizzo IP valido.',
  };

  @override
  String cidr(IpVersion version) => switch (version) {
    IpVersion.v4 => 'Deve essere una rete IPv4 valida in notazione CIDR.',
    IpVersion.v6 => 'Deve essere una rete IPv6 valida in notazione CIDR.',
    IpVersion.any => 'Deve essere una rete valida in notazione CIDR.',
  };

  @override
  String macAddress() => 'Deve essere un indirizzo MAC valido.';

  @override
  String hostname() => 'Deve essere un nome host valido.';

  @override
  String fqdn() => 'Deve essere un nome di dominio completo (FQDN).';

  @override
  String domain() => 'Deve essere un nome di dominio valido.';

  @override
  String latitude() => 'Deve essere una latitudine compresa tra -90 e 90.';

  @override
  String longitude() => 'Deve essere una longitudine compresa tra -180 e 180.';

  @override
  String latLng() =>
      'Deve essere una coppia di coordinate nel formato "latitudine, longitudine".';
}

mixin FormidableNetworkMessagesEs implements FormidableNetworkMessages {
  @override
  String ip(IpVersion version) => switch (version) {
    IpVersion.v4 => 'Debe ser una dirección IPv4 válida.',
    IpVersion.v6 => 'Debe ser una dirección IPv6 válida.',
    IpVersion.any => 'Debe ser una dirección IP válida.',
  };

  @override
  String cidr(IpVersion version) => switch (version) {
    IpVersion.v4 => 'Debe ser una red IPv4 válida en notación CIDR.',
    IpVersion.v6 => 'Debe ser una red IPv6 válida en notación CIDR.',
    IpVersion.any => 'Debe ser una red válida en notación CIDR.',
  };

  @override
  String macAddress() => 'Debe ser una dirección MAC válida.';

  @override
  String hostname() => 'Debe ser un nombre de host válido.';

  @override
  String fqdn() => 'Debe ser un nombre de dominio completo (FQDN).';

  @override
  String domain() => 'Debe ser un nombre de dominio válido.';

  @override
  String latitude() => 'Debe ser una latitud entre -90 y 90.';

  @override
  String longitude() => 'Debe ser una longitud entre -180 y 180.';

  @override
  String latLng() =>
      'Debe ser un par de coordenadas con el formato "latitud, longitud".';
}

mixin FormidableNetworkMessagesFr implements FormidableNetworkMessages {
  @override
  String ip(IpVersion version) => switch (version) {
    IpVersion.v4 => 'Doit être une adresse IPv4 valide.',
    IpVersion.v6 => 'Doit être une adresse IPv6 valide.',
    IpVersion.any => 'Doit être une adresse IP valide.',
  };

  @override
  String cidr(IpVersion version) => switch (version) {
    IpVersion.v4 => 'Doit être un réseau IPv4 valide en notation CIDR.',
    IpVersion.v6 => 'Doit être un réseau IPv6 valide en notation CIDR.',
    IpVersion.any => 'Doit être un réseau valide en notation CIDR.',
  };

  @override
  String macAddress() => 'Doit être une adresse MAC valide.';

  @override
  String hostname() => "Doit être un nom d'hôte valide.";

  @override
  String fqdn() => 'Doit être un nom de domaine complet (FQDN).';

  @override
  String domain() => 'Doit être un nom de domaine valide.';

  @override
  String latitude() => 'Doit être une latitude comprise entre -90 et 90.';

  @override
  String longitude() => 'Doit être une longitude comprise entre -180 et 180.';

  @override
  String latLng() =>
      'Doit être des coordonnées au format « latitude, longitude ».';
}

mixin FormidableNetworkMessagesDe implements FormidableNetworkMessages {
  @override
  String ip(IpVersion version) => switch (version) {
    IpVersion.v4 => 'Muss eine gültige IPv4-Adresse sein.',
    IpVersion.v6 => 'Muss eine gültige IPv6-Adresse sein.',
    IpVersion.any => 'Muss eine gültige IP-Adresse sein.',
  };

  @override
  String cidr(IpVersion version) => switch (version) {
    IpVersion.v4 => 'Muss ein gültiges IPv4-Netz in CIDR-Notation sein.',
    IpVersion.v6 => 'Muss ein gültiges IPv6-Netz in CIDR-Notation sein.',
    IpVersion.any => 'Muss ein gültiges Netz in CIDR-Notation sein.',
  };

  @override
  String macAddress() => 'Muss eine gültige MAC-Adresse sein.';

  @override
  String hostname() => 'Muss ein gültiger Hostname sein.';

  @override
  String fqdn() => 'Muss ein vollqualifizierter Domainname (FQDN) sein.';

  @override
  String domain() => 'Muss ein gültiger Domainname sein.';

  @override
  String latitude() => 'Muss ein Breitengrad zwischen -90 und 90 sein.';

  @override
  String longitude() => 'Muss ein Längengrad zwischen -180 und 180 sein.';

  @override
  String latLng() =>
      'Muss ein Koordinatenpaar im Format „Breitengrad, Längengrad“ sein.';
}

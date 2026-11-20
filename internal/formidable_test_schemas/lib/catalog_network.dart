import 'package:formidable/formidable.dart';

part 'catalog_network.formidable.dart';

/// One Field per network Validator of the built-in catalog.
@Formidable()
class Endpoint {
  const Endpoint({
    required this.ip,
    required this.ipV4,
    required this.ipV6,
    required this.cidr,
    required this.cidrV4,
    required this.cidrV6,
    required this.mac,
    required this.hostname,
    required this.fqdn,
    required this.domain,
    required this.latitude,
    required this.longitude,
    required this.position,
  });

  @Ip()
  final String ip;

  @Ip(IpVersion.v4)
  final String ipV4;

  @Ip(IpVersion.v6)
  final String ipV6;

  @Cidr()
  final String cidr;

  @Cidr(IpVersion.v4)
  final String cidrV4;

  @Cidr(IpVersion.v6)
  final String cidrV6;

  @MacAddress()
  final String mac;

  @Hostname()
  final String hostname;

  @Fqdn()
  final String fqdn;

  @Domain()
  final String domain;

  @Latitude()
  final String latitude;

  @Longitude()
  final String longitude;

  @LatLng()
  final String position;
}

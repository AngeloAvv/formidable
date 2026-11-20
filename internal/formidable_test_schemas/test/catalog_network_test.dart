import 'package:formidable/formidable.dart';
import 'package:formidable_test_schemas/catalog_network.dart';
import 'package:test/test.dart';

/// Seam 1: the network Validators of the built-in catalog.
void main() {
  /// Writes each value to [field] and expects [error] for the invalid ones.
  void check(
    FormidableField<String> field, {
    required List<String> valid,
    required List<String> invalid,
    required FormidableValidationError error,
  }) {
    for (final value in valid) {
      field.setValue(value);
      expect(field.state.errors, isEmpty, reason: 'valid: "$value"');
    }
    for (final value in invalid) {
      field.setValue(value);
      expect(field.state.errors, [error], reason: 'invalid: "$value"');
    }
  }

  late EndpointForm form;
  setUp(() => form = EndpointForm());

  group('Ip', () {
    const v4 = ['0.0.0.0', '127.0.0.1', '192.168.1.255', '255.255.255.255'];
    const v6 = [
      '::',
      '::1',
      '2001:db8::8a2e:370:7334',
      '2001:0db8:0000:0000:0000:8a2e:0370:7334',
      '::ffff:192.168.1.1',
      'fe80::1',
    ];
    const notIp = [
      '',
      'abc',
      '1.2.3',
      '1.2.3.4.5',
      '256.1.1.1',
      '01.2.3.4',
      '1.2.3.-4',
      ' 1.2.3.4',
      '1:2',
      ':::',
      '12345::1',
      '1.2.3.4/24',
    ];

    test('any version accepts both families', () {
      check(
        form.ip,
        valid: [...v4, ...v6],
        invalid: notIp,
        error: const FormidableIpError(IpVersion.any),
      );
    });

    test('version 4 accepts only dotted quads', () {
      check(
        form.ipV4,
        valid: v4,
        invalid: [...v6, ...notIp],
        error: const FormidableIpError(IpVersion.v4),
      );
    });

    test('version 6 accepts only IPv6', () {
      check(
        form.ipV6,
        valid: v6,
        invalid: [...v4, ...notIp],
        error: const FormidableIpError(IpVersion.v6),
      );
    });
  });

  group('Cidr', () {
    const v4 = ['10.0.0.0/8', '192.168.1.0/24', '0.0.0.0/0', '1.2.3.4/32'];
    const v6 = ['::/0', '2001:db8::/32', 'fe80::1/128'];
    const notCidr = [
      '',
      '10.0.0.0',
      '10.0.0.0/',
      '10.0.0.0/33',
      '10.0.0.0/-1',
      '10.0.0.0/08',
      '10.0.0.0/a',
      '300.0.0.0/8',
      '2001:db8::/129',
      '/24',
      '10.0.0.0/24/1',
    ];

    test('any version accepts both families', () {
      check(
        form.cidr,
        valid: [...v4, ...v6],
        invalid: notCidr,
        error: const FormidableCidrError(IpVersion.any),
      );
    });

    test('version 4 and 6 are strict', () {
      check(
        form.cidrV4,
        valid: v4,
        invalid: [...v6, ...notCidr],
        error: const FormidableCidrError(IpVersion.v4),
      );
      check(
        form.cidrV6,
        valid: v6,
        invalid: [...v4, ...notCidr],
        error: const FormidableCidrError(IpVersion.v6),
      );
    });
  });

  test('MacAddress accepts colon, hyphen and dotted notation', () {
    check(
      form.mac,
      valid: ['00:1A:2b:3C:4d:5E', '00-1A-2B-3C-4D-5E', '001A.2B3C.4D5E'],
      invalid: [
        '',
        '00:1A:2B:3C:4D',
        '00:1A:2B:3C:4D:5E:6F',
        '00:1A:2B:3C:4D:5G',
        '00:1A-2B:3C-4D:5E',
        '001A2B3C4D5E',
        '001A.2B3C.4D',
      ],
      error: const FormidableMacAddressError(),
    );
  });

  test('Hostname follows the label rules', () {
    check(
      form.hostname,
      valid: [
        'localhost',
        'my-host',
        'host1',
        'a.b',
        'example.com',
        'a' * 63,
        'x.${'a' * 63}.com',
      ],
      invalid: [
        '',
        '-host',
        'host-',
        'my_host',
        'ho st',
        'host.',
        '.host',
        'a..b',
        'a' * 64,
        List.filled(64, 'abcd').join('.'),
        'münchen',
      ],
      error: const FormidableHostnameError(),
    );
  });

  test('Fqdn needs at least two labels and a non numeric last one', () {
    check(
      form.fqdn,
      valid: [
        'example.com',
        'a.b.example.co.uk',
        'example.com.',
        'xn--nxasmq6b.com',
        'host-1.example.org',
      ],
      invalid: [
        '',
        'localhost',
        'example',
        'example.',
        'example..com',
        '-a.com',
        'a_b.com',
        '192.168.1.1',
        'example.123',
        '.example.com',
        'example.com..',
      ],
      error: const FormidableFqdnError(),
    );
  });

  test('Domain is a registrable name with an alphabetic top level', () {
    check(
      form.domain,
      valid: [
        'example.com',
        'sub.example.co.uk',
        'EXAMPLE.IT',
        'xn--nxasmq6b.xn--p1ai',
        'a-b.io',
      ],
      invalid: [
        '',
        'localhost',
        'example.c',
        'example.123',
        'example.com.',
        '192.168.1.1',
        'exa_mple.com',
        '-example.com',
        'example .com',
        'http://example.com',
      ],
      error: const FormidableDomainError(),
    );
  });

  test('Latitude is a decimal number from -90 to 90', () {
    check(
      form.latitude,
      valid: ['0', '45.4642', '-90', '90', '+12.5', '-89.999999', '90.0'],
      invalid: [
        '',
        'abc',
        '90.0001',
        '-91',
        '1e2',
        '.5',
        '5.',
        '12,5',
        ' 1',
        '--1',
        '1.2.3',
      ],
      error: const FormidableLatitudeError(),
    );
  });

  test('Longitude is a decimal number from -180 to 180', () {
    check(
      form.longitude,
      valid: ['0', '9.19', '-180', '180', '179.999', '-122.4194'],
      invalid: ['', 'abc', '180.0001', '-181', '1e2', '.5', '5.', '9,19'],
      error: const FormidableLongitudeError(),
    );
  });

  test('LatLng is a latitude and a longitude separated by a comma', () {
    check(
      form.position,
      valid: ['45.4642,9.19', '45.4642, 9.19', '-90,-180', '0 , 0', '90,180'],
      invalid: [
        '',
        '45.4642',
        '91,0',
        '0,181',
        '9.19,45.4642,3',
        'a,b',
        '45.4642;9.19',
        ',9',
      ],
      error: const FormidableLatLngError(),
    );
  });
}

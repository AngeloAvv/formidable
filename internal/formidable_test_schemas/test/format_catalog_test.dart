import 'package:formidable/formidable.dart';
import 'package:formidable_test_schemas/format_catalog.dart';
import 'package:test/test.dart';

class _Case {
  const _Case(
    this.name,
    this.field,
    this.error, {
    required this.valid,
    required this.invalid,
  });

  final String name;
  final FormidableField<String?> Function(FormatCatalogForm form) field;
  final Matcher error;
  final List<String> valid;
  final List<String> invalid;
}

List<FormidableValidationError> _errorsOf(_Case c, String value) {
  final field = c.field(FormatCatalogForm())..setValue(value);
  return field.state.errors;
}

const _jwt =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.'
    'eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ.'
    'SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c';

final _cases = <_Case>[
  _Case(
    'Email',
    (f) => f.email,
    isA<FormidableEmailError>(),
    valid: [
      'user@example.com',
      'first.last+tag@sub.example.co.uk',
      "o'brien@example.org",
      'a@b.io',
    ],
    invalid: [
      '',
      'user',
      'user@',
      '@example.com',
      'user@example',
      'user@@example.com',
      'user @example.com',
      '.user@example.com',
      'user.@example.com',
      'us..er@example.com',
      'user@-example.com',
      'user@example..com',
    ],
  ),
  _Case(
    'Url',
    (f) => f.url,
    isA<FormidableUrlError>(),
    valid: [
      'https://example.com',
      'http://example.com/path?q=1#frag',
      'HTTPS://Example.com:8080/a',
      'http://127.0.0.1:3000',
      'https://sub.example.co.uk',
    ],
    invalid: [
      '',
      'example.com',
      'ftp://example.com',
      'http://localhost',
      'http://',
      'https://exa mple.com',
      'https://example',
      'mailto:user@example.com',
      'javascript:alert(1)',
    ],
  ),
  _Case(
    'Url(schemes, requireTld: false)',
    (f) => f.ftpUrl,
    isA<FormidableUrlError>(),
    valid: ['ftp://files.example.com', 'https://localhost:8080', 'ftp://nas'],
    invalid: ['http://example.com', 'example.com', 'ftp://'],
  ),
  _Case(
    'Uuid',
    (f) => f.uuid,
    isA<FormidableUuidError>(),
    valid: [
      '123e4567-e89b-12d3-a456-426614174000',
      '550E8400-E29B-41D4-A716-446655440000',
      '018f4e0a-7c3b-7a2e-8f1a-2b3c4d5e6f70',
    ],
    invalid: [
      '',
      '123e4567e89b12d3a456426614174000',
      '123e4567-e89b-12d3-a456-42661417400',
      '123e4567-e89b-02d3-a456-426614174000',
      '123e4567-e89b-12d3-c456-426614174000',
      'zzzzzzzz-zzzz-zzzz-zzzz-zzzzzzzzzzzz',
    ],
  ),
  _Case(
    'Uuid(version: 4)',
    (f) => f.uuidV4,
    isA<FormidableUuidError>(),
    valid: ['550e8400-e29b-41d4-a716-446655440000'],
    invalid: ['123e4567-e89b-12d3-a456-426614174000'],
  ),
  _Case(
    'Ulid',
    (f) => f.ulid,
    isA<FormidableUlidError>(),
    valid: ['01ARZ3NDEKTSV4RRFFQ69G5FAV', '01arz3ndektsv4rrffq69g5fav'],
    invalid: [
      '',
      '01ARZ3NDEKTSV4RRFFQ69G5FA',
      '01ARZ3NDEKTSV4RRFFQ69G5FAVV',
      '01ARZ3NDEKTSV4RRFFQ69G5FAU',
      '81ARZ3NDEKTSV4RRFFQ69G5FAV',
    ],
  ),
  _Case(
    'HexColor',
    (f) => f.hexColor,
    isA<FormidableHexColorError>(),
    valid: ['#fff', '#FFF', '#ffff', '#112233', '#11223344', '#aBcDeF'],
    invalid: ['', 'fff', '#ff', '#fffff', '#ggg', '#1122334', '112233'],
  ),
  _Case(
    'HexColor(requireHash: false)',
    (f) => f.hexColorNoHash,
    isA<FormidableHexColorError>(),
    valid: ['fff', '#fff', '112233', '#11223344'],
    invalid: ['', 'ff', 'ggg', '##fff'],
  ),
  _Case(
    'ColorCode',
    (f) => f.color,
    isA<FormidableColorCodeError>(),
    valid: [
      '#fff',
      '#11223344',
      'rgb(255, 0, 0)',
      'rgb(255 0 0)',
      'rgb(100%, 50%, 0%)',
      'rgba(0, 0, 0, 0.5)',
      'rgba(0, 0, 0, 50%)',
      'rgba(0 0 0 / 0.5)',
      'hsl(120, 100%, 50%)',
      'hsl(120deg 100% 50%)',
      'hsla(360, 0%, 100%, 1)',
    ],
    invalid: [
      '',
      'red',
      'rgb(256, 0, 0)',
      'rgb(255, 0)',
      'rgb(255, 0, 0, 1)',
      'rgba(0, 0, 0)',
      'rgba(0, 0, 0, 2)',
      'rgb(a, b, c)',
      'hsl(361, 0%, 0%)',
      'hsl(120, 100, 50)',
      'hsl(120, 101%, 50%)',
      'rgb(0, 0, 0',
    ],
  ),
  _Case(
    'ColorCode(formats: rgb, rgba)',
    (f) => f.rgbColor,
    isA<FormidableColorCodeError>(),
    valid: ['rgb(1, 2, 3)', 'rgba(1, 2, 3, 0.1)'],
    invalid: ['#fff', 'hsl(0, 0%, 0%)', 'hsla(0, 0%, 0%, 1)'],
  ),
  _Case(
    'Hexadecimal',
    (f) => f.hexadecimal,
    isA<FormidableHexadecimalError>(),
    valid: ['0', 'ff', 'DEADbeef', '0x1F', '0XaB'],
    invalid: ['', 'g', '0x', '1 2', '-1', 'xff'],
  ),
  _Case(
    'Octal',
    (f) => f.octal,
    isA<FormidableOctalError>(),
    valid: ['0', '755', '0o17', '0O7'],
    invalid: ['', '8', '78', '0o', '-1', '0x7'],
  ),
  _Case(
    'Base64',
    (f) => f.base64,
    isA<FormidableBase64Error>(),
    valid: ['aGVsbG8=', 'aGVsbG8h', 'aGk=', 'YQ==', 'a+b/'],
    invalid: ['', 'aGVsbG8', 'aGVsbG8===', 'a-b_', r'aGV$bG8=', 'YQ=a', '=YQ='],
  ),
  _Case(
    'Base64(urlSafe: true)',
    (f) => f.base64Url,
    isA<FormidableBase64Error>(),
    valid: ['aGVsbG8', 'aGVsbG8=', 'a-b_', 'YQ', 'YQ=='],
    invalid: ['', 'a+b/', 'a', 'aGVsbG8===', 'YQ=a'],
  ),
  _Case(
    'Json',
    (f) => f.json,
    isA<FormidableJsonError>(),
    valid: ['{}', '{"a": [1, 2, {"b": null}]}', '[]', '"text"', '12', 'true'],
    invalid: ['', '{', "{'a': 1}", '{"a": 1,}', 'undefined', 'abc'],
  ),
  _Case(
    'Jwt',
    (f) => f.jwt,
    isA<FormidableJwtError>(),
    valid: [_jwt],
    invalid: [
      '',
      'a.b',
      'a.b.c.d',
      '$_jwt.extra',
      // header is not JSON
      'bm90IGpzb24.eyJzdWIiOiIxIn0.c2ln',
      // payload is not an object
      'eyJhbGciOiJIUzI1NiJ9.WzFd.c2ln',
      // not base64url
      'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxIn0.si+n',
      // empty signature
      'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxIn0.',
    ],
  ),
  _Case(
    'SemVer',
    (f) => f.semVer,
    isA<FormidableSemVerError>(),
    valid: [
      '0.0.0',
      '1.2.3',
      '10.20.30',
      '1.0.0-alpha',
      '1.0.0-alpha.1',
      '1.0.0-0.3.7',
      '1.0.0+20130313144700',
      '1.0.0-beta+exp.sha.5114f85',
    ],
    invalid: [
      '',
      '1',
      '1.2',
      '1.2.3.4',
      'v1.2.3',
      '01.2.3',
      '1.02.3',
      '1.2.03',
      '1.0.0-',
      '1.0.0-01',
      '1.0.0+',
      '-1.0.0',
    ],
  ),
  _Case(
    'Luhn',
    (f) => f.luhn,
    isA<FormidableLuhnError>(),
    valid: ['79927398713', '4539 1488 0343 6467', '4539-1488-0343-6467', '00'],
    invalid: ['', '79927398710', '4539 1488 0343 6468', '1', 'abcd', '12a45'],
  ),
  _Case(
    'Isbn',
    (f) => f.isbn,
    isA<FormidableIsbnError>(),
    valid: [
      '0306406152',
      '0-306-40615-2',
      '080442957X',
      '0-8044-2957-x',
      '9783161484100',
      '978-3-16-148410-0',
      '978 0 306 40615 7',
    ],
    invalid: [
      '',
      '0306406153',
      '9783161484101',
      '978316148410',
      '1234567890123',
      '0-306-40615',
      'abcdefghij',
      '03064061X2',
    ],
  ),
  _Case(
    'Isbn(version: 13)',
    (f) => f.isbn13,
    isA<FormidableIsbnError>(),
    valid: ['978-3-16-148410-0', '9780306406157'],
    invalid: ['0-306-40615-2', '0306406152'],
  ),
];

void main() {
  group('format Validators', () {
    for (final c in _cases) {
      group(c.name, () {
        for (final value in c.valid) {
          test('accepts ${_show(value)}', () {
            expect(_errorsOf(c, value), isEmpty);
          });
        }
        for (final value in c.invalid) {
          test('rejects ${_show(value)}', () {
            expect(_errorsOf(c, value), [c.error]);
          });
        }
      });
    }

    test('are skipped while the Field is Unset', () {
      final form = FormatCatalogForm();

      expect(form.email.state.errors, isEmpty);
      expect(form.jwt.state.errors, isEmpty);
    });
  });

  group('error data', () {
    test('Url reports its schemes and the TLD requirement', () {
      final form = FormatCatalogForm()
        ..url.setValue('x')
        ..ftpUrl.setValue('x');

      expect(form.url.state.errors, [
        const FormidableUrlError(schemes: ['http', 'https'], requireTld: true),
      ]);
      expect(form.ftpUrl.state.errors, [
        const FormidableUrlError(schemes: ['ftp', 'https'], requireTld: false),
      ]);
    });

    test('Uuid reports the version, or null for any version', () {
      final form = FormatCatalogForm()
        ..uuid.setValue('x')
        ..uuidV4.setValue('x');

      expect(form.uuid.state.errors, [const FormidableUuidError()]);
      expect(form.uuidV4.state.errors, [const FormidableUuidError(version: 4)]);
    });

    test('ColorCode reports the formats it accepts', () {
      final form = FormatCatalogForm()
        ..color.setValue('x')
        ..rgbColor.setValue('x');

      expect(form.color.state.errors, [
        const FormidableColorCodeError(formats: ColorFormat.values),
      ]);
      expect(form.rgbColor.state.errors, [
        const FormidableColorCodeError(
          formats: [ColorFormat.rgb, ColorFormat.rgba],
        ),
      ]);
    });

    test('Isbn reports the version, or null for either', () {
      final form = FormatCatalogForm()
        ..isbn.setValue('x')
        ..isbn13.setValue('x');

      expect(form.isbn.state.errors, [const FormidableIsbnError()]);
      expect(form.isbn13.state.errors, [
        const FormidableIsbnError(version: 13),
      ]);
    });
  });
}

String _show(String value) => value.isEmpty ? '(empty)' : "'$value'";

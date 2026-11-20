import 'package:formidable/formidable.dart';

part 'format_catalog.formidable.dart';

/// One nullable Field per built-in format Validator.
@Formidable()
class FormatCatalog {
  const FormatCatalog({
    this.email,
    this.url,
    this.ftpUrl,
    this.uuid,
    this.uuidV4,
    this.ulid,
    this.hexColor,
    this.hexColorNoHash,
    this.color,
    this.rgbColor,
    this.hexadecimal,
    this.octal,
    this.base64,
    this.base64Url,
    this.json,
    this.jwt,
    this.semVer,
    this.luhn,
    this.isbn,
    this.isbn13,
  });

  @Email()
  final String? email;

  @Url()
  final String? url;

  @Url(schemes: ['ftp', 'https'], requireTld: false)
  final String? ftpUrl;

  @Uuid()
  final String? uuid;

  @Uuid(version: 4)
  final String? uuidV4;

  @Ulid()
  final String? ulid;

  @HexColor()
  final String? hexColor;

  @HexColor(requireHash: false)
  final String? hexColorNoHash;

  @ColorCode()
  final String? color;

  @ColorCode(formats: [ColorFormat.rgb, ColorFormat.rgba])
  final String? rgbColor;

  @Hexadecimal()
  final String? hexadecimal;

  @Octal()
  final String? octal;

  @Base64()
  final String? base64;

  @Base64(urlSafe: true)
  final String? base64Url;

  @Json()
  final String? json;

  @Jwt()
  final String? jwt;

  @SemVer()
  final String? semVer;

  @Luhn()
  final String? luhn;

  @Isbn()
  final String? isbn;

  @Isbn(version: 13)
  final String? isbn13;
}

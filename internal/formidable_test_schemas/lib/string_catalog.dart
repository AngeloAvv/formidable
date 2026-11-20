import 'package:formidable/formidable.dart';

part 'string_catalog.formidable.dart';

/// One nullable Field per built-in string Validator, so a test can drive each
/// rule on its own through the generated Form.
@Formidable()
class StringCatalog {
  const StringCatalog({
    this.maxLength,
    this.exactLength,
    this.betweenLength,
    this.pattern,
    this.notPattern,
    this.startsWith,
    this.endsWith,
    this.doesntStartWith,
    this.doesntEndWith,
    this.contains,
    this.notContains,
    this.alpha,
    this.alphaNumeric,
    this.alphaDash,
    this.alphaSpaces,
    this.ascii,
    this.lowercase,
    this.uppercase,
    this.hasLowercase,
    this.hasUppercase,
    this.hasDigit,
    this.hasSpecialChar,
    this.hasTwoSpecialChars,
    this.strongPassword,
    this.singleLine,
    this.minWords,
    this.maxWords,
    this.slug,
  });

  @MaxLength(5)
  final String? maxLength;

  @Length.exactly(4)
  final String? exactLength;

  @Length.between(2, 4)
  final String? betweenLength;

  @Pattern(r'^\d{3}$')
  final String? pattern;

  @Pattern(r'\d', negate: true)
  final String? notPattern;

  @StartsWith('ab')
  final String? startsWith;

  @EndsWith('yz')
  final String? endsWith;

  @DoesntStartWith('ab')
  final String? doesntStartWith;

  @DoesntEndWith('yz')
  final String? doesntEndWith;

  @Contains('mid')
  final String? contains;

  @NotContains('bad')
  final String? notContains;

  @Alpha()
  final String? alpha;

  @AlphaNumeric()
  final String? alphaNumeric;

  @AlphaDash()
  final String? alphaDash;

  @AlphaSpaces()
  final String? alphaSpaces;

  @Ascii()
  final String? ascii;

  @Lowercase()
  final String? lowercase;

  @Uppercase()
  final String? uppercase;

  @HasLowercase()
  final String? hasLowercase;

  @HasUppercase()
  final String? hasUppercase;

  @HasDigit()
  final String? hasDigit;

  @HasSpecialChar()
  final String? hasSpecialChar;

  @HasSpecialChar(2)
  final String? hasTwoSpecialChars;

  @StrongPassword()
  final String? strongPassword;

  @SingleLine()
  final String? singleLine;

  @MinWords(2)
  final String? minWords;

  @MaxWords(3)
  final String? maxWords;

  @Slug()
  final String? slug;
}

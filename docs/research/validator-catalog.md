# Validator catalog research

This file compares the built-in validators of Angular Forms, Laravel, Zod, Yup, class-validator, Joi, VeeValidate, form_builder_validators, Symfony, Rails and Django. We use the comparison to pick Formidable's built-in catalog.

The Tier column means:
- **v1**: ships in the first release.
- **v1-cross**: a cross-field rule that ships in the first release.
- **later**: a future release, often because it needs heavy data or dependencies.
- **skip**: out of scope.

## Not validators in Formidable

- **Presence** comes from the Schema type and `@Required()`.
- **Transforms** such as trim, lowercase and truncate are Normalizers.
- **Type and format parsing** (number, integer, boolean, date, enum) produces a `ParseError` from a Codec.
- **Server-dependent checks** such as uniqueness, existence and DNS lookups belong in Async Validators.
- **Combinators** are engine features, not catalog entries. The engine only provides `AnyOf([...])`.

## Strings (String)

| Annotation | Tier |
|---|---|
| `MinLength`, `MaxLength`, `Length(min, max \| exact)` (also for collections) | v1 |
| `Pattern(regex, negate)` | v1 |
| `StartsWith`, `EndsWith`, `DoesntStartWith`, `DoesntEndWith` | v1 |
| `Contains`, `NotContains` | v1 |
| `Alpha`, `AlphaNumeric`, `AlphaDash`, `AlphaSpaces`, `Ascii` | v1 |
| `Lowercase`, `Uppercase` (check only, no transform) | v1 |
| `HasLowercase`, `HasUppercase`, `HasDigit`, `HasSpecialChar(min)` | v1 |
| `StrongPassword(minLength, minLower, minUpper, minDigits, minSymbols)` | v1 |
| `SingleLine`, `MinWords`, `MaxWords`, `Slug` | v1 |
| `ByteLength`, full-width and half-width checks, `NoSuspiciousChars` | later |

## Formats and identifiers (String)

| Annotation | Tier |
|---|---|
| `Email`, `Url(schemes, requireTld)`, `Uuid(version)`, `Ulid` | v1 |
| `HexColor`, `Color(formats)`, `Hexadecimal`, `Octal`, `Base64` | v1 |
| `Json`, `Jwt`, `SemVer`, `Luhn`, `Isbn` | v1 |
| `Cuid`, `NanoId`, `Base32`, `Base58`, `DataUri`, `Hash(alg)` | later |
| `Issn`, `Isrc`, `Ean`, `Isin`, `Vin`, `MimeType`, `Emoji` | later |

## Numbers (num, int)

| Annotation | Tier |
|---|---|
| `Min`, `Max(exclusive)`, `Range(min, max)` | v1 |
| `Positive`, `PositiveOrZero`, `Negative`, `NegativeOrZero`, `NonZero` | v1 |
| `MultipleOf`, `Even`, `Odd` | v1 |
| `DecimalPlaces`, `Digits`, `MinDigits`, `MaxDigits` | v1 |
| `Port` | v1 |
| `Prime`, `Int32` | later |

## Dates (DateTime)

| Annotation | Tier |
|---|---|
| `After`, `Before` (against a const date, `now` or `today`, `inclusive` option) | v1 |
| `Future`, `Past` (injectable clock) | v1 |
| `DateBetween`, `SameDay` | v1 |
| `MinAge`, `MaxAge` | v1 |
| `Weekday`, `TimeZone` | later |

## Collections (Iterable, Set, Map)

| Annotation | Tier |
|---|---|
| `NotEmpty`, `Unique(ignoreCase)` | v1 |
| `ContainsAll`, `ContainsNone` | v1 |
| `HasKeys` | v1 |
| `Each([validators])` | v1 |

## Files

| Annotation | Tier |
|---|---|
| `MaxFileSize`, `MinFileSize` | v1 |
| `FileExtension`, `MimeType`, `Image`, `FileName` | v1 |
| `ImageDimensions` (async) | later |

## Booleans and choices

| Annotation | Tier |
|---|---|
| `IsTrue` (alias `Accepted`), `IsFalse` (alias `Declined`) | v1 |
| `OneOf(ignoreCase)`, `NoneOf` | v1 |
| `EqualTo`, `NotEqualTo` | v1 |

## Network (String)

| Annotation | Tier |
|---|---|
| `Ip(version)`, `Cidr`, `MacAddress` | v1 |
| `Hostname`, `Fqdn`, `Domain` | v1 |
| `LatLng`, `Latitude`, `Longitude` | v1 |

## Finance

| Annotation | Tier |
|---|---|
| `CreditCard(brands)`, `CardCvc`, `CardExpiry` | v1 |
| `Iban(countries)`, `Bic` | v1 |
| `CurrencyCode` | v1 |
| `CurrencyAmount`, crypto addresses | later |

## Locale-specific

| Annotation | Tier |
|---|---|
| `CountryCode`, `LanguageCode`, `Locale` | v1 |
| `Phone` (E.164 shape only) | v1 |
| `PhoneNumber(region)` (needs libphonenumber metadata) | later |
| `PostalCode(country)` | later |
| `VatNumber`, `TaxId` (e.g. Italian codice fiscale), `Ssn`, `Passport` | later |

## Cross-field rules

| Rule | Tier |
|---|---|
| `MustMatch` (alias `Confirmed`), `Different` | v1-cross |
| `Compare(op)` and `DateRangeOrder` | v1-cross |
| `RequiredIf`, `RequiredUnless` | v1-cross |
| `RequiredWith`, `RequiredWithAll`, `RequiredWithout`, `RequiredWithoutAll` | v1-cross |
| `RequiredIfAccepted`, `RequiredIfDeclined` | v1-cross |
| `ProhibitedIf`, `ProhibitedUnless`, `Prohibits` | v1-cross |
| `AcceptedIf`, `DeclinedIf` | v1-cross |
| `AtLeastOneOf`, `ExactlyOneOf`, `AtMostOneOf` | v1-cross |
| `InList`, `UniqueBy` | v1-cross |
| `EqualLength` | later |

## Sources

- https://angular.dev/api/forms/Validators
- https://laravel.com/docs/12.x/validation#available-validation-rules
- https://zod.dev/api
- https://github.com/jquense/yup#api
- https://github.com/typestack/class-validator#validation-decorators
- https://joi.dev/api/
- https://vee-validate.logaretm.com/v4/guide/global-validators/
- https://pub.dev/packages/form_builder_validators
- https://symfony.com/doc/current/reference/constraints.html
- https://guides.rubyonrails.org/active_record_validations.html
- https://docs.djangoproject.com/en/stable/ref/validators/

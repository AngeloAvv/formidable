import 'package:formidable/formidable.dart';

part 'catalog_locale.formidable.dart';

/// One Field per locale Validator of the built-in catalog.
@Formidable()
class Traveler {
  const Traveler({
    required this.country,
    required this.language,
    required this.locale,
    required this.phone,
  });

  @CountryCode()
  final String country;

  @LanguageCode()
  final String language;

  @LocaleCode()
  final String locale;

  @Phone()
  final String phone;
}

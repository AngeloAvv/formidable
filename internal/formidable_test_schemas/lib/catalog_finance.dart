import 'package:formidable/formidable.dart';

part 'catalog_finance.formidable.dart';

/// One Field per finance Validator of the built-in catalog.
@Formidable()
class Payment {
  const Payment({
    required this.card,
    required this.visaOrMastercard,
    required this.cvc,
    required this.expiry,
    required this.iban,
    required this.italianOrGermanIban,
    required this.bic,
    required this.currency,
  });

  @CreditCard()
  final String card;

  @CreditCard(brands: [CardBrand.visa, CardBrand.mastercard])
  final String visaOrMastercard;

  @CardCvc()
  final String cvc;

  @CardExpiry()
  final String expiry;

  @Iban()
  final String iban;

  @Iban(countries: ['IT', 'DE'])
  final String italianOrGermanIban;

  @Bic()
  final String bic;

  @CurrencyCode()
  final String currency;
}

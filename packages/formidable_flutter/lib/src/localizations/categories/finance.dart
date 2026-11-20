import 'package:formidable/formidable.dart';

/// Messages for the errors of the finance Validators.
abstract mixin class FormidableFinanceMessages {
  /// The value is not a valid card number of one of [brands] (any when empty).
  String creditCard(List<CardBrand> brands);

  /// The value is not a card security code.
  String cardCvc();

  /// The value is not written as a card expiry date.
  String cardExpiry();

  /// The card has expired.
  String cardExpired();

  /// The value is not a valid IBAN of one of [countries] (any when empty).
  String iban(List<String> countries);

  /// The value is not a valid BIC.
  String bic();

  /// The value is not a currency code.
  String currencyCode();

  /// The message for a finance error, or null for any other error.
  String? financeMessageOf(FormidableValidationError error) => switch (error) {
    FormidableCreditCardError(:final brands) => creditCard(brands),
    FormidableCardCvcError() => cardCvc(),
    FormidableCardExpiryError() => cardExpiry(),
    FormidableCardExpiredError() => cardExpired(),
    FormidableIbanError(:final countries) => iban(countries),
    FormidableBicError() => bic(),
    FormidableCurrencyCodeError() => currencyCode(),
    _ => null,
  };
}

String _brands(List<CardBrand> brands) => brands
    .map(
      (brand) => switch (brand) {
        CardBrand.visa => 'Visa',
        CardBrand.mastercard => 'Mastercard',
        CardBrand.amex => 'American Express',
        CardBrand.discover => 'Discover',
        CardBrand.diners => 'Diners Club',
        CardBrand.jcb => 'JCB',
        CardBrand.unionpay => 'UnionPay',
        CardBrand.maestro => 'Maestro',
      },
    )
    .join(', ');

mixin FormidableFinanceMessagesEn implements FormidableFinanceMessages {
  @override
  String creditCard(List<CardBrand> brands) => brands.isEmpty
      ? 'Must be a valid card number.'
      : 'Must be a valid card number (accepted: ${_brands(brands)}).';

  @override
  String cardCvc() => 'Must be a 3 or 4 digit security code.';

  @override
  String cardExpiry() => 'Must be an expiry date written as MM/YY.';

  @override
  String cardExpired() => 'The card has expired.';

  @override
  String iban(List<String> countries) => countries.isEmpty
      ? 'Must be a valid IBAN.'
      : 'Must be a valid IBAN from: ${countries.join(', ')}.';

  @override
  String bic() => 'Must be a valid BIC.';

  @override
  String currencyCode() => 'Must be a valid currency code.';
}

mixin FormidableFinanceMessagesIt implements FormidableFinanceMessages {
  @override
  String creditCard(List<CardBrand> brands) => brands.isEmpty
      ? 'Deve essere un numero di carta valido.'
      : 'Deve essere un numero di carta valido (accettate: ${_brands(brands)}).';

  @override
  String cardCvc() => 'Deve essere un codice di sicurezza di 3 o 4 cifre.';

  @override
  String cardExpiry() => 'Deve essere una data di scadenza nel formato MM/AA.';

  @override
  String cardExpired() => 'La carta è scaduta.';

  @override
  String iban(List<String> countries) => countries.isEmpty
      ? 'Deve essere un IBAN valido.'
      : 'Deve essere un IBAN valido tra i paesi: ${countries.join(', ')}.';

  @override
  String bic() => 'Deve essere un BIC valido.';

  @override
  String currencyCode() => 'Deve essere un codice valuta valido.';
}

mixin FormidableFinanceMessagesEs implements FormidableFinanceMessages {
  @override
  String creditCard(List<CardBrand> brands) => brands.isEmpty
      ? 'Debe ser un número de tarjeta válido.'
      : 'Debe ser un número de tarjeta válido (se aceptan: ${_brands(brands)}).';

  @override
  String cardCvc() => 'Debe ser un código de seguridad de 3 o 4 dígitos.';

  @override
  String cardExpiry() =>
      'Debe ser una fecha de caducidad con el formato MM/AA.';

  @override
  String cardExpired() => 'La tarjeta ha caducado.';

  @override
  String iban(List<String> countries) => countries.isEmpty
      ? 'Debe ser un IBAN válido.'
      : 'Debe ser un IBAN válido de: ${countries.join(', ')}.';

  @override
  String bic() => 'Debe ser un BIC válido.';

  @override
  String currencyCode() => 'Debe ser un código de moneda válido.';
}

mixin FormidableFinanceMessagesFr implements FormidableFinanceMessages {
  @override
  String creditCard(List<CardBrand> brands) => brands.isEmpty
      ? 'Doit être un numéro de carte valide.'
      : 'Doit être un numéro de carte valide (acceptées : ${_brands(brands)}).';

  @override
  String cardCvc() => 'Doit être un code de sécurité à 3 ou 4 chiffres.';

  @override
  String cardExpiry() => "Doit être une date d'expiration au format MM/AA.";

  @override
  String cardExpired() => 'La carte a expiré.';

  @override
  String iban(List<String> countries) => countries.isEmpty
      ? 'Doit être un IBAN valide.'
      : 'Doit être un IBAN valide parmi les pays : ${countries.join(', ')}.';

  @override
  String bic() => 'Doit être un BIC valide.';

  @override
  String currencyCode() => 'Doit être un code de devise valide.';
}

mixin FormidableFinanceMessagesDe implements FormidableFinanceMessages {
  @override
  String creditCard(List<CardBrand> brands) => brands.isEmpty
      ? 'Muss eine gültige Kartennummer sein.'
      : 'Muss eine gültige Kartennummer sein (akzeptiert: ${_brands(brands)}).';

  @override
  String cardCvc() => 'Muss ein drei- oder vierstelliger Sicherheitscode sein.';

  @override
  String cardExpiry() => 'Muss ein Ablaufdatum im Format MM/JJ sein.';

  @override
  String cardExpired() => 'Die Karte ist abgelaufen.';

  @override
  String iban(List<String> countries) => countries.isEmpty
      ? 'Muss eine gültige IBAN sein.'
      : 'Muss eine gültige IBAN aus folgenden Ländern sein: '
            '${countries.join(', ')}.';

  @override
  String bic() => 'Muss ein gültiger BIC sein.';

  @override
  String currencyCode() => 'Muss ein gültiger Währungscode sein.';
}

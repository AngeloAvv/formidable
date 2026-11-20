import 'package:formidable/formidable.dart';

/// Messages for the errors of the cross-field rules.
abstract mixin class FormidableCrossFieldMessages {
  /// The message of `FormidableMustMatchError`.
  String mustMatch();

  /// The message of `FormidableDifferentError`.
  String different();

  /// The Field is not in the relation [comparison] with the other Field.
  String compare(FormidableComparison comparison);

  /// The date is before the start of its range. [allowSame] says whether the start itself was accepted.
  String dateRangeOrder(bool allowSame);

  /// The message of `FormidableRequiredIfError`.
  String requiredIf();

  /// The message of `FormidableRequiredUnlessError`.
  String requiredUnless();

  /// The message of `FormidableRequiredWithError`.
  String requiredWith();

  /// The message of `FormidableRequiredWithAllError`.
  String requiredWithAll();

  /// The message of `FormidableRequiredWithoutError`.
  String requiredWithout();

  /// The message of `FormidableRequiredWithoutAllError`.
  String requiredWithoutAll();

  /// The message of `FormidableRequiredIfAcceptedError`.
  String requiredIfAccepted();

  /// The message of `FormidableRequiredIfDeclinedError`.
  String requiredIfDeclined();

  /// The message of `FormidableProhibitedIfError`.
  String prohibitedIf();

  /// The message of `FormidableProhibitedUnlessError`.
  String prohibitedUnless();

  /// The message of `FormidableProhibitsError`.
  String prohibits();

  /// The message of `FormidableAcceptedIfError`.
  String acceptedIf();

  /// The message of `FormidableDeclinedIfError`.
  String declinedIf();

  /// The message of `FormidableAtLeastOneOfError`.
  String atLeastOneOf();

  /// The message of `FormidableExactlyOneOfError`.
  String exactlyOneOf();

  /// The message of `FormidableAtMostOneOfError`.
  String atMostOneOf();

  /// The message of `FormidableInListError`.
  String inList();

  /// The message of `FormidableUniqueByError`.
  String uniqueBy();

  /// The message for a cross-field error, or null for any other error.
  String? crossFieldMessageOf(FormidableValidationError error) =>
      switch (error) {
        FormidableMustMatchError() => mustMatch(),
        FormidableDifferentError() => different(),
        FormidableCompareError(:final comparison) => compare(comparison),
        FormidableDateRangeOrderError(:final allowSame) => dateRangeOrder(
          allowSame,
        ),
        FormidableRequiredIfError() => requiredIf(),
        FormidableRequiredUnlessError() => requiredUnless(),
        FormidableRequiredWithError() => requiredWith(),
        FormidableRequiredWithAllError() => requiredWithAll(),
        FormidableRequiredWithoutError() => requiredWithout(),
        FormidableRequiredWithoutAllError() => requiredWithoutAll(),
        FormidableRequiredIfAcceptedError() => requiredIfAccepted(),
        FormidableRequiredIfDeclinedError() => requiredIfDeclined(),
        FormidableProhibitedIfError() => prohibitedIf(),
        FormidableProhibitedUnlessError() => prohibitedUnless(),
        FormidableProhibitsError() => prohibits(),
        FormidableAcceptedIfError() => acceptedIf(),
        FormidableDeclinedIfError() => declinedIf(),
        FormidableAtLeastOneOfError() => atLeastOneOf(),
        FormidableExactlyOneOfError() => exactlyOneOf(),
        FormidableAtMostOneOfError() => atMostOneOf(),
        FormidableInListError() => inList(),
        FormidableUniqueByError() => uniqueBy(),
        _ => null,
      };
}

mixin FormidableCrossFieldMessagesEn implements FormidableCrossFieldMessages {
  @override
  String mustMatch() => 'The values do not match.';

  @override
  String different() => 'Must be different from the other value.';

  @override
  String compare(FormidableComparison comparison) => switch (comparison) {
    FormidableComparison.equalTo => 'Must be equal to the other value.',
    FormidableComparison.notEqualTo =>
      'Must be different from the other value.',
    FormidableComparison.lessThan => 'Must be less than the other value.',
    FormidableComparison.lessThanOrEqualTo =>
      'Must be less than or equal to the other value.',
    FormidableComparison.greaterThan => 'Must be greater than the other value.',
    FormidableComparison.greaterThanOrEqualTo =>
      'Must be greater than or equal to the other value.',
  };

  @override
  String dateRangeOrder(bool allowSame) => allowSame
      ? 'Must not be before the start date.'
      : 'Must be after the start date.';

  @override
  String requiredIf() => 'This field is required.';

  @override
  String requiredUnless() => 'This field is required.';

  @override
  String requiredWith() => 'This field is required.';

  @override
  String requiredWithAll() => 'This field is required.';

  @override
  String requiredWithout() => 'This field is required.';

  @override
  String requiredWithoutAll() => 'This field is required.';

  @override
  String requiredIfAccepted() => 'This field is required.';

  @override
  String requiredIfDeclined() => 'This field is required.';

  @override
  String prohibitedIf() => 'This field is not allowed.';

  @override
  String prohibitedUnless() => 'This field is not allowed.';

  @override
  String prohibits() =>
      'This field cannot be used together with the related fields.';

  @override
  String acceptedIf() => 'This must be accepted.';

  @override
  String declinedIf() => 'This must be declined.';

  @override
  String atLeastOneOf() => 'Fill in at least one of the related fields.';

  @override
  String exactlyOneOf() => 'Fill in exactly one of the related fields.';

  @override
  String atMostOneOf() => 'Fill in at most one of the related fields.';

  @override
  String inList() => 'Must be one of the available values.';

  @override
  String uniqueBy() => 'This value is already in the list.';
}

mixin FormidableCrossFieldMessagesIt implements FormidableCrossFieldMessages {
  @override
  String mustMatch() => 'I valori non coincidono.';

  @override
  String different() => 'Deve essere diverso dall\'altro valore.';

  @override
  String compare(FormidableComparison comparison) => switch (comparison) {
    FormidableComparison.equalTo => 'Deve essere uguale all\'altro valore.',
    FormidableComparison.notEqualTo =>
      'Deve essere diverso dall\'altro valore.',
    FormidableComparison.lessThan => 'Deve essere minore dell\'altro valore.',
    FormidableComparison.lessThanOrEqualTo =>
      'Deve essere minore o uguale all\'altro valore.',
    FormidableComparison.greaterThan =>
      'Deve essere maggiore dell\'altro valore.',
    FormidableComparison.greaterThanOrEqualTo =>
      'Deve essere maggiore o uguale all\'altro valore.',
  };

  @override
  String dateRangeOrder(bool allowSame) => allowSame
      ? 'Non può precedere la data di inizio.'
      : 'Deve essere successiva alla data di inizio.';

  @override
  String requiredIf() => 'Questo campo è obbligatorio.';

  @override
  String requiredUnless() => 'Questo campo è obbligatorio.';

  @override
  String requiredWith() => 'Questo campo è obbligatorio.';

  @override
  String requiredWithAll() => 'Questo campo è obbligatorio.';

  @override
  String requiredWithout() => 'Questo campo è obbligatorio.';

  @override
  String requiredWithoutAll() => 'Questo campo è obbligatorio.';

  @override
  String requiredIfAccepted() => 'Questo campo è obbligatorio.';

  @override
  String requiredIfDeclined() => 'Questo campo è obbligatorio.';

  @override
  String prohibitedIf() => 'Questo campo non è consentito.';

  @override
  String prohibitedUnless() => 'Questo campo non è consentito.';

  @override
  String prohibits() =>
      'Questo campo non può essere usato insieme ai campi correlati.';

  @override
  String acceptedIf() => 'Questo deve essere accettato.';

  @override
  String declinedIf() => 'Questo deve essere rifiutato.';

  @override
  String atLeastOneOf() => 'Compila almeno uno dei campi correlati.';

  @override
  String exactlyOneOf() => 'Compila esattamente uno dei campi correlati.';

  @override
  String atMostOneOf() => 'Compila al massimo uno dei campi correlati.';

  @override
  String inList() => 'Deve essere uno dei valori disponibili.';

  @override
  String uniqueBy() => 'Questo valore è già presente nell\'elenco.';
}

mixin FormidableCrossFieldMessagesEs implements FormidableCrossFieldMessages {
  @override
  String mustMatch() => 'Los valores no coinciden.';

  @override
  String different() => 'Debe ser distinto del otro valor.';

  @override
  String compare(FormidableComparison comparison) => switch (comparison) {
    FormidableComparison.equalTo => 'Debe ser igual al otro valor.',
    FormidableComparison.notEqualTo => 'Debe ser distinto del otro valor.',
    FormidableComparison.lessThan => 'Debe ser menor que el otro valor.',
    FormidableComparison.lessThanOrEqualTo =>
      'Debe ser menor o igual que el otro valor.',
    FormidableComparison.greaterThan => 'Debe ser mayor que el otro valor.',
    FormidableComparison.greaterThanOrEqualTo =>
      'Debe ser mayor o igual que el otro valor.',
  };

  @override
  String dateRangeOrder(bool allowSame) => allowSame
      ? 'No puede ser anterior a la fecha de inicio.'
      : 'Debe ser posterior a la fecha de inicio.';

  @override
  String requiredIf() => 'Este campo es obligatorio.';

  @override
  String requiredUnless() => 'Este campo es obligatorio.';

  @override
  String requiredWith() => 'Este campo es obligatorio.';

  @override
  String requiredWithAll() => 'Este campo es obligatorio.';

  @override
  String requiredWithout() => 'Este campo es obligatorio.';

  @override
  String requiredWithoutAll() => 'Este campo es obligatorio.';

  @override
  String requiredIfAccepted() => 'Este campo es obligatorio.';

  @override
  String requiredIfDeclined() => 'Este campo es obligatorio.';

  @override
  String prohibitedIf() => 'Este campo no está permitido.';

  @override
  String prohibitedUnless() => 'Este campo no está permitido.';

  @override
  String prohibits() =>
      'Este campo no se puede usar junto con los campos relacionados.';

  @override
  String acceptedIf() => 'Esto debe ser aceptado.';

  @override
  String declinedIf() => 'Esto debe ser rechazado.';

  @override
  String atLeastOneOf() => 'Rellena al menos uno de los campos relacionados.';

  @override
  String exactlyOneOf() =>
      'Rellena exactamente uno de los campos relacionados.';

  @override
  String atMostOneOf() => 'Rellena como máximo uno de los campos relacionados.';

  @override
  String inList() => 'Debe ser uno de los valores disponibles.';

  @override
  String uniqueBy() => 'Este valor ya está en la lista.';
}

mixin FormidableCrossFieldMessagesFr implements FormidableCrossFieldMessages {
  @override
  String mustMatch() => 'Les valeurs ne correspondent pas.';

  @override
  String different() => 'Doit être différent de l\'autre valeur.';

  @override
  String compare(FormidableComparison comparison) => switch (comparison) {
    FormidableComparison.equalTo => 'Doit être égal à l\'autre valeur.',
    FormidableComparison.notEqualTo =>
      'Doit être différent de l\'autre valeur.',
    FormidableComparison.lessThan => 'Doit être inférieur à l\'autre valeur.',
    FormidableComparison.lessThanOrEqualTo =>
      'Doit être inférieur ou égal à l\'autre valeur.',
    FormidableComparison.greaterThan =>
      'Doit être supérieur à l\'autre valeur.',
    FormidableComparison.greaterThanOrEqualTo =>
      'Doit être supérieur ou égal à l\'autre valeur.',
  };

  @override
  String dateRangeOrder(bool allowSame) => allowSame
      ? 'Ne peut pas précéder la date de début.'
      : 'Doit être postérieure à la date de début.';

  @override
  String requiredIf() => 'Ce champ est obligatoire.';

  @override
  String requiredUnless() => 'Ce champ est obligatoire.';

  @override
  String requiredWith() => 'Ce champ est obligatoire.';

  @override
  String requiredWithAll() => 'Ce champ est obligatoire.';

  @override
  String requiredWithout() => 'Ce champ est obligatoire.';

  @override
  String requiredWithoutAll() => 'Ce champ est obligatoire.';

  @override
  String requiredIfAccepted() => 'Ce champ est obligatoire.';

  @override
  String requiredIfDeclined() => 'Ce champ est obligatoire.';

  @override
  String prohibitedIf() => 'Ce champ n\'est pas autorisé.';

  @override
  String prohibitedUnless() => 'Ce champ n\'est pas autorisé.';

  @override
  String prohibits() =>
      'Ce champ ne peut pas être utilisé avec les champs associés.';

  @override
  String acceptedIf() => 'Ceci doit être accepté.';

  @override
  String declinedIf() => 'Ceci doit être refusé.';

  @override
  String atLeastOneOf() => 'Remplissez au moins l\'un des champs associés.';

  @override
  String exactlyOneOf() => 'Remplissez exactement l\'un des champs associés.';

  @override
  String atMostOneOf() => 'Remplissez au plus l\'un des champs associés.';

  @override
  String inList() => 'Doit être l\'une des valeurs disponibles.';

  @override
  String uniqueBy() => 'Cette valeur figure déjà dans la liste.';
}

mixin FormidableCrossFieldMessagesDe implements FormidableCrossFieldMessages {
  @override
  String mustMatch() => 'Die Werte stimmen nicht überein.';

  @override
  String different() => 'Muss sich vom anderen Wert unterscheiden.';

  @override
  String compare(FormidableComparison comparison) => switch (comparison) {
    FormidableComparison.equalTo => 'Muss dem anderen Wert entsprechen.',
    FormidableComparison.notEqualTo =>
      'Muss sich vom anderen Wert unterscheiden.',
    FormidableComparison.lessThan => 'Muss kleiner als der andere Wert sein.',
    FormidableComparison.lessThanOrEqualTo =>
      'Muss kleiner oder gleich dem anderen Wert sein.',
    FormidableComparison.greaterThan => 'Muss größer als der andere Wert sein.',
    FormidableComparison.greaterThanOrEqualTo =>
      'Muss größer oder gleich dem anderen Wert sein.',
  };

  @override
  String dateRangeOrder(bool allowSame) => allowSame
      ? 'Darf nicht vor dem Startdatum liegen.'
      : 'Muss nach dem Startdatum liegen.';

  @override
  String requiredIf() => 'Dieses Feld ist erforderlich.';

  @override
  String requiredUnless() => 'Dieses Feld ist erforderlich.';

  @override
  String requiredWith() => 'Dieses Feld ist erforderlich.';

  @override
  String requiredWithAll() => 'Dieses Feld ist erforderlich.';

  @override
  String requiredWithout() => 'Dieses Feld ist erforderlich.';

  @override
  String requiredWithoutAll() => 'Dieses Feld ist erforderlich.';

  @override
  String requiredIfAccepted() => 'Dieses Feld ist erforderlich.';

  @override
  String requiredIfDeclined() => 'Dieses Feld ist erforderlich.';

  @override
  String prohibitedIf() => 'Dieses Feld ist nicht erlaubt.';

  @override
  String prohibitedUnless() => 'Dieses Feld ist nicht erlaubt.';

  @override
  String prohibits() =>
      'Dieses Feld darf nicht zusammen mit den zugehörigen Feldern verwendet werden.';

  @override
  String acceptedIf() => 'Dies muss akzeptiert werden.';

  @override
  String declinedIf() => 'Dies muss abgelehnt werden.';

  @override
  String atLeastOneOf() =>
      'Füllen Sie mindestens eines der zugehörigen Felder aus.';

  @override
  String exactlyOneOf() => 'Füllen Sie genau eines der zugehörigen Felder aus.';

  @override
  String atMostOneOf() =>
      'Füllen Sie höchstens eines der zugehörigen Felder aus.';

  @override
  String inList() => 'Muss einer der verfügbaren Werte sein.';

  @override
  String uniqueBy() => 'Dieser Wert ist bereits in der Liste enthalten.';
}

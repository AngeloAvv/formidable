import 'package:formidable/formidable.dart';

/// Messages for the errors of the collection Validators.
abstract mixin class FormidableCollectionMessages {
  /// The collection is empty.
  String notEmpty();

  /// The collection holds the [duplicates] more than once.
  String unique(List<Object?> duplicates);

  /// The collection lacks the [missing] elements.
  String containsAll(List<Object?> missing);

  /// The collection holds the forbidden elements in [found].
  String containsNone(List<Object?> found);

  /// The map lacks the [missing] keys.
  String hasKeys(List<Object?> missing);

  /// The elements at [positions] are invalid. Positions start at 1.
  String each(List<int> positions);

  /// The message for a collection error, or null for any other error.
  String? collectionMessageOf(FormidableValidationError error) =>
      switch (error) {
        FormidableNotEmptyError() => notEmpty(),
        FormidableUniqueError(:final duplicates) => unique(duplicates),
        FormidableContainsAllError(:final missing) => containsAll(missing),
        FormidableContainsNoneError(:final found) => containsNone(found),
        FormidableHasKeysError(:final missing) => hasKeys(missing),
        FormidableEachError(:final failures) => each([
          for (final index in failures.keys) index + 1,
        ]),
        _ => null,
      };
}

mixin FormidableCollectionMessagesEn implements FormidableCollectionMessages {
  @override
  String notEmpty() => 'Must not be empty.';

  @override
  String unique(List<Object?> duplicates) =>
      'Must not contain duplicates: ${duplicates.join(', ')}.';

  @override
  String containsAll(List<Object?> missing) =>
      'Must contain: ${missing.join(', ')}.';

  @override
  String containsNone(List<Object?> found) =>
      'Must not contain: ${found.join(', ')}.';

  @override
  String hasKeys(List<Object?> missing) =>
      'Must have the keys: ${missing.join(', ')}.';

  @override
  String each(List<int> positions) => positions.length == 1
      ? 'Item ${positions.single} is invalid.'
      : 'Items ${positions.join(', ')} are invalid.';
}

mixin FormidableCollectionMessagesIt implements FormidableCollectionMessages {
  @override
  String notEmpty() => 'Non può essere vuoto.';

  @override
  String unique(List<Object?> duplicates) =>
      'Non può contenere duplicati: ${duplicates.join(', ')}.';

  @override
  String containsAll(List<Object?> missing) =>
      'Deve contenere: ${missing.join(', ')}.';

  @override
  String containsNone(List<Object?> found) =>
      'Non può contenere: ${found.join(', ')}.';

  @override
  String hasKeys(List<Object?> missing) =>
      'Deve avere le chiavi: ${missing.join(', ')}.';

  @override
  String each(List<int> positions) => positions.length == 1
      ? "L'elemento ${positions.single} non è valido."
      : 'Gli elementi ${positions.join(', ')} non sono validi.';
}

mixin FormidableCollectionMessagesEs implements FormidableCollectionMessages {
  @override
  String notEmpty() => 'No puede estar vacío.';

  @override
  String unique(List<Object?> duplicates) =>
      'No puede contener duplicados: ${duplicates.join(', ')}.';

  @override
  String containsAll(List<Object?> missing) =>
      'Debe contener: ${missing.join(', ')}.';

  @override
  String containsNone(List<Object?> found) =>
      'No puede contener: ${found.join(', ')}.';

  @override
  String hasKeys(List<Object?> missing) =>
      'Debe tener las claves: ${missing.join(', ')}.';

  @override
  String each(List<int> positions) => positions.length == 1
      ? 'El elemento ${positions.single} no es válido.'
      : 'Los elementos ${positions.join(', ')} no son válidos.';
}

mixin FormidableCollectionMessagesFr implements FormidableCollectionMessages {
  @override
  String notEmpty() => 'Ne doit pas être vide.';

  @override
  String unique(List<Object?> duplicates) =>
      'Ne doit pas contenir de doublons : ${duplicates.join(', ')}.';

  @override
  String containsAll(List<Object?> missing) =>
      'Doit contenir : ${missing.join(', ')}.';

  @override
  String containsNone(List<Object?> found) =>
      'Ne doit pas contenir : ${found.join(', ')}.';

  @override
  String hasKeys(List<Object?> missing) =>
      'Doit avoir les clés : ${missing.join(', ')}.';

  @override
  String each(List<int> positions) => positions.length == 1
      ? "L'élément ${positions.single} n'est pas valide."
      : 'Les éléments ${positions.join(', ')} ne sont pas valides.';
}

mixin FormidableCollectionMessagesDe implements FormidableCollectionMessages {
  @override
  String notEmpty() => 'Darf nicht leer sein.';

  @override
  String unique(List<Object?> duplicates) =>
      'Darf keine Duplikate enthalten: ${duplicates.join(', ')}.';

  @override
  String containsAll(List<Object?> missing) =>
      'Muss enthalten: ${missing.join(', ')}.';

  @override
  String containsNone(List<Object?> found) =>
      'Darf nicht enthalten: ${found.join(', ')}.';

  @override
  String hasKeys(List<Object?> missing) =>
      'Muss die Schlüssel enthalten: ${missing.join(', ')}.';

  @override
  String each(List<int> positions) => positions.length == 1
      ? 'Element ${positions.single} ist ungültig.'
      : 'Die Elemente ${positions.join(', ')} sind ungültig.';
}

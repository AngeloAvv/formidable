import 'package:formidable/formidable.dart';

/// Messages for the item-count errors of Field Arrays.
abstract mixin class FormidableFieldArrayMessages {
  /// The array has fewer than [min] items.
  String minItems(int min, int actual);

  /// The array has more than [max] items.
  String maxItems(int max, int actual);

  /// The message for an item-count error, or null for any other error.
  String? fieldArrayMessageOf(
    FormidableValidationError error,
  ) => switch (error) {
    FormidableMinItemsError(:final min, :final actual) => minItems(min, actual),
    FormidableMaxItemsError(:final max, :final actual) => maxItems(max, actual),
    _ => null,
  };
}

mixin FormidableFieldArrayMessagesEn implements FormidableFieldArrayMessages {
  @override
  String minItems(int min, int actual) =>
      'Must have at least $min ${min == 1 ? 'item' : 'items'} (got $actual).';

  @override
  String maxItems(int max, int actual) =>
      'Must have at most $max ${max == 1 ? 'item' : 'items'} (got $actual).';
}

mixin FormidableFieldArrayMessagesIt implements FormidableFieldArrayMessages {
  @override
  String minItems(int min, int actual) =>
      'Deve avere almeno $min ${min == 1 ? 'elemento' : 'elementi'} '
      '(ne ha $actual).';

  @override
  String maxItems(int max, int actual) =>
      'Deve avere al massimo $max ${max == 1 ? 'elemento' : 'elementi'} '
      '(ne ha $actual).';
}

mixin FormidableFieldArrayMessagesEs implements FormidableFieldArrayMessages {
  @override
  String minItems(int min, int actual) =>
      'Debe tener al menos $min ${min == 1 ? 'elemento' : 'elementos'} '
      '(tiene $actual).';

  @override
  String maxItems(int max, int actual) =>
      'Debe tener como máximo $max ${max == 1 ? 'elemento' : 'elementos'} '
      '(tiene $actual).';
}

mixin FormidableFieldArrayMessagesFr implements FormidableFieldArrayMessages {
  @override
  String minItems(int min, int actual) =>
      'Doit contenir au moins $min ${min == 1 ? 'élément' : 'éléments'} '
      '(actuellement $actual).';

  @override
  String maxItems(int max, int actual) =>
      'Doit contenir au plus $max ${max == 1 ? 'élément' : 'éléments'} '
      '(actuellement $actual).';
}

mixin FormidableFieldArrayMessagesDe implements FormidableFieldArrayMessages {
  @override
  String minItems(int min, int actual) =>
      'Muss mindestens $min ${min == 1 ? 'Eintrag' : 'Einträge'} haben '
      '(aktuell $actual).';

  @override
  String maxItems(int max, int actual) =>
      'Muss höchstens $max ${max == 1 ? 'Eintrag' : 'Einträge'} haben '
      '(aktuell $actual).';
}

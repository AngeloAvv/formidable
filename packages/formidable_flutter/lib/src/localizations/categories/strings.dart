import 'package:formidable/formidable.dart';

/// Messages for the errors of the string Validators.
abstract mixin class FormidableStringMessages {
  /// The value is shorter than [minLength].
  String minLength(int minLength, int actualLength);

  /// The message for a string error, or null for any other error.
  String? stringMessageOf(FormidableValidationError error) => switch (error) {
    FormidableMinLengthError(:final minLength, :final actualLength) =>
      this.minLength(minLength, actualLength),
    _ => null,
  };
}

mixin FormidableStringMessagesEn implements FormidableStringMessages {
  @override
  String minLength(int minLength, int actualLength) =>
      'Must be at least $minLength '
      '${minLength == 1 ? 'character' : 'characters'} long '
      '(got $actualLength).';
}

mixin FormidableStringMessagesIt implements FormidableStringMessages {
  @override
  String minLength(int minLength, int actualLength) =>
      'Deve contenere almeno $minLength '
      '${minLength == 1 ? 'carattere' : 'caratteri'} '
      '(ne ha $actualLength).';
}

mixin FormidableStringMessagesEs implements FormidableStringMessages {
  @override
  String minLength(int minLength, int actualLength) =>
      'Debe tener al menos $minLength '
      '${minLength == 1 ? 'carácter' : 'caracteres'} '
      '(tiene $actualLength).';
}

mixin FormidableStringMessagesFr implements FormidableStringMessages {
  @override
  String minLength(int minLength, int actualLength) =>
      'Doit contenir au moins $minLength '
      '${minLength == 1 ? 'caractère' : 'caractères'} '
      '(actuellement $actualLength).';
}

mixin FormidableStringMessagesDe implements FormidableStringMessages {
  @override
  String minLength(int minLength, int actualLength) =>
      'Muss mindestens $minLength '
      'Zeichen lang sein '
      '(aktuell $actualLength).';
}

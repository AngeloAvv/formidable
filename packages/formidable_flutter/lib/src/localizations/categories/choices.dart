import 'package:formidable/formidable.dart';

import '../format.dart';

/// Messages for the errors of the choice and equality Validators.
abstract mixin class FormidableChoiceMessages {
  /// The value is not true.
  String isTrue();

  /// The value is not false.
  String isFalse();

  /// The value is not one of the [allowed] ones.
  String oneOf(List<Object?> allowed);

  /// The value is one of the [disallowed] ones.
  String noneOf(List<Object?> disallowed);

  /// The value is not equal to [expected].
  String equalTo(Object? expected);

  /// The value is equal to [unexpected].
  String notEqualTo(Object? unexpected);

  /// The message for a choice or equality error, or null for any other error.
  String? choiceMessageOf(FormidableValidationError error) => switch (error) {
    FormidableIsTrueError() => isTrue(),
    FormidableIsFalseError() => isFalse(),
    FormidableOneOfError(:final allowed) => oneOf(allowed),
    FormidableNoneOfError(:final disallowed) => noneOf(disallowed),
    FormidableEqualToError(:final expected) => equalTo(expected),
    FormidableNotEqualToError(:final unexpected) => notEqualTo(unexpected),
    _ => null,
  };
}

mixin FormidableChoiceMessagesEn implements FormidableChoiceMessages {
  @override
  String isTrue() => 'Must be accepted.';

  @override
  String isFalse() => 'Must be declined.';

  @override
  String oneOf(List<Object?> allowed) =>
      'Must be one of: ${formatChoices(allowed)}.';

  @override
  String noneOf(List<Object?> disallowed) =>
      'Must not be any of: ${formatChoices(disallowed)}.';

  @override
  String equalTo(Object? expected) =>
      'Must be equal to ${formatChoice(expected)}.';

  @override
  String notEqualTo(Object? unexpected) =>
      'Must not be equal to ${formatChoice(unexpected)}.';
}

mixin FormidableChoiceMessagesIt implements FormidableChoiceMessages {
  @override
  String isTrue() => 'Deve essere accettato.';

  @override
  String isFalse() => 'Deve essere rifiutato.';

  @override
  String oneOf(List<Object?> allowed) =>
      'Deve essere uno tra: ${formatChoices(allowed)}.';

  @override
  String noneOf(List<Object?> disallowed) =>
      'Non deve essere nessuno tra: ${formatChoices(disallowed)}.';

  @override
  String equalTo(Object? expected) =>
      'Deve essere uguale a ${formatChoice(expected)}.';

  @override
  String notEqualTo(Object? unexpected) =>
      'Non deve essere uguale a ${formatChoice(unexpected)}.';
}

mixin FormidableChoiceMessagesEs implements FormidableChoiceMessages {
  @override
  String isTrue() => 'Debe aceptarse.';

  @override
  String isFalse() => 'Debe rechazarse.';

  @override
  String oneOf(List<Object?> allowed) =>
      'Debe ser uno de: ${formatChoices(allowed)}.';

  @override
  String noneOf(List<Object?> disallowed) =>
      'No debe ser ninguno de: ${formatChoices(disallowed)}.';

  @override
  String equalTo(Object? expected) =>
      'Debe ser igual a ${formatChoice(expected)}.';

  @override
  String notEqualTo(Object? unexpected) =>
      'No debe ser igual a ${formatChoice(unexpected)}.';
}

mixin FormidableChoiceMessagesFr implements FormidableChoiceMessages {
  @override
  String isTrue() => 'Doit être accepté.';

  @override
  String isFalse() => 'Doit être refusé.';

  @override
  String oneOf(List<Object?> allowed) =>
      'Doit être l’une des valeurs suivantes : ${formatChoices(allowed)}.';

  @override
  String noneOf(List<Object?> disallowed) =>
      'Ne doit être aucune des valeurs suivantes : ${formatChoices(disallowed)}.';

  @override
  String equalTo(Object? expected) =>
      'Doit être égal à ${formatChoice(expected)}.';

  @override
  String notEqualTo(Object? unexpected) =>
      'Ne doit pas être égal à ${formatChoice(unexpected)}.';
}

mixin FormidableChoiceMessagesDe implements FormidableChoiceMessages {
  @override
  String isTrue() => 'Muss akzeptiert werden.';

  @override
  String isFalse() => 'Muss abgelehnt werden.';

  @override
  String oneOf(List<Object?> allowed) =>
      'Muss einer der folgenden Werte sein: ${formatChoices(allowed)}.';

  @override
  String noneOf(List<Object?> disallowed) =>
      'Darf keiner der folgenden Werte sein: ${formatChoices(disallowed)}.';

  @override
  String equalTo(Object? expected) =>
      'Muss gleich ${formatChoice(expected)} sein.';

  @override
  String notEqualTo(Object? unexpected) =>
      'Darf nicht gleich ${formatChoice(unexpected)} sein.';
}

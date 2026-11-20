import 'package:formidable/formidable.dart';

/// Messages for the errors of the combinators.
abstract mixin class FormidableCombinatorMessages {
  /// None of the alternatives of `AnyOf` accepted the value.
  String anyOf();

  /// The message for a combinator error, or null for any other error.
  String? combinatorMessageOf(FormidableValidationError error) =>
      switch (error) {
        FormidableAnyOfError() => anyOf(),
        _ => null,
      };
}

mixin FormidableCombinatorMessagesEn implements FormidableCombinatorMessages {
  @override
  String anyOf() => 'Does not satisfy any of the allowed rules.';
}

mixin FormidableCombinatorMessagesIt implements FormidableCombinatorMessages {
  @override
  String anyOf() => 'Non soddisfa nessuna delle regole consentite.';
}

mixin FormidableCombinatorMessagesEs implements FormidableCombinatorMessages {
  @override
  String anyOf() => 'No cumple ninguna de las reglas permitidas.';
}

mixin FormidableCombinatorMessagesFr implements FormidableCombinatorMessages {
  @override
  String anyOf() => "Ne satisfait aucune des règles autorisées.";
}

mixin FormidableCombinatorMessagesDe implements FormidableCombinatorMessages {
  @override
  String anyOf() => 'Erfüllt keine der erlaubten Regeln.';
}

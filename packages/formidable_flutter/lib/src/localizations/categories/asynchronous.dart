import 'package:formidable/formidable.dart';

/// Messages for the errors of asynchronous validation.
abstract mixin class FormidableAsyncMessages {
  /// An Async Validator threw instead of answering, so the value could not be
  /// checked.
  String asyncCheckFailed();

  /// The message for an asynchronous validation error, or null for any other
  /// error.
  String? asyncMessageOf(FormidableValidationError error) => switch (error) {
    FormidableAsyncCheckFailedError() => asyncCheckFailed(),
    _ => null,
  };
}

mixin FormidableAsyncMessagesEn implements FormidableAsyncMessages {
  @override
  String asyncCheckFailed() => 'The value could not be checked. Try again.';
}

mixin FormidableAsyncMessagesIt implements FormidableAsyncMessages {
  @override
  String asyncCheckFailed() =>
      'Non è stato possibile verificare il valore. Riprova.';
}

mixin FormidableAsyncMessagesEs implements FormidableAsyncMessages {
  @override
  String asyncCheckFailed() =>
      'No se pudo comprobar el valor. Inténtalo de nuevo.';
}

mixin FormidableAsyncMessagesFr implements FormidableAsyncMessages {
  @override
  String asyncCheckFailed() => "La valeur n'a pas pu être vérifiée. Réessayez.";
}

mixin FormidableAsyncMessagesDe implements FormidableAsyncMessages {
  @override
  String asyncCheckFailed() =>
      'Der Wert konnte nicht geprüft werden. Versuchen Sie es erneut.';
}

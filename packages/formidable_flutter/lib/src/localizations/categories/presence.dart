import 'package:formidable/formidable.dart';

/// Messages for the presence errors.
///
/// This file is the template for every category of built-in errors: an
/// abstract mixin class with one method per error and a dispatcher, followed by
/// one implementation mixin per language. See NOTES.md for the recipe.
abstract mixin class FormidablePresenceMessages {
  /// A Required Field is Unset.
  String requiredField();

  /// The message for a presence error, or null for any other error.
  String? presenceMessageOf(FormidableValidationError error) => switch (error) {
    FormidableRequiredError() => requiredField(),
    _ => null,
  };
}

mixin FormidablePresenceMessagesEn implements FormidablePresenceMessages {
  @override
  String requiredField() => 'This field is required.';
}

mixin FormidablePresenceMessagesIt implements FormidablePresenceMessages {
  @override
  String requiredField() => 'Questo campo è obbligatorio.';
}

mixin FormidablePresenceMessagesEs implements FormidablePresenceMessages {
  @override
  String requiredField() => 'Este campo es obligatorio.';
}

mixin FormidablePresenceMessagesFr implements FormidablePresenceMessages {
  @override
  String requiredField() => 'Ce champ est obligatoire.';
}

mixin FormidablePresenceMessagesDe implements FormidablePresenceMessages {
  @override
  String requiredField() => 'Dieses Feld ist erforderlich.';
}

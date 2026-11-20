import 'package:formidable/formidable.dart';

/// Messages for the errors Codecs produce when input can't be parsed.
abstract mixin class FormidableParsingMessages {
  /// The input is not a number.
  String numberParse(String input);

  /// The input is not a date.
  String dateParse(String input);

  /// The message for a parse error, or null for any other error.
  String? parsingMessageOf(FormidableValidationError error) => switch (error) {
    FormidableNumberParseError(:final input) => numberParse(input),
    FormidableDateParseError(:final input) => dateParse(input),
    _ => null,
  };
}

mixin FormidableParsingMessagesEn implements FormidableParsingMessages {
  @override
  String numberParse(String input) => 'Enter a valid number.';

  @override
  String dateParse(String input) => 'Enter a valid date.';
}

mixin FormidableParsingMessagesIt implements FormidableParsingMessages {
  @override
  String numberParse(String input) => 'Inserisci un numero valido.';

  @override
  String dateParse(String input) => 'Inserisci una data valida.';
}

mixin FormidableParsingMessagesEs implements FormidableParsingMessages {
  @override
  String numberParse(String input) => 'Introduce un número válido.';

  @override
  String dateParse(String input) => 'Introduce una fecha válida.';
}

mixin FormidableParsingMessagesFr implements FormidableParsingMessages {
  @override
  String numberParse(String input) => 'Saisissez un nombre valide.';

  @override
  String dateParse(String input) => 'Saisissez une date valide.';
}

mixin FormidableParsingMessagesDe implements FormidableParsingMessages {
  @override
  String numberParse(String input) => 'Geben Sie eine gültige Zahl ein.';

  @override
  String dateParse(String input) => 'Geben Sie ein gültiges Datum ein.';
}

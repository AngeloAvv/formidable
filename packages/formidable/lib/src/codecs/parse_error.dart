import '../validation/validation_error.dart';

/// The input of a widget can't be parsed into the value of a Field.
///
/// Every Codec reports its failures with a subclass, so that each failure has
/// its own message. [input] is the raw text the user typed.
abstract class FormidableParseError extends FormidableValidationError {
  const FormidableParseError({required this.input});

  final String input;

  @override
  List<Object?> get props => [input];
}

/// The input is not a number the Field can hold.
final class FormidableNumberParseError extends FormidableParseError {
  const FormidableNumberParseError({required super.input});

  @override
  String toString() => 'Enter a valid number.';
}

/// The input is not a date the Field can hold.
final class FormidableDateParseError extends FormidableParseError {
  const FormidableDateParseError({required super.input});

  @override
  String toString() => 'Enter a valid date.';
}

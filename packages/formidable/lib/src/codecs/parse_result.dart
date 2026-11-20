import '../validation/validation_error.dart';

/// What parsing the input of a widget produced.
///
/// It is exactly one of: a value ([FormidableParsedValue]), no value at all
/// ([FormidableParsedUnset]) or a typed error ([FormidableParseFailure]).
sealed class FormidableParseResult<T> {
  const FormidableParseResult();
}

/// The input is a valid value.
final class FormidableParsedValue<T> extends FormidableParseResult<T> {
  const FormidableParsedValue(this.value);

  final T value;
}

/// The input says there is no value, for example a blank text. The Field
/// becomes Unset (ADR-0003).
final class FormidableParsedUnset<T> extends FormidableParseResult<T> {
  const FormidableParsedUnset();
}

/// The input can't be turned into a value.
///
/// The widget keeps what the user typed and the Field becomes invalid with
/// [error], even when the Field is optional.
final class FormidableParseFailure<T> extends FormidableParseResult<T> {
  const FormidableParseFailure(this.error);

  final FormidableValidationError error;
}

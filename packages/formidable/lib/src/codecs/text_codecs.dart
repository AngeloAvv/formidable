import 'codec.dart';
import 'parse_error.dart';
import 'parse_result.dart';

/// `String` to text. An empty text is Unset; whitespace is a value.
final class FormidableStringTextCodec extends FormidableCodec<String, String> {
  const FormidableStringTextCodec();

  @override
  String format(String value) => value;

  @override
  FormidableParseResult<String> parse(String input) => input.isEmpty
      ? const FormidableParsedUnset()
      : FormidableParsedValue(input);
}

/// `int` to text. Blank text is Unset; text that is not a whole number is a
/// [FormidableNumberParseError].
final class FormidableIntTextCodec extends FormidableCodec<int, String> {
  const FormidableIntTextCodec();

  @override
  String format(int value) => value.toString();

  @override
  FormidableParseResult<int> parse(String input) {
    final text = input.trim();
    if (text.isEmpty) return const FormidableParsedUnset();
    final value = int.tryParse(text);
    return value == null
        ? FormidableParseFailure(FormidableNumberParseError(input: input))
        : FormidableParsedValue(value);
  }
}

/// `double` to text. Blank text is Unset; text that is not a finite number is
/// a [FormidableNumberParseError].
final class FormidableDoubleTextCodec extends FormidableCodec<double, String> {
  const FormidableDoubleTextCodec();

  @override
  String format(double value) => value.toString();

  @override
  FormidableParseResult<double> parse(String input) {
    final text = input.trim();
    if (text.isEmpty) return const FormidableParsedUnset();
    final value = double.tryParse(text);
    return value == null || !value.isFinite
        ? FormidableParseFailure(FormidableNumberParseError(input: input))
        : FormidableParsedValue(value);
  }
}

/// `num` to text. Whole numbers parse to an `int`, anything else to a
/// `double`. Blank text is Unset.
final class FormidableNumTextCodec extends FormidableCodec<num, String> {
  const FormidableNumTextCodec();

  @override
  String format(num value) => value.toString();

  @override
  FormidableParseResult<num> parse(String input) {
    final text = input.trim();
    if (text.isEmpty) return const FormidableParsedUnset();
    final value = int.tryParse(text) ?? double.tryParse(text);
    return value == null || !value.isFinite
        ? FormidableParseFailure(FormidableNumberParseError(input: input))
        : FormidableParsedValue(value);
  }
}

/// `DateTime` to text, in ISO 8601.
///
/// A date at midnight is written as `yyyy-MM-dd` and any other as a full ISO
/// 8601 string. Parsing accepts what `DateTime.tryParse` accepts. Blank text
/// is Unset. For another format, pass your own Codec to the widget.
final class FormidableDateTimeTextCodec
    extends FormidableCodec<DateTime, String> {
  const FormidableDateTimeTextCodec();

  @override
  String format(DateTime value) {
    final iso = value.toIso8601String();
    final atMidnight =
        value.hour == 0 &&
        value.minute == 0 &&
        value.second == 0 &&
        value.millisecond == 0 &&
        value.microsecond == 0;
    return atMidnight && !value.isUtc ? iso.substring(0, 10) : iso;
  }

  @override
  FormidableParseResult<DateTime> parse(String input) {
    final text = input.trim();
    if (text.isEmpty) return const FormidableParsedUnset();
    final value = DateTime.tryParse(text);
    return value == null
        ? FormidableParseFailure(FormidableDateParseError(input: input))
        : FormidableParsedValue(value);
  }
}

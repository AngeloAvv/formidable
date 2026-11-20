import 'package:formidable/formidable.dart';

part 'measurements.formidable.dart';

/// A custom value type, to prove that Codecs are chosen by the pair of types
/// and can be registered for any type.
final class Money {
  const Money(this.cents);

  final int cents;

  @override
  bool operator ==(Object other) => other is Money && other.cents == cents;

  @override
  int get hashCode => cents.hashCode;
}

/// `Money` as text, such as `12.50`.
class MoneyTextCodec extends FormidableCodec<Money, String> {
  const MoneyTextCodec({this.prefix = ''});

  final String prefix;

  @override
  String format(Money value) =>
      '$prefix${(value.cents / 100).toStringAsFixed(2)}';

  @override
  FormidableParseResult<Money> parse(String input) {
    final text = input.replaceFirst(prefix, '').trim();
    if (text.isEmpty) return const FormidableParsedUnset();
    final euros = double.tryParse(text);
    return euros == null
        ? FormidableParseFailure(FormidableNumberParseError(input: input))
        : FormidableParsedValue(Money((euros * 100).round()));
  }
}

@Formidable()
class Measurements {
  const Measurements({
    required this.age,
    this.weight,
    this.nickname,
    this.born,
    this.price,
  });

  final int age;
  final double? weight;
  final String? nickname;
  final DateTime? born;
  final Money? price;
}

/// Helpers shared by the messages of the built-in categories.
library;

/// A number the way a reader of the language expects it: [decimal] replaces
/// the decimal point.
String formatNumber(num value, {String decimal = '.'}) {
  final text = value is double && value == value.truncateToDouble()
      ? value.toInt().toString()
      : value.toString();
  return decimal == '.' ? text : text.replaceFirst('.', decimal);
}

String _two(int value) => value.toString().padLeft(2, '0');

/// `2024-06-15`.
String formatDateIso(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}-${_two(date.month)}-${_two(date.day)}';

/// `15/06/2024`.
String formatDateSlashes(DateTime date) =>
    '${_two(date.day)}/${_two(date.month)}/${date.year.toString().padLeft(4, '0')}';

/// `15.06.2024`.
String formatDateDots(DateTime date) =>
    '${_two(date.day)}.${_two(date.month)}.${date.year.toString().padLeft(4, '0')}';

/// A value as shown in a message: enums by name, everything else as text.
String formatChoice(Object? value) => value is Enum ? value.name : '$value';

/// The values of a choice, comma separated.
String formatChoices(Iterable<Object?> values) =>
    values.map(formatChoice).join(', ');

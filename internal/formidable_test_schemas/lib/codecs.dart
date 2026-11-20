import 'package:formidable/formidable.dart';

part 'codecs.formidable.dart';

/// Codec coverage: Fields whose widget value differs from the Field value.
@Formidable()
class Measurements {
  const Measurements({
    required this.age,
    this.weight,
    this.visits = 0,
    this.born,
  });

  /// Required `int`, shown as text.
  final int age;

  /// Optional `double`: bad input must still block submit.
  final double? weight;

  /// Optional `int` with a default.
  final int visits;

  /// Optional `DateTime`.
  final DateTime? born;
}

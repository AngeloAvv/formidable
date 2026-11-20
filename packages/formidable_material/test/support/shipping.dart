import 'package:formidable/formidable.dart';

part 'shipping.formidable.dart';

/// Keyboard navigation: three text Fields, a Passthrough and a Field that
/// tests leave without a widget.
@Formidable()
class Shipping {
  const Shipping({
    this.id = 1,
    required this.name,
    required this.street,
    required this.city,
    this.note,
  });

  @Passthrough()
  final int id;

  final String name;
  final String street;
  final String city;
  final String? note;
}

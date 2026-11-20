import 'package:formidable/formidable.dart';

import 'field_arrays.dart';
import 'nested.dart';

part 'mixed_containers.formidable.dart';

/// Every kind of container node in one Form: a Nested Form, a Field Array of
/// Nested Forms and a Dynamic Form, around plain Fields.
@Formidable()
class Itinerary {
  const Itinerary({
    required this.title,
    required this.contact,
    required this.phones,
    required this.extras,
    required this.footer,
  });

  @MinLength(2)
  final String title;

  final Address contact;

  final List<Telephone> phones;

  @Dynamic()
  final Map<String, Object?> extras;

  final String? footer;
}

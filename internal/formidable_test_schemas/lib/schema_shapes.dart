import 'package:formidable/formidable.dart';

part 'schema_shapes.formidable.dart';

/// Shared fields, declared once and reused by several Schemas.
abstract class Entity {
  const Entity({required this.id});

  final int id;
}

/// An inherited Field (`id`) that appears in the constructor, and a getter
/// that must not become a Field.
@Formidable()
class Customer extends Entity {
  const Customer({required super.id, required this.name});

  final String name;

  String get label => '$name#$id';
}

/// Positional constructor parameters, one of them optional with a default.
@Formidable()
class Coordinates {
  const Coordinates(this.latitude, this.longitude, [this.label = 'unnamed']);

  final double latitude;
  final double longitude;
  final String label;
}

/// Positional and named parameters in the same constructor, declared in a
/// different order from the fields.
@Formidable()
class Mixed {
  const Mixed(this.second, {required this.first});

  final String first;
  final int second;
}

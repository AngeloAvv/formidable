import 'package:formidable/formidable.dart';

part 'nested.formidable.dart';

/// A leaf Schema that other Schemas nest.
@Formidable()
class Address {
  const Address({required this.street, this.zip});

  @MinLength(2)
  final String street;

  final String? zip;
}

/// Nests an Address three ways: always present, optional and required.
@Formidable()
class Contact {
  const Contact({
    required this.name,
    required this.home,
    this.work,
    this.billing,
  });

  @MinLength(2)
  final String name;

  /// Non-nullable: always present, so its Fields always count.
  final Address home;

  /// Nullable: Unset until the user starts filling it.
  final Address? work;

  /// Nullable, but `@Required()`: always present.
  @Required()
  final Address? billing;
}

/// A second nesting level: an Order holds a Contact, which holds Addresses.
@Formidable()
class Order {
  const Order({required this.title, required this.owner});

  final String title;
  final Contact owner;
}

/// A Schema with its own Form Effect: the zip goes away with its street.
@Formidable()
@Effects([ClearZipOnStreetChange()])
class Place {
  const Place({this.street, this.zip});

  final String? street;
  final String? zip;
}

class ClearZipOnStreetChange extends FormidableEffect<PlaceForm> {
  const ClearZipOnStreetChange();

  @override
  void apply(PlaceForm form, FormidableEffectContext context) {
    if (context.changed(form.street)) form.zip.clear();
  }
}

/// A parent Effect that reacts to a Field of a Nested Form.
@Formidable()
@Effects([NoteWhenStreetChanges()])
class Shipment {
  const Shipment({required this.place, this.note});

  final Place place;
  final String? note;
}

class NoteWhenStreetChanges extends FormidableEffect<ShipmentForm> {
  const NoteWhenStreetChanges();

  @override
  void apply(ShipmentForm form, FormidableEffectContext context) {
    if (context.changed(form.place.street)) {
      form.note.setValue('street: ${form.place.street.value}');
    }
  }
}

/// A Schema that cannot be created empty: it has a Passthrough Field.
@Formidable()
class Record {
  const Record({required this.id, required this.title});

  @Passthrough()
  final int id;

  final String title;
}

@Formidable()
class Editor {
  const Editor({required this.record});

  final Record record;
}

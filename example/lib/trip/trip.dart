import 'package:formidable/formidable.dart';

part 'trip.formidable.dart';

/// One stop of a trip. A list of Schemas becomes a Field Array of Nested
/// Forms: every item is a full `StopForm`.
@Formidable()
class Stop {
  const Stop({required this.place, this.nights = 1});

  @Trim()
  @MinLength(2)
  final String place;

  @Min(1)
  final int nights;
}

/// The Schema of the Field Array guide.
///
/// - `stops` is a Field Array of Nested Forms. `@MinItems`/`@MaxItems` judge
///   the array itself; an empty array is Unset, so it is required.
/// - `tags` is a list of Strings opted into a Field Array of Fields with
///   `@FieldArray`: every tag is an input of its own.
@Formidable()
class Trip {
  const Trip({required this.name, required this.stops, this.tags = const []});

  @Trim()
  @MinLength(3)
  final String name;

  @MaxItems(3)
  final List<Stop> stops;

  @FieldArray(each: [MinLength(2)], normalizers: [Trim()])
  @MaxItems(4)
  final List<String> tags;
}

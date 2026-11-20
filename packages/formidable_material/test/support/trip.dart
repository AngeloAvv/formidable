import 'package:formidable/formidable.dart';

part 'trip.formidable.dart';

/// A leaf Schema nested once and repeated in a Field Array.
@Formidable()
class Stop {
  const Stop({required this.place, this.note});

  @MinLength(3)
  final String place;

  final String? note;
}

@Formidable()
class Origin {
  const Origin({required this.street, required this.city});

  final String street;
  final String city;
}

/// Declaration order is the focus order: the Fields of `origin` and of every
/// item of `stops` come right where those Fields are declared.
@Formidable()
class Trip {
  const Trip({
    required this.title,
    required this.origin,
    required this.stops,
    this.memo,
  });

  final String title;

  final Origin origin;

  @MinItems(2)
  final List<Stop> stops;

  final String? memo;
}

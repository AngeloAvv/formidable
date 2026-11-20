import 'package:formidable/formidable.dart';

import 'nested.dart';

part 'field_arrays.formidable.dart';

/// An item of a Field Array of Nested Forms.
@Formidable()
class Telephone {
  const Telephone({required this.number, this.label});

  @MinLength(3)
  final String number;

  final String? label;
}

/// A list of Schemas: a Field Array of Nested Forms.
@Formidable()
class Person {
  const Person({required this.name, this.phones = const []});

  final String name;

  final List<Telephone> phones;
}

/// Item-count Validators, a required array and a nullable one.
@Formidable()
class Team {
  const Team({required this.members, this.backups});

  /// Required (non-nullable, no default): an empty array is Unset and invalid.
  @MinItems(1)
  @MaxItems(3)
  final List<Telephone> members;

  /// Nullable: an empty array is Unset and produces null.
  final List<Telephone>? backups;
}

/// Lists, sets and maps of primitive values are one Field by default, and a
/// list opts into a Field Array with `@FieldArray()`.
@Formidable()
class Labels {
  const Labels({
    this.single = const [],
    this.flags = const {},
    this.counts = const {},
    this.tags = const [],
    this.notes,
  });

  final List<String> single;

  final Set<String> flags;

  final Map<String, int> counts;

  @FieldArray(each: [MinLength(2)], normalizers: [Trim()])
  @MaxItems(3)
  final List<String> tags;

  @FieldArray()
  final List<String?>? notes;
}

/// Field Arrays nested in Field Arrays.
@Formidable()
class Company {
  const Company({required this.name, this.teams = const []});

  final String name;

  final List<Team> teams;
}

/// A Form Validator of the parent that addresses a Field of an array item.
class FirstPlaceNeedsStreet extends FormidableFormValidator<DirectoryForm> {
  const FirstPlaceNeedsStreet();

  @override
  List<FormidableFieldError> validate(DirectoryForm form) =>
      form.places.isNotEmpty && !form.places.items.first.node.street.isSet
      ? [
          FormidableFieldError(
            form.places.items.first.node.street,
            const PasswordMismatch(),
          ),
        ]
      : const [];
}

/// Items with their own Form Effects and Form Validators.
@Formidable()
@FirstPlaceNeedsStreet()
class Directory {
  const Directory({this.places = const [], this.logins = const []});

  /// `Place` has an Effect: the zip goes away with its street.
  final List<Place> places;

  /// `Credentials` has a Form Validator of its own.
  final List<Credentials> logins;
}

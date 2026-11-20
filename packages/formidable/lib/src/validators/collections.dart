import '../validation/validation_error.dart';
import '../validation/validator.dart';

/// The collection or string has no elements.
final class FormidableNotEmptyError extends FormidableValidationError {
  const FormidableNotEmptyError();

  @override
  String toString() => 'Must not be empty.';
}

/// The value is not empty: an [Iterable], a [Map] or a [String] with at least
/// one element.
///
/// It is typed for any object because Dart has no common supertype for these
/// three, so passing any other type throws an [ArgumentError].
class NotEmpty extends FormidableValidator<Object> {
  const NotEmpty();

  @override
  List<FormidableValidationError> validate(Object value) {
    final isEmpty = switch (value) {
      Iterable<Object?>(:final isEmpty) => isEmpty,
      Map<Object?, Object?>(:final isEmpty) => isEmpty,
      String(:final isEmpty) => isEmpty,
      _ => throw ArgumentError.value(
        value,
        'value',
        'NotEmpty judges an Iterable, a Map or a String',
      ),
    };
    return isEmpty ? const [FormidableNotEmptyError()] : const [];
  }
}

/// The collection holds the same value more than once.
final class FormidableUniqueError extends FormidableValidationError {
  const FormidableUniqueError({required this.duplicates});

  /// Each repeated value, once and as first seen, in the order it first repeats.
  final List<Object?> duplicates;

  @override
  List<Object?> get props => [...duplicates];

  @override
  String toString() => 'Must not contain duplicates: ${duplicates.join(', ')}.';
}

/// Every element of the collection is different from the others.
///
/// With [ignoreCase], strings that differ only in letter case are the same
/// element. Other elements are compared with `==`.
class Unique extends FormidableValidator<Iterable<Object?>> {
  const Unique({this.ignoreCase = false});

  final bool ignoreCase;

  @override
  List<FormidableValidationError> validate(Iterable<Object?> value) {
    final firstSeen = <Object?, Object?>{};
    final repeated = <Object?>{};
    final duplicates = <Object?>[];
    for (final element in value) {
      final key = ignoreCase && element is String
          ? element.toLowerCase()
          : element;
      if (!firstSeen.containsKey(key)) {
        firstSeen[key] = element;
      } else if (repeated.add(key)) {
        duplicates.add(firstSeen[key]);
      }
    }
    return duplicates.isEmpty
        ? const []
        : [FormidableUniqueError(duplicates: duplicates)];
  }
}

/// The collection lacks some required elements.
final class FormidableContainsAllError extends FormidableValidationError {
  const FormidableContainsAllError({required this.missing});

  /// The required elements the collection does not hold.
  final List<Object?> missing;

  @override
  List<Object?> get props => [...missing];

  @override
  String toString() => 'Must contain: ${missing.join(', ')}.';
}

/// The collection holds every one of [values].
class ContainsAll extends FormidableValidator<Iterable<Object?>> {
  const ContainsAll(this.values);

  final List<Object?> values;

  @override
  List<FormidableValidationError> validate(Iterable<Object?> value) {
    final missing = [
      for (final required in values)
        if (!value.contains(required)) required,
    ];
    return missing.isEmpty
        ? const []
        : [FormidableContainsAllError(missing: missing)];
  }
}

/// The collection holds elements that are not allowed.
final class FormidableContainsNoneError extends FormidableValidationError {
  const FormidableContainsNoneError({required this.found});

  /// The forbidden elements the collection holds.
  final List<Object?> found;

  @override
  List<Object?> get props => [...found];

  @override
  String toString() => 'Must not contain: ${found.join(', ')}.';
}

/// The collection holds none of [values].
class ContainsNone extends FormidableValidator<Iterable<Object?>> {
  const ContainsNone(this.values);

  final List<Object?> values;

  @override
  List<FormidableValidationError> validate(Iterable<Object?> value) {
    final found = [
      for (final forbidden in values)
        if (value.contains(forbidden)) forbidden,
    ];
    return found.isEmpty
        ? const []
        : [FormidableContainsNoneError(found: found)];
  }
}

/// The map lacks some required keys.
final class FormidableHasKeysError extends FormidableValidationError {
  const FormidableHasKeysError({required this.missing});

  /// The required keys the map does not hold.
  final List<Object?> missing;

  @override
  List<Object?> get props => [...missing];

  @override
  String toString() => 'Must have the keys: ${missing.join(', ')}.';
}

/// The map has every one of [keys].
class HasKeys extends FormidableValidator<Map<Object?, Object?>> {
  const HasKeys(this.keys);

  final List<Object?> keys;

  @override
  List<FormidableValidationError> validate(Map<Object?, Object?> value) {
    final missing = [
      for (final key in keys)
        if (!value.containsKey(key)) key,
    ];
    return missing.isEmpty
        ? const []
        : [FormidableHasKeysError(missing: missing)];
  }
}

/// Some elements of the collection are invalid.
final class FormidableEachError extends FormidableValidationError {
  const FormidableEachError(this.failures);

  /// The errors of each rejected element, by its position in the collection.
  final Map<int, List<FormidableValidationError>> failures;

  @override
  List<Object?> get props => [
    for (final entry in failures.entries) ...[
      entry.key,
      entry.value.length,
      ...entry.value,
    ],
  ];

  @override
  String toString() =>
      'Some items are invalid (positions '
      '${failures.keys.map((index) => index + 1).join(', ')}).';
}

/// Every element of the collection passes all of the [validators].
///
/// The Validators judge one element, so they are checked against the element
/// type of the Field. A Validator is skipped for a null element when it does
/// not accept null.
class Each extends FormidableValidator<Iterable<Object?>> {
  const Each(this.validators);

  final List<FormidableValidator<Object?>> validators;

  @override
  List<FormidableValidationError> validate(Iterable<Object?> value) {
    final failures = <int, List<FormidableValidationError>>{};
    var index = 0;
    for (final element in value) {
      final errors = [
        for (final validator in validators)
          if (element != null || validator.acceptsNull)
            ...validator.validate(element),
      ];
      if (errors.isNotEmpty) failures[index] = errors;
      index++;
    }
    return failures.isEmpty ? const [] : [FormidableEachError(failures)];
  }
}

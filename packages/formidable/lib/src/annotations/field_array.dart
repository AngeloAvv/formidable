import '../normalizers/normalizer.dart';
import '../validation/validator.dart';

/// Makes a list of primitive values a Field Array: one Field per item, each
/// with its own state and a stable identifier, instead of a single Field that
/// holds the whole list.
///
/// A list of Schemas is always a Field Array, with or without this annotation.
/// A list, set or map of primitive values is a single Field by default.
///
/// Validators written as annotations of the list judge the list as a whole
/// (for example `MinItems`). [each] and [normalizers] apply to every item.
class FieldArray {
  const FieldArray({this.each = const [], this.normalizers = const []});

  /// Validators that run on every item that has a value.
  final List<FormidableValidator<Object?>> each;

  /// Normalizers that rewrite every item written to the array.
  final List<FormidableNormalizer<Object?>> normalizers;
}

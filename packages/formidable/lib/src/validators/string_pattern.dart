import '../validation/validation_error.dart';
import '../validation/validator.dart';

/// The value does not match the required pattern, or matches a forbidden one.
final class FormidablePatternError extends FormidableValidationError {
  const FormidablePatternError({required this.pattern, required this.negated});

  /// The source of the regular expression.
  final String pattern;

  /// Whether the value was forbidden to match the pattern.
  final bool negated;

  @override
  List<Object?> get props => [pattern, negated];

  @override
  String toString() =>
      negated ? 'Must not match the pattern.' : 'Does not match the format.';
}

/// The value does not start with the required text.
final class FormidableStartsWithError extends FormidableValidationError {
  const FormidableStartsWithError({required this.prefix});

  final String prefix;

  @override
  List<Object?> get props => [prefix];

  @override
  String toString() => 'Must start with "$prefix".';
}

/// The value does not end with the required text.
final class FormidableEndsWithError extends FormidableValidationError {
  const FormidableEndsWithError({required this.suffix});

  final String suffix;

  @override
  List<Object?> get props => [suffix];

  @override
  String toString() => 'Must end with "$suffix".';
}

/// The value starts with forbidden text.
final class FormidableDoesntStartWithError extends FormidableValidationError {
  const FormidableDoesntStartWithError({required this.prefix});

  final String prefix;

  @override
  List<Object?> get props => [prefix];

  @override
  String toString() => 'Must not start with "$prefix".';
}

/// The value ends with forbidden text.
final class FormidableDoesntEndWithError extends FormidableValidationError {
  const FormidableDoesntEndWithError({required this.suffix});

  final String suffix;

  @override
  List<Object?> get props => [suffix];

  @override
  String toString() => 'Must not end with "$suffix".';
}

/// The value does not contain the required text.
final class FormidableContainsError extends FormidableValidationError {
  const FormidableContainsError({required this.text});

  final String text;

  @override
  List<Object?> get props => [text];

  @override
  String toString() => 'Must contain "$text".';
}

/// The value contains forbidden text.
final class FormidableNotContainsError extends FormidableValidationError {
  const FormidableNotContainsError({required this.text});

  final String text;

  @override
  List<Object?> get props => [text];

  @override
  String toString() => 'Must not contain "$text".';
}

/// The value must match the regular expression [pattern], or must not match it
/// when [negate] is true. The match can be anywhere in the value: anchor the
/// pattern with `^` and `\$` to match all of it.
///
/// The pattern is the source of a Dart `RegExp`, because annotations cannot
/// hold a `RegExp`. Use a raw string: `@Pattern(r'^\d{3}\$')`.
///
/// Note that this name shadows `Pattern` of `dart:core` in files that import
/// Formidable. Add `hide Pattern` to the import if such a file also needs the
/// core type.
class Pattern extends FormidableValidator<String> {
  const Pattern(this.pattern, {this.negate = false});

  final String pattern;
  final bool negate;

  @override
  List<FormidableValidationError> validate(String value) =>
      RegExp(pattern).hasMatch(value) == negate
      ? [FormidablePatternError(pattern: pattern, negated: negate)]
      : const [];
}

/// The value must start with [prefix].
class StartsWith extends FormidableValidator<String> {
  const StartsWith(this.prefix);

  final String prefix;

  @override
  List<FormidableValidationError> validate(String value) =>
      value.startsWith(prefix)
      ? const []
      : [FormidableStartsWithError(prefix: prefix)];
}

/// The value must end with [suffix].
class EndsWith extends FormidableValidator<String> {
  const EndsWith(this.suffix);

  final String suffix;

  @override
  List<FormidableValidationError> validate(String value) =>
      value.endsWith(suffix)
      ? const []
      : [FormidableEndsWithError(suffix: suffix)];
}

/// The value must not start with [prefix].
class DoesntStartWith extends FormidableValidator<String> {
  const DoesntStartWith(this.prefix);

  final String prefix;

  @override
  List<FormidableValidationError> validate(String value) =>
      value.startsWith(prefix)
      ? [FormidableDoesntStartWithError(prefix: prefix)]
      : const [];
}

/// The value must not end with [suffix].
class DoesntEndWith extends FormidableValidator<String> {
  const DoesntEndWith(this.suffix);

  final String suffix;

  @override
  List<FormidableValidationError> validate(String value) =>
      value.endsWith(suffix)
      ? [FormidableDoesntEndWithError(suffix: suffix)]
      : const [];
}

/// The value must contain [text]. The comparison is case sensitive.
class Contains extends FormidableValidator<String> {
  const Contains(this.text);

  final String text;

  @override
  List<FormidableValidationError> validate(String value) =>
      value.contains(text) ? const [] : [FormidableContainsError(text: text)];
}

/// The value must not contain [text]. The comparison is case sensitive.
class NotContains extends FormidableValidator<String> {
  const NotContains(this.text);

  final String text;

  @override
  List<FormidableValidationError> validate(String value) => value.contains(text)
      ? [FormidableNotContainsError(text: text)]
      : const [];
}

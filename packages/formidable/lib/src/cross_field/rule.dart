import '../runtime/field.dart';
import '../validation/validation_error.dart';

/// What the Field that carries a cross-field rule has to be.
///
/// The generator reads it from the rule and fails the build when the Field
/// does not fit. The nullability of the Field never matters.
enum FormidableTargetFit {
  /// Any type.
  any,

  /// `bool`.
  boolean,

  /// `DateTime`.
  dateTime,

  /// A `Comparable` type, such as `num`, `String` or `DateTime`.
  comparable,
}

/// What every Field referenced by a cross-field rule has to be, in relation to
/// the Field that carries the rule.
enum FormidableReferenceFit {
  /// Any type.
  any,

  /// `bool`.
  boolean,

  /// `DateTime`.
  dateTime,

  /// The same type as the Field that carries the rule.
  sameAsTarget,

  /// A `Comparable` type that can be compared with the Field that carries the
  /// rule: the same type, or two numbers.
  comparableWithTarget,

  /// An `Iterable` whose elements can hold the value of the Field that carries
  /// the rule.
  iterableOfTarget,
}

/// A rule that spans several Fields, declared as an annotation on the Field
/// that receives the error.
///
/// It names the other Fields by Dart symbol, for example
/// `@MustMatch(#password)`. The symbols exist only for the generator: it
/// resolves each one to a typed Field handle, fails the build when a symbol is
/// not a Field or its type does not fit, and gives the handles to the Form.
/// The rule never looks anything up by name at runtime.
///
/// Unlike a Field Validator, a rule also runs while its Field is Unset,
/// because "required if" has to. Each built-in rule documents what it does in
/// that case. To write your own rule, use a `FormidableFormValidator`.
abstract class FormidableCrossFieldRule {
  const FormidableCrossFieldRule({
    this.other,
    this.others = const [],
    this.targetFit = FormidableTargetFit.any,
    this.referenceFit = FormidableReferenceFit.any,
    this.hasOperand = false,
    this.operand,
  });

  /// The Field the rule reads, by symbol, for a rule that names one. Read by
  /// the generator only.
  final Symbol? other;

  /// The Fields the rule reads, by symbol, for a rule that names several. Read
  /// by the generator only. The referenced Fields are [other] followed by
  /// these.
  final List<Symbol> others;

  /// What the Field that carries the rule has to be.
  final FormidableTargetFit targetFit;

  /// What every referenced Field has to be.
  final FormidableReferenceFit referenceFit;

  /// Whether [operand] is meaningful. It is false for a rule that compares
  /// with a constant of its own, such as `RequiredIf`.
  final bool hasOperand;

  /// A constant the rule compares the first referenced Field with. The
  /// generator checks that its type fits that Field.
  final Object? operand;

  /// Returns the errors for [target], which carries the rule. [references]
  /// are the Fields named by the rule, in the same order.
  List<FormidableValidationError> validate(
    FormidableField<Object?> target,
    List<FormidableField<Object?>> references,
  );
}

/// A cross-field rule together with the Field handles it applies to. A
/// generated Form builds one per annotation.
final class FormidableCrossFieldBinding {
  FormidableCrossFieldBinding(this.rule, this.target, this.references);

  final FormidableCrossFieldRule rule;

  /// The Field that carries the rule and receives its errors.
  final FormidableField<Object?> target;

  /// The Fields the rule names, in the order of its symbols.
  final List<FormidableField<Object?>> references;

  List<FormidableValidationError> evaluate() =>
      rule.validate(target, references);
}

/// Presence as the cross-field rules read it.
extension FormidableFieldFilled on FormidableField<Object?> {
  /// Whether the Field holds something: it is set, the value is not null, and
  /// it is not an empty string, collection or map. `false` for the number zero
  /// and for `false`.
  bool get isFilled {
    if (!defined) return false;
    return switch (value) {
      null => false,
      final String text => text.isNotEmpty,
      final Iterable<Object?> items => items.isNotEmpty,
      final Map<Object?, Object?> map => map.isNotEmpty,
      _ => true,
    };
  }
}

/// Whether [field] is set to exactly [value]. An Unset Field equals nothing.
bool formidableFieldEquals(FormidableField<Object?> field, Object? value) =>
    field.defined && field.value == value;

import 'package:formidable/formidable.dart';
import 'package:formidable_test_schemas/choice_validators.dart';
import 'package:test/test.dart';

void main() {
  List<FormidableValidationError> errorsOf<T extends Object>(
    FormidableField<T?> Function(ChoiceRulesForm form) pick,
    T value,
  ) {
    final field = pick(ChoiceRulesForm())..setValue(value);
    return field.state.errors;
  }

  group('IsTrue and Accepted', () {
    test('accept true and reject false', () {
      expect(errorsOf((f) => f.isTrue, true), isEmpty);
      expect(errorsOf((f) => f.isTrue, false), [const FormidableIsTrueError()]);
    });

    test('Accepted is the same Validator under another name', () {
      expect(errorsOf((f) => f.accepted, true), isEmpty);
      expect(errorsOf((f) => f.accepted, false), [
        const FormidableIsTrueError(),
      ]);
    });

    test('are skipped while the Field is Unset', () {
      expect(ChoiceRulesForm().isTrue.state.errors, isEmpty);
    });
  });

  group('IsFalse and Declined', () {
    test('accept false and reject true', () {
      expect(errorsOf((f) => f.isFalse, false), isEmpty);
      expect(errorsOf((f) => f.isFalse, true), [
        const FormidableIsFalseError(),
      ]);
      expect(errorsOf((f) => f.declined, true), [
        const FormidableIsFalseError(),
      ]);
      expect(errorsOf((f) => f.declined, false), isEmpty);
    });
  });

  group('OneOf', () {
    test('accepts a listed value and rejects any other', () {
      expect(errorsOf((f) => f.oneOf, 'red'), isEmpty);
      expect(errorsOf((f) => f.oneOf, 'blue'), [
        const FormidableOneOfError(allowed: ['red', 'green'], actual: 'blue'),
      ]);
    });

    test('is case sensitive by default', () {
      expect(errorsOf((f) => f.oneOf, 'RED'), hasLength(1));
    });

    test('can ignore case', () {
      expect(errorsOf((f) => f.oneOfIgnoreCase, 'RED'), isEmpty);
      expect(errorsOf((f) => f.oneOfIgnoreCase, 'Blue'), hasLength(1));
    });

    test('works on numbers and enums', () {
      expect(errorsOf((f) => f.oneOfNumber, 2), isEmpty);
      expect(errorsOf((f) => f.oneOfNumber, 4), hasLength(1));
      expect(errorsOf((f) => f.oneOfPlan, Plan.pro), isEmpty);
      expect(errorsOf((f) => f.oneOfPlan, Plan.free), [
        const FormidableOneOfError(
          allowed: [Plan.pro, Plan.team],
          actual: Plan.free,
        ),
      ]);
    });
  });

  group('NoneOf', () {
    test('rejects a listed value and accepts any other', () {
      expect(errorsOf((f) => f.noneOf, 'guest'), isEmpty);
      expect(errorsOf((f) => f.noneOf, 'admin'), [
        const FormidableNoneOfError(
          disallowed: ['admin', 'root'],
          actual: 'admin',
        ),
      ]);
    });

    test('can ignore case', () {
      expect(errorsOf((f) => f.noneOf, 'ADMIN'), isEmpty);
      expect(errorsOf((f) => f.noneOfIgnoreCase, 'ADMIN'), hasLength(1));
    });
  });

  group('EqualTo and NotEqualTo', () {
    test('EqualTo needs the constant', () {
      expect(errorsOf((f) => f.equalTo, 'agree'), isEmpty);
      expect(errorsOf((f) => f.equalTo, 'nope'), [
        const FormidableEqualToError(expected: 'agree', actual: 'nope'),
      ]);
      expect(errorsOf((f) => f.equalToNumber, 42), isEmpty);
      expect(errorsOf((f) => f.equalToNumber, 41), hasLength(1));
    });

    test('NotEqualTo rejects the constant', () {
      expect(errorsOf((f) => f.notEqualTo, 'hunter2'), isEmpty);
      expect(errorsOf((f) => f.notEqualTo, 'password'), [
        const FormidableNotEqualToError(unexpected: 'password'),
      ]);
    });
  });
}

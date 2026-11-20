import 'package:build/build.dart';
import 'package:build_test/build_test.dart';
import 'package:formidable_generator/formidable_generator.dart';
import 'package:test/test.dart';

/// Seam 3 for the cross-field rules: a rule that names a symbol which is not a
/// Field, or Fields whose types do not fit, fails the build with a message
/// that names both sides.
Future<TestBuilderResult> _build(String schema) async {
  final readerWriter = TestReaderWriter(rootPackage: 'app');
  await readerWriter.testing.loadIsolateSources();
  return testBuilder(
    formidableBuilder(BuilderOptions.empty),
    {'app|lib/schema.dart': schema},
    rootPackage: 'app',
    readerWriter: readerWriter,
    generateFor: {'app|lib/schema.dart'},
  );
}

/// A Schema whose Field `target` carries [annotation]; [others] are more
/// Fields, declared as `final Type name;`.
Future<TestBuilderResult> _rule({
  required String annotation,
  required String type,
  String others = 'final String other;',
  String declarations = '',
  String? target,
}) {
  final names = RegExp(
    r'final [^;]+? (\w+);',
  ).allMatches(others).map((m) => m.group(1)!).toList();
  return _build('''
import 'package:formidable/formidable.dart';

part 'schema.formidable.dart';

$declarations

@Formidable()
class Account {
  const Account({required this.target, ${names.map((n) => 'required this.$n').join(', ')}});

  $annotation
  final ${target ?? type} target;
  $others
}
''');
}

void main() {
  group('references', () {
    test('fail when a symbol is not a Field, listing the Fields', () async {
      final result = await _rule(
        annotation: '@MustMatch(#pasword)',
        type: 'String',
        others: 'final String password;',
      );

      expect(result.succeeded, isFalse);
      expect(
        result.errors.join('\n'),
        allOf(
          contains('@MustMatch'),
          contains('"target"'),
          contains('#pasword'),
          contains('password'),
        ),
      );
    });

    test('fail when a Field names itself', () async {
      final result = await _rule(
        annotation: '@MustMatch(#target)',
        type: 'String',
      );

      expect(result.succeeded, isFalse);
      expect(result.errors.join('\n'), contains('its own Field'));
    });

    test('fail when a rule names no Field', () async {
      final result = await _rule(
        annotation: '@RequiredWith([])',
        type: 'String?',
      );

      expect(result.succeeded, isFalse);
      expect(result.errors.join('\n'), contains('does not name any Field'));
    });

    test('fail when a symbol is a Passthrough Field', () async {
      final result = await _rule(
        annotation: '@MustMatch(#other)',
        type: 'String',
        others: '@Passthrough()\n  final String other;',
      );

      expect(result.succeeded, isFalse);
      expect(result.errors.join('\n'), contains('Passthrough'));
    });

    test(
      'fail when the Field that carries the rule is a Passthrough',
      () async {
        final result = await _rule(
          annotation: '@Passthrough()\n  @MustMatch(#other)',
          type: 'String',
        );

        expect(result.succeeded, isFalse);
        expect(result.errors.join('\n'), contains('Passthrough'));
      },
    );
  });

  group('types', () {
    test('MustMatch needs the same type', () async {
      final result = await _rule(
        annotation: '@MustMatch(#other)',
        type: 'String',
        others: 'final int other;',
      );

      expect(result.succeeded, isFalse);
      expect(
        result.errors.join('\n'),
        allOf(contains('"other"'), contains('int'), contains('String')),
      );
    });

    test('MustMatch accepts a nullable Field of the same type', () async {
      final result = await _rule(
        annotation: '@MustMatch(#other)',
        type: 'String',
        others: 'final String? other;',
      );

      expect(result.succeeded, isTrue);
    });

    test('Compare accepts an int and a double', () async {
      final result = await _rule(
        annotation: '@Compare(FormidableComparison.lessThan, #other)',
        type: 'int',
        others: 'final double other;',
      );

      expect(result.succeeded, isTrue);
    });

    test('Compare rejects different comparable types', () async {
      final result = await _rule(
        annotation: '@Compare(FormidableComparison.lessThan, #other)',
        type: 'int',
        others: 'final String other;',
      );

      expect(result.succeeded, isFalse);
      expect(result.errors.join('\n'), contains('compared'));
    });

    test('Compare rejects a Field that is not comparable', () async {
      final result = await _rule(
        annotation: '@Compare(FormidableComparison.lessThan, #other)',
        type: 'List<int>',
        others: 'final List<int> other;',
      );

      expect(result.succeeded, isFalse);
      expect(result.errors.join('\n'), contains('Comparable'));
    });

    test('DateRangeOrder needs DateTime Fields', () async {
      final onString = await _rule(
        annotation: '@DateRangeOrder(#other)',
        type: 'String',
        others: 'final DateTime other;',
      );
      final onOther = await _rule(
        annotation: '@DateRangeOrder(#other)',
        type: 'DateTime',
        others: 'final String other;',
      );
      final ok = await _rule(
        annotation: '@DateRangeOrder(#other)',
        type: 'DateTime?',
        others: 'final DateTime other;',
      );

      expect(onString.succeeded, isFalse);
      expect(onString.errors.join('\n'), contains('DateTime'));
      expect(onOther.succeeded, isFalse);
      expect(onOther.errors.join('\n'), contains('"other"'));
      expect(ok.succeeded, isTrue);
    });

    test('RequiredIfAccepted needs a bool Field', () async {
      final result = await _rule(
        annotation: '@RequiredIfAccepted(#other)',
        type: 'String?',
        others: 'final String other;',
      );

      expect(result.succeeded, isFalse);
      expect(result.errors.join('\n'), contains('bool'));
    });

    test('AcceptedIf needs a bool Field on its own side', () async {
      final result = await _rule(
        annotation: '@AcceptedIf(#other, true)',
        type: 'String?',
        others: 'final bool other;',
      );

      expect(result.succeeded, isFalse);
      expect(result.errors.join('\n'), contains('bool'));
    });

    test(
      'a constant has to fit the type of the Field it is compared with',
      () async {
        final bad = await _rule(
          annotation: "@RequiredIf(#other, 'x')",
          type: 'String?',
          others: 'final int other;',
        );
        final ok = await _rule(
          annotation: '@RequiredIf(#other, 3)',
          type: 'String?',
          others: 'final int other;',
        );

        expect(bad.succeeded, isFalse);
        expect(
          bad.errors.join('\n'),
          allOf(contains('String'), contains('int')),
        );
        expect(ok.succeeded, isTrue);
      },
    );

    test('InList needs an Iterable of the type of the Field', () async {
      final bad = await _rule(
        annotation: '@InList(#other)',
        type: 'String',
        others: 'final List<int> other;',
      );
      final notIterable = await _rule(
        annotation: '@InList(#other)',
        type: 'String',
        others: 'final String other;',
      );
      final ok = await _rule(
        annotation: '@InList(#other)',
        type: 'String',
        others: 'final List<String>? other;',
      );

      expect(bad.succeeded, isFalse);
      expect(bad.errors.join('\n'), contains('Iterable'));
      expect(notIterable.succeeded, isFalse);
      expect(ok.succeeded, isTrue);
    });

    test('UniqueBy needs a key function for the type of the Field', () async {
      const declarations = '''
String lower(String value) => value.toLowerCase();
''';
      final bad = await _rule(
        annotation: '@UniqueBy(#other, lower)',
        type: 'int',
        others: 'final List<int> other;',
        declarations: declarations,
      );
      final ok = await _rule(
        annotation: '@UniqueBy(#other, lower)',
        type: 'String',
        others: 'final List<String> other;',
        declarations: declarations,
      );

      expect(bad.succeeded, isFalse);
      expect(bad.errors.join('\n'), contains('String'));
      expect(ok.succeeded, isTrue);
    });

    test('group rules accept Fields of any type', () async {
      final result = await _rule(
        annotation: '@ExactlyOneOf([#a, #b])',
        type: 'String?',
        others: 'final int? a;\n  final List<String>? b;',
      );

      expect(result.succeeded, isTrue);
    });
  });
}

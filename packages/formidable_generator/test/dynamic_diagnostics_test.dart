import 'package:build/build.dart';
import 'package:build_test/build_test.dart';
import 'package:formidable_generator/formidable_generator.dart';
import 'package:test/test.dart';

/// Seam 3 for Dynamic Forms: Schemas go through the real builder and the test
/// asserts on the build result, never on the text of generated code.
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

String _schema(String field, {String extra = ''}) =>
    '''
import 'package:formidable/formidable.dart';

part 'schema.formidable.dart';

@Formidable()
class Survey {
  const Survey({required this.title, required this.answers});

  final String title;

  $field
}
$extra
''';

void main() {
  group('Dynamic Form diagnostics', () {
    test('@Dynamic() on a Map<String, Object?> builds', () async {
      final result = await _build(
        _schema('@Dynamic()\n  final Map<String, Object?> answers;'),
      );

      expect(result.succeeded, isTrue);
      expect(result.errors, isEmpty);
      expect(result.outputs.map((id) => id.path), [
        'lib/schema.formidable.dart',
      ]);
    });

    for (final (type, label) in [
      ('Map<String, int>', 'a map of another value type'),
      ('Map<int, Object?>', 'a map with another key type'),
      ('Map<String, Object>', 'a map of non-null values'),
      ('Map<String, Object?>?', 'a nullable map'),
      ('List<String>', 'a list'),
      ('String', 'a String'),
    ]) {
      test('@Dynamic() on $label fails', () async {
        final result = await _build(
          _schema('@Dynamic()\n  final $type answers;'),
        );

        expect(result.succeeded, isFalse);
        expect(
          result.errors.join('\n'),
          allOf(
            contains('@Dynamic()'),
            contains('Map<String, Object?>'),
            contains('"answers" of Survey'),
          ),
        );
      });
    }

    test('@Dynamic() with @Passthrough() fails', () async {
      final result = await _build(
        _schema(
          '@Dynamic()\n  @Passthrough()\n  final Map<String, Object?> answers;',
        ),
      );

      expect(result.succeeded, isFalse);
      expect(result.errors.join('\n'), contains('cannot be a @Passthrough()'));
    });

    test('@Dynamic() with a Validator fails', () async {
      final result = await _build(
        _schema(
          '@Dynamic()\n  @MinLength(2)\n  final Map<String, Object?> answers;',
        ),
      );

      expect(result.succeeded, isFalse);
      expect(
        result.errors.join('\n'),
        allOf(contains('Dynamic Form'), contains('@MinLength(2)')),
      );
    });

    test('@Dynamic() with an @AsyncValidator fails', () async {
      final result = await _build(
        _schema(
          '@Dynamic()\n  @AsyncValidator<UsernameFree>()\n'
          '  final Map<String, Object?> answers;',
          extra: '''
class UsernameFree extends FormidableAsyncValidator<String> {
  @override
  Future<List<FormidableValidationError>> validate(String value) async =>
      const [];
}
''',
        ),
      );

      expect(result.succeeded, isFalse);
      expect(
        result.errors.join('\n'),
        allOf(contains('Dynamic Form'), contains('@AsyncValidator')),
      );
    });

    test('@Dynamic() with a Normalizer fails', () async {
      final result = await _build(
        _schema('@Dynamic()\n  @Trim()\n  final Map<String, Object?> answers;'),
      );

      expect(result.succeeded, isFalse);
      expect(result.errors.join('\n'), contains('@Trim()'));
    });

    test('@Dynamic() with a default value fails', () async {
      final result = await _build('''
import 'package:formidable/formidable.dart';

part 'schema.formidable.dart';

@Formidable()
class Survey {
  const Survey({this.answers = const {}});

  @Dynamic()
  final Map<String, Object?> answers;
}
''');

      expect(result.succeeded, isFalse);
      expect(result.errors.join('\n'), contains('cannot have a default value'));
    });
  });
}

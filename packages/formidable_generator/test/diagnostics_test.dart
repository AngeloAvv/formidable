import 'package:build/build.dart';
import 'package:build_test/build_test.dart';
import 'package:formidable_generator/formidable_generator.dart';
import 'package:test/test.dart';

/// Seam 3: feed Schemas to the real builders and assert on the diagnostics
/// they report. Nothing here asserts on the text of generated code.
Future<TestBuilderResult> _build(
  Builder builder,
  String schema, {
  String? pubspec,
}) async {
  final readerWriter = TestReaderWriter(rootPackage: 'app');
  await readerWriter.testing.loadIsolateSources();
  return testBuilder(
    builder,
    {'app|lib/schema.dart': schema, 'app|pubspec.yaml': ?pubspec},
    rootPackage: 'app',
    readerWriter: readerWriter,
    generateFor: {'app|lib/schema.dart'},
  );
}

const _prelude = '''
import 'package:formidable/formidable.dart';

part 'schema.formidable.dart';
''';

void main() {
  final formBuilder = formidableBuilder(BuilderOptions.empty);
  final scopeBuilder = formidableScopeBuilder(BuilderOptions.empty);

  group('Form builder diagnostics', () {
    test('fails when a final field is missing from the constructor', () async {
      final result = await _build(formBuilder, '''
$_prelude
@Formidable()
class SignUp {
  const SignUp({required this.username});

  final String username;
  final String email;
}
''');

      expect(result.succeeded, isFalse);
      expect(
        result.errors.join('\n'),
        allOf(contains('email'), contains('missing from its constructor')),
      );
    });

    test('fails when a constructor parameter has no matching field', () async {
      final result = await _build(formBuilder, '''
$_prelude
@Formidable()
class SignUp {
  const SignUp({required this.username, required String extra})
      : username = extra;

  final String username;
}
''');

      expect(result.succeeded, isFalse);
      expect(
        result.errors.join('\n'),
        allOf(contains('extra'), contains('no matching final field')),
      );
    });

    test('fails when the annotation is not on a class', () async {
      final result = await _build(formBuilder, '''
$_prelude
@Formidable()
enum SignUp { a }
''');

      expect(result.succeeded, isFalse);
      expect(result.errors.join('\n'), contains('can only annotate a class'));
    });

    test('succeeds and writes the part file for a valid Schema', () async {
      final result = await _build(formBuilder, '''
$_prelude
@Formidable()
class SignUp {
  const SignUp({required this.username});

  @MinLength(4)
  final String username;
}
''');

      expect(result.succeeded, isTrue);
      expect(result.outputs.map((id) => id.path), [
        'lib/schema.formidable.dart',
      ]);
    });

    test('accepts @Required() and @Passthrough() Fields', () async {
      final result = await _build(formBuilder, '''
$_prelude
@Formidable()
class EditUser {
  const EditUser({
    required this.id,
    this.mood,
    this.revision = 1,
    this.parentId,
  });

  @Passthrough()
  final int id;

  @Required()
  final bool? mood;

  @Passthrough()
  final int revision;

  @Passthrough()
  final int? parentId;
}
''');

      expect(result.succeeded, isTrue);
      expect(result.outputs.map((id) => id.path), [
        'lib/schema.formidable.dart',
      ]);
    });
  });

  group('Form Scope builder', () {
    const schema = '''
import 'package:formidable/formidable.dart';

@Formidable()
class SignUp {
  const SignUp({required this.username});

  final String username;
}
''';

    test(
      'writes the scope library when the package uses the bindings',
      () async {
        final result = await _build(
          scopeBuilder,
          schema,
          pubspec: 'name: app\ndependencies:\n  formidable_flutter: ^0.1.0\n',
        );

        expect(result.succeeded, isTrue);
        expect(result.outputs.map((id) => id.path), [
          'lib/schema.formidable_scope.dart',
        ]);
      },
    );

    test('writes nothing when the package does not use the bindings', () async {
      final result = await _build(
        scopeBuilder,
        schema,
        pubspec: 'name: app\ndependencies:\n  formidable: ^0.1.0\n',
      );

      expect(result.succeeded, isTrue);
      expect(result.outputs, isEmpty);
    });
  });
}

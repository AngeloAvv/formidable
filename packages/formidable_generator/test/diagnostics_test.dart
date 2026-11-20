import 'package:build/build.dart';
import 'package:build_test/build_test.dart';
import 'package:formidable_generator/formidable_generator.dart';
import 'package:logging/logging.dart';
import 'package:test/test.dart';

/// Seam 3: feed Schemas to the real builders and assert on the diagnostics
/// they report. Nothing here asserts on the text of generated code.
Future<TestBuilderResult> _build(
  Builder builder,
  String schema, {
  String? pubspec,
  List<LogRecord>? logs,
}) async {
  final readerWriter = TestReaderWriter(rootPackage: 'app');
  await readerWriter.testing.loadIsolateSources();
  return testBuilder(
    builder,
    {'app|lib/schema.dart': schema, 'app|pubspec.yaml': ?pubspec},
    rootPackage: 'app',
    readerWriter: readerWriter,
    generateFor: {'app|lib/schema.dart'},
    onLog: logs?.add,
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

    test('fails when the Schema is generic', () async {
      final result = await _build(formBuilder, '''
$_prelude
@Formidable()
class Wrapper<T> {
  const Wrapper({required this.value});

  final T value;
}
''');

      expect(result.succeeded, isFalse);
      expect(
        result.errors.join('\n'),
        allOf(contains('Wrapper'), contains('generic')),
      );
    });

    test('positional constructor parameters are matched by name', () async {
      final result = await _build(formBuilder, '''
$_prelude
@Formidable()
class SignUp {
  const SignUp(this.username, [this.email = '']);

  final String username;
  final String email;
}
''');

      expect(result.succeeded, isTrue);
    });

    test('getters are ignored and inherited fields are accepted', () async {
      final result = await _build(formBuilder, '''
$_prelude
abstract class Base {
  const Base({required this.id});

  final int id;
}

@Formidable()
class SignUp extends Base {
  const SignUp({required super.id, required this.username});

  final String username;

  String get label => '\$username#\$id';
}
''');

      expect(result.succeeded, isTrue);
    });

    test(
      'an inherited final field missing from the constructor fails',
      () async {
        final result = await _build(formBuilder, '''
$_prelude
abstract class Base {
  const Base({this.id = 0});

  final int id;
}

@Formidable()
class SignUp extends Base {
  const SignUp({required this.username});

  final String username;
}
''');

        expect(result.succeeded, isFalse);
        expect(
          result.errors.join('\n'),
          allOf(contains('id'), contains('missing from its constructor')),
        );
      },
    );
  });

  group('Required warning', () {
    test('@Required() on a non-nullable Field warns but builds', () async {
      final logs = <LogRecord>[];
      final result = await _build(formBuilder, '''
$_prelude
@Formidable()
class SignUp {
  const SignUp({required this.username});

  @Required()
  final String username;
}
''', logs: logs);

      expect(result.succeeded, isTrue);
      final warnings = logs.where((r) => r.level == Level.WARNING);
      expect(
        warnings.map((r) => r.message).join('\n'),
        allOf(contains('username'), contains('@Required()')),
      );
    });

    test('@Required() on a nullable Field does not warn', () async {
      final logs = <LogRecord>[];
      final result = await _build(formBuilder, '''
$_prelude
@Formidable()
class SignUp {
  const SignUp({this.nickname});

  @Required()
  final String? nickname;
}
''', logs: logs);

      expect(result.succeeded, isTrue);
      expect(logs.where((r) => r.level >= Level.WARNING), isEmpty);
    });
  });

  group('Form builder success', () {
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

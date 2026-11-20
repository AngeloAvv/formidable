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

const _isEven = '''
class IsEven extends FormidableValidator<int> {
  const IsEven();

  @override
  List<FormidableValidationError> validate(int value) => const [];
}
''';

const _notBlank = '''
class NotBlank extends FormidableValidator<Object> {
  const NotBlank();

  @override
  List<FormidableValidationError> validate(Object value) => const [];
}
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

  group('Validator type fit', () {
    Future<TestBuilderResult> build({
      required String annotations,
      required String type,
      String declarations = '',
    }) => _build(formBuilder, '''
$_prelude
$declarations
@Formidable()
class Account {
  const Account({required this.value});

  $annotations
  final $type value;
}
''');

    test('fails when a Validator does not fit the Field type', () async {
      final result = await build(annotations: '@MinLength(3)', type: 'int');

      expect(result.succeeded, isFalse);
      expect(
        result.errors.join('\n'),
        allOf(
          contains('MinLength'),
          contains('"value"'),
          contains('int'),
          contains('String'),
        ),
      );
    });

    test('names the offending Validator among several', () async {
      final result = await build(
        annotations: '@MinLength(3)\n  @IsEven()',
        type: 'int',
        declarations: _isEven,
      );

      expect(result.succeeded, isFalse);
      final errors = result.errors.join('\n');
      expect(errors, contains('MinLength'));
      expect(errors, isNot(contains('IsEven')));
    });

    test('accepts a Validator typed for the Field type', () async {
      final result = await build(annotations: '@MinLength(3)', type: 'String');

      expect(result.succeeded, isTrue);
    });

    test('accepts a non-nullable Validator on a nullable Field', () async {
      final result = await build(annotations: '@MinLength(3)', type: 'String?');

      expect(result.succeeded, isTrue);
    });

    test('accepts a Validator typed for a supertype of the Field', () async {
      final result = await build(
        annotations: '@NotBlank()',
        type: 'String',
        declarations: _notBlank,
      );

      expect(result.succeeded, isTrue);
    });

    test('accepts a custom Validator typed for the Field', () async {
      final result = await build(
        annotations: '@IsEven()',
        type: 'int',
        declarations: _isEven,
      );

      expect(result.succeeded, isTrue);
    });

    test('rejects a custom Validator typed for another type', () async {
      final result = await build(
        annotations: '@IsEven()',
        type: 'String',
        declarations: _isEven,
      );

      expect(result.succeeded, isFalse);
      expect(result.errors.join('\n'), contains('IsEven'));
    });

    test('checks the Validators inside a combinator', () async {
      final result = await build(
        annotations: '@AnyOf([MinLength(3), IsEven()])',
        type: 'String',
        declarations: _isEven,
      );

      expect(result.succeeded, isFalse);
      expect(result.errors.join('\n'), contains('IsEven'));
    });

    test('accepts a combinator whose Validators all fit', () async {
      final result = await build(
        annotations: '@AnyOf([MinLength(3), NotBlank()])',
        type: 'String',
        declarations: _notBlank,
      );

      expect(result.succeeded, isTrue);
    });

    test('checks a Validator nested in a combinator against an unfit Field', () async {
      final result = await build(
        annotations: '@AnyOf([MinLength(3)])',
        type: 'int',
      );

      expect(result.succeeded, isFalse);
      expect(result.errors.join('\n'), contains('MinLength'));
    });
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

    test(
      '@Required() on a non-nullable Field with a default does not warn',
      () async {
        final logs = <LogRecord>[];
        final result = await _build(formBuilder, '''
$_prelude
@Formidable()
class SignUp {
  const SignUp({this.username = 'guest'});

  @Required()
  final String username;
}
''', logs: logs);

        expect(result.succeeded, isTrue);
        expect(logs.where((r) => r.level == Level.WARNING), isEmpty);
      },
    );

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

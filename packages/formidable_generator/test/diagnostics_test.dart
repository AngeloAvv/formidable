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
  const Account({required this.amount});

  $annotations
  final $type amount;
}
''');

    test('fails when a Validator does not fit the Field type', () async {
      final result = await build(annotations: '@MinLength(3)', type: 'int');

      expect(result.succeeded, isFalse);
      expect(
        result.errors.join('\n'),
        allOf(
          contains('MinLength'),
          contains('"amount"'),
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

    test(
      'checks a Validator nested in a combinator against an unfit Field',
      () async {
        final result = await build(
          annotations: '@AnyOf([MinLength(3)])',
          type: 'int',
        );

        expect(result.succeeded, isFalse);
        expect(result.errors.join('\n'), contains('MinLength'));
      },
    );

    test('checks the Validators of Each against the element type', () async {
      final result = await build(
        annotations: '@Each([MinLength(3)])',
        type: 'List<int>',
      );

      expect(result.succeeded, isFalse);
      final errors = result.errors.join('\n');
      expect(errors, allOf(contains('MinLength'), contains('elements')));
      expect(errors, contains('int'));
    });

    test('accepts Each whose Validators fit the elements', () async {
      final strings = await build(
        annotations: '@Each([MinLength(3)])',
        type: 'List<String>',
      );
      final nullable = await build(
        annotations: '@Each([MinLength(3)])',
        type: 'Set<String?>?',
      );

      expect(strings.succeeded, isTrue);
      expect(nullable.succeeded, isTrue);
    });

    test('rejects Each on a Field that is not a collection', () async {
      final result = await build(
        annotations: '@Each([MinLength(3)])',
        type: 'String',
      );

      expect(result.succeeded, isFalse);
      expect(result.errors.join('\n'), contains('Each'));
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

    test('accepts @Trim() Normalizers and @Effects() on the Schema', () async {
      final result = await _build(formBuilder, '''
$_prelude
@Formidable()
@Effects([ClearCity()])
class Address {
  const Address({required this.country, this.city});

  @Trim()
  final String country;

  final String? city;
}

class ClearCity extends FormidableEffect<AddressForm> {
  const ClearCity();

  @override
  void apply(AddressForm form, FormidableEffectContext context) {
    if (context.changed(form.country)) form.city.clear();
  }
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

  group('Nested Form diagnostics', () {
    const address = '''
@Formidable()
class Address {
  const Address({required this.street});

  final String street;
}
''';

    test('a Schema nested in another Schema builds', () async {
      final result = await _build(formBuilder, '''
$_prelude
$address
@Formidable()
class Contact {
  const Contact({required this.home, this.work});

  final Address home;
  final Address? work;
}
''');

      expect(result.succeeded, isTrue);
    });

    test('a Schema that contains itself fails', () async {
      final result = await _build(formBuilder, '''
$_prelude
@Formidable()
class Node {
  const Node({this.next});

  final Node? next;
}
''');

      expect(result.succeeded, isFalse);
      expect(
        result.errors.join('\n'),
        allOf(contains('Node'), contains('nests itself')),
      );
    });

    test('two Schemas that contain each other fail', () async {
      final result = await _build(formBuilder, '''
$_prelude
@Formidable()
class Chicken {
  const Chicken({this.egg});

  final Egg? egg;
}

@Formidable()
class Egg {
  const Egg({this.chicken});

  final Chicken? chicken;
}
''');

      expect(result.succeeded, isFalse);
      expect(result.errors.join('\n'), contains('Chicken -> Egg -> Chicken'));
    });

    test('a Nested Form cannot be a @Passthrough()', () async {
      final result = await _build(formBuilder, '''
$_prelude
$address
@Formidable()
class Contact {
  const Contact({required this.home});

  @Passthrough()
  final Address home;
}
''');

      expect(result.succeeded, isFalse);
      expect(
        result.errors.join('\n'),
        allOf(contains('home'), contains('cannot be a @Passthrough()')),
      );
    });

    test('a Nested Form cannot have a Validator', () async {
      final result = await _build(formBuilder, '''
$_prelude
$address
@Formidable()
class Contact {
  const Contact({required this.home});

  @MinLength(2)
  final Address home;
}
''');

      expect(result.succeeded, isFalse);
      expect(
        result.errors.join('\n'),
        allOf(contains('home'), contains('Nested Form'), contains('MinLength')),
      );
    });

    test('a Nested Form cannot have a default', () async {
      final result = await _build(formBuilder, '''
$_prelude
$address
@Formidable()
class Contact {
  const Contact({this.home = const Address(street: 'x')});

  final Address home;
}
''');

      expect(result.succeeded, isFalse);
      expect(
        result.errors.join('\n'),
        allOf(contains('home'), contains('default value')),
      );
    });

    test('a nullable Nested Form that needs a Passthrough fails', () async {
      final result = await _build(formBuilder, '''
$_prelude
@Formidable()
class Record {
  const Record({required this.id});

  @Passthrough()
  final int id;
}

@Formidable()
class Editor {
  const Editor({this.record});

  final Record? record;
}
''');

      expect(result.succeeded, isFalse);
      expect(
        result.errors.join('\n'),
        allOf(contains('record'), contains('@Passthrough()')),
      );
    });

    test('the Scope builder fails on a cyclic Schema too', () async {
      final result = await _build(scopeBuilder, '''
$_prelude
@Formidable()
class Node {
  const Node({this.next});

  final Node? next;
}
''', pubspec: 'name: app\ndependencies:\n  formidable_flutter: any\n');

      expect(result.succeeded, isFalse);
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
          pubspec: 'name: app\ndependencies:\n  formidable_flutter: ^0.3.0\n',
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
        pubspec: 'name: app\ndependencies:\n  formidable: ^0.3.0\n',
      );

      expect(result.succeeded, isTrue);
      expect(result.outputs, isEmpty);
    });
  });

  group('Async Validator diagnostics', () {
    const emailCheck = '''
class EmailAvailable extends FormidableAsyncValidator<String> {
  @override
  Future<List<FormidableValidationError>> validate(String value) async =>
      const [];
}
''';

    Future<TestBuilderResult> build(String schema) =>
        _build(formBuilder, '$_prelude\n$emailCheck\n$schema');

    test('succeeds and writes the part file for a valid Schema', () async {
      final result = await build('''
@Formidable()
class SignUp {
  const SignUp({required this.email, required this.backup});

  @AsyncValidator<EmailAvailable>()
  final String email;

  @AsyncValidator<EmailAvailable>()
  final String? backup;
}
''');

      expect(result.succeeded, isTrue);
      expect(result.outputs.map((id) => id.path), [
        'lib/schema.formidable.dart',
      ]);
    });

    test(
      'fails when the Async Validator does not fit the Field type',
      () async {
        final result = await build('''
@Formidable()
class SignUp {
  const SignUp({required this.age});

  @AsyncValidator<EmailAvailable>()
  final int age;
}
''');

        expect(result.succeeded, isFalse);
        expect(
          result.errors.join('\n'),
          allOf(
            contains('EmailAvailable'),
            contains('"age"'),
            contains('int'),
            contains('String'),
          ),
        );
      },
    );

    test('fails when no validator class is named', () async {
      final result = await build('''
@Formidable()
class SignUp {
  const SignUp({required this.email});

  @AsyncValidator()
  final String email;
}
''');

      expect(result.succeeded, isFalse);
      expect(result.errors.join('\n'), contains('must name the class'));
    });

    test('fails on a Passthrough Field', () async {
      final result = await build('''
@Formidable()
class SignUp {
  const SignUp({required this.email});

  @Passthrough()
  @AsyncValidator<EmailAvailable>()
  final String email;
}
''');

      expect(result.succeeded, isFalse);
      expect(
        result.errors.join('\n'),
        allOf(contains('Passthrough'), contains('"email"')),
      );
    });

    test('fails when the parameter name is the name of a Field', () async {
      final result = await build('''
@Formidable()
class SignUp {
  const SignUp({required this.emailAvailable, required this.email});

  final String emailAvailable;

  @AsyncValidator<EmailAvailable>()
  final String email;
}
''');

      expect(result.succeeded, isFalse);
      expect(result.errors.join('\n'), contains('"emailAvailable"'));
    });

    test('fails when an asynchronous Form Validator names no class', () async {
      final result = await build('''
@Formidable()
@AsyncFormValidator()
class SignUp {
  const SignUp({required this.email});

  final String email;
}
''');

      expect(result.succeeded, isFalse);
      expect(result.errors.join('\n'), contains('must name the class'));
    });

    test('accepts an asynchronous Form Validator on the Schema', () async {
      final result = await build('''
@Formidable()
@AsyncFormValidator<EmailAndName>()
class SignUp {
  const SignUp({required this.email});

  final String email;
}

class EmailAndName extends FormidableAsyncFormValidator<SignUpForm> {
  @override
  List<FormidableField<Object?>> dependencies(SignUpForm form) => [form.email];

  @override
  Future<List<FormidableFieldError>> validate(SignUpForm form) async =>
      const [];
}
''');

      expect(result.succeeded, isTrue);
    });
  });
  group('Passthrough diagnostics', () {
    Future<TestBuilderResult> build(String fieldSource) =>
        _build(formBuilder, '''
$_prelude
@Formidable()
class EditUser {
  const EditUser({required this.id});

$fieldSource
}
''');

    for (final (annotation, type) in [
      ('@Required()', 'int?'),
      ('@MinLength(3)', 'String'),
      ('@Trim()', 'String'),
      ('@Min(1)', 'int'),
    ]) {
      test('fails when a Passthrough Field has $annotation', () async {
        final result = await build('''
  @Passthrough()
  $annotation
  final $type id;
''');

        expect(result.succeeded, isFalse);
        expect(
          result.errors.join('\n'),
          allOf(
            contains('"id"'),
            contains('Passthrough'),
            contains(annotation),
          ),
        );
      });
    }

    test('accepts a Passthrough Field with a default value', () async {
      final result = await build('''
  @Passthrough()
  final int id = 1;
''');

      expect(result.succeeded, isTrue);
    });
  });

  group('Field names that collide with the Form', () {
    Future<TestBuilderResult> build(String name) => _build(formBuilder, '''
$_prelude
@Formidable()
class SignUp {
  const SignUp({required this.$name});

  final String $name;
}
''');

    for (final name in [
      'patch',
      'replace',
      'reset',
      'commit',
      'clear',
      'enable',
      'disable',
      'touch',
      'untouch',
      'batch',
      'value',
      'valueOrNull',
      'submit',
      'state',
      'applyErrors',
      'dispose',
      'focusOrder',
      'defined',
      'isValid',
      'isDirty',
      'isPending',
      'buildOutput',
      'buildState',
      'hashCode',
      'toString',
      // The streams of the Form.
      'changes',
      'valueChanges',
      'statusChanges',
      'select',
      'hasListeners',
      // The metadata of the generated state lives under `meta`, so `meta` is
      // the only name the state takes from the Schema's Fields.
      'meta',
    ]) {
      test('fails for a Field named $name', () async {
        final result = await build(name);

        expect(result.succeeded, isFalse);
        expect(
          result.errors.join('\n'),
          allOf(
            contains('"$name"'),
            contains('SignUp'),
            contains('Form'),
            contains('Rename the field'),
          ),
        );
      });
    }

    test('accepts an ordinary name', () async {
      final result = await build('email');

      expect(result.succeeded, isTrue);
    });

    // The metadata of the Form is under `state.meta`, so these names are free.
    for (final name in ['form', 'status', 'dirty', 'pending', 'errors']) {
      test('accepts a Field named $name', () async {
        final result = await build(name);

        expect(result.succeeded, isTrue);
      });
    }
  });

  group('Nested Form with an Async Validator', () {
    test('fails', () async {
      final result = await _build(formBuilder, '''
$_prelude
class Taken extends FormidableAsyncValidator<Object> {
  @override
  Future<List<FormidableValidationError>> validate(Object value) async =>
      const [];
}

@Formidable()
class Address {
  const Address({required this.street});

  final String street;
}

@Formidable()
class SignUp {
  const SignUp({required this.home});

  @AsyncValidator<Taken>()
  final Address home;
}
''');

      expect(result.succeeded, isFalse);
      expect(
        result.errors.join('\n'),
        allOf(contains('"home"'), contains('Nested Form'), contains('Async')),
      );
    });
  });

  group('NotEmpty fit', () {
    Future<TestBuilderResult> build(String type) => _build(formBuilder, '''
$_prelude
@Formidable()
class Form1 {
  const Form1({required this.items});

  @NotEmpty()
  final $type items;
}
''');

    for (final type in [
      'String',
      'List<int>',
      'Set<String>',
      'Map<String, int>',
    ]) {
      test('accepts $type', () async {
        expect((await build(type)).succeeded, isTrue);
      });
    }

    for (final type in ['int', 'bool', 'DateTime']) {
      test('rejects $type', () async {
        final result = await build(type);

        expect(result.succeeded, isFalse);
        expect(
          result.errors.join('\n'),
          allOf(contains('@NotEmpty'), contains('"items"'), contains(type)),
        );
      });
    }
  });
}

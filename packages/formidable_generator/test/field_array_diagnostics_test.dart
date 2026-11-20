import 'package:build/build.dart';
import 'package:build_test/build_test.dart';
import 'package:formidable_generator/formidable_generator.dart';
import 'package:test/test.dart';

/// Seam 3 for Field Arrays: Schemas go through the real Form builder and the
/// tests assert on the reported diagnostics, never on generated code.
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

const _prelude = '''
import 'package:formidable/formidable.dart';

part 'schema.formidable.dart';

@Formidable()
class Phone {
  const Phone({required this.number});

  final String number;
}

class IsEven extends FormidableValidator<int> {
  const IsEven();

  @override
  List<FormidableValidationError> validate(int value) => const [];
}

class OnlyStringLists extends FormidableValidator<List<String>> {
  const OnlyStringLists();

  @override
  List<FormidableValidationError> validate(List<String> value) => const [];
}
''';

void main() {
  Future<void> fails(String schema, List<String> messages) async {
    final result = await _build('$_prelude\n$schema');
    expect(result.succeeded, isFalse, reason: 'the build should fail');
    expect(result.errors.join('\n'), allOf(messages.map(contains).toList()));
  }

  Future<void> builds(String schema) async {
    final result = await _build('$_prelude\n$schema');
    expect(result.errors, isEmpty);
    expect(result.succeeded, isTrue);
  }

  group('Field Array diagnostics', () {
    test(
      'a list of Schemas builds',
      () => builds('''
@Formidable()
class Person {
  const Person({this.phones = const [], this.backup});

  @MinItems(1)
  final List<Phone> phones;

  final List<Phone>? backup;
}
'''),
    );

    test(
      'lists, sets and maps of primitives build as single Fields',
      () => builds('''
@Formidable()
class Tags {
  const Tags({this.a = const [], this.b = const {}, this.c = const {}});

  final List<String> a;
  final Set<String> b;
  final Map<String, int> c;
}
'''),
    );

    test(
      '@FieldArray on a list of primitives builds',
      () => builds('''
@Formidable()
class Tags {
  const Tags({this.a = const []});

  @FieldArray(each: [MinLength(2)], normalizers: [Trim()])
  @MaxItems(3)
  final List<String> a;
}
'''),
    );

    test(
      'a set of Schemas fails',
      () => fails(
        '''
@Formidable()
class Person {
  const Person({required this.phones});

  final Set<Phone> phones;
}
''',
        ['set of Schemas', 'phones', 'List<Phone>'],
      ),
    );

    test(
      '@FieldArray on something that is not a list fails',
      () => fails(
        '''
@Formidable()
class Tags {
  const Tags({required this.tags});

  @FieldArray()
  final Set<String> tags;
}
''',
        ['@FieldArray()', 'can only annotate a List'],
      ),
    );

    test(
      '@FieldArray on a list of Schemas with each fails',
      () => fails(
        '''
@Formidable()
class Person {
  const Person({required this.phones});

  @FieldArray(each: [MinLength(2)])
  final List<Phone> phones;
}
''',
        ['Field Array of Nested Forms', 'Phone'],
      ),
    );

    test(
      'a Passthrough list of Schemas fails',
      () => fails(
        '''
@Formidable()
class Person {
  const Person({required this.phones});

  @Passthrough()
  final List<Phone> phones;
}
''',
        ['@Passthrough()', 'Field Array'],
      ),
    );

    test(
      'a list of nullable Schemas fails',
      () => fails(
        '''
@Formidable()
class Person {
  const Person({required this.phones});

  final List<Phone?> phones;
}
''',
        ['nullable Schemas', 'List<Phone>'],
      ),
    );

    test(
      'a Normalizer on the list fails',
      () => fails(
        '''
@Formidable()
class Tags {
  const Tags({required this.tags});

  @FieldArray()
  @Trim()
  final List<String> tags;
}
''',
        ['Field Array', 'normalizers', '@Trim()'],
      ),
    );

    test(
      'a Validator that cannot judge Iterable<Object?> fails',
      () => fails(
        '''
@Formidable()
class Tags {
  const Tags({required this.tags});

  @FieldArray()
  @OnlyStringLists()
  final List<String> tags;
}
''',
        ['@OnlyStringLists', 'Iterable<Object?>'],
      ),
    );

    test(
      'an each Validator that does not fit the items fails',
      () => fails(
        '''
@Formidable()
class Tags {
  const Tags({required this.tags});

  @FieldArray(each: [IsEven()])
  final List<String> tags;
}
''',
        ['@IsEven', 'items', 'String'],
      ),
    );

    test(
      'a list of a Schema that contains itself fails',
      () => fails(
        '''
@Formidable()
class Node {
  const Node({this.children = const []});

  final List<Node> children;
}
''',
        ['Node', 'contains itself'],
      ),
    );

    test(
      'a list of a Schema that cannot be created empty fails',
      () => fails(
        '''
@Formidable()
class Record {
  const Record({required this.id});

  @Passthrough()
  final int id;
}

@Formidable()
class Library {
  const Library({required this.records});

  final List<Record> records;
}
''',
        ['records', '@Passthrough()', 'created empty'],
      ),
    );
  });
}

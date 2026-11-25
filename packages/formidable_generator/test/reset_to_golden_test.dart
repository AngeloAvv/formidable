import 'dart:io';

import 'package:build/build.dart';
import 'package:build_test/build_test.dart';
import 'package:formidable_generator/formidable_generator.dart';
import 'package:test/test.dart';

const _schema = '''
import 'package:formidable/formidable.dart';

part 'schema.formidable.dart';

@Formidable()
class Phone {
  const Phone({required this.number});

  final String number;
}

@Formidable()
class Person {
  const Person({required this.name, required this.home, required this.phones});

  final String name;
  final Phone home;

  @FieldArray()
  final List<Phone> phones;
}
''';

void main() {
  test('the generated Form emits reset({to}) next to patch and replace', () async {
    final readerWriter = TestReaderWriter(rootPackage: 'app');
    await readerWriter.testing.loadIsolateSources();
    final result = await testBuilder(
      formidableBuilder(BuilderOptions.empty),
      {'app|lib/schema.dart': _schema},
      rootPackage: 'app',
      readerWriter: readerWriter,
      generateFor: {'app|lib/schema.dart'},
    );
    expect(result.errors, isEmpty);
    expect(result.succeeded, isTrue);

    final generated = readerWriter.testing.readString(
      AssetId(
        'app',
        '.dart_tool/build/generated/app/lib/schema.formidable.dart',
      ),
    );
    final start = generated.indexOf('class PersonForm');
    expect(start, isNonNegative, reason: generated);
    final form = generated.substring(start);

    // Golden: the whole `reset` method, byte for byte.
    final method = RegExp(
      r'  /// Restores every Field to its initial state.*?resetTo\(\(\) => replace\(to\)\);\n',
      dotAll: true,
    ).firstMatch(form);
    expect(method, isNotNull, reason: form);
    final golden = File('test/goldens/reset_to.golden').readAsStringSync();
    expect(method!.group(0), golden);

    // It sits next to the other whole-Schema writers, in the Form that owns the
    // Nested Form and the Field Array, and the Nested Form gets its own.
    expect(form, contains('void reset({Person? to})'));
    expect(form, contains('replace(Person'));
    expect(generated, contains('void reset({Phone? to})'));
  });
}

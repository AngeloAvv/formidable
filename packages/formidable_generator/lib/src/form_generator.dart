import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:formidable/formidable.dart';
import 'package:source_gen/source_gen.dart';

import 'form_emitter.dart';
import 'schema.dart';

/// Generates the Form of every `@Formidable()` Schema into a part file.
class FormGenerator extends GeneratorForAnnotation<Formidable> {
  FormGenerator() : super(inPackage: 'formidable');

  @override
  String generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) {
    final schema = readSchema(element);
    // Only this builder reports warnings, so the Form Scope builder, which
    // reads the same Schema, does not repeat them.
    schema.warnings.forEach(log.warning);
    return emitForm(schema);
  }
}

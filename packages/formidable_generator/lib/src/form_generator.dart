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
  ) => emitForm(readSchema(element));
}

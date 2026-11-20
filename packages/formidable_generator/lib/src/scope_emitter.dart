import 'schema.dart';

/// Emits the library with the Form Scope and the context extension of every
/// Schema in [schemas], which all live in [schemaFile].
String emitScopeLibrary(
  List<SchemaModel> schemas, {
  required String schemaFile,
}) {
  final out = StringBuffer()
    ..writeln('// GENERATED CODE - DO NOT MODIFY BY HAND')
    ..writeln()
    ..writeln("import 'package:flutter/widgets.dart';")
    ..writeln("import 'package:formidable_flutter/formidable_flutter.dart';")
    ..writeln()
    ..writeln("import '$schemaFile';");
  for (final schema in schemas) {
    out
      ..writeln()
      ..write(_scope(schema));
  }
  return out.toString();
}

String _scope(SchemaModel schema) {
  final form = schema.formName;
  final scope = schema.scopeName;
  final getter =
      '${schema.name[0].toLowerCase()}${schema.name.substring(1)}Form';
  return '''
/// Creates a [$form], makes it available to the widgets below and disposes it.
class $scope extends FormidableScope<$form> {
  $scope({super.key, $form Function()? create, required super.child})
      : super(create: create ?? $form.new);

  /// The [$form] of the closest [$scope] above [context].
  static $form of(BuildContext context) =>
      FormidableScope.of<$form>(context);
}

extension ${schema.name}FormContext on BuildContext {
  /// The [$form] of the closest [$scope] above this context.
  $form get $getter => $scope.of(this);
}
''';
}

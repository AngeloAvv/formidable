import 'schema.dart';

/// Emits the library with the Form Scope and the context extension of every
/// Schema in [schemas], which all live in [schemaFile].
String emitScopeLibrary(
  List<SchemaModel> schemas, {
  required String schemaFile,
}) {
  final out = StringBuffer()
    ..writeln('// GENERATED CODE - DO NOT MODIFY BY HAND')
    ..writeln('// ignore_for_file: type=lint')
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
  // A Form that cannot be created without arguments (it takes Async Validator
  // instances or a Schema instance for a Passthrough Field) has no default.
  final needsCreate =
      schema.requiresInitial || schema.asyncParameters.isNotEmpty;
  final createParameter = needsCreate
      ? 'required $form Function() create,'
      : '$form Function()? create,';
  final createArgument = needsCreate ? 'create' : 'create ?? $form.new';
  final state = schema.stateName;
  final prefix = schema.name;
  return '''
/// Creates a [$form], makes it available to the widgets below and disposes it.
///
/// Give it exactly one of `child` and `builder`. The `builder` receives the
/// [$form] and a context below the scope.
class $scope extends FormidableScope<$form> {
  $scope({
    super.key,
    $createParameter
    super.errorDisplay,
    super.child,
    super.builder,
  }) : super(create: $createArgument);

  /// Exposes a [$form] that something else owns, without disposing it.
  const $scope.value({
    super.key,
    required $form form,
    super.errorDisplay,
    super.child,
    super.builder,
  }) : super.value(form: form);

  /// The [$form] of the closest [$scope] above [context].
  static $form of(BuildContext context) =>
      FormidableScope.of<$form>(context);
}

extension ${schema.name}FormContext on BuildContext {
  /// The [$form] of the closest [$scope] above this context.
  $form get $getter => $scope.of(this);
}

/// Rebuilds with the [$state] of a [$form] on every change of the Form.
///
/// Without `form` it uses the closest [$scope].
class ${prefix}FormBuilder
    extends FormidableTypedFormBuilder<$form, $state> {
  const ${prefix}FormBuilder({
    super.key,
    super.form,
    required super.builder,
    super.buildWhen,
  });
}

/// Calls `listener` with each new [$state] of a [$form], never for the state
/// present when it is built.
///
/// Without `form` it uses the closest [$scope].
class ${prefix}FormListener
    extends FormidableTypedFormListener<$form, $state> {
  const ${prefix}FormListener({
    super.key,
    super.form,
    required super.listener,
    required super.child,
    super.listenWhen,
  });
}

/// Rebuilds only when what `selector` picks from the [$state] of a [$form]
/// changes.
///
/// Without `form` it uses the closest [$scope].
class ${prefix}FormSelector<R>
    extends FormidableTypedFormSelector<$form, $state, R> {
  const ${prefix}FormSelector({
    super.key,
    super.form,
    required super.selector,
    required super.builder,
    super.buildWhen,
  });
}
''';
}

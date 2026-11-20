import 'schema.dart';

/// Emits the Form class of [schema].
///
/// The output only configures the generic runtime in `package:formidable`:
/// typed Field handles, the two constructors and the construction of the
/// Schema instance. No behavior lives here.
String emitForm(SchemaModel schema) {
  final form = schema.formName;
  final fields = schema.fields;
  final out = StringBuffer();

  final partialParameters = fields
      .map(_partialParameter)
      .join(', ');
  final partialForwards = fields
      .map(_partialForward)
      .join(', ');
  final fromForwards = fields
      .map(
        (f) => f.isPassthrough
            ? '${f.name}: source.${f.name}'
            : '${f.name}: (value: source.${f.name})',
      )
      .join(', ');
  final privateParameters = fields
      .map(
        (f) => f.isPassthrough
            ? 'required ${f.typeSource} ${f.name}'
            : '({${f.typeSource} value})? ${f.name}',
      )
      .join(', ');

  out.writeln('class $form extends FormidableForm<${schema.name}> {');
  out.writeln(
    '  /// Creates a Form with only some Fields prefilled. An omitted',
  );
  out.writeln('  /// or null argument leaves the Field Unset.');
  out.writeln('  $form({$partialParameters}) : this._($partialForwards);');
  out.writeln();
  out.writeln('  /// Creates a Form with every Field set from [source].');
  out.writeln('  $form.from(${schema.name} source) : this._($fromForwards);');
  out.writeln();
  out.writeln('  $form._({$privateParameters})');
  out.write('      : ');
  out.write(fields.map((f) => '${f.name} = ${_field(f)}').join(',\n        '));
  out.writeln(' {');
  final nodes = fields.map((f) => 'this.${f.name}').join(', ');
  final validators = schema.formValidators.isEmpty
      ? ''
      : ', formValidators: [${schema.formValidators.join(', ')}]';
  out.writeln('    attach<$form>([$nodes]$validators);');
  out.writeln('  }');
  for (final f in fields) {
    out.writeln();
    out.writeln('  final ${_handleType(f)} ${f.name};');
  }
  out.writeln();
  out.writeln('  @override');
  out.writeln('  ${schema.name} buildOutput() => ${_construct(schema)};');
  out.writeln('}');
  return out.toString().trimRight();
}

/// A Passthrough Field must be given when it is non-nullable and has no
/// default. Otherwise it is optional.
bool _isRequiredParameter(FieldModel f) =>
    f.isPassthrough && !f.isNullable && f.defaultSource == null;

String _partialParameter(FieldModel f) {
  if (_isRequiredParameter(f)) return 'required ${f.typeSource} ${f.name}';
  return '${f.optionalTypeSource} ${f.name}';
}

String _partialForward(FieldModel f) {
  if (!f.isPassthrough) {
    return '${f.name}: ${f.name} == null ? null : (value: ${f.name})';
  }
  if (f.defaultSource != null && !_isRequiredParameter(f)) {
    return '${f.name}: ${f.name} ?? ${f.defaultSource}';
  }
  return '${f.name}: ${f.name}';
}

String _handleType(FieldModel f) => f.isPassthrough
    ? 'FormidablePassthrough<${f.typeSource}>'
    : 'FormidableField<${f.typeSource}>';

String _field(FieldModel f) {
  if (f.isPassthrough) return 'FormidablePassthrough<${f.typeSource}>(${f.name})';
  final arguments = [
    if (f.validators.isNotEmpty)
      'validators: const [${f.validators.map((v) => v.replaceFirst('const ', '')).join(', ')}]',
    if (f.isRequired) 'required: true',
    if (f.defaultSource != null) 'defaultValue: ${f.defaultSource}',
    'initial: ${f.name}',
  ];
  return 'FormidableField<${f.typeSource}>(${arguments.join(', ')})';
}

String _construct(SchemaModel schema) {
  final arguments = [
    for (final a in schema.constructorArguments)
      a.isNamed
          ? '${a.field.name}: ${a.field.name}.output'
          : '${a.field.name}.output',
  ];
  return '${schema.name}(${arguments.join(', ')})';
}

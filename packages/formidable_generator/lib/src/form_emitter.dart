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

  final asyncParameters = schema.asyncParameters;
  final asyncDeclarations = asyncParameters
      .map((p) => 'required ${p.typeSource} ${p.name}')
      .toList();
  final asyncForwards = asyncParameters
      .map((p) => '${p.name}: ${p.name}')
      .toList();
  final partialParameters = [
    ...fields.map(_partialParameter),
    ...asyncDeclarations,
  ].join(', ');
  final partialForwards = [
    ...fields.map(_partialForward),
    ...asyncForwards,
  ].join(', ');
  final patchParameters = fields
      .map((f) => '${f.optionalTypeSource} ${f.name}')
      .join(', ');
  final fromForwards = [
    ...fields.map(
      (f) => f.isPassthrough || f.isNested || f.isDynamic
          ? '${f.name}: source.${f.name}'
          : '${f.name}: (value: source.${f.name})',
    ),
    ...asyncForwards,
  ].join(', ');
  final fromParameters = asyncDeclarations.isEmpty
      ? ''
      : ', {${asyncDeclarations.join(', ')}}';
  final privateParameters = [
    ...fields.map(_privateParameter),
    ...asyncDeclarations,
  ].join(', ');

  out.writeln('class $form extends FormidableForm<${schema.name}> {');
  out.writeln(
    '  /// Creates a Form with only some Fields prefilled. An omitted',
  );
  out.writeln('  /// or null argument leaves the Field Unset.');
  out.writeln('  $form({$partialParameters}) : this._($partialForwards);');
  out.writeln();
  out.writeln('  /// Creates a Form with every Field set from [source].');
  out.writeln(
    '  $form.from(${schema.name} source$fromParameters) : '
    'this._($fromForwards);',
  );
  out.writeln();
  out.writeln('  $form._({$privateParameters})');
  out.write('      : ');
  out.write(fields.map((f) => '${f.name} = ${_field(f)}').join(',\n        '));
  out.writeln(' {');
  final nodes = fields.map((f) => 'this.${f.name}').join(', ');
  final effects = schema.effects.isEmpty
      ? ''
      : ', effects: [${schema.effects.map((e) => '...$e.effects').join(', ')}]';
  final validators = schema.formValidators.isEmpty
      ? ''
      : ', formValidators: [${schema.formValidators.join(', ')}]';
  final rules = [
    for (final f in fields)
      for (final rule in f.crossFieldRules)
        'FormidableCrossFieldBinding(${rule.source}, this.${f.name}, '
            '[${rule.references.map((r) => 'this.$r').join(', ')}])',
  ];
  final crossFieldRules = rules.isEmpty
      ? ''
      : ', crossFieldRules: [${rules.join(', ')}]';
  final asyncForm = schema.asyncFormValidators.isEmpty
      ? ''
      : ', asyncFormValidators: '
            '[${schema.asyncFormValidators.map((p) => p.name).join(', ')}]';
  out.writeln(
    '    attach<$form>([$nodes]$effects$validators$crossFieldRules$asyncForm);',
  );
  out.writeln('  }');
  for (final f in fields) {
    out.writeln();
    out.writeln('  final ${_handleType(f)} ${f.name};');
  }
  out.writeln();
  out.writeln(
    '  /// Writes only the Fields that are given, as one change. A null',
  );
  out.writeln('  /// argument leaves the Field as it is: use `clear()` or');
  out.writeln(
    '  /// `setValue` on the Field, or [replace], to write null. A Nested',
  );
  out.writeln(
    '  /// Form takes a Schema instance and replaces all its Fields; patch',
  );
  out.writeln('  /// part of it through its own `patch`.');
  out.writeln('  void patch({$patchParameters}) => batch(() {');
  for (final f in fields) {
    out.writeln(
      f.isNested
          ? '    if (${f.name} != null) this.${f.name}.replace(${f.name});'
          : f.isDynamic
          ? '    if (${f.name} != null) this.${f.name}.patch(${f.name});'
          : '    if (${f.name} != null) this.${f.name}.setValue(${f.name});',
    );
  }
  out.writeln('  });');
  out.writeln();
  out.writeln('  /// Writes every Field from [source], as one change.');
  out.writeln('  void replace(${schema.name} source) => batch(() {');
  for (final f in fields) {
    if (f.isDynamic) {
      out.writeln('    ${f.name}.replace(source.${f.name});');
    } else if (!f.isNested) {
      out.writeln('    ${f.name}.setValue(source.${f.name});');
    } else if (f.isNullable) {
      out.writeln(
        '    source.${f.name} == null ? ${f.name}.clear() : '
        '${f.name}.replace(source.${f.name}!);',
      );
    } else {
      out.writeln('    ${f.name}.replace(source.${f.name});');
    }
  }
  out.writeln('  });');
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

String _privateParameter(FieldModel f) {
  if (f.isDynamic) return '${f.optionalTypeSource} ${f.name}';
  if (f.isNested) {
    return f.nested!.requiresInitial
        ? 'required ${f.typeSource} ${f.name}'
        : '${f.optionalTypeSource} ${f.name}';
  }
  return f.isPassthrough
      ? 'required ${f.typeSource} ${f.name}'
      : '({${f.typeSource} value})? ${f.name}';
}

String _partialParameter(FieldModel f) {
  if (f.isNested && f.nested!.requiresInitial) {
    return 'required ${f.typeSource} ${f.name}';
  }
  if (_isRequiredParameter(f)) return 'required ${f.typeSource} ${f.name}';
  return '${f.optionalTypeSource} ${f.name}';
}

String _partialForward(FieldModel f) {
  if (f.isNested || f.isDynamic) return '${f.name}: ${f.name}';
  if (!f.isPassthrough) {
    return '${f.name}: ${f.name} == null ? null : (value: ${f.name})';
  }
  if (f.defaultSource != null && !_isRequiredParameter(f)) {
    return '${f.name}: ${f.name} ?? ${f.defaultSource}';
  }
  return '${f.name}: ${f.name}';
}

String _handleType(FieldModel f) => f.isDynamic
    ? 'FormidableDynamicForm'
    : f.isNested
    ? f.nested!.formName
    : f.isPassthrough
    ? 'FormidablePassthrough<${f.typeSource}>'
    : 'FormidableField<${f.typeSource}>';

/// A nullable Nested Form without `@Required()` can be Unset.
bool _isOptionalNested(FieldModel f) =>
    f.isNested && f.isNullable && !f.isRequired;

String _nested(FieldModel f) {
  final form = f.nested!.formName;
  final name = f.name;
  final injected = f.nested!.asyncParameters
      .map((p) => '${p.name}: ${p.name}')
      .join(', ');
  final fromInjected = injected.isEmpty ? '' : ', $injected';
  if (f.nested!.requiresInitial) return '$form.from($name$fromInjected)';
  final create =
      '$name == null ? $form($injected) : $form.from($name$fromInjected)';
  return _isOptionalNested(f)
      ? '($create)..markOptional(initiallySet: $name != null)'
      : create;
}

String _output(FieldModel f) => f.isDynamic
    ? '${f.name}.output'
    : f.isNested
    ? (_isOptionalNested(f)
          ? '${f.name}.outputOrNull'
          : '${f.name}.buildOutput()')
    : '${f.name}.output';

String _field(FieldModel f) {
  if (f.isDynamic) return 'FormidableDynamicForm(initial: ${f.name})';
  if (f.isNested) return _nested(f);
  if (f.isPassthrough) {
    return 'FormidablePassthrough<${f.typeSource}>(${f.name})';
  }
  final arguments = [
    if (f.normalizers.isNotEmpty)
      'normalizers: const [${f.normalizers.map((v) => v.replaceFirst('const ', '')).join(', ')}]',
    if (f.validators.isNotEmpty)
      'validators: const [${f.validators.map((v) => v.replaceFirst('const ', '')).join(', ')}]',
    if (f.asyncValidators.isNotEmpty)
      'asyncValidators: [${f.asyncValidators.map((p) => p.name).join(', ')}]',
    if (f.isRequired) 'required: true',
    if (f.defaultSource != null) 'defaultValue: ${f.defaultSource}',
    'initial: ${f.name}',
  ];
  return 'FormidableField<${f.typeSource}>(${arguments.join(', ')})';
}

String _construct(SchemaModel schema) {
  final arguments = [
    for (final a in schema.constructorArguments)
      a.isNamed ? '${a.field.name}: ${_output(a.field)}' : _output(a.field),
  ];
  return '${schema.name}(${arguments.join(', ')})';
}

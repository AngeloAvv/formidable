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
      (f) => f.isPassthrough || f.isNested || f.isDynamic || f.isArray
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
    '  /// `setValue` on the Field, or [replace], to write null. To write a',
  );
  out.writeln(
    '  /// chosen null together with other Fields as one change, wrap the',
  );
  out.writeln('  /// writes in [batch]. A Nested');
  out.writeln(
    '  /// Form takes a Schema instance and replaces all its Fields; patch',
  );
  out.writeln(
    '  /// part of it through its own `patch`. A Field Array takes a list and',
  );
  out.writeln('  /// replaces all its items.');
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
    } else if (f.isArray) {
      out.writeln(
        f.isNullable
            ? '    ${f.name}.setValue(source.${f.name} ?? const []);'
            : '    ${f.name}.setValue(source.${f.name});',
      );
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
  out.writeln();
  out.writeln('  @override');
  out.writeln(
    '  ${schema.stateName} get state => super.state as ${schema.stateName};',
  );
  out.writeln();
  // The streams, typed after the state like `state` is.
  out.writeln('  @override');
  out.writeln(
    '  Stream<${schema.stateName}> get changes =>\n'
    '      super.changes.cast<${schema.stateName}>();',
  );
  out.writeln();
  out.writeln('  @override');
  out.writeln(
    '  Stream<${schema.stateName}> get valueChanges =>\n'
    '      super.valueChanges.cast<${schema.stateName}>();',
  );
  out.writeln();
  out.writeln('  @override');
  out.writeln(
    '  Stream<R> select<R>(R Function(${schema.stateName} state) selector) =>\n'
    '      super.select<R>((state) => selector(state as ${schema.stateName}));',
  );
  out.writeln();
  out.writeln('  @override');
  out.writeln('  ${schema.stateName} buildState({');
  out.writeln('    required FormidableStatus status,');
  out.writeln('    required bool dirty,');
  out.writeln('    required bool pending,');
  out.writeln('    required bool isSet,');
  out.writeln('    required List<FormidableValidationError> errors,');
  out.writeln('  }) {');
  for (final f in fields) {
    // `this.`: a Field may be called like a parameter of this method.
    out.writeln('    final ${f.name}\$ = this.${f.name}.state;');
  }
  out.writeln('    return ${schema.stateName}(');
  out.writeln('      form: FormidableFormMeta<${schema.name}>(');
  out.writeln('        status: status,');
  out.writeln('        dirty: dirty,');
  out.writeln('        pending: pending,');
  out.writeln('        isSet: isSet,');
  out.writeln('        errors: errors,');
  out.writeln('        // Built from the child states, on the first read.');
  out.writeln('        buildValue: () => ${_constructFromStates(schema)},');
  out.writeln('      ),');
  for (final f in fields) {
    out.writeln('      ${f.name}: ${f.name}\$,');
  }
  out.writeln('    );');
  out.writeln('  }');
  out.writeln('}');
  out.writeln();
  out.write(_state(schema));
  return out.toString().trimRight();
}

/// The immutable state of a Form: the generic Form state plus the state of
/// every child, with deep equality.
String _state(SchemaModel schema) {
  final fields = schema.fields;
  final name = schema.stateName;
  final out = StringBuffer()
    ..writeln(
      '/// The state of a [${schema.formName}]: the state of every Field, Nested',
    )
    ..writeln(
      '/// Form and Field Array below it, and its own status under [form], as one',
    )
    ..writeln('/// immutable snapshot with deep equality.')
    ..writeln('final class $name extends FormidableFormState {')
    ..writeln('  $name({')
    ..writeln('    required FormidableFormMeta<${schema.name}> form,');
  for (final f in fields) {
    out.writeln('    required this.${f.name},');
  }
  out
    ..writeln('  }) : super(form: form);')
    ..writeln()
    ..writeln(
      '  /// The status, flags, errors and Schema value of the Form. The value',
    )
    ..writeln('  /// is lazy and does not take part in equality.')
    ..writeln('  @override')
    ..writeln('  FormidableFormMeta<${schema.name}> get form =>')
    ..writeln('      super.form as FormidableFormMeta<${schema.name}>;');
  for (final f in fields) {
    out
      ..writeln()
      ..writeln('  final ${_stateType(f)} ${f.name};');
  }
  out
    ..writeln()
    ..writeln('  @override')
    ..writeln('  bool operator ==(Object other) =>')
    ..write('      super == other && other is $name');
  for (final f in fields) {
    out.write(' && other.${f.name} == ${f.name}');
  }
  out
    ..writeln(';')
    ..writeln()
    ..writeln('  @override')
    ..writeln(
      '  int get hashCode => Object.hashAll([super.hashCode'
      '${fields.map((f) => ', ${f.name}').join()}]);',
    )
    ..writeln()
    ..writeln('  @override')
    ..writeln("  String toString() => '$name(form: \$form'");
  for (final f in fields) {
    out.writeln("      ', ${f.name}: \$${f.name}'");
  }
  out
    ..writeln("      ')';")
    ..writeln('}');
  return out.toString();
}

/// The type of the state of [f] in the state of its Form.
String _stateType(FieldModel f) => f.isDynamic
    ? 'FormidableDynamicFormState'
    : f.isNested
    ? f.nested!.stateName
    : f.isArray
    ? 'FormidableFieldArrayState<${f.array!.itemStateType}>'
    : f.isPassthrough
    ? f.typeSource
    : 'FormidableFieldState<${f.typeSource}>';

/// A Passthrough Field must be given when it is non-nullable and has no
/// default. Otherwise it is optional.
bool _isRequiredParameter(FieldModel f) =>
    f.isPassthrough && !f.isNullable && f.defaultSource == null;

String _privateParameter(FieldModel f) {
  if (f.isDynamic || f.isArray) return '${f.optionalTypeSource} ${f.name}';
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
  if (f.isNested || f.isDynamic || f.isArray) return '${f.name}: ${f.name}';
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
    : f.isArray
    ? 'FormidableFieldArray<${f.array!.nodeType}, ${f.array!.elementTypeSource}, ${f.array!.itemStateType}>'
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
    : f.isArray
    ? (f.isNullable ? '${f.name}.outputOrNull' : '${f.name}.output')
    : f.isNested
    ? (_isOptionalNested(f)
          ? '${f.name}.outputOrNull'
          : '${f.name}.buildOutput()')
    : '${f.name}.output';

/// The Field Array of [f]: the items are Nested Forms or Fields.
String _array(FieldModel f) {
  final array = f.array!;
  final element = array.elementTypeSource;
  final String create;
  final String read;
  final String readState;
  if (array.nested != null) {
    final form = array.nested!.formName;
    final injected = array.nested!.asyncParameters
        .map((p) => '${p.name}: ${p.name}')
        .join(', ');
    final fromInjected = injected.isEmpty ? '' : ', $injected';
    create =
        'initial == null ? $form($injected) : $form.from(initial$fromInjected)';
    read = 'item.buildOutput()';
    readState = 'state.form.value!';
  } else {
    final source = array.fieldArraySource!;
    final itemArguments = [
      if (array.hasNormalizers)
        'normalizers: $source.normalizers'
            '.cast<FormidableNormalizer<$element>>()',
      if (array.hasEach) 'validators: $source.each',
      'initial: initial == null ? null : (value: initial)',
    ];
    create = 'FormidableField<$element>(${itemArguments.join(', ')})';
    read = 'item.output';
    readState = element.endsWith('?')
        ? 'state.value'
        : 'state.value as $element';
  }
  final arguments = [
    'create: (initial) => $create',
    'read: (item) => $read',
    'itemState: (item) => item.state',
    'readState: (state) => $readState',
    if (f.validators.isNotEmpty)
      'validators: const [${f.validators.map((v) => v.replaceFirst('const ', '')).join(', ')}]',
    if (f.isRequired) 'required: true',
    if (f.isNullable) 'nullable: true',
    if (f.defaultSource != null) 'defaultValue: ${f.defaultSource}',
    'initial: ${f.name}',
  ];
  return 'FormidableFieldArray<${array.nodeType}, $element, '
      '${array.itemStateType}>(${arguments.join(', ')})';
}

String _field(FieldModel f) {
  if (f.isDynamic) return 'FormidableDynamicForm(initial: ${f.name})';
  if (f.isArray) return _array(f);
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

/// The Schema constructor call, reading the value of every child from the
/// child states (`email$`) instead of the live handles, so a state never
/// reads a Form that has moved on.
String _constructFromStates(SchemaModel schema) {
  final arguments = [
    for (final a in schema.constructorArguments)
      a.isNamed
          ? '${a.field.name}: ${_fromState(a.field)}'
          : _fromState(a.field),
  ];
  return '${schema.name}(${arguments.join(', ')})';
}

/// The Schema value of [f], from its state `name$`. It mirrors [_output],
/// which reads the live handle.
String _fromState(FieldModel f) {
  final state = '${f.name}\$';
  if (f.isDynamic) return '$state.output';
  if (f.isArray) {
    final list = 'List<${f.array!.elementTypeSource}>';
    return f.isNullable
        ? '$state.outputOrNull as $list?'
        : '$state.outputOrNull as $list';
  }
  if (f.isNested) {
    return _isOptionalNested(f) ? '$state.form.value' : '$state.form.value!';
  }
  if (f.isPassthrough) return state;
  // The state holds `T?`, which is `T` already when the Field is nullable.
  final value = f.isNullable
      ? '$state.value'
      : '$state.value as ${f.typeSource}';
  return f.defaultSource == null
      ? value
      : '$state.isSet ? $value : ${f.defaultSource}';
}

String _construct(SchemaModel schema) {
  final arguments = [
    for (final a in schema.constructorArguments)
      a.isNamed ? '${a.field.name}: ${_output(a.field)}' : _output(a.field),
  ];
  return '${schema.name}(${arguments.join(', ')})';
}

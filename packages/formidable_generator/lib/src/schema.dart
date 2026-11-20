import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:formidable/formidable.dart';
import 'package:source_gen/source_gen.dart';

const _schemaChecker = TypeChecker.typeNamed(
  Formidable,
  inPackage: 'formidable',
);
const _requiredChecker = TypeChecker.typeNamed(
  Required,
  inPackage: 'formidable',
);
const _passthroughChecker = TypeChecker.typeNamed(
  Passthrough,
  inPackage: 'formidable',
);
const _normalizerChecker = TypeChecker.typeNamed(
  FormidableNormalizer,
  inPackage: 'formidable',
);
const _dynamicChecker = TypeChecker.typeNamed(Dynamic, inPackage: 'formidable');
const _effectsChecker = TypeChecker.typeNamed(Effects, inPackage: 'formidable');
const _validatorChecker = TypeChecker.typeNamed(
  FormidableValidator,
  inPackage: 'formidable',
);

const _crossFieldRuleChecker = TypeChecker.typeNamed(
  FormidableCrossFieldRule,
  inPackage: 'formidable',
);
const _asyncValidatorChecker = TypeChecker.typeNamed(
  AsyncValidator,
  inPackage: 'formidable',
);
const _asyncFormValidatorChecker = TypeChecker.typeNamed(
  AsyncFormValidator,
  inPackage: 'formidable',
);

const _eachChecker = TypeChecker.typeNamed(Each, inPackage: 'formidable');
const _formValidatorChecker = TypeChecker.typeNamed(
  FormidableFormValidator,
  inPackage: 'formidable',
);

/// Whether [element] is annotated with `@Formidable()`.
bool isSchema(Element element) => _schemaChecker.hasAnnotationOf(element);

/// A Schema as the emitters see it.
final class SchemaModel {
  const SchemaModel({
    required this.name,
    required this.fields,
    required this.constructorArguments,
    this.asyncParameters = const [],
    this.asyncFormValidators = const [],
    this.formValidators = const [],
    this.effects = const [],
    this.warnings = const [],
  });

  /// The Schema class name, for example `SignUp`.
  final String name;

  /// The Fields in declaration order.
  final List<FieldModel> fields;

  /// How the Schema constructor is called, in parameter order.
  final List<ConstructorArgument> constructorArguments;

  /// Const expressions that rebuild the Form Validators, in annotation order.
  final List<String> formValidators;

  /// The injected Async Validators and asynchronous Form Validators of the
  /// Schema: one required parameter of each generated constructor, once per
  /// class even when several Fields name it.
  final List<AsyncParameter> asyncParameters;

  /// The parameters of the asynchronous Form Validators, in annotation order.
  final List<AsyncParameter> asyncFormValidators;

  /// Const `Effects(...)` expressions of the Schema, in annotation order.
  final List<String> effects;

  /// Problems that do not stop the build, reported by the Form builder only.
  final List<String> warnings;

  /// Whether a Form of this Schema cannot be created without a Schema
  /// instance, because a Passthrough Field has no value to start from.
  bool get requiresInitial => fields.any(
    (f) =>
        (f.isPassthrough && !f.isNullable && f.defaultSource == null) ||
        (f.nested?.requiresInitial ?? false),
  );

  String get formName => '${name}Form';
  String get scopeName => '${name}FormScope';
}

/// A cross-field rule as the emitter sees it: the annotation rebuilt as a const
/// expression and the Fields it names, resolved from symbols to Field names.
final class CrossFieldRuleModel {
  const CrossFieldRuleModel({required this.source, required this.references});

  /// The const expression that rebuilds the rule, for example
  /// `const MustMatch(#password)`.
  final String source;

  /// The names of the referenced Fields, in the order of the rule's symbols.
  final List<String> references;
}

/// A validator instance the caller injects into the generated Form.
final class AsyncParameter {
  const AsyncParameter({required this.name, required this.typeSource});

  /// The parameter name: the validator class name in lowerCamelCase.
  final String name;

  /// The validator class as written.
  final String typeSource;
}

final class FieldModel {
  const FieldModel({
    required this.name,
    required this.typeSource,
    required this.isNullable,
    required this.validators,
    required this.normalizers,
    this.crossFieldRules = const [],
    this.asyncValidators = const [],
    required this.defaultSource,
    required this.isRequired,
    required this.isPassthrough,
    this.nested,
    this.isDynamic = false,
  });

  final String name;

  /// The Dart type exactly as written, including a trailing `?`.
  final String typeSource;
  final bool isNullable;

  /// Const expressions that rebuild the Validators, in annotation order.
  final List<String> validators;

  /// Const expressions that rebuild the Normalizers, in annotation order.
  final List<String> normalizers;

  /// The cross-field rules of the Field, in annotation order.
  final List<CrossFieldRuleModel> crossFieldRules;
  /// The Async Validators of the Field, in annotation order.
  final List<AsyncParameter> asyncValidators;

  /// The constructor default of the Schema field, or null.
  final String? defaultSource;

  /// Whether the Field has `@Required()`.
  final bool isRequired;

  /// Whether the Field has `@Passthrough()`.
  final bool isPassthrough;

  /// Set when the Field's type is another Schema: the Field is a Nested Form.
  final NestedModel? nested;

  bool get isNested => nested != null;

  /// Whether the Field has `@Dynamic()`: its Fields are registered at runtime.
  final bool isDynamic;

  /// The type with a trailing `?`, for optional parameters.
  String get optionalTypeSource => isNullable ? typeSource : '$typeSource?';
}

/// What the emitters need to know about the Schema a Field nests.
final class NestedModel {
  const NestedModel({
    required this.formName,
    required this.requiresInitial,
    this.asyncParameters = const [],
  });

  /// The injected validators of the nested Schema. The parent Form takes them
  /// too and hands them down.
  final List<AsyncParameter> asyncParameters;

  /// The generated Form of the nested Schema, for example `AddressForm`.
  final String formName;

  /// Whether the nested Form cannot be created empty because it has a
  /// Passthrough Field that must be supplied.
  final bool requiresInitial;
}

/// One argument of the Schema constructor call.
final class ConstructorArgument {
  const ConstructorArgument({required this.field, required this.isNamed});

  final FieldModel field;
  final bool isNamed;
}

/// Reads [element] into a [SchemaModel], or throws an
/// [InvalidGenerationSourceError] when it cannot become a Form.
SchemaModel readSchema(Element element, [List<ClassElement> path = const []]) {
  if (element is! ClassElement) {
    throw InvalidGenerationSourceError(
      '@Formidable() can only annotate a class.',
      element: element,
    );
  }
  final name = element.name!;

  if (element.typeParameters.isNotEmpty) {
    throw InvalidGenerationSourceError(
      '$name is generic, and generic Schemas are not supported. '
      'Declare a Schema without type parameters.',
      element: element,
    );
  }

  final constructor = element.constructors.where(
    (c) => c.name == null || c.name == 'new' || c.name!.isEmpty,
  );
  if (constructor.isEmpty) {
    throw InvalidGenerationSourceError(
      '$name must declare an unnamed constructor that takes its fields.',
      element: element,
    );
  }
  final parameters = constructor.first.formalParameters;

  final fields = _finalFields(element);
  final fieldByName = {for (final f in fields) f.name!: f};
  final parameterNames = {for (final p in parameters) p.name};

  for (final parameter in parameters) {
    if (!fieldByName.containsKey(parameter.name)) {
      throw InvalidGenerationSourceError(
        'Constructor parameter "${parameter.name}" of $name has no matching '
        'final field.',
        element: parameter,
      );
    }
  }
  for (final field in fields) {
    if (!parameterNames.contains(field.name)) {
      throw InvalidGenerationSourceError(
        'Final field "${field.name}" of $name is missing from its '
        'constructor.',
        element: field,
      );
    }
  }

  final defaults = {
    for (final p in parameters)
      if (p.defaultValueCode != null) p.name!: p.defaultValueCode!,
  };
  final models = {
    for (final field in fields)
      field.name!: _readField(field, defaults[field.name], element, [
        ...path,
        element,
      ], fieldByName),
  };

  final warnings = [
    for (final field in fields)
      if (_requiredChecker.hasAnnotationOf(field) &&
          !models[field.name!]!.isNullable &&
          models[field.name!]!.defaultSource == null)
        '@Required() on "${field.name}" of $name has no effect: a '
            'non-nullable Field without a default is already required. Remove '
            'it, or make the Field nullable if choosing null should count as a '
            'value.',
  ];

  final asyncFormValidators = _readAsyncFormValidators(element);
  final asyncParameters = _collectAsyncParameters(
    name,
    models.values.toList(),
    asyncFormValidators,
    element,
  );

  return SchemaModel(
    name: name,
    fields: [for (final field in fields) models[field.name!]!],
    constructorArguments: [
      for (final p in parameters)
        ConstructorArgument(field: models[p.name]!, isNamed: p.isNamed),
    ],
    asyncParameters: asyncParameters,
    asyncFormValidators: asyncFormValidators,
    formValidators: [
      for (final annotation in element.metadata.annotations)
        if (_isFormValidator(annotation))
          'const ${annotation.toSource().substring(1)}',
    ],
    effects: _readEffects(element),
    warnings: warnings,
  );
}

/// The `@Effects(...)` annotations of [element], rebuilt as const expressions.
///
/// The annotation is matched by its constructor, not by its evaluated value:
/// the Effects name the generated Form, which does not exist yet in the first
/// build round, so the constant may not evaluate.
List<String> _readEffects(ClassElement element) => [
  for (final annotation in element.metadata.annotations)
    if (annotation.element?.enclosingElement case final owner?)
      if (_effectsChecker.isExactly(owner))
        'const ${annotation.toSource().substring(1)}',
];

/// The final instance fields of [element] and its superclasses, supertypes
/// first, in declaration order. Getters are not fields.
List<FieldElement> _finalFields(ClassElement element) {
  final chain = <InterfaceElement>[];
  for (InterfaceType? t = element.thisType; t != null; t = t.superclass) {
    if (t.isDartCoreObject) break;
    chain.insert(0, t.element);
  }
  return [
    for (final type in chain)
      for (final field in type.fields)
        if (!field.isStatic &&
            field.isFinal &&
            (field.isOriginDeclaration ||
                field.isOriginDeclaringFormalParameter))
          field,
  ];
}

FieldModel _readField(
  FieldElement field,
  String? defaultSource,
  ClassElement owner,
  List<ClassElement> path,
  Map<String, FieldElement> fieldByName,
) {
  final isDynamic = _readDynamic(field, defaultSource, owner);
  final nested = _readNested(field, defaultSource, owner, path);
  final validators = <String>[];
  final normalizers = <String>[];
  final crossFieldRules = <CrossFieldRuleModel>[];
  final asyncValidators = <AsyncParameter>[];
  for (final annotation in field.metadata.annotations) {
    final value = annotation.computeConstantValue();
    final type = value?.type;
    if (type == null) continue;
    if (_asyncValidatorChecker.isExactlyType(type) && type is InterfaceType) {
      asyncValidators.add(_readAsyncValidator(field, type));
    } else if (_normalizerChecker.isAssignableFromType(type)) {
      normalizers.add('const ${annotation.toSource().substring(1)}');
    } else if (_validatorChecker.isAssignableFromType(type)) {
      _checkValidatorFits(field, value!);
      // The part file shares the Schema library's scope, so the annotation
      // source can be reused as a const expression as it is written.
      validators.add('const ${annotation.toSource().substring(1)}');
    } else if (_crossFieldRuleChecker.isAssignableFromType(type)) {
      crossFieldRules.add(
        _readCrossFieldRule(field, annotation, value!, fieldByName),
      );
    }
  }
  return FieldModel(
    name: field.name!,
    typeSource: field.type.getDisplayString(),
    isNullable: field.type.nullabilitySuffix == NullabilitySuffix.question,
    validators: validators,
    normalizers: normalizers,
    crossFieldRules: crossFieldRules,
    asyncValidators: asyncValidators,
    defaultSource: defaultSource,
    isRequired: _requiredChecker.hasAnnotationOf(field),
    isPassthrough: _passthroughChecker.hasAnnotationOf(field),
    nested: nested,
    isDynamic: isDynamic,
  );
}

/// Whether [field] is a Dynamic Form, after checking that `@Dynamic()` is used
/// on a `Map<String, Object?>` Field and nothing else is declared on it.
bool _readDynamic(
  FieldElement field,
  String? defaultSource,
  ClassElement owner,
) {
  if (!_dynamicChecker.hasAnnotationOf(field)) return false;
  final where = '"${field.name}" of ${owner.name}';
  final type = field.type;
  final isDynamicMap =
      type is InterfaceType &&
      type.isDartCoreMap &&
      type.nullabilitySuffix == NullabilitySuffix.none &&
      type.typeArguments[0].isDartCoreString &&
      type.typeArguments[0].nullabilitySuffix == NullabilitySuffix.none &&
      type.typeArguments[1].isDartCoreObject &&
      type.typeArguments[1].nullabilitySuffix == NullabilitySuffix.question;
  if (!isDynamicMap) {
    throw InvalidGenerationSourceError(
      '@Dynamic() can only be used on a Field of type Map<String, Object?>, '
      'but $where is ${type.getDisplayString()}. Change the Field type, or '
      'remove @Dynamic().',
      element: field,
    );
  }
  if (_passthroughChecker.hasAnnotationOf(field)) {
    throw InvalidGenerationSourceError(
      '$where is a Dynamic Form and cannot be a @Passthrough(). Its Fields '
      'are registered at runtime.',
      element: field,
    );
  }
  final rules = [
    for (final annotation in field.metadata.annotations)
      if (annotation.computeConstantValue()?.type case final t?)
        if (_normalizerChecker.isAssignableFromType(t) ||
            _validatorChecker.isAssignableFromType(t))
          annotation.toSource(),
  ];
  if (rules.isNotEmpty) {
    throw InvalidGenerationSourceError(
      '$where is a Dynamic Form and cannot have ${rules.first}. Pass '
      'Validators and Normalizers when you register each Field.',
      element: field,
    );
  }
  if (defaultSource != null) {
    throw InvalidGenerationSourceError(
      '$where is a Dynamic Form and cannot have a default value. Its Fields '
      'are registered at runtime.',
      element: field,
    );
  }
  return true;
}

/// The nested Schema of [field], or null when its type is not a Schema.
NestedModel? _readNested(
  FieldElement field,
  String? defaultSource,
  ClassElement owner,
  List<ClassElement> path,
) {
  final type = field.type;
  final target = type is InterfaceType ? type.element : null;
  if (target is! ClassElement || !isSchema(target)) return null;

  final where = 'Field "${field.name}" of ${owner.name}';
  if (path.contains(target)) {
    final cycle = [...path.skipWhile((c) => c != target), target];
    throw InvalidGenerationSourceError(
      '$where nests ${target.name}, which nests itself again '
      '(${cycle.map((c) => c.name).join(' -> ')}). A Nested Form is always '
      'created with its parent, so a Schema cannot contain itself.',
      element: field,
    );
  }
  if (_passthroughChecker.hasAnnotationOf(field)) {
    throw InvalidGenerationSourceError(
      '$where is a Nested Form and cannot be a @Passthrough(). Mark the '
      'Fields of ${target.name} instead.',
      element: field,
    );
  }
  final rules = [
    for (final annotation in field.metadata.annotations)
      if (annotation.computeConstantValue()?.type case final t?)
        if (_normalizerChecker.isAssignableFromType(t) ||
            _validatorChecker.isAssignableFromType(t))
          annotation.toSource(),
  ];
  if (rules.isNotEmpty) {
    throw InvalidGenerationSourceError(
      '$where is a Nested Form and cannot have ${rules.first}. Put Validators '
      'and Normalizers on the Fields of ${target.name}.',
      element: field,
    );
  }
  if (defaultSource != null) {
    throw InvalidGenerationSourceError(
      '$where is a Nested Form and cannot have a default value. Give the '
      'Fields of ${target.name} their own defaults.',
      element: field,
    );
  }

  final nestedSchema = readSchema(target, path);
  final requiresInitial = nestedSchema.requiresInitial;
  if (requiresInitial &&
      field.type.nullabilitySuffix == NullabilitySuffix.question) {
    throw InvalidGenerationSourceError(
      '$where is a nullable Nested Form, but ${target.name} has a '
      '@Passthrough() Field that must be supplied, so it cannot be created '
      'while Unset. Make the Field non-nullable.',
      element: field,
    );
  }
  return NestedModel(
    formName: nestedSchema.formName,
    requiresInitial: requiresInitial,
    asyncParameters: nestedSchema.asyncParameters,
  );
}

/// The validator class named by `@AsyncValidator<V>()` on [field], checked to
/// fit the Field.
AsyncParameter _readAsyncValidator(FieldElement field, InterfaceType type) {
  final owner = field.enclosingElement.name;
  if (_passthroughChecker.hasAnnotationOf(field)) {
    throw InvalidGenerationSourceError(
      '@AsyncValidator cannot be used on "${field.name}" of $owner: a '
      'Passthrough Field is never validated. Remove the annotation, or the '
      '@Passthrough().',
      element: field,
    );
  }
  final validator = type.typeArguments.single;
  if (validator is! InterfaceType ||
      validator.element.name == 'FormidableAsyncValidator') {
    throw InvalidGenerationSourceError(
      '@AsyncValidator on "${field.name}" of $owner must name the class of '
      'the validator, for example @AsyncValidator<UsernameAvailable>().',
      element: field,
    );
  }
  final accepted = <InterfaceType>[validator, ...validator.allSupertypes]
      .where((t) => t.element.name == 'FormidableAsyncValidator')
      .map((t) => t.typeArguments.single)
      .firstOrNull;
  if (accepted != null) {
    final typeSystem = field.library.typeSystem;
    final fieldType = typeSystem.promoteToNonNull(field.type);
    if (!typeSystem.isAssignableTo(fieldType, accepted)) {
      throw InvalidGenerationSourceError(
        '@AsyncValidator<${validator.element.name}> cannot be used on '
        '"${field.name}" of $owner: it validates '
        '${accepted.getDisplayString()}, but the Field is '
        '${field.type.getDisplayString()}. Use an Async Validator that '
        'accepts ${field.type.getDisplayString()}, or change the Field type.',
        element: field,
      );
    }
  }
  return _asyncParameter(validator);
}

AsyncParameter _asyncParameter(InterfaceType validator) {
  final name = validator.element.name!;
  return AsyncParameter(
    name: '${name[0].toLowerCase()}${name.substring(1)}',
    typeSource: validator.getDisplayString(),
  );
}

/// The `@AsyncFormValidator<V>()` annotations of [element].
List<AsyncParameter> _readAsyncFormValidators(ClassElement element) {
  final parameters = <AsyncParameter>[];
  for (final annotation in element.metadata.annotations) {
    final type = annotation.computeConstantValue()?.type;
    if (type is! InterfaceType ||
        !_asyncFormValidatorChecker.isExactlyType(type)) {
      continue;
    }
    final validator = type.typeArguments.single;
    if (validator is! InterfaceType ||
        validator.element.name == 'FormidableAsyncFormValidator') {
      throw InvalidGenerationSourceError(
        '@AsyncFormValidator on ${element.name} must name the class of the '
        'validator, for example @AsyncFormValidator<PostalCodeMatchesCity>().',
        element: element,
      );
    }
    parameters.add(_asyncParameter(validator));
  }
  return parameters;
}

/// Every injected validator of the Schema once, after checking that its
/// parameter name is free.
List<AsyncParameter> _collectAsyncParameters(
  String schema,
  List<FieldModel> fields,
  List<AsyncParameter> formValidators,
  ClassElement element,
) {
  final fieldNames = {for (final f in fields) f.name, 'source'};
  final byName = <String, AsyncParameter>{};
  for (final parameter in [
    for (final f in fields) ...f.asyncValidators,
    for (final f in fields) ...?f.nested?.asyncParameters,
    ...formValidators,
  ]) {
    if (fieldNames.contains(parameter.name)) {
      throw InvalidGenerationSourceError(
        'The Async Validator ${parameter.typeSource} of $schema becomes the '
        'constructor parameter "${parameter.name}", which is already the '
        'name of a Field of $schema. Rename the validator class.',
        element: element,
      );
    }
    final known = byName[parameter.name];
    if (known != null && known.typeSource != parameter.typeSource) {
      throw InvalidGenerationSourceError(
        '${known.typeSource} and ${parameter.typeSource} would both become '
        'the constructor parameter "${parameter.name}" of $schema. Rename one '
        'of the validator classes.',
        element: element,
      );
    }
    byName[parameter.name] = parameter;
  }
  return byName.values.toList();
}

/// Fails the build when the value a Validator [object] accepts cannot be the
/// value of [field].
///
/// A Validator is called only with a chosen non-null value, or with null when
/// it accepts null, so the check is on the non-null type of the Field: a
/// `MinLength` (a `String` Validator) fits both `String` and `String?`.
///
/// A combinator such as `AnyOf` holds other Validators in its fields. They are
/// called with the same value, so each of them has to fit too. The members of
/// `Each` judge the elements, so they are checked against the element type of
/// the Field instead.
///
/// [valueType] is the type the Validator receives, the Field type by default.
void _checkValidatorFits(
  FieldElement field,
  DartObject object, [
  DartType? valueType,
]) {
  final validatorType = object.type;
  if (validatorType is! InterfaceType) return;
  final accepted = validatorType.allSupertypes
      .where(
        (t) =>
            t.element.name == 'FormidableValidator' &&
            _validatorChecker.isExactlyType(t),
      )
      .map((t) => t.typeArguments.single)
      .firstOrNull;
  if (accepted == null) return;
  final typeSystem = field.library.typeSystem;
  final receivedType = valueType ?? field.type;
  final fieldType = typeSystem.promoteToNonNull(receivedType);
  if (!typeSystem.isAssignableTo(fieldType, accepted)) {
    final validator = validatorType.element.name;
    final what = valueType == null ? 'the Field' : 'the elements';
    throw InvalidGenerationSourceError(
      '@$validator cannot be used on "${field.name}" of '
      '${field.enclosingElement.name}: it validates '
      '${accepted.getDisplayString()}, but $what is '
      '${receivedType.getDisplayString()}. Use a Validator that accepts '
      '${receivedType.getDisplayString()}, or change the Field type.',
      element: field,
    );
  }
  var memberValueType = valueType;
  if (_eachChecker.isExactlyType(validatorType)) {
    // The Field type fits `Iterable<Object?>`, so it has an element type.
    memberValueType = (fieldType as InterfaceType)
        .asInstanceOf(field.library.typeProvider.iterableElement)
        ?.typeArguments
        .single;
  }
  for (final member in validatorType.element.fields) {
    if (member.isStatic) continue;
    for (final nested
        in object.getField(member.name!)?.toListValue() ?? <DartObject>[]) {
      final nestedType = nested.type;
      if (nestedType != null &&
          _validatorChecker.isAssignableFromType(nestedType)) {
        _checkValidatorFits(field, nested, memberValueType);
      }
    }
  }
}

bool _isFormValidator(ElementAnnotation annotation) {
  final type = annotation.computeConstantValue()?.type;
  return type != null && _formValidatorChecker.isAssignableFromType(type);
}

/// Reads a cross-field rule annotation of [field]: resolves its symbols to
/// Fields of the same Schema and fails the build when a symbol is not a Field
/// or when the types of the Fields do not fit the rule.
CrossFieldRuleModel _readCrossFieldRule(
  FieldElement field,
  ElementAnnotation annotation,
  DartObject rule,
  Map<String, FieldElement> fieldByName,
) {
  final ruleType = rule.type as InterfaceType;
  final ruleName = ruleType.element.name!;
  final schemaName = field.enclosingElement.name;
  String problem(String message) =>
      '@$ruleName on "${field.name}" of $schemaName $message';

  if (_passthroughChecker.hasAnnotationOf(field)) {
    throw InvalidGenerationSourceError(
      problem(
        'cannot be used: "${field.name}" is a Passthrough Field, which has '
        'no errors.',
      ),
      element: field,
    );
  }

  final symbols = [
    ?_inheritedField(rule, 'other')?.toSymbolValue(),
    for (final symbol
        in _inheritedField(rule, 'others')?.toListValue() ?? <DartObject>[])
      ?symbol.toSymbolValue(),
  ];
  if (symbols.isEmpty) {
    throw InvalidGenerationSourceError(
      problem('does not name any Field.'),
      element: field,
    );
  }

  final typeSystem = field.library.typeSystem;
  final references = <FieldElement>[];
  for (final name in symbols) {
    final referenced = fieldByName[name];
    if (referenced == null) {
      throw InvalidGenerationSourceError(
        problem(
          'refers to #$name, but $schemaName has no Field named "$name". '
          'The Fields are: ${fieldByName.keys.join(', ')}.',
        ),
        element: field,
      );
    }
    if (referenced.name == field.name) {
      throw InvalidGenerationSourceError(
        problem('refers to its own Field.'),
        element: field,
      );
    }
    if (_passthroughChecker.hasAnnotationOf(referenced)) {
      throw InvalidGenerationSourceError(
        problem(
          'refers to #$name, which is a Passthrough Field. A Passthrough '
          'Field cannot be used in a rule.',
        ),
        element: field,
      );
    }
    references.add(referenced);
  }

  final typeProvider = field.library.typeProvider;
  final target = typeSystem.promoteToNonNull(field.type);
  final targetName = field.type.getDisplayString();

  void mismatch(FieldElement referenced, String expected) {
    throw InvalidGenerationSourceError(
      problem(
        'cannot use #${referenced.name}: the rule needs $expected, but '
        '"${referenced.name}" is ${referenced.type.getDisplayString()}.',
      ),
      element: field,
    );
  }

  final targetFit =
      FormidableTargetFit.values[_inheritedField(
        rule,
        'targetFit',
      )!.getField('index')!.toIntValue()!];
  final targetOk = switch (targetFit) {
    FormidableTargetFit.any => true,
    FormidableTargetFit.boolean => typeSystem.isSubtypeOf(
      target,
      typeProvider.boolType,
    ),
    FormidableTargetFit.dateTime => _isDateTime(target),
    FormidableTargetFit.comparable => _isComparable(target),
  };
  if (!targetOk) {
    throw InvalidGenerationSourceError(
      problem(
        'cannot be used: it needs a Field of type '
        '${switch (targetFit) {
          FormidableTargetFit.boolean => 'bool',
          FormidableTargetFit.dateTime => 'DateTime',
          _ => 'Comparable (such as num, String or DateTime)',
        }}, but "${field.name}" is $targetName.',
      ),
      element: field,
    );
  }

  final referenceFit =
      FormidableReferenceFit.values[_inheritedField(
        rule,
        'referenceFit',
      )!.getField('index')!.toIntValue()!];
  final typeArgument = ruleType.typeArguments.firstOrNull;
  if (typeArgument != null &&
      !typeSystem.isAssignableTo(target, typeArgument)) {
    throw InvalidGenerationSourceError(
      problem(
        'cannot be used: it works on ${typeArgument.getDisplayString()}, but '
        '"${field.name}" is $targetName.',
      ),
      element: field,
    );
  }

  for (final referenced in references) {
    final type = typeSystem.promoteToNonNull(referenced.type);
    switch (referenceFit) {
      case FormidableReferenceFit.any:
        break;
      case FormidableReferenceFit.boolean:
        if (!typeSystem.isSubtypeOf(type, typeProvider.boolType)) {
          mismatch(referenced, 'a bool Field');
        }
      case FormidableReferenceFit.dateTime:
        if (!_isDateTime(type)) mismatch(referenced, 'a DateTime Field');
      case FormidableReferenceFit.sameAsTarget:
        if (!typeSystem.isAssignableTo(type, target) ||
            !typeSystem.isAssignableTo(target, type)) {
          mismatch(
            referenced,
            'the same type as "${field.name}" ($targetName)',
          );
        }
      case FormidableReferenceFit.comparableWithTarget:
        final bothNumbers =
            typeSystem.isSubtypeOf(type, typeProvider.numType) &&
            typeSystem.isSubtypeOf(target, typeProvider.numType);
        if (!_isComparable(type) ||
            !(bothNumbers ||
                (typeSystem.isAssignableTo(type, target) &&
                    typeSystem.isAssignableTo(target, type)))) {
          mismatch(
            referenced,
            'a Field that can be compared with "${field.name}" '
            '($targetName)',
          );
        }
      case FormidableReferenceFit.iterableOfTarget:
        final element = type is InterfaceType
            ? type
                  .asInstanceOf(typeProvider.iterableElement)
                  ?.typeArguments
                  .single
            : null;
        if (element == null || !typeSystem.isAssignableTo(target, element)) {
          mismatch(
            referenced,
            'an Iterable of the type of "${field.name}" ($targetName)',
          );
        } else if (typeArgument != null &&
            !typeSystem.isAssignableTo(element, typeArgument)) {
          mismatch(
            referenced,
            'elements of type ${typeArgument.getDisplayString()}, the type '
            'its key function takes',
          );
        }
    }
  }

  if (_inheritedField(rule, 'hasOperand')?.toBoolValue() ?? false) {
    final operandType = _inheritedField(rule, 'operand')?.type;
    final first = references.first;
    if (operandType != null &&
        !typeSystem.isAssignableTo(operandType, first.type)) {
      throw InvalidGenerationSourceError(
        problem(
          'compares #${first.name} with a value of type '
          '${operandType.getDisplayString()}, but "${first.name}" is '
          '${first.type.getDisplayString()}.',
        ),
        element: field,
      );
    }
  }

  return CrossFieldRuleModel(
    source: 'const ${annotation.toSource().substring(1)}',
    references: [for (final r in references) r.name!],
  );
}

bool _isDateTime(DartType type) =>
    type is InterfaceType &&
    type.element.name == 'DateTime' &&
    type.element.library.isDartCore;

/// Whether [type] implements `Comparable`.
bool _isComparable(DartType type) =>
    type is InterfaceType &&
    [type, ...type.allSupertypes].any(
      (t) => t.element.name == 'Comparable' && t.element.library.isDartCore,
    );

/// A field of a constant [object] declared on it or on one of its
/// superclasses. `DartObject.getField` only sees the class of the object.
DartObject? _inheritedField(DartObject object, String name) {
  for (DartObject? o = object; o != null; o = o.getField('(super)')) {
    final value = o.getField(name);
    if (value != null) return value;
  }
  return null;
}

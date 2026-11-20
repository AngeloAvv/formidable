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
const _fieldArrayChecker = TypeChecker.typeNamed(
  FieldArray,
  inPackage: 'formidable',
);
const _effectsChecker = TypeChecker.typeNamed(Effects, inPackage: 'formidable');
const _validatorChecker = TypeChecker.typeNamed(
  FormidableValidator,
  inPackage: 'formidable',
);

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

final class FieldModel {
  const FieldModel({
    required this.name,
    required this.typeSource,
    required this.isNullable,
    required this.validators,
    required this.normalizers,
    required this.defaultSource,
    required this.isRequired,
    required this.isPassthrough,
    this.nested,
    this.array,
  });

  final String name;

  /// The Dart type exactly as written, including a trailing `?`.
  final String typeSource;
  final bool isNullable;

  /// Const expressions that rebuild the Validators, in annotation order.
  final List<String> validators;

  /// Const expressions that rebuild the Normalizers, in annotation order.
  final List<String> normalizers;

  /// The constructor default of the Schema field, or null.
  final String? defaultSource;

  /// Whether the Field has `@Required()`.
  final bool isRequired;

  /// Whether the Field has `@Passthrough()`.
  final bool isPassthrough;

  /// Set when the Field's type is another Schema: the Field is a Nested Form.
  final NestedModel? nested;

  /// Set when the Field is a Field Array: a list of Schemas or a list of
  /// primitive values annotated with `@FieldArray()`.
  final ArrayModel? array;

  bool get isNested => nested != null;

  bool get isArray => array != null;

  /// The type with a trailing `?`, for optional parameters.
  String get optionalTypeSource => isNullable ? typeSource : '$typeSource?';
}

/// What the emitters need to know about the Schema a Field nests.
final class NestedModel {
  const NestedModel({required this.formName, required this.requiresInitial});

  /// The generated Form of the nested Schema, for example `AddressForm`.
  final String formName;

  /// Whether the nested Form cannot be created empty because it has a
  /// Passthrough Field that must be supplied.
  final bool requiresInitial;
}

/// What the emitters need to know about a Field Array.
final class ArrayModel {
  const ArrayModel({
    required this.elementTypeSource,
    this.nested,
    this.fieldArraySource,
    this.hasEach = false,
    this.hasNormalizers = false,
  });

  /// The type of an item value as written, for example `Phone` or `String?`.
  final String elementTypeSource;

  /// Set when the items are Nested Forms of another Schema.
  final NestedModel? nested;

  /// The `@FieldArray(...)` annotation as a const expression, or null.
  final String? fieldArraySource;

  /// Whether `@FieldArray` carries Validators for every item.
  final bool hasEach;

  /// Whether `@FieldArray` carries Normalizers for every item.
  final bool hasNormalizers;

  /// The generated Form of the items, or `FormidableField<T>` for primitives.
  String get nodeType =>
      nested?.formName ?? 'FormidableField<$elementTypeSource>';
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
      ]),
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

  return SchemaModel(
    name: name,
    fields: [for (final field in fields) models[field.name!]!],
    constructorArguments: [
      for (final p in parameters)
        ConstructorArgument(field: models[p.name]!, isNamed: p.isNamed),
    ],
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
) {
  final nested = _readNested(field, defaultSource, owner, path);
  final array = nested == null
      ? _readArray(field, defaultSource, owner, path)
      : null;
  final validators = <String>[];
  final normalizers = <String>[];
  for (final annotation in field.metadata.annotations) {
    final value = annotation.computeConstantValue();
    final type = value?.type;
    if (type == null) continue;
    if (_normalizerChecker.isAssignableFromType(type)) {
      if (array != null) {
        throw InvalidGenerationSourceError(
          'Field "${field.name}" of ${owner.name} is a Field Array and cannot '
          'have ${annotation.toSource()} on the list. Normalizers apply to '
          'the items: use @FieldArray(normalizers: [...]).',
          element: field,
        );
      }
      normalizers.add('const ${annotation.toSource().substring(1)}');
    } else if (_validatorChecker.isAssignableFromType(type)) {
      if (array != null) {
        _checkArrayValidatorFits(field, value!);
      } else {
        _checkValidatorFits(field, value!);
      }
      // The part file shares the Schema library's scope, so the annotation
      // source can be reused as a const expression as it is written.
      validators.add('const ${annotation.toSource().substring(1)}');
    }
  }
  return FieldModel(
    name: field.name!,
    typeSource: field.type.getDisplayString(),
    isNullable: field.type.nullabilitySuffix == NullabilitySuffix.question,
    validators: validators,
    normalizers: normalizers,
    defaultSource: defaultSource,
    isRequired: _requiredChecker.hasAnnotationOf(field),
    isPassthrough: _passthroughChecker.hasAnnotationOf(field),
    nested: nested,
    array: array,
  );
}

/// The Field Array model of [field], or null when it is a single Field.
///
/// A list of Schemas is always a Field Array. A list of anything else is one
/// only with `@FieldArray()`. A set of Schemas is a build error: its items
/// have no stable identity.
ArrayModel? _readArray(
  FieldElement field,
  String? defaultSource,
  ClassElement owner,
  List<ClassElement> path,
) {
  final where = 'Field "${field.name}" of ${owner.name}';
  final type = field.type;
  final annotation = field.metadata.annotations
      .where((a) {
        final t = a.computeConstantValue()?.type;
        return t != null && _fieldArrayChecker.isExactlyType(t);
      })
      .firstOrNull;

  final listType = type is InterfaceType && type.isDartCoreList ? type : null;

  if (type is InterfaceType && type.isDartCoreSet) {
    final element = type.typeArguments.single;
    final target = element is InterfaceType ? element.element : null;
    if (target is ClassElement && isSchema(target)) {
      throw InvalidGenerationSourceError(
        '$where is a set of Schemas (${type.getDisplayString()}). The items of '
        'a Field Array need a stable identity and an order, which a set does '
        'not give. Use List<${target.name}>.',
        element: field,
      );
    }
  }

  if (annotation != null && listType == null) {
    throw InvalidGenerationSourceError(
      '$where has @FieldArray(), which can only annotate a List, but the Field '
      'is ${type.getDisplayString()}.',
      element: field,
    );
  }
  if (listType == null) return null;

  final element = listType.typeArguments.single;
  final target = element is InterfaceType ? element.element : null;
  final isSchemaList = target is ClassElement && isSchema(target);
  if (!isSchemaList && annotation == null) return null;

  if (_passthroughChecker.hasAnnotationOf(field)) {
    throw InvalidGenerationSourceError(
      '$where is a Field Array and cannot be a @Passthrough(). A Passthrough '
      'Field cannot change, so it cannot be a collection of items.',
      element: field,
    );
  }

  if (!isSchemaList) {
    final each = <DartObject>[];
    if (annotation != null) {
      final value = annotation.computeConstantValue()!;
      each.addAll(value.getField('each')?.toListValue() ?? const []);
    }
    for (final validator in each) {
      _checkValidatorFits(field, validator, valueType: element);
    }
    final value = annotation!.computeConstantValue()!;
    return ArrayModel(
      elementTypeSource: element.getDisplayString(),
      fieldArraySource: 'const ${annotation.toSource().substring(1)}',
      hasEach: each.isNotEmpty,
      hasNormalizers:
          value.getField('normalizers')?.toListValue()?.isNotEmpty ?? false,
    );
  }

  if (annotation != null) {
    final value = annotation.computeConstantValue()!;
    if ((value.getField('each')?.toListValue()?.isNotEmpty ?? false) ||
        (value.getField('normalizers')?.toListValue()?.isNotEmpty ?? false)) {
      throw InvalidGenerationSourceError(
        '$where is a Field Array of Nested Forms, so @FieldArray(each: ..., '
        'normalizers: ...) has nothing to apply to. Put Validators and '
        'Normalizers on the Fields of ${target.name}.',
        element: field,
      );
    }
  }
  if (element.nullabilitySuffix == NullabilitySuffix.question) {
    throw InvalidGenerationSourceError(
      '$where is a list of nullable Schemas (${type.getDisplayString()}). '
      'Every item of a Field Array of Nested Forms is a Form, so it cannot be '
      'null. Use List<${target.name}>.',
      element: field,
    );
  }
  if (path.contains(target)) {
    final cycle = [...path.skipWhile((c) => c != target), target];
    throw InvalidGenerationSourceError(
      '$where contains ${target.name}, which contains itself again '
      '(${cycle.map((c) => c.name).join(' -> ')}). '
      'A Nested Form is always created with its parent, so a Schema cannot '
      'contain itself, not even through a list.',
      element: field,
    );
  }
  final itemSchema = readSchema(target, path);
  if (itemSchema.requiresInitial) {
    throw InvalidGenerationSourceError(
      '$where is a list of ${target.name}, but ${target.name} has a '
      '@Passthrough() Field that must be supplied, so a new item cannot be '
      'created empty. Make that Field nullable or give it a default.',
      element: field,
    );
  }
  return ArrayModel(
    elementTypeSource: element.getDisplayString(),
    nested: NestedModel(
      formName: itemSchema.formName,
      requiresInitial: false,
    ),
  );
}

/// Fails the build when a Validator on a Field Array cannot judge the list a
/// Field Array hands it: one entry per item, as an `Iterable<Object?>`.
void _checkArrayValidatorFits(FieldElement field, DartObject object) {
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
  final received = field.library.typeProvider.iterableType(
    field.library.typeProvider.objectQuestionType,
  );
  if (!typeSystem.isAssignableTo(received, accepted)) {
    throw InvalidGenerationSourceError(
      '@${validatorType.element.name} cannot be used on "${field.name}" of '
      '${field.enclosingElement.name}: it validates '
      '${accepted.getDisplayString()}, but a Field Array hands its Validators '
      'one entry per item as Iterable<Object?>. Use a Validator that accepts '
      'Iterable<Object?>, such as MinItems or MaxItems, or put the Validator '
      'on the items with @FieldArray(each: [...]).',
      element: field,
    );
  }
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
  );
}

/// Fails the build when the value a Validator [object] accepts cannot be the
/// value of [field].
///
/// A Validator is called only with a chosen non-null value, or with null when
/// it accepts null, so the check is on the non-null type of the Field: a
/// `MinLength` (a `String` Validator) fits both `String` and `String?`.
///
/// A combinator such as `AnyOf` holds other Validators in its fields. They are
/// called with the same value, so each of them has to fit too.
void _checkValidatorFits(
  FieldElement field,
  DartObject object, {
  DartType? valueType,
}) {
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
  final checked = valueType ?? field.type;
  final fieldType = typeSystem.promoteToNonNull(checked);
  if (!typeSystem.isAssignableTo(fieldType, accepted)) {
    final validator = validatorType.element.name;
    throw InvalidGenerationSourceError(
      '@$validator cannot be used on "${field.name}" of '
      '${field.enclosingElement.name}: it validates '
      '${accepted.getDisplayString()}, but the ${valueType == null ? 'Field' : 'items'} is '
      '${checked.getDisplayString()}. Use a Validator that accepts '
      '${checked.getDisplayString()}, or change the ${valueType == null ? 'Field' : 'item'} type.',
      element: field,
    );
  }
  for (final member in validatorType.element.fields) {
    if (member.isStatic) continue;
    for (final nested
        in object.getField(member.name!)?.toListValue() ?? <DartObject>[]) {
      final nestedType = nested.type;
      if (nestedType != null &&
          _validatorChecker.isAssignableFromType(nestedType)) {
        _checkValidatorFits(field, nested, valueType: valueType);
      }
    }
  }
}

bool _isFormValidator(ElementAnnotation annotation) {
  final type = annotation.computeConstantValue()?.type;
  return type != null && _formValidatorChecker.isAssignableFromType(type);
}

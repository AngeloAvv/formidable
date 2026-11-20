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

  bool get isNested => nested != null;

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
  final validators = <String>[];
  final normalizers = <String>[];
  for (final annotation in field.metadata.annotations) {
    final value = annotation.computeConstantValue();
    final type = value?.type;
    if (type == null) continue;
    if (_normalizerChecker.isAssignableFromType(type)) {
      normalizers.add('const ${annotation.toSource().substring(1)}');
    } else if (_validatorChecker.isAssignableFromType(type)) {
      _checkValidatorFits(field, value!);
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
  );
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
void _checkValidatorFits(FieldElement field, DartObject object) {
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
  final fieldType = typeSystem.promoteToNonNull(field.type);
  if (!typeSystem.isAssignableTo(fieldType, accepted)) {
    final validator = validatorType.element.name;
    throw InvalidGenerationSourceError(
      '@$validator cannot be used on "${field.name}" of '
      '${field.enclosingElement.name}: it validates '
      '${accepted.getDisplayString()}, but the Field is '
      '${field.type.getDisplayString()}. Use a Validator that accepts '
      '${field.type.getDisplayString()}, or change the Field type.',
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
        _checkValidatorFits(field, nested);
      }
    }
  }
}

bool _isFormValidator(ElementAnnotation annotation) {
  final type = annotation.computeConstantValue()?.type;
  return type != null && _formValidatorChecker.isAssignableFromType(type);
}

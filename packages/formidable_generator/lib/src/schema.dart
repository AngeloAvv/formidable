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
const _validatorChecker = TypeChecker.typeNamed(
  FormidableValidator,
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
    this.warnings = const [],
  });

  /// The Schema class name, for example `SignUp`.
  final String name;

  /// The Fields in declaration order.
  final List<FieldModel> fields;

  /// How the Schema constructor is called, in parameter order.
  final List<ConstructorArgument> constructorArguments;

  /// Problems that do not stop the build, reported by the Form builder only.
  final List<String> warnings;

  String get formName => '${name}Form';
  String get scopeName => '${name}FormScope';
}

final class FieldModel {
  const FieldModel({
    required this.name,
    required this.typeSource,
    required this.isNullable,
    required this.validators,
    required this.defaultSource,
    required this.isRequired,
    required this.isPassthrough,
  });

  final String name;

  /// The Dart type exactly as written, including a trailing `?`.
  final String typeSource;
  final bool isNullable;

  /// Const expressions that rebuild the Validators, in annotation order.
  final List<String> validators;

  /// The constructor default of the Schema field, or null.
  final String? defaultSource;

  /// Whether the Field has `@Required()`.
  final bool isRequired;

  /// Whether the Field has `@Passthrough()`.
  final bool isPassthrough;

  /// The type with a trailing `?`, for optional parameters.
  String get optionalTypeSource => isNullable ? typeSource : '$typeSource?';
}

/// One argument of the Schema constructor call.
final class ConstructorArgument {
  const ConstructorArgument({required this.field, required this.isNamed});

  final FieldModel field;
  final bool isNamed;
}

/// Reads [element] into a [SchemaModel], or throws an
/// [InvalidGenerationSourceError] when it cannot become a Form.
SchemaModel readSchema(Element element) {
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
      field.name!: _readField(field, defaults[field.name]),
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
    warnings: warnings,
  );
}

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

FieldModel _readField(FieldElement field, String? defaultSource) {
  final validators = <String>[];
  for (final annotation in field.metadata.annotations) {
    final type = annotation.computeConstantValue()?.type;
    if (type != null && _validatorChecker.isAssignableFromType(type)) {
      _checkValidatorFits(field, type);
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
    defaultSource: defaultSource,
    isRequired: _requiredChecker.hasAnnotationOf(field),
    isPassthrough: _passthroughChecker.hasAnnotationOf(field),
  );
}

/// Fails the build when the value a Validator of [validatorType] accepts
/// cannot be the value of [field].
///
/// A Validator is called only with a chosen non-null value, or with null when
/// it accepts null, so the check is on the non-null type of the Field: a
/// `MinLength` (a `String` Validator) fits both `String` and `String?`.
void _checkValidatorFits(FieldElement field, DartType validatorType) {
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
  if (typeSystem.isAssignableTo(fieldType, accepted)) return;
  final validator = validatorType.element.name;
  throw InvalidGenerationSourceError(
    '@$validator cannot be used on "${field.name}" of '
    '${field.enclosingElement?.name}: it validates '
    '${accepted.getDisplayString()}, but the Field is '
    '${field.type.getDisplayString()}. Use a Validator that accepts '
    '${field.type.getDisplayString()}, or change the Field type.',
    element: field,
  );
}

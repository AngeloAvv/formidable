import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';
import 'package:yaml/yaml.dart';

import 'schema.dart';
import 'scope_emitter.dart';

/// Writes `<name>.formidable_scope.dart` next to a Schema library.
///
/// It is a separate builder, writing a standalone library, so that the part
/// file with the Form stays pure Dart. It writes nothing unless the package
/// that holds the Schema depends on `formidable_flutter`.
class ScopeBuilder implements Builder {
  @override
  final Map<String, List<String>> buildExtensions = const {
    '.dart': ['.formidable_scope.dart'],
  };

  @override
  Future<void> build(BuildStep buildStep) async {
    final input = buildStep.inputId;
    // A cheap text check avoids resolving every library of the package.
    if (!(await buildStep.readAsString(input)).contains('Formidable')) return;
    if (!await buildStep.resolver.isLibrary(input)) return;
    if (!await _dependsOnFlutterBindings(buildStep)) return;

    final library = LibraryReader(await buildStep.resolver.libraryFor(input));
    final schemas = [
      for (final annotated in library.classes.where(isSchema))
        readSchema(annotated),
    ];
    if (schemas.isEmpty) return;

    final output = input.changeExtension('.formidable_scope.dart');
    await buildStep.writeAsString(
      output,
      emitScopeLibrary(schemas, schemaFile: input.pathSegments.last),
    );
  }

  Future<bool> _dependsOnFlutterBindings(BuildStep buildStep) async {
    final pubspec = AssetId(buildStep.inputId.package, 'pubspec.yaml');
    if (!await buildStep.canRead(pubspec)) return false;
    final yaml = loadYaml(await buildStep.readAsString(pubspec));
    if (yaml is! YamlMap) return false;
    return [yaml['dependencies'], yaml['dev_dependencies']].any(
      (section) =>
          section is YamlMap && section.containsKey('formidable_flutter'),
    );
  }
}

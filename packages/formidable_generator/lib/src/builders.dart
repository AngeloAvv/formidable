import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import 'form_generator.dart';
import 'scope_builder.dart';

/// Writes the Form of every Schema to a part file next to the Schema.
Builder formidableBuilder(BuilderOptions options) =>
    PartBuilder([FormGenerator()], '.formidable.dart');

/// Writes the Form Scope of every Schema to a standalone library.
Builder formidableScopeBuilder(BuilderOptions options) => ScopeBuilder();

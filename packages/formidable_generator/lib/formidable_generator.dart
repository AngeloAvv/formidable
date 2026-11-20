/// Code generator for Formidable.
///
/// Two builders run over every library that declares a `@Formidable()`
/// Schema:
///
/// - `formidable` writes the Form to a part file (`.formidable.dart`). It is
///   pure Dart, so Schemas can live in packages that do not depend on Flutter.
/// - `formidable_scope` writes the Form Scope and its context extension to a
///   standalone library (`.formidable_scope.dart`). It writes nothing unless
///   the package depends on `formidable_flutter`.
library;

export 'src/builders.dart' show formidableBuilder, formidableScopeBuilder;

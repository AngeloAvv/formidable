# formidable_generator

The code generator of [Formidable](https://github.com/AngeloAvv/formidable), a reactive form library for Dart and Flutter. It runs on `build_runner` and turns every Schema marked with `@Formidable()` into a typed Form:

- `<schema>.formidable.dart` holds the generated Form: one typed Field per Schema field, `submit()`, `patch`, `replace` and the typed state.
- `<schema>.formidable_scope.dart` holds the Form Scope and the typed widgets (`SignUpFormScope`, `SignUpFormBuilder`, `SignUpFormListener` and `SignUpFormSelector`). It is written only when your package depends on `formidable_flutter`.

## Install

```yaml
dependencies:
  formidable: ^0.2.0

dev_dependencies:
  build_runner: ^2.4.0
  formidable_generator: ^0.2.0
```

A Flutter app also adds `formidable_flutter` and the widget package it uses (`formidable_material` or `formidable_cupertino`).

## Use

Annotate a Schema and declare the part file the generator writes to:

```dart
import 'package:formidable/formidable.dart';

part 'sign_up.formidable.dart';

@Formidable()
class SignUp {
  const SignUp({required this.email, required this.password});

  @Trim()
  @Email()
  final String email;

  @MinLength(8)
  final String password;
}
```

Then run the generator:

```sh
dart run build_runner build
```

The generated files are source files next to the Schema. An app usually does not commit them: add `*.formidable.dart` and `*.formidable_scope.dart` to `.gitignore` and generate them in CI.

A package published to pub.dev is different: its users never run the generator on it, so the generated files must be in the archive, or the `part` directives of its Schemas do not resolve. `dart pub publish` leaves out every file matched by `.gitignore`, so either commit the generated files, or add a `.pubignore` that does not list them (when a directory has a `.pubignore`, pub uses it instead of `.gitignore`) and run `build_runner` before publishing.

## Learn more

- [Documentation](https://docs.page/AngeloAvv/formidable)
- [Formidable README](https://github.com/AngeloAvv/formidable#readme)

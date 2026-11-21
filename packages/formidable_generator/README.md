# formidable_generator

The code generator of [Formidable](https://github.com/AngeloAvv/formidable), a reactive form library for Dart and Flutter. It runs on `build_runner` and turns every Schema marked with `@Formidable()` into a typed Form:

- `<schema>.formidable.dart` holds the generated Form: one typed Field per Schema field, `submit()`, `patch`, `replace` and the typed state.
- `<schema>.formidable_scope.dart` holds the Form Scope and the typed widgets (`SignUpFormScope`, `SignUpFormBuilder`, `SignUpFormListener` and `SignUpFormSelector`). It is written only when your package depends on `formidable_flutter`.

## Install

```yaml
dependencies:
  formidable: ^0.1.0

dev_dependencies:
  build_runner: ^2.4.0
  formidable_generator: ^0.1.0
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

The generated files are source files next to the Schema. Most projects do not commit them: add `*.formidable.dart` and `*.formidable_scope.dart` to `.gitignore` and generate them in CI.

## Learn more

- [Documentation](https://docs.page/AngeloAvv/formidable)
- [Formidable README](https://github.com/AngeloAvv/formidable#readme)

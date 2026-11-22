# Formidable

Formidable is a reactive form library for Dart and Flutter. Forms usually mean one controller per input, string keys, casts, and validation logic scattered across widgets. Formidable removes all of it. You write one plain Dart class, annotate its fields with the rules you want, and code generation gives you a typed, reactive form that works in any Dart program, drops into any Flutter widget tree, and hands your class back, fully validated, when the user submits.

- **The Schema is your class, and so is the output.** Annotate a plain Dart class with `@Formidable()`. A valid form gives you an instance of that same class, with no maps and no casts.
- **A generated, type-safe Form.** One getter per Field (`form.email`), each typed as the Field, so a widget bound to the wrong type does not compile.
- **A large catalog of declarative Validators.** Length, character classes, formats, numbers, dates, choices, collections and more are one annotation each. Write your own when none fits.
- **Cross-field and async rules.** `@MustMatch(#password)` and `@RequiredIf(...)` name other Fields by symbol, checked at build time. Async Validators debounce and expose a `pending` state.
- **Unset is not null.** A Field the user has not filled in is different from a Field whose chosen value is null, so required-ness follows the type.
- **Normalizers and Form Effects.** Trim input before it is validated, and enable, disable or clear Fields when others change.
- **Nested Forms, Field Arrays and Dynamic Forms** for addresses, repeatable rows and questionnaires built at runtime.
- **A typed, immutable Form state** with Builders, Listeners and Selectors for widgets, and streams (`valueChanges`, `statusChanges`, `select`) for code.
- **Ready-to-use Material and Cupertino widgets** that expose the full API of the Flutter widgets they wrap, plus a base class that turns any widget into a form widget.
- **Localized Validation Messages** in English, Italian, Spanish, French and German.
- **Dart first, Flutter ready.** The core and the generator are pure Dart: Schemas, Validators, Forms, their state and streams run in a CLI, on a server or in a shared domain package, and test without Flutter. Flutter apps add Form Scopes, reactive widgets and Material and Cupertino widgets on top.

## A sign-up form in one file

A Schema with an email, a password that must be strong, a confirmation that must match it, and terms that must be accepted:

```dart
import 'package:formidable/formidable.dart';

part 'sign_up.formidable.dart';

@Formidable()
class SignUp {
  const SignUp({
    required this.email,
    required this.password,
    required this.confirmation,
    this.acceptedTerms = false,
  });

  @Trim()
  @Email()
  final String email;

  @MinLength(8)
  @HasUppercase()
  @HasDigit()
  final String password;

  @MustMatch(#password)
  final String confirmation;

  @IsTrue()
  final bool acceptedTerms;
}
```

Run `dart run build_runner build`, and bind the generated Form to the page. The button follows the state of the Form, and `submit()` returns the validated `SignUp`:

```dart
import 'dart:convert';

import 'package:formidable/formidable.dart';
import 'package:formidable_material/formidable_material.dart';
import 'package:http/http.dart' as http;
import 'package:material_ui/material_ui.dart';

import 'sign_up.dart';
import 'sign_up.formidable_scope.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  Future<void> _onSubmit(SignUpForm form) async {
    switch (await form.submit()) {
      case FormidableSubmitValid(:final value):
        final response = await http.post(
          Uri.parse('https://api.example.com/sign-up'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'email': value.email, 'password': value.password}),
        );
        if (!mounted) return;
        final message = response.statusCode == 201
            ? 'Welcome aboard!'
            : 'Sign up failed (${response.statusCode}).';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      case FormidableSubmitInvalid():
        break; // The errors are already shown on the Fields.
    }
  }

  @override
  Widget build(BuildContext context) => SignUpFormScope(
    create: SignUpForm.new,
    builder: (context, form) => Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          FormidableMaterialTextField(
            field: form.email,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(labelText: 'Email'),
          ),
          FormidableMaterialTextField(
            field: form.password,
            obscureText: true,
            decoration: const InputDecoration(labelText: 'Password'),
          ),
          FormidableMaterialTextField(
            field: form.confirmation,
            obscureText: true,
            decoration: const InputDecoration(labelText: 'Confirm password'),
          ),
          FormidableMaterialCheckboxListTile(
            field: form.acceptedTerms,
            title: const Text('I accept the terms and conditions'),
          ),
          SignUpFormSelector<FormidableStatus>(
            selector: (state) => state.meta.status,
            builder: (context, status) => FilledButton(
              onPressed: status == FormidableStatus.valid
                  ? () => _onSubmit(form)
                  : null,
              child: const Text('Sign up'),
            ),
          ),
        ],
      ),
    ),
  );
}
```

The fields show their Validation Message once the user leaves them, and the button is enabled only while the Form is valid. The [Getting Started](https://docs.page/AngeloAvv/formidable/getting-started) guide walks through this example step by step, including the dependencies to add.

## Learn more

- [Documentation](https://docs.page/AngeloAvv/formidable): the Schema, the Validator catalog, the Form state, the widgets and guides.
- [Example app](https://github.com/AngeloAvv/formidable/tree/main/example): every feature as a runnable app, with each guide shown in Material and in Cupertino side by side.
- [`GLOSSARY.md`](https://github.com/AngeloAvv/formidable/blob/main/GLOSSARY.md) for the vocabulary and [`docs/adr`](https://github.com/AngeloAvv/formidable/tree/main/docs/adr) for the decisions behind the design.

## Packages

| Package | Platform | |
|---|---|---|
| [`formidable`](https://github.com/AngeloAvv/formidable/tree/main/packages/formidable) | Dart | Core: annotations, runtime, Validators, Validation Errors |
| [`formidable_generator`](https://github.com/AngeloAvv/formidable/tree/main/packages/formidable_generator) | Dart | Code generator for `build_runner` |
| [`formidable_flutter`](https://github.com/AngeloAvv/formidable/tree/main/packages/formidable_flutter) | Flutter | Form Scope, reactive widgets and the Field Widget base, built only on the widgets library |
| [`formidable_material`](https://github.com/AngeloAvv/formidable/tree/main/packages/formidable_material) | Flutter | Material widgets, built on `material_ui` |
| [`formidable_cupertino`](https://github.com/AngeloAvv/formidable/tree/main/packages/formidable_cupertino) | Flutter | Cupertino widgets, built on `cupertino_ui` |

A pure Dart project needs only `formidable` and `formidable_generator`; a Flutter app adds `formidable_flutter` and the widget package it uses. All packages share one version. Until the API is declared stable, expect breaking changes across 0.x releases.

## Contributing

The repository is a pub workspace managed with [melos](https://melos.invertase.dev), with Flutter pinned by [fvm](https://fvm.app) in `.fvmrc`.

```sh
dart pub global activate fvm
fvm install
fvm flutter pub get          # resolves every package at once
fvm dart run melos run ci    # generate, analyze and test everything
```

Other scripts: `melos run generate`, `analyze`, `test` and `format`. Generated files (`*.formidable.dart`, `*.formidable_scope.dart`) are not committed.

## Releasing

Set the same version in every `packages/*/pubspec.yaml`, add a matching entry to every `CHANGELOG.md`, then push a tag named `v<version>` (for example `v0.1.0`). The pipeline checks that the tag matches every package, runs analyze and test, and publishes the packages to pub.dev in dependency order, waiting for each one to be indexed before publishing the next.

## License

MIT, see [`LICENSE`](https://github.com/AngeloAvv/formidable/blob/main/LICENSE).

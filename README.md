# Formidable

A reactive form library for Flutter built on annotations and code generation. Declare a form by annotating a plain Dart class, and the generator turns it into a live, typed form that you bind to widgets.

```dart
@Formidable()
class SignUp {
  const SignUp({required this.username});

  @MinLength(4)
  final String username;
}
```

```dart
final form = SignUpForm();
form.username.setValue('angelo');

switch (await form.submit()) {
  case FormidableSubmitValid(:final value): // a SignUp
  case FormidableSubmitInvalid(:final fieldErrors):
}
```

Read [Getting Started](docs/getting-started.mdx) for the full walkthrough, or run the app in [`example`](example).

## Packages

| Package | |
|---|---|
| [`formidable`](packages/formidable) | Pure Dart core: annotations, runtime, Validators, Validation Errors |
| [`formidable_generator`](packages/formidable_generator) | Code generator for `build_runner` |
| [`formidable_flutter`](packages/formidable_flutter) | Flutter bindings, built only on the widgets library |
| [`formidable_material`](packages/formidable_material) | Material widgets, built on `material_ui` |
| [`formidable_cupertino`](packages/formidable_cupertino) | Cupertino widgets, built on `cupertino_ui` |

All packages share one version. Until the API is declared stable, expect breaking changes across 0.x releases.

## Working on the repository

The repository is a pub workspace managed with [melos](https://melos.invertase.dev). Flutter is pinned with [fvm](https://fvm.app) in `.fvmrc`.

```sh
dart pub global activate fvm
fvm install
fvm flutter pub get          # resolves every package at once
fvm dart run melos run ci    # generate, analyze and test everything
```

Other scripts: `melos run generate`, `analyze`, `test` and `format`. Generated files (`*.formidable.dart`, `*.formidable_scope.dart`) are not committed.

See [`GLOSSARY.md`](GLOSSARY.md) for the vocabulary and [`docs/adr`](docs/adr) for the decisions behind the design.

## Releasing

Set the same version in every `packages/*/pubspec.yaml`, add a matching entry to every `CHANGELOG.md`, then push a tag named `v<version>` (for example `v0.1.0`). The pipeline checks that the tag matches every package, runs analyze and test, and publishes the packages to pub.dev through automated publishing in dependency order, waiting for each one to be indexed before publishing the next.

## License

MIT, see [`LICENSE`](LICENSE).

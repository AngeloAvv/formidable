## 0.2.0

- **Breaking changes**
  - The generated state keeps the Form metadata under `meta` instead of `form` (`state.form.valid` becomes `state.meta.valid`), so `meta` is now the only name of this kind reserved among the Schema field names and `form` is free again. A Schema field called `meta` is a build error; rename it.
  - The generated Form uses `defined` instead of `isSet` and `markOptional(initiallyDefined:)` instead of `markOptional(initiallySet:)`. Regenerate with `dart run build_runner build`.
- Requires `formidable` 0.2.0.

## 0.1.0

- Initial release.
- The build_runner builders that turn a Schema into a typed Form, its typed state (`SignUpFormState`, with the Form metadata under `state.form`, so only `form` is reserved among the names of the state) and its Form Scope with the typed `SignUpFormBuilder`, `SignUpFormListener` and `SignUpFormSelector`.
- Works with `analyzer` 10 to 14, so it can sit next to other generators that hold `analyzer` back.
- Build errors for invalid Schemas: constructor mismatches, Validators that do not fit the Field type, Passthrough Fields with rules, names that collide with the Form API, Nested Form cycles, and misplaced Async Validators, Normalizers, cross-field rules, Field Arrays and Dynamic Forms.
- The generated Form types `changes`, `valueChanges` and `select` after its state (`Stream<SignUpFormState>`, and the selector of `select` receives a `SignUpFormState`). `changes`, `valueChanges`, `statusChanges`, `select` and `hasListeners` are now names a Schema field cannot use.

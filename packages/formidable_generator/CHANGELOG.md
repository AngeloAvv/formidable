## 0.1.0

- Initial release.
- The build_runner builders that turn a Schema into a typed Form, its typed state (`SignUpFormState`, with the Form metadata under `state.form`, so only `form` is reserved among the names of the state) and its Form Scope with the typed `SignUpFormBuilder`, `SignUpFormListener` and `SignUpFormSelector`.
- Works with `analyzer` 10 to 14, so it can sit next to other generators that hold `analyzer` back.
- Build errors for invalid Schemas: constructor mismatches, Validators that do not fit the Field type, Passthrough Fields with rules, names that collide with the Form API, Nested Form cycles, and misplaced Async Validators, Normalizers, cross-field rules, Field Arrays and Dynamic Forms.

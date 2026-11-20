## 0.1.0

- Initial release.
- Form Scope (owning and `.value`), the headless Binding and `FormidableBindingBuilder`, with Codec-backed text controllers that keep what the user types.
- Builders, listeners and selectors for Form, Field and Field Array state, driven by the complete state (`buildWhen`, `listenWhen`), typed building blocks for the generated widgets, and a pop scope that guards a dirty Form.
- The Form Scope takes a `builder` as an alternative to `child`.
- Error display policies (touched, dirty, submit), Validation Message resolution and localizations for the built-in Validation Errors.
- Focus navigation and keyboard actions across the Fields of a Form.
- Widgets for Field Arrays and Dynamic Forms.

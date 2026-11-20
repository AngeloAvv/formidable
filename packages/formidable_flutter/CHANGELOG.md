## 0.1.0

- Initial release.
- Form Scope (owning and `.value`), which takes a `builder` as an alternative to `child`.
- `FormidableFieldWidget<T, V>`, a generic and inheritance-friendly base that turns any widget into a Formidable widget: value through an optional Codec, `didChange`, `clear`, `markAsTouched`, `errorText`, `enabled`, `pending`, an owned focus node and keyboard navigation. A subclass of `FormidableFieldWidgetState` can add behavior.
- `FormidableTextFieldWidget<T>`, its specialization for text, with a text controller that keeps what the user types and Codec lookup in the `FormidableConfig`.
- Builders, listeners and selectors for Form, Field and Field Array state, driven by the complete state (`buildWhen`, `listenWhen`; read the metadata as `state.form.status`), typed building blocks for the generated widgets, and a pop scope that guards a dirty Form.
- Error display policies (touched, dirty, submit), Validation Message resolution and localizations for the built-in Validation Errors.
- Focus navigation and keyboard actions across the Fields of a Form.
- Widgets for Field Arrays and Dynamic Forms.

## 0.3.0

- `didChange(value, touched: true)` writes and touches in a single notification, through `FormidableField.setValue(value, touched: true)`. `clear` and a rejected parse still notify twice.
- Field Widgets honor the container lock through `state.enabled`: a Field below a disabled Form, Nested Form, Field Array or Dynamic Form is not interactive, and the widgets need no change.
- `errorText` reads only the errors of the Field, so a Field that is `pending` shows no Validation Message while a check runs.
- Requires `formidable` 0.3.0.

## 0.2.0

- **Breaking changes**
  - `FormidableFieldWidgetState.markAsTouched()` becomes `touch()`.
  - `didChange(value, touch: true)` and `clear(touch: true)` take `touched:` instead.
  - `FormidableFieldWidgetState.isSet` becomes `defined`.
  - Builders, listeners and selectors read the Form metadata as `state.meta` instead of `state.form`: `state.form.status` becomes `state.meta.status`, `state.form.dirty` becomes `state.meta.dirty`.
- Requires `formidable` 0.2.0.

## 0.1.0

- Initial release.
- Form Scope (owning and `.value`), which takes a `builder` as an alternative to `child`.
- `FormidableFieldWidget<T, V>`, a generic and inheritance-friendly base that turns any widget into a Formidable widget: value through an optional Codec, `didChange`, `clear`, `markAsTouched`, `errorText`, `enabled`, `pending`, an owned focus node and keyboard navigation. A subclass of `FormidableFieldWidgetState` can add behavior.
- `FormidableTextFieldWidget<T>`, its specialization for text, with a text controller that keeps what the user types and Codec lookup in the `FormidableConfig`.
- Builders, listeners and selectors for Form, Field and Field Array state, driven by the complete state (`buildWhen`, `listenWhen`; read the metadata as `state.form.status`), typed building blocks for the generated widgets, and a pop scope that guards a dirty Form.
- Error display policies (touched, dirty, submit), Validation Message resolution and localizations for the built-in Validation Errors.
- Focus navigation and keyboard actions across the Fields of a Form.
- Widgets for Field Arrays and Dynamic Forms.

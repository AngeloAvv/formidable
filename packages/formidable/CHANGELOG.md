## 0.2.0

- **Breaking changes**
  - The metadata of a Form moves from `state.form` to `state.meta`: `form.state.form.valid` becomes `form.state.meta.valid`, and `FormidableFormState(form: ...)` becomes `FormidableFormState(meta: ...)`.
  - `isSet` becomes `defined`, on nodes, on states and on `FormidableFormMeta`: `field.isSet` becomes `field.defined`, `state.form.isSet` becomes `state.meta.defined`. `markOptional(initiallySet:)` becomes `markOptional(initiallyDefined:)`.
  - `markAsTouched()` becomes `touch()`.
  - `didChange(value, touch: true)` and `clear(touch: true)` take `touched:` instead, so the parameter no longer shadows the `touch()` method.
  - `isValid`, `isDirty` and `isPending` are no longer public on Fields, Passthrough Fields, Forms, Field Arrays and Dynamic Forms (the runtime keeps them as `@internal`). Read the flags from the state: `field.isValid` becomes `field.state.valid`, `field.isDirty` becomes `field.state.dirty`, `form.isValid`, `form.isDirty` and `form.isPending` become `form.state.meta.valid`, `form.state.meta.dirty` and `form.state.meta.pending`.
- Every State has a derived `valid` getter: `FormidableFieldState.valid`, `FormidableFormMeta.valid`, `FormidableFieldArrayState.valid` and `FormidableDynamicFormState.valid`. It adds no stored field, so equality and hash codes are unchanged.
- `FormidableDynamicFormState` gets derived `valid`, `dirty` and `pending` getters.
- ADR 0005 records that flags are read only from the State.

## 0.1.0

- Initial release.
- Typed, reactive Forms built from a Schema: a `FormidableField` per Schema field, immutable state snapshots with deep equality (Field state: value, status, dirty, touched, submitted, enabled, pending; Form state: the state of every child, Field Arrays and Dynamic Forms included, and the metadata of the Form under `state.form`: status, dirty, pending, isSet, errors and the Schema value, built lazily on the first read from the child states) and listeners that notify once per change.
- Unset is distinct from null, Presence rules (`@Required()`, defaults, nullable Fields) and `@Passthrough()` Fields.
- Programmatic writes: `patch`, `replace`, `reset`, `commit`, `clear` and `batch`, all as a single change. A chosen null is written with `batch(() => form.notes.setValue(null))`, since a null `patch` argument means "leave unchanged".
- Normalizers (`@Trim()` and others), Codecs, Form Effects and a catalog of about 150 built-in Validators with typed Validation Errors.
- Cross-field rules, custom Form Validators and Async Validators for Fields and for Forms, with debounce and a pending state.
- Nested Forms, Field Arrays and Dynamic Forms.
- Submit flow: `submit()` marks every Field, waits for pending checks, focuses the first invalid Field and returns a typed result whose invalid case has one `errors` map, keyed by the handle of every Field and Field Array with errors, in tree order; server errors can be applied back with `applyErrors`.
- Field focus targets and tree-order focus navigation.
- Filtered subscriptions for imperative code: every Field, Passthrough Field, Form, Nested Form, Field Array and Dynamic Form has the broadcast, synchronous streams `changes` (every state change), `valueChanges` (only when the value or presence changes: the value for a Field, the state for the others), `statusChanges` (only when valid/invalid changes) and `select(selector)` (only when the selected value changes). They never emit the initial state, listen to the node only while subscribed and close on dispose. `hasListeners` tells whether anything listens. `package:formidable/formidable.dart` re-exports `Stream` for the generated code.

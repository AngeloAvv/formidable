## 0.3.0

- **Breaking changes**
  - `valid` means "can be submitted now". `FormidableStatus` gets a third value, `pending`: a node with no errors and a check still running (an Async Validator or an asynchronous Form Validator) is `pending`, and `valid` is `status == FormidableStatus.valid`, so it is false while pending. `invalid` stays reserved for real errors, and a running check never shows a Validation Message. An exhaustive `switch` on `FormidableStatus` needs a `pending` case, and a button that read `state.meta.valid` is now off while a check runs. Code that used `valid` to mean "has no errors" reads `state.errors.isEmpty`. `statusChanges` emits the new value too.
  - `value` is non-nullable and throws. `FormidableField.value` and `FormidableFieldState.value` return `T` and throw a `StateError` while the Field is Unset, and `FormidableForm.value` and `FormidableFormMeta.value` return the Schema instance and throw while the Form is not valid (or is an Unset optional Nested Form). Use `valueOrNull` (`T?` and `S?`) where null is fine, and check `defined` first in Form Effects, widgets and Codecs. A nullable Field still returns null for a chosen null. `valueChanges` stays `Stream<T?>`.
  - `markSubmitted()` is `@internal` on every node. `submit()` is the only public way to submit.
  - `FormidableField.reset()` also clears `submitted`, as the reset of a Field Array already did.
  - The Schema field names `enable`, `disable`, `touch`, `untouch` and `valueOrNull` clash with new members of the Form, so they are reserved and a Schema field with one of these names is a build error. Rename it. `resetTo` is reserved as well.
- `enable()` and `disable()` on a Form, a Nested Form, a Field Array and a Dynamic Form. A container keeps its own flag, separate from the flags of the Fields: a Field is effectively enabled only when its own flag and the flag of every container above it are set, and `state.enabled` of a Field reports that. Disabling never writes to the Fields, so `enable()` restores exactly the previous state, and the lock reaches items and Fields added later. An effectively disabled Field behaves like a disabled one: no Validators, no applied errors shown, no focus, and an Unset required Field still blocks submit. `state.meta.enabled`, `FormidableFieldArrayState.enabled` and `FormidableDynamicFormState.enabled` report the container. One call is one notification.
- `touch()` on a Form (and a Dynamic Form) touches every Field below it with one notification, and `untouch()` on a Field, a Field Array, a Dynamic Form and a Form clears touched and nothing else.
- `FormidableField.setValue(value, touched: true)` writes and touches in one notification.
- `reset(to: source)` on the generated Form replaces every value, makes it the new initial state, clears touched and submitted and runs the Form Effects as at creation, in one notification. It works on Nested Forms and Field Arrays, and replaces `replace` followed by `commit()` and `reset()`.
- `FormidableField.validators`, `addValidator` and `removeValidator`: a read-only list (the Validators of the Schema first, then the added ones) and runtime changes that validate the Field right away with one notification. Widgets can read constraints such as a maximum length from it.
- `FormidableFieldArray.add` and `insert` return the node of the new item (its Field or Nested Form) instead of the item wrapper.
- `FormidableField.applyErrors(errors, clearOn: [...])`: the errors also go away on the next value change of any listed Field, Nested Form or Field Array, for errors that depend on other values, such as a server that rejects the credentials. The listeners are released when the errors go away, are replaced and when the Form is disposed.
- `FormidableFieldArrayState` gets `status` and `pending`, and `FormidableDynamicFormState` gets `status`, so every State has the same `valid`, `status` and `pending`.
- A Field takes an optional `name`, used in the message of the `StateError`. A Dynamic Form passes its key.
- ADR 0006 records the container lock, `valid` as "submittable now" and `value` against `valueOrNull`.

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

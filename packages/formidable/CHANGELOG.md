## 0.1.0

- Initial release.
- Typed, reactive Forms built from a Schema: a `FormidableField` per Schema field, immutable state snapshots with deep equality (Field state: value, defined, valid, status, dirty, touched, submitted, enabled, pending; Form state: the state of every child, Field Arrays and Dynamic Forms included, and the metadata of the Form under `state.meta`: status, valid, dirty, pending, defined, errors and the Schema value, built lazily on the first read from the child states) and listeners that notify once per change.
- Flags are read from the state, never from the node: `field.state.valid`, `field.state.dirty`, `form.state.meta.valid`. A node offers actions (`setValue`, `clear`, `touch()`, `reset`, `commit`, `submit`...) plus `value` and `defined`, which are current even while Form Effects run. See ADR 0005.
- Unset is distinct from null, Presence rules (`@Required()`, defaults, nullable Fields) and `@Passthrough()` Fields.
- Programmatic writes: `patch`, `replace`, `reset`, `commit`, `clear` and `batch`, all as a single change. A chosen null is written with `batch(() => form.notes.setValue(null))`, since a null `patch` argument means "leave unchanged".
- Normalizers (`@Trim()` and others), Codecs, Form Effects and a catalog of about 150 built-in Validators with typed Validation Errors.
- Cross-field rules, custom Form Validators and Async Validators for Fields and for Forms, with debounce and a pending state.
- Nested Forms, Field Arrays and Dynamic Forms.
- Submit flow: `submit()` marks every Field, waits for pending checks, focuses the first invalid Field and returns a typed result whose invalid case has one `errors` map, keyed by the handle of every Field and Field Array with errors, in tree order; server errors can be applied back with `applyErrors`.
- Field focus targets and tree-order focus navigation.
- Filtered subscriptions for imperative code: every Field, Passthrough Field, Form, Nested Form, Field Array and Dynamic Form has the broadcast, synchronous streams `changes` (every state change), `valueChanges` (only when the value or presence changes: the value for a Field, the state for the others), `statusChanges` (only when valid/invalid changes) and `select(selector)` (only when the selected value changes). They never emit the initial state, listen to the node only while subscribed and close on dispose. `hasListeners` tells whether anything listens. `package:formidable/formidable.dart` re-exports `Stream` for the generated code.

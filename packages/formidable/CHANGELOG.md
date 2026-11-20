## 0.1.0

- Initial release.
- Typed, reactive Forms built from a Schema: a `FormidableField` per Schema field, Form and Field state snapshots (status, dirty, touched, submitted, enabled, pending) and listeners that notify once per change.
- Unset is distinct from null, Presence rules (`@Required()`, defaults, nullable Fields) and `@Passthrough()` Fields.
- Programmatic writes: `patch`, `replace`, `reset`, `commit`, `clear` and `batch`, all as a single change.
- Normalizers (`@Trim()` and others), Codecs, Form Effects and a catalog of about 150 built-in Validators with typed Validation Errors.
- Cross-field rules, custom Form Validators and Async Validators for Fields and for Forms, with debounce and a pending state.
- Nested Forms, Field Arrays and Dynamic Forms.
- Submit flow: `submit()` marks every Field, waits for pending checks, focuses the first invalid Field and returns a typed result; server errors can be applied back with `applyErrors`.
- Field focus targets and tree-order focus navigation.

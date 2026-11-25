# The Form lock, `valid` as "submittable now" and a `value` that throws

Three decisions of 0.3.0 share one idea: each name says exactly one thing, and what the library cannot answer is an error and not a quiet null.

## A container lock, not a cascade of flags

`enable()` and `disable()` exist on a Form, a Nested Form, a Field Array and a Dynamic Form. A container keeps its own `enabled` flag, which is a separate layer from the flags of the Fields below it. A Field is effectively enabled only when its own flag and the flag of every container above it are set. `state.enabled` of a Field, and `enabled` of the state of a container, report this effective value, so a widget disables its input without knowing why.

`form.disable()` therefore never writes to the Fields: it changes one flag and the lock reaches every Field below it, including items added later and Fields registered later. `form.enable()` restores exactly what was there before. A Field that a Form Effect or the app had disabled on its own stays disabled. An effectively disabled Field behaves like a Field disabled on its own, with the same validation rules, the same hidden applied errors, and an Unset required Field that still blocks submit, so "disabled" has a single meaning. One call is one notification, and a call that changes nothing notifies nothing.

### Considered options

- **Cascade: `form.disable()` disables every Field.** It is simple, but `form.enable()` cannot know which Fields were disabled before, so it either enables Fields that an Effect had turned off (`vat` of a person account, say) or has to remember them. Remembering them is the lock layer, only hidden. It would also overwrite the flags the Effects own, and an Effect that re-runs would fight the Form.
- **A flag on the Form only, read by the widgets.** The Fields would keep validating and focusing while the Form is disabled, so there would be two meanings of "disabled".
- **Leave it to `AbsorbPointer` or `IgnorePointer`.** It stops touches but not the focus, the keyboard, or code that writes to the Field, and it does not exist in the pure Dart core.

The cost is that a Field has two reasons to be disabled, and `state.enabled` does not say which. The reason is rarely needed, and the container is one `state.meta.enabled` away.

## `valid` means "submittable now"

`FormidableStatus` has three values: `invalid` when there is at least one error, even if other checks are still running, `pending` when there are no errors and an Async Validator or asynchronous Form Validator is still running, and `valid` when there are no errors and nothing is running. `valid` is `status == FormidableStatus.valid`, so it is false while pending. The rule is the same for the state of a Field, of a Form, of a Field Array and of a Dynamic Form, and a pending child makes its parent pending, never invalid.

A running check is neither a pass nor a failure. It never makes a node invalid and never shows a Validation Message, because pending errors are not in `errors` yet. `invalid` stays reserved for real errors, so "show the errors" and "show progress" read different flags.

### Considered options

- **`valid` stays true while pending, and the user reads `pending` too.** This was the 0.2.0 behavior. A button on `state.meta.valid` was enabled during a check that could still fail, and every button needed `valid && !pending`.
- **Pending counts as invalid.** The Field would turn red, and a Validation Message could appear, before anyone knows whether the value is wrong.
- **A fourth flag such as `canSubmit`.** It adds a second name for something `valid` can say, and the aggregation would have to keep both in sync.

The cost is a new value in `FormidableStatus`, so an exhaustive `switch` on it needs a `pending` case, and code that read `valid` to mean "has no errors" must read `state.errors.isEmpty` instead.

## `value` throws and `valueOrNull` does not

ADR 0003 says that Unset is not null, so `value` cannot return a nullable type to mean "absent". On a Field, `value` returns `T` and throws a `StateError` when the Field is not `defined`. `valueOrNull` returns `T?`. For a nullable Field, `value` returns null when null was chosen and throws only when the Field is Unset. On a Form and its meta, `value` returns the Schema instance and throws when the Form is not `valid` (so also while pending), and `valueOrNull` returns it or null. The messages name the Field or the Form and give both ways out: check `defined` (or `valid`), or read `valueOrNull`.

The name follows Dart's own convention (`firstOrNull`, `singleOrNull`, `lastOrNull`): the plain name is the one that throws, and the `OrNull` suffix is the one that does not. `valueChanges` stays `Stream<T?>` because it has to emit the transition to Unset. Code that can run on an Unset Field, such as a Form Effect, a widget or a Codec, checks `defined` first. `valueOrNull` cannot tell Unset from null on a nullable Field, so it is for code that does not care.

### Considered options

- **`value` stays nullable.** A required Field would read as `String?` even where the Form guarantees a value, and every use needs a `!`. The nullable result also hides the difference between Unset and null that ADR 0003 insists on.
- **`tryValue`.** `try*` is Dart's prefix for an operation that may fail, such as `tryParse`, and `value` is a read. It would also sit next to `firstOrNull` in the same codebase with a second convention for the same idea.
- **`requireValue`.** It makes the throwing variant the one with a long name, which tells the reader to avoid it, while it is the one to use whenever the code already checked `defined` or `valid`.

The cost is that reading `value` without checking can throw. This is intended, because the alternative is a null the program carries somewhere else. Existing reads need a decision: `defined` first, or `valueOrNull`.

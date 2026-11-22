# Flags are read from the State

Boolean flags have one name, a plain adjective (`valid`, `dirty`, `pending`, `touched`, `enabled`, `submitted`), and they are read only from the immutable State: `field.state.dirty`, `form.state.meta.valid`. A node (Field, Passthrough Field, Form, Field Array, Dynamic Form) has no `is*` getter that repeats them, so there is a single path to each flag and nothing to keep in sync.

A node keeps its actions (`setValue`, `clear`, `touch`, `enable`, `disable`, `reset`, `commit`, `submit`, `batch`) plus `value` and `defined`. Those two stay on the node because they are current even while Form Effects run, while `state` is updated after every Effect has run. An Effect that needs to know whether a Field holds a value reads `defined`, not `state.defined`. The runtime still aggregates children through `isValid`, `isDirty` and `isPending` on `FormidableNode`, but they are marked `@internal` and are not part of the public API.

The metadata of a Form lives under `meta` (`state.meta`), a `FormidableFormMeta`, and not as members of the state itself. The generated state has one member per Schema field, so every name the state declares is a name a Schema field cannot use. A verb on the Form (`submit`, `reset`, `patch`) is an acceptable reservation, because nobody names a Schema field that way. Adjectives such as `valid`, `enabled` or `status` are common Schema field names, so they must not be reserved. Putting them under `meta` leaves `meta` as the only name of this kind that the state reserves.

`isSet` became `defined`. `set` reads as a verb and collides with `Set`, while `defined` says that the Field holds a value, null included, and keeps the distinction of ADR 0003: an Unset Field is one that is not `defined`. `markAsTouched()` became `touch()`, in line with the other actions.

Each State also has a derived `valid` getter (`FormidableFieldState.valid`, `FormidableFormMeta.valid`, `FormidableFieldArrayState.valid`). They do not add stored fields, so equality and hash codes are unchanged.

## Considered options

- **A `form.meta` shortcut on the node.** It is redundant with `form.state.meta`, and it would give flags two paths again.
- **`state.form` for the metadata.** It reads `form.state.form.valid`, which says "form" twice.
- **Straight getters on the Form (`form.valid`, `form.dirty`).** They would reserve `valid`, `dirty`, `enabled` and similar adjectives, which are common Schema field names.
- **A method `valid()`.** Dart has one namespace per class, so a method would still collide with a Schema field of the same name.

The cost is that reading a flag takes one more hop than a getter on the node, and that a flag read inside a Form Effect is stale until the Effects have run.

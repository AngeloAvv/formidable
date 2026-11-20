# Formidable

Formidable is a reactive form library for Flutter. You declare a form by annotating a plain Dart class, and code generation turns that declaration into a live, typed form you can bind to widgets.

## Language

### Declaration

**Schema**:
A class marked with the `@Formidable()` annotation. It declares a form's Fields and their rules, and a valid form outputs an instance of it.
_Avoid_: Model, form model, form class

**Field**:
A single value inside a form. It has its own status, its own errors and its own interaction state.
_Avoid_: Control, form control, input

**Required Field**:
A Field that must not be Unset when the form is submitted. If the Field's type allows null, choosing null counts as a value.
_Avoid_: Mandatory field, non-null field

**Optional Field**:
A Field that can stay Unset. If it does, its default goes into the output, or null when it has no default.
_Avoid_: Nullable field

**Passthrough Field**:
A Field whose value has to be supplied when the Form is created and that can never be Unset, for example an identifier in an edit form. It is not bound to a widget, but the Form can still change it.
_Avoid_: Hidden field, internal field, readonly field

**Unset**:
The state of a Field the user has not given a value yet. This is different from a Field whose chosen value is null.
_Avoid_: Empty, missing, blank

### Live form

**Form**:
The live instance generated from a Schema. It holds the current state of every Field, and when it is valid it produces an instance of the Schema.
_Avoid_: Controller, form group, form model

**Nested Form**:
The Form for a Schema that is used as a Field of another Schema. You reach it through its parent Form.
_Avoid_: Subgroup, form group

**Field Array**:
An ordered collection of Nested Forms or Fields that can grow and shrink. It is generated from a list in the Schema.
_Avoid_: Form array, repeater

**Dynamic Form**:
A part of a Form whose Fields are registered at runtime under string keys rather than declared in the Schema. Each registered Field still has an explicit type. Use it only for edge cases.
_Avoid_: Untyped form, free form

**Form Scope**:
The part of the widget tree where a Form is available. A scope can own the Form, creating and disposing it, or it can expose a Form that something else owns.
_Avoid_: Provider, form builder

**Dirty**:
Describes a Field or Form whose value or presence differs from its initial state. If it returns to the initial state, it is no longer dirty.
_Avoid_: Changed, modified, pristine (as the opposite)

**Touched**:
Describes a Field the user has interacted with and then left. Whether a Field is touched decides when its errors are shown.
_Avoid_: Visited, blurred

### Rules

**Validator**:
A synchronous rule attached to a Field that produces zero or more Validation Errors for a value. You declare it as an annotation on the Field.
_Avoid_: Rule, constraint

**Async Validator**:
A Validator that needs time or external dependencies to produce its result, for example a network check. The Field is pending while it runs.
_Avoid_: Remote validator

**Form Validator**:
A rule declared on a Schema that reads several Fields of the Form and attaches Validation Errors to specific Fields. It can be synchronous or asynchronous.
_Avoid_: Group validator, multi-field validator

**Cross-field rule**:
A built-in Form Validator that you declare as an annotation on a Field instead of on the Schema, and that refers to other Fields of the Schema by symbol, for example `@MustMatch(#password)`. It attaches its Validation Error to the annotated Field.
_Avoid_: Cross-field validator, dependent validator

**Normalizer**:
A rule declared on a Field that rewrites its value before validation, for example trimming whitespace. It applies only when you declare it.
_Avoid_: Sanitizer, formatter, transformer

**Form Effect**:
A rule declared on a Schema that changes some Fields when others change, for example clearing the province when the country changes.
_Avoid_: Side effect, listener, reaction

**Validation Error**:
A typed description of why a Field is invalid. It carries the data needed to explain the problem, and it is separate from the text shown to the user.
_Avoid_: Error key, error code

**Validation Message**:
The localized text shown to the user for a Validation Error.
_Avoid_: Error text, error string

### UI

**Binding**:
The link between one Field and one widget. It keeps the value the widget displays, its focus and its errors in sync with the Field.
_Avoid_: Reactive field, field widget

**Codec**:
A pure two-way conversion between a Field's value and the value a widget displays or edits. Parsing an edited value can fail, and when it does the failure becomes a Validation Error.
_Avoid_: Value accessor, accessor, transformer, converter

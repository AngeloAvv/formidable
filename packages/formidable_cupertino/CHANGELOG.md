## 0.2.0

- Released in lockstep with the other packages. Requires `formidable` 0.2.0 and `formidable_flutter` 0.2.0; the widgets use `touch()`, `touched:` and `defined`, with no change to their own API.

## 0.1.0

- Initial release.
- Text field and Codecs, switch, checkbox, segmented control, sliding segmented control, radio group, slider, date picker and timer picker. Every widget takes the whole API of the Cupertino widget it wraps (minus what Formidable owns and the deprecated parameters), and every parameter is a public `final` field.
- Text field: `decorationBuilder`, `prefixBuilder`, `suffixBuilder` and `styleBuilder` build the decoration, prefix, suffix and text style from the control of the Field Widget (for example a clear button that shows once there is text, or red text while the Field has an error).
- Checkbox: `tristate`. Cycling to the mixed state is a choice: a `bool?` Field is set to null (set and dirty), a `bool` Field falls back to Unset, touched. `FormidableCupertinoCheckbox` is generic over the type of the Field, inferred from `field:`. Checkbox and switch attach the focus node of the Field Widget, so keyboard navigation reaches them and the Field is touched when they lose focus.
- Every widget is a `FormidableFieldWidget`, so each takes `messages`, `errorDisplay` and `focusNode`.
- Validation Messages shown under each widget, with the error display policy of the Form.

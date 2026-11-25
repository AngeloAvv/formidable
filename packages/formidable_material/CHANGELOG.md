## 0.3.0

- Released in lockstep with the other packages. Requires `formidable` 0.3.0 and `formidable_flutter` 0.3.0. The widgets read `valueOrNull`, a disabled container disables them through `state.enabled`, and a switch or a checkbox touches its Field in the same notification as the write, with no change to their own API.

## 0.2.0

- Released in lockstep with the other packages. Requires `formidable` 0.2.0 and `formidable_flutter` 0.2.0; the widgets use `touch()`, `touched:` and `defined`, with no change to their own API.

## 0.1.0

- Initial release.
- Every public class starts with `FormidableMaterial`, like the Cupertino ones start with `FormidableCupertino`: `FormidableMaterialTextField`, `FormidableMaterialCheckbox`, `FormidableMaterialCheckboxListTile`, `FormidableMaterialSwitch`, `FormidableMaterialSwitchListTile`, `FormidableMaterialRadioGroup` (with `FormidableMaterialRadioOption`), `FormidableMaterialSlider`, `FormidableMaterialDropdown`, `FormidableMaterialDatePicker`, `FormidableMaterialTimePicker`, `FormidableMaterialSegmentedButton` and `FormidableMaterialErrorLine`.
- Every widget takes the whole API of the Flutter widget it wraps, except what Formidable owns (value, `onChanged`, the controller, `enabled`) and the deprecated parameters. Each parameter is a public `final` field of the widget. A checkbox or switch with a title is its own widget, one per Flutter widget.
- `decorationBuilder` next to `decoration` on the text field, the dropdown and the date and time pickers. It receives the control of the widget, so the decoration can depend on the value, for example a clear button. Its result is merged like `decoration`: the Validation Message is added as `errorText` when it has none.
- `styleBuilder` next to `style` on the text field, built like `decorationBuilder` from the control of the widget (for example red text while the Field has an error).
- Text field with Codecs. Its decoration is merged with the Validation Message, never replaced.
- Deselecting is a choice: a `toggleable` radio group, a segmented button with `allowDeselect` a `tristate` checkbox or checkbox row and the clear button of a `clearable` date or time picker write null when the type of the Field admits it (the Field stays set and is dirty), and fall back to Unset, touched, when it does not.
- Radio group (with an option that stands for null), slider, dropdown, date picker, time picker and segmented control.
- A disabled Field disables its widget.
- Every widget is a `FormidableFieldWidget`, so each takes `messages`, `errorDisplay` and `focusNode`.
- Validation Messages shown through the Material decoration, with the error display policy of the Form.

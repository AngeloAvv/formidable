## 0.1.0

- Initial release.
- Every public class starts with `FormidableMaterial`, like the Cupertino ones start with `FormidableCupertino`: `FormidableMaterialTextField`, `FormidableMaterialCheckbox`, `FormidableMaterialCheckboxListTile`, `FormidableMaterialSwitch`, `FormidableMaterialSwitchListTile`, `FormidableMaterialRadioGroup` (with `FormidableMaterialRadioOption`), `FormidableMaterialSlider`, `FormidableMaterialDropdown`, `FormidableMaterialDatePicker`, `FormidableMaterialTimePicker`, `FormidableMaterialSegmentedButton` and `FormidableMaterialErrorLine`.
- Every widget takes the whole API of the Flutter widget it wraps, except what Formidable owns (value, `onChanged`, the controller, `enabled`) and the deprecated parameters. Each parameter is a public `final` field of the widget. A checkbox or switch with a title is its own widget, one per Flutter widget.
- `decorationBuilder` next to `decoration` on the text field, the dropdown and the date and time pickers. It receives the control of the widget, so the decoration can depend on the value, for example a clear button. Its result is merged like `decoration`: the Validation Message is added as `errorText` when it has none.
- Text field with Codecs. Its decoration is merged with the Validation Message, never replaced.
- Radio group (with an option that stands for null), slider, dropdown, date picker, time picker and segmented control.
- A disabled Field disables its widget.
- Every widget is a `FormidableFieldWidget`, so each takes `messages`, `errorDisplay` and `focusNode`.
- Validation Messages shown through the Material decoration, with the error display policy of the Form.
